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
TARBALL="${VERDIFY_TARBALL:-}"
SIDECAR="${VERDIFY_SIDECAR:-}"
ARCHIVE="${VERDIFY_ARCHIVE:-}"
BUILT_LOCALLY=false
if [[ -z "$TARBALL" ]]; then
  bash "$ROOT/scripts/build-release-candidate.sh" "$TMP/candidate" > "$OUTPUTS"
  TARBALL="$(sed -n 's/^tarball=//p' "$OUTPUTS")"
  SIDECAR="$(sed -n 's/^sidecar=//p' "$OUTPUTS")"
  ARCHIVE="$(sed -n 's/^archive=//p' "$OUTPUTS")"
  SOURCE_SHA="$(sed -n 's/^source_sha=//p' "$OUTPUTS")"
  BUILT_LOCALLY=true
else
  SOURCE_SHA="$(ruby -rjson -e 'puts JSON.parse(File.read(ARGV.fetch(0))).dig("source", "commit")' "$SIDECAR")"
fi
[[ -f "$TARBALL" && -f "$SIDECAR" && -f "$ARCHIVE" && -f "$ARCHIVE.sha256" ]]
if [[ "$BUILT_LOCALLY" == true ]]; then
  [[ "$(find "$TMP/candidate" -maxdepth 1 -type f -name '*.tgz' | wc -l | tr -d ' ')" == "1" ]]
fi
[[ "$SOURCE_SHA" == "$(git -C "$ROOT" rev-parse HEAD)" ]]

ruby -rbase64 -rdigest -rjson -e '
  sidecar, tarball, archive, source = ARGV
  d = JSON.parse(File.read(sidecar))
  abort unless d.dig("source", "commit") == source && d.dig("source", "clean") == true
  abort unless d.dig("build", "npm_pack_invocations") == 1
  abort unless d.dig("tarball", "sha256") == Digest::SHA256.file(tarball).hexdigest
  abort unless d.dig("tarball", "sha512") == Digest::SHA512.file(tarball).hexdigest
  abort unless d.dig("tarball", "npm_shasum") == Digest::SHA1.file(tarball).hexdigest
  integrity = "sha512-#{Base64.strict_encode64(Digest::SHA512.file(tarball).digest)}"
  abort unless d.dig("tarball", "integrity") == integrity
  abort unless d.dig("archive", "sha256") == Digest::SHA256.file(archive).hexdigest
  checksum = archive + ".sha256"
  abort unless d.dig("archive", "checksum_sha256") == Digest::SHA256.file(checksum).hexdigest
  abort unless d.dig("build", "package_file_list_blob") == "23dadc1d138fdd5b8269ffc76d11d691f2faed9b"
  abort unless d.dig("build", "candidate_identity") == "v1.3.0-#{source}"
  abort unless d.dig("tarball", "files").all? { |entry| entry.fetch("sha256").match?(/\A[0-9a-f]{64}\z/) }
' "$SIDECAR" "$TARBALL" "$ARCHIVE" "$SOURCE_SHA"

ruby "$ROOT/scripts/verify-npm-tarball.rb" --tarball "$TARBALL" --sidecar "$SIDECAR" >/dev/null
bash "$ROOT/scripts/verify-package.sh" "$ARCHIVE" >/dev/null

if [[ "$BUILT_LOCALLY" == true ]]; then
  bash "$ROOT/scripts/build-release-candidate.sh" "$TMP/candidate-repeat" > "$TMP/candidate-repeat.outputs"
  REPEAT_TARBALL="$(sed -n 's/^tarball=//p' "$TMP/candidate-repeat.outputs")"
  REPEAT_SIDECAR="$(sed -n 's/^sidecar=//p' "$TMP/candidate-repeat.outputs")"
  REPEAT_ARCHIVE="$(sed -n 's/^archive=//p' "$TMP/candidate-repeat.outputs")"
  cmp "$TARBALL" "$REPEAT_TARBALL"
  cmp "$SIDECAR" "$REPEAT_SIDECAR"
  cmp "$ARCHIVE" "$REPEAT_ARCHIVE"
  cmp "$ARCHIVE.sha256" "$REPEAT_ARCHIVE.sha256"
fi

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
  case "$relative" in
    skills/controller-merge/SKILL.md|skills/independent-critic/SKILL.md|skills/release-verification/SKILL.md)
      # Issue #121 owns transport-neutral delivery-governance changes in these
      # skills; the version-only release assertion remains strict for all others.
      continue
      ;;
  esac
  git -C "$ROOT" show "$BASELINE:$relative" | sed 's/^  version: "1\.2\.1"$/  version: "VERSION"/' > "$TMP/old-skill"
  sed 's/^  version: "1\.3\.0"$/  version: "VERSION"/' "$skill" > "$TMP/new-skill"
  cmp "$TMP/old-skill" "$TMP/new-skill"
done

[[ "$(git -C "$ROOT" hash-object scripts/package-file-list.rb)" == "23dadc1d138fdd5b8269ffc76d11d691f2faed9b" ]]
[[ "$(grep -Ec '^[[:space:]]*npm pack --json --pack-destination' "$ROOT/scripts/build-release-candidate.sh")" == "1" ]]
grep -Fq 'npm publish "${TARBALL}" --access public --provenance' "$ROOT/.github/workflows/publish-npm.yml"
[[ "$(grep -Fc 'npm publish "${TARBALL}" --access public --provenance' "$ROOT/.github/workflows/publish-npm.yml")" == "1" ]]
! grep -En 'uses: (actions/checkout|actions/setup-node|actions/upload-artifact|actions/download-artifact|ruby/setup-ruby)@v' \
  "$ROOT/.github/workflows/publish-npm.yml" "$ROOT/.github/workflows/release-pr.yml"
