#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

CANDIDATE="$TMP/candidate"
bash "$ROOT/scripts/build-release-candidate.sh" "$CANDIDATE" > "$TMP/candidate.outputs"
SIDECAR="$(sed -n 's/^sidecar=//p' "$TMP/candidate.outputs")"
SOURCE_SHA="$(sed -n 's/^source_sha=//p' "$TMP/candidate.outputs")"
INTEGRITY="$(ruby -rjson -e 'puts JSON.parse(File.read(ARGV.fetch(0))).dig("tarball", "integrity")' "$SIDECAR")"

make_facts() {
  local state="$1"
  local path="$2"
  ruby -rjson -e '
    state, path, source, integrity = ARGV
    npm_absent = {"status"=>"absent", "version"=>nil, "integrity"=>nil, "git_head"=>nil}
    npm_present = {"status"=>"published", "version"=>"1.3.0", "integrity"=>integrity, "git_head"=>source}
    tag_absent = {"status"=>"absent", "name"=>"v1.3.0", "commit"=>nil}
    tag_present = {"status"=>"present", "name"=>"v1.3.0", "commit"=>source}
    release_absent = {"status"=>"absent", "tag"=>nil, "url"=>nil, "required_assets_complete"=>false, "completed_ledger_asset"=>false}
    release_present = {"status"=>"present", "tag"=>"v1.3.0", "url"=>"https://example.invalid/releases/v1.3.0", "required_assets_complete"=>true, "completed_ledger_asset"=>false}
    document = {"artifact_verified"=>true, "npm"=>npm_absent, "tag"=>tag_absent, "github_release"=>release_absent}
    case state
    when "prepared"
      document["artifact_verified"] = false
    when "artifact_verified"
    when "npm_published"
      document["npm"] = npm_present
    when "tag_pushed"
      document["npm"] = npm_present
      document["tag"] = tag_present
    when "github_released"
      document["npm"] = npm_present
      document["tag"] = tag_present
      document["github_release"] = release_present
    when "partial_release"
      document["npm"] = npm_present
      document["tag"] = tag_present
      document["github_release"] = release_present.merge("status"=>"partial", "required_assets_complete"=>false)
    when "completed"
      document["npm"] = npm_present
      document["tag"] = tag_present
      document["github_release"] = release_present.merge("completed_ledger_asset"=>true)
    when "mismatch"
      document["npm"] = npm_present.merge("integrity"=>"sha512-WRONG")
    when "unknown"
      document["npm"] = npm_absent.merge("status"=>"unknown")
    else
      abort "unknown fixture state"
    end
    File.write(path, JSON.pretty_generate(document) + "\n")
  ' "$state" "$path" "$SOURCE_SHA" "$INTEGRITY"
}

assert_state() {
  local fixture_state="$1"
  local expected_state="$2"
  local expected_action="$3"
  local facts="$TMP/$fixture_state.facts.json"
  local ledger="$TMP/$fixture_state.ledger.json"
  make_facts "$fixture_state" "$facts"
  ruby "$ROOT/scripts/release-transaction.rb" --sidecar "$SIDECAR" --facts "$facts" --ledger "$ledger" >/dev/null
  ruby -rjson -e '
    ledger, state, action = ARGV
    document = JSON.parse(File.read(ledger))
    abort "unexpected state #{document["state"]}" unless document["state"] == state
    abort "unexpected action #{document["next_action"]}" unless document["next_action"] == action
  ' "$ledger" "$expected_state" "$expected_action"
  "$ROOT/bin/verdify" artifact validate --file "$ledger" >/dev/null
}

assert_state prepared prepared verify_artifact
assert_state artifact_verified artifact_verified publish_npm
assert_state npm_published npm_published push_tag
assert_state tag_pushed tag_pushed create_github_release
assert_state partial_release github_released upload_release_assets
assert_state github_released github_released upload_completed_ledger
assert_state completed completed none

