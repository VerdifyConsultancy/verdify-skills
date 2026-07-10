#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

SOURCE_SHA="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
INTEGRITY="sha512-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="
SIDECAR="$TMP/candidate.json"
ruby -rjson -e '
  path, source, integrity = ARGV
  document = {
    "schema_version"=>"1.0",
    "package"=>{"name"=>"@verdify-cli/cli", "version"=>"1.3.0"},
    "source"=>{"commit"=>source, "clean"=>true},
    "tarball"=>{
      "filename"=>"verdify-cli-cli-1.3.0.tgz", "size"=>1,
      "sha256"=>"b"*64, "sha512"=>"c"*128, "integrity"=>integrity,
      "npm_shasum"=>"d"*40, "files"=>[{"path"=>"package.json", "size"=>1, "mode"=>420}]
    },
    "archive"=>{
      "filename"=>"verdify-lifecycle-skills-v1.3.0.zip", "size"=>1,
      "sha256"=>"e"*64, "checksum_filename"=>"verdify-lifecycle-skills-v1.3.0.zip.sha256"
    },
    "build"=>{
      "npm_pack_invocations"=>1,
      "npm_pack_command"=>["npm", "pack", "--json", "--pack-destination", "dist"],
      "package_file_list_blob"=>"f"*40
    }
  }
  File.write(path, JSON.pretty_generate(document) + "\n")
' "$SIDECAR" "$SOURCE_SHA" "$INTEGRITY"

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