! grep -En 'npm@(latest|next)|npm install --global npm@[^0-9]' \
  "$ROOT/.github/workflows/publish-npm.yml" "$ROOT/.github/workflows/release-pr.yml"
ruby -rrubygems/version -e '
  workflow = File.read(ARGV.fetch(0))
  candidate = workflow.index("\n  candidate:\n") or abort "candidate job is missing"
  publish = workflow.index("\n  publish:\n", candidate + 1) or abort "publish job is missing"
  pin_pattern = /^[ \t]*run: npm install --global npm@([0-9]+\.[0-9]+\.[0-9]+)[ \t]*$/
  candidate_pins = workflow[candidate...publish].scan(pin_pattern).flatten
  publish_pins = workflow[publish..].scan(pin_pattern).flatten
  pins = candidate_pins + publish_pins
  abort "expected one exact npm pin in each publish job" unless candidate_pins.length == 1 && publish_pins.length == 1
  abort "expected exactly two identical npm 11.15.0 pins" unless pins == ["11.15.0", "11.15.0"]
  minimum = Gem::Version.new("11.5.1")
  abort "npm publish pins must satisfy trusted publishing minimum #{minimum}" unless pins.all? { |pin| Gem::Version.new(pin) >= minimum }
' "$ROOT/.github/workflows/publish-npm.yml"
ruby -e '
  workflow = File.read(ARGV.fetch(0))
  candidate = workflow.index("candidate:") or abort "unprivileged candidate job is missing"
  tests = workflow.index("bash tests/test_packed_artifact.sh") or abort "full candidate matrix is missing"
  publish = workflow.index("publish:", candidate + 1) or abort "privileged publish job is missing"
  canonicalize = workflow.index(%q{TARBALL="$(ruby -e "puts File.realpath(ARGV.fetch(0))" "${TARBALL}")"}, publish) or abort "privileged tarball canonicalization is missing"
  reconcile = workflow.index("reconcile() {", publish) or abort "release transaction reconciliation is missing"
  npm_publish = workflow.index(%q{npm publish "${TARBALL}" --access public --provenance}) or abort "exact tarball publish is missing"
  abort "consumer matrix is not separated from privileged publish" unless candidate < tests && tests < publish
  abort "tarball must be canonicalized before release transaction and npm publish" unless publish < canonicalize && canonicalize < reconcile && reconcile < npm_publish
  abort "privileged tarball canonicalization must be unique" unless workflow.scan(%q{TARBALL="$(ruby -e "puts File.realpath(ARGV.fetch(0))" "${TARBALL}")"}).length == 1
  abort "publish job repacks the candidate" unless workflow.scan("build-release-candidate.sh").length == 1
  abort "stable candidate artifact name is missing" unless workflow.include?("verdify-release-candidate-v${VERSION}-${SOURCE_SHA}")
  abort "candidate retention is not explicit" unless workflow.include?("retention-days: 90")
  abort "cross-run artifact identity is not pinned" unless workflow.include?(%q{actions/artifacts/${ARTIFACT_ID}}) && workflow.include?(%q{actions/runs/${ARTIFACT_RUN_ID}})
  abort "platform artifact bytes are not digest verified" unless workflow.include?(%q{actions/artifacts/${ARTIFACT_ID}/zip}) && workflow.include?("Actions artifact archive digest")
  abort "download-artifact warning behavior remains authoritative" if workflow.include?("actions/download-artifact@")
  %w[repository workflow_path workflow_run_id workflow_run_attempt artifact_id artifact_name artifact_digest source_sha sidecar_sha256 provenance_sha256 binding_sha256 binding_artifact_id binding_artifact_run_id binding_artifact_run_attempt binding_artifact_name binding_artifact_digest].each do |field|
    abort "candidate provenance is missing #{field}" unless workflow.include?(field)
  end
  upload = workflow.index("- uses: actions/upload-artifact@") or abort "candidate upload is missing"
  binding = workflow.index("- name: Bind the uploaded Actions artifact") or abort "post-upload artifact binding is missing"
  binding_upload = workflow.index("id: binding-upload", binding) or abort "external binding artifact upload is missing"
  abort "artifact binding is recursively included in its own candidate artifact" unless upload < binding && binding < binding_upload
  abort "external binding artifact bytes are not API-digest verified" unless workflow.include?(%q{actions/artifacts/${BINDING_ARTIFACT_ID}/zip})
  abort "provenance release asset is missing" unless workflow.scan(%q{"${PROVENANCE}"}).length >= 2
  abort "artifact binding release asset is missing" unless workflow.scan(%q{"${BINDING}"}).length >= 2
  abort "missing no-repack guard after npm mutation" unless workflow.include?("--require-unpublished")
  abort "missing no-repack guard after tag mutation" unless workflow.include?("refusing to repack after authority mutation")
  abort "missing no-repack guard after release mutation" unless workflow.include?("GitHub release v${VERSION} already exists; refusing to repack")
' "$ROOT/.github/workflows/publish-npm.yml"

echo "Packed artifact tests passed: $TARBALL ($ORIGINAL_SHA256)"