# A later workflow attempt retrieves the retained bundle byte-for-byte. Recovery
# after npm publication and after a partial asset upload must advance from public
# authority facts without invoking the candidate builder again.
for fixture in npm_published partial_release; do
  retry="$TMP/retry-$fixture"
  cp -R "$CANDIDATE" "$retry"
  while IFS= read -r relative; do
    cmp "$CANDIDATE/$relative" "$retry/$relative"
  done < <(cd "$CANDIDATE" && find . -type f -print | sed 's#^./##' | sort)
  make_facts "$fixture" "$TMP/retry-$fixture.facts.json"
  retry_sidecar="$retry/$(basename "$SIDECAR")"
  ruby "$ROOT/scripts/release-transaction.rb" \
    --sidecar "$retry_sidecar" \
    --facts "$TMP/retry-$fixture.facts.json" \
    --ledger "$TMP/retry-$fixture.ledger.json" >/dev/null
done
ruby -rjson -e 'd=JSON.parse(File.read(ARGV.fetch(0))); abort unless d["state"] == "npm_published" && d["next_action"] == "push_tag"' "$TMP/retry-npm_published.ledger.json"
ruby -rjson -e 'd=JSON.parse(File.read(ARGV.fetch(0))); abort unless d["state"] == "github_released" && d["next_action"] == "upload_release_assets"' "$TMP/retry-partial_release.ledger.json"

FAILED_FACTS="$TMP/failed.facts.json"
FAILED_LEDGER="$TMP/failed.ledger.json"
make_facts mismatch "$FAILED_FACTS"
if ruby "$ROOT/scripts/release-transaction.rb" --sidecar "$SIDECAR" --facts "$FAILED_FACTS" --ledger "$FAILED_LEDGER" >/dev/null 2>&1; then
  echo "expected identity mismatch to fail closed" >&2
  exit 1
fi
ruby -rjson -e '
  d = JSON.parse(File.read(ARGV.fetch(0)))
  abort unless d["state"] == "failed" && d["next_action"] == "manual_reconcile" && d["resumable"] == false
  abort unless d["errors"].any? { |error| error.include?("npm integrity") }
' "$FAILED_LEDGER"
"$ROOT/bin/verdify" artifact validate --file "$FAILED_LEDGER" >/dev/null

