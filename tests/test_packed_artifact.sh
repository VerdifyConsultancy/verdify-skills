#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASELINE="da2f43392e768c7554fd35d750507eea64ca0fb3"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

for command in git npm ruby shasum tar; do
  command -v "$command" >/dev/null || { echo "$command is required for packed artifact tests" >&2; exit 1; }
done

OUTPUTS="$TMP/candidate.outputs"
bash "$ROOT/scripts/build-release-candidate.sh" "$TMP/candidate" > "$OUTPUTS"
TARBALL="$(sed -n 's/^tarball=//p' "$OUTPUTS")"
SIDECAR="$(sed -n 's/^sidecar=//p' "$OUTPUTS")"
ARCHIVE="$(sed -n 's/^archive=//p' "$OUTPUTS")"
SOURCE_SHA="$(sed -n 's/^source_sha=//p' "$OUTPUTS")"
[[ -f "$TARBALL" && -f "$SIDECAR" && -f "$ARCHIVE" && -f "$ARCHIVE.sha256" ]]
[[ "$(find "$TMP/candidate" -maxdepth 1 -type f -name '*.tgz' | wc -l | tr -d ' ')" == "1" ]]
[[ "$SOURCE_SHA" == "$(git -C "$ROOT" rev-parse HEAD)" ]]

ruby -rbase64 -rdigest -rjson -e '
  sidecar, tarball, archive, source = ARGV
  d = JSON.parse(File.read(sidecar))
  abort unless d.dig("source", "commit") == source && d.dig("source", "clean") == true
  abort unless d.dig("build", "npm_pack_invocations") == 1
  abort unless d.dig("tarball", "sha256") == Digest::SHA256.file(tarball).hexdigest
  abort unless d.dig("tarball", "sha512") == Digest::SHA512.file(tarball).hexdigest
  integrity = "sha512-#{Base64.strict_encode64(Digest::SHA512.file(tarball).digest)}"
  abort unless d.dig("tarball", "integrity") == integrity
  abort unless d.dig("archive", "sha256") == Digest::SHA256.file(archive).hexdigest
  abort unless d.dig("build", "package_file_list_blob") == "23dadc1d138fdd5b8269ffc76d11d691f2faed9b"
' "$SIDECAR" "$TARBALL" "$ARCHIVE" "$SOURCE_SHA"

ruby "$ROOT/scripts/verify-npm-tarball.rb" --tarball "$TARBALL" --sidecar "$SIDECAR" >/dev/null
bash "$ROOT/scripts/verify-package.sh" "$ARCHIVE" >/dev/null
ORIGINAL_SHA256="$(shasum -a 256 "$TARBALL" | awk '{print $1}')"
VERDIFY_TARBALL="$TARBALL" VERDIFY_SIDECAR="$SIDECAR" bash "$ROOT/tests/test_npm_install.sh"
[[ "$ORIGINAL_SHA256" == "$(shasum -a 256 "$TARBALL" | awk '{print $1}')" ]]

CORRUPT="$TMP/corrupt.tgz"
cp "$TARBALL" "$CORRUPT"
ruby -e '
  path = ARGV.fetch(0)
  data = File.binread(path)
  index = data.length / 2
  data.setbyte(index, data.getbyte(index) ^ 0xff)
  File.binwrite(path, data)
' "$CORRUPT"
if ruby "$ROOT/scripts/verify-npm-tarball.rb" --tarball "$CORRUPT" --sidecar "$SIDECAR" > "$TMP/corrupt.out" 2> "$TMP/corrupt.err"; then
  echo "expected corrupted exact tarball to fail" >&2
  exit 1
fi

[[ "$(cat "$ROOT/VERSION")" == "1.3.0" ]]
ruby -rjson -e 'd=JSON.parse(File.read(ARGV.fetch(0))); abort unless d["version"] == "1.3.0"' "$ROOT/package.json"
grep -q '^## 1.3.0 - 2026-07-10$' "$ROOT/CHANGELOG.md"
[[ "$(grep -l '^  version: "1\.3\.0"$' "$ROOT"/skills/*/SKILL.md | wc -l | tr -d ' ')" == "28" ]]

for skill in "$ROOT"/skills/*/SKILL.md; do
  relative="${skill#$ROOT/}"
  git -C "$ROOT" show "$BASELINE:$relative" | sed 's/^  version: "1\.2\.1"$/  version: "VERSION"/' > "$TMP/old-skill"
  sed 's/^  version: "1\.3\.0"$/  version: "VERSION"/' "$skill" > "$TMP/new-skill"
  cmp "$TMP/old-skill" "$TMP/new-skill"
done

[[ "$(git -C "$ROOT" hash-object scripts/package-file-list.rb)" == "23dadc1d138fdd5b8269ffc76d11d691f2faed9b" ]]
[[ "$(grep -Ec '^[[:space:]]*npm pack --json --pack-destination' "$ROOT/scripts/build-release-candidate.sh")" == "1" ]]
grep -Fq 'npm publish "${TARBALL}" --access public --provenance' "$ROOT/.github/workflows/publish-npm.yml"
[[ "$(grep -Fc 'npm publish "${TARBALL}" --access public --provenance' "$ROOT/.github/workflows/publish-npm.yml")" == "1" ]]
! grep -En 'uses: (actions/checkout|actions/setup-node|ruby/setup-ruby)@v' \
  "$ROOT/.github/workflows/publish-npm.yml" "$ROOT/.github/workflows/release-pr.yml"
! grep -En 'npm@(latest|next)|npm install --global npm@[^0-9]' \
  "$ROOT/.github/workflows/publish-npm.yml" "$ROOT/.github/workflows/release-pr.yml"

echo "Packed artifact tests passed: $TARBALL ($ORIGINAL_SHA256)"
