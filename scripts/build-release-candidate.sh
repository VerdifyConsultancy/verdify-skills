#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-$ROOT/dist}"

for command in git npm ruby shasum; do
  command -v "$command" >/dev/null || { echo "$command is required to build a release candidate" >&2; exit 1; }
done

mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"
if find "$OUT" -maxdepth 1 -type f -name '*.tgz' -print -quit | grep -q .; then
  echo "release candidate output already contains an npm tarball: $OUT" >&2
  exit 1
fi

SOURCE_SHA="$(git -C "$ROOT" rev-parse HEAD)"
SOURCE_STATUS="$(git -C "$ROOT" status --porcelain --untracked-files=all)"
SOURCE_CLEAN=true
if [[ -n "$SOURCE_STATUS" ]]; then
  if [[ "${VERDIFY_TESTING:-0}" == "1" && "${VERDIFY_ALLOW_DIRTY_CANDIDATE:-0}" == "1" ]]; then
    SOURCE_CLEAN=false
  else
    echo "release candidates require a clean HEAD" >&2
    exit 1
  fi
fi

PACK_JSON="$OUT/npm-pack-result.json"
PACK_STAGE="$(mktemp -d)"
trap 'rm -rf "$PACK_STAGE"' EXIT
ruby "$ROOT/scripts/package-file-list.rb" --stage "$PACK_STAGE" "$ROOT" >/dev/null
ruby -rjson -e '
  path, source_sha = ARGV
  package = JSON.parse(File.read(path))
  package["gitHead"] = source_sha
  File.write(path, JSON.pretty_generate(package) + "\n")
' "$PACK_STAGE/package.json" "$SOURCE_SHA"
(
  cd "$PACK_STAGE"
  npm pack --json --pack-destination "$OUT"
) > "$PACK_JSON"

ruby -rjson -e '
  result = JSON.parse(File.read(ARGV.fetch(0)))
  abort "npm pack must return exactly one artifact" unless result.is_a?(Array) && result.length == 1
  artifact = result.first
  %w[filename integrity shasum files].each { |key| abort "npm pack result is missing #{key}" unless artifact.key?(key) }
' "$PACK_JSON"

TARBALL_NAME="$(ruby -rjson -e 'puts JSON.parse(File.read(ARGV.fetch(0))).fetch(0).fetch("filename")' "$PACK_JSON")"
TARBALL="$OUT/$TARBALL_NAME"
[[ -f "$TARBALL" ]] || { echo "npm pack did not create $TARBALL" >&2; exit 1; }
[[ "$(find "$OUT" -maxdepth 1 -type f -name '*.tgz' | wc -l | tr -d ' ')" == "1" ]] || {
  echo "npm pack created more than one tarball" >&2
  exit 1
}

ARCHIVE="$(VERDIFY_PACKAGE_SKIP_TESTS=1 bash "$ROOT/scripts/package.sh" "$OUT")"
bash "$ROOT/scripts/verify-package.sh" "$ARCHIVE" >/dev/null

SIDECAR="$TARBALL.release-candidate.json"
ruby -rbase64 -rdigest -rjson -rpathname -rshellwords -e '
  root, out, source_sha, source_clean, pack_json, tarball, archive, sidecar = ARGV
  pack = JSON.parse(File.read(pack_json)).fetch(0)
  package = JSON.parse(File.read(File.join(root, "package.json")))
  tarball_sha512 = Digest::SHA512.file(tarball).digest
  computed_integrity = "sha512-#{Base64.strict_encode64(tarball_sha512)}"
  abort "npm integrity does not match exact tarball" unless pack.fetch("integrity") == computed_integrity
  document = {
    "schema_version" => "1.0",
    "package" => {"name" => package.fetch("name"), "version" => package.fetch("version")},
    "source" => {"commit" => source_sha, "clean" => source_clean == "true"},
    "tarball" => {
      "filename" => File.basename(tarball),
      "size" => File.size(tarball),
      "sha256" => Digest::SHA256.file(tarball).hexdigest,
      "sha512" => Digest::SHA512.file(tarball).hexdigest,
      "integrity" => computed_integrity,
      "npm_shasum" => pack.fetch("shasum"),
      "files" => pack.fetch("files").map { |entry| entry.slice("path", "size", "mode") }.sort_by { |entry| entry.fetch("path") }
    },
    "archive" => {
      "filename" => File.basename(archive),
      "size" => File.size(archive),
      "sha256" => Digest::SHA256.file(archive).hexdigest,
      "checksum_filename" => File.basename(archive) + ".sha256"
    },
    "build" => {
      "npm_pack_invocations" => 1,
      "npm_pack_command" => ["npm", "pack", "--json", "--pack-destination", out],
      "package_file_list_blob" => `git -C #{root.shellescape} rev-parse HEAD:scripts/package-file-list.rb`.strip
    }
  }
  File.write(sidecar, JSON.pretty_generate(document) + "\n")
' "$ROOT" "$OUT" "$SOURCE_SHA" "$SOURCE_CLEAN" "$PACK_JSON" "$TARBALL" "$ARCHIVE" "$SIDECAR"

ruby "$ROOT/scripts/verify-npm-tarball.rb" --tarball "$TARBALL" --sidecar "$SIDECAR" >/dev/null

if [[ "$(git -C "$ROOT" rev-parse HEAD)" != "$SOURCE_SHA" ]]; then
  echo "source HEAD changed while building the release candidate" >&2
  exit 1
fi
if [[ "$SOURCE_CLEAN" == true && -n "$(git -C "$ROOT" status --porcelain --untracked-files=all)" ]]; then
  echo "source worktree changed while building the release candidate" >&2
  exit 1
fi

printf 'tarball=%s\n' "$TARBALL"
printf 'sidecar=%s\n' "$SIDECAR"
printf 'archive=%s\n' "$ARCHIVE"
printf 'checksum=%s\n' "$ARCHIVE.sha256"
printf 'source_sha=%s\n' "$SOURCE_SHA"