# Every identity copied from the sidecar must be checked against local bytes or
# the clean source before any authority result can authorize publication.
IDENTITY_FIELDS=(
  package.name package.version source.commit source.clean
  tarball.filename tarball.size tarball.sha256 tarball.sha512 tarball.integrity tarball.npm_shasum
  member.path member.size member.mode member.sha256
  archive.filename archive.size archive.sha256 archive.checksum_filename archive.checksum_sha256
  build.candidate_identity build.package_file_list_blob
)
make_facts artifact_verified "$TMP/identity.facts.json"
for field in "${IDENTITY_FIELDS[@]}"; do
  mutated="$CANDIDATE/mismatch-${field//./-}.json"
  ruby -rjson -e '
    source, output, field, previous = ARGV
    d = JSON.parse(File.read(source))
    case field
    when "package.name" then d["package"]["name"] = "@wrong/cli"
    when "package.version" then d["package"]["version"] = "9.9.9"
    when "source.commit"
      d["source"]["commit"] = previous
      d["build"]["candidate_identity"] = "v#{d.dig("package", "version")}-#{previous}"
    when "source.clean" then d["source"]["clean"] = false
    when "tarball.filename" then d["tarball"]["filename"] = "missing.tgz"
    when "tarball.size" then d["tarball"]["size"] += 1
    when "tarball.sha256" then d["tarball"]["sha256"] = "0" * 64
    when "tarball.sha512" then d["tarball"]["sha512"] = "0" * 128
    when "tarball.integrity" then d["tarball"]["integrity"] = "sha512-#{"A" * 86}=="
    when "tarball.npm_shasum" then d["tarball"]["npm_shasum"] = "0" * 40
    when "member.path" then d["tarball"]["files"][0]["path"] = "wrong-member"
    when "member.size" then d["tarball"]["files"][0]["size"] += 1
    when "member.mode" then d["tarball"]["files"][0]["mode"] ^= 0o100
    when "member.sha256" then d["tarball"]["files"][0]["sha256"] = "0" * 64
    when "archive.filename" then d["archive"]["filename"] = "missing.zip"
    when "archive.size" then d["archive"]["size"] += 1
    when "archive.sha256" then d["archive"]["sha256"] = "0" * 64
    when "archive.checksum_filename" then d["archive"]["checksum_filename"] = "missing.zip.sha256"
    when "archive.checksum_sha256" then d["archive"]["checksum_sha256"] = "0" * 64
    when "build.candidate_identity" then d["build"]["candidate_identity"] = "v1.3.0-#{"0" * 40}"
    when "build.package_file_list_blob" then d["build"]["package_file_list_blob"] = "0" * 40
    else abort "unknown mismatch field"
    end
    File.write(output, JSON.pretty_generate(d) + "\n")
  ' "$SIDECAR" "$mutated" "$field" "$(git -C "$ROOT" rev-parse HEAD^)"
  ledger="$TMP/mismatch-${field//./-}.ledger.json"
  if ruby "$ROOT/scripts/release-transaction.rb" --sidecar "$mutated" --facts "$TMP/identity.facts.json" --ledger "$ledger" \
    >"$TMP/mismatch-${field//./-}.out" 2>"$TMP/mismatch-${field//./-}.err"; then
    echo "expected $field identity mismatch to fail closed" >&2
    exit 1
  fi
  ruby -rjson -e '
    d=JSON.parse(File.read(ARGV.fetch(0)))
    abort unless d["state"] == "failed" && d["next_action"] == "manual_reconcile"
    abort if d["next_action"] == "publish_npm"
  ' "$ledger"
done

UNKNOWN_FACTS="$TMP/unknown.facts.json"
UNKNOWN_LEDGER="$TMP/unknown.ledger.json"
make_facts unknown "$UNKNOWN_FACTS"
if ruby "$ROOT/scripts/release-transaction.rb" --sidecar "$SIDECAR" --facts "$UNKNOWN_FACTS" --ledger "$UNKNOWN_LEDGER" >/dev/null 2>&1; then
  echo "expected unknown authority state to stop recovery" >&2
  exit 1
fi
ruby -rjson -e 'd=JSON.parse(File.read(ARGV.fetch(0))); abort unless d["state"] == "failed" && d["resumable"] == true' "$UNKNOWN_LEDGER"

# An existing or corrupt partial ledger is never a resume prerequisite.
printf '{not valid json\n' > "$TMP/reconstructed.json"
make_facts npm_published "$TMP/reconstructed.facts.json"
ruby "$ROOT/scripts/release-transaction.rb" --sidecar "$SIDECAR" --facts "$TMP/reconstructed.facts.json" --ledger "$TMP/reconstructed.json" >/dev/null
cp "$TMP/reconstructed.json" "$TMP/reconstructed.first.json"
ruby "$ROOT/scripts/release-transaction.rb" --sidecar "$SIDECAR" --facts "$TMP/reconstructed.facts.json" --ledger "$TMP/reconstructed.json" >/dev/null
cmp "$TMP/reconstructed.first.json" "$TMP/reconstructed.json"

make_facts github_released "$TMP/finalize.facts.json"
ruby "$ROOT/scripts/release-transaction.rb" --sidecar "$SIDECAR" --facts "$TMP/finalize.facts.json" --ledger "$TMP/finalize.json" --finalize >/dev/null
ruby -rjson -e '
  d=JSON.parse(File.read(ARGV.fetch(0)))
  abort unless d["state"] == "completed" && d["next_action"] == "none"
  abort unless d.dig("authorities", "github_release", "completed_ledger_asset") == true
' "$TMP/finalize.json"
"$ROOT/bin/verdify" artifact validate --file "$TMP/finalize.json" >/dev/null

echo "Release transaction tests passed."
