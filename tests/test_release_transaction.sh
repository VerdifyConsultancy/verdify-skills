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
REPOSITORY="VerdifyConsultancy/verdify-skills"
PROVENANCE="$CANDIDATE/candidate-provenance.json"
BINDING="$CANDIDATE/candidate-artifact-binding.json"
PLATFORM_ARCHIVE="$TMP/platform-artifact.zip"
BINDING_ARTIFACT_ARCHIVE="$TMP/platform-binding-artifact.zip"
printf 'exact retained Actions artifact archive bytes\n' > "$PLATFORM_ARCHIVE"
ruby -rjson -rdigest -e '
  dir, output, repository, source = ARGV
  files = Dir.children(dir).sort.to_h do |name|
    path = File.join(dir, name)
    [name, Digest::SHA256.file(path).hexdigest] if File.file?(path)
  end.compact
  sidecar = files.keys.grep(/\.release-candidate\.json\z/).fetch(0)
  document = {
    "schema_version"=>"1.0", "repository"=>repository,
    "workflow_path"=>".github/workflows/publish-npm.yml",
    "workflow_run_id"=>12001, "workflow_run_attempt"=>2,
    "artifact_name"=>"verdify-release-candidate-v1.3.0-#{source}", "source_sha"=>source,
    "sidecar_filename"=>sidecar, "sidecar_sha256"=>files.fetch(sidecar), "files"=>files
  }
  File.write(output, JSON.pretty_generate(document) + "\n")
' "$CANDIDATE" "$PROVENANCE" "$REPOSITORY" "$SOURCE_SHA"
ruby -rjson -rdigest -e '
  output, repository, source, archive, provenance = ARGV
  document = {
    "schema_version"=>"1.0", "repository"=>repository,
    "workflow_path"=>".github/workflows/publish-npm.yml", "source_branch"=>"main", "source_sha"=>source,
    "workflow_run_id"=>12001, "workflow_run_attempt"=>2, "artifact_id"=>12002,
    "artifact_name"=>"verdify-release-candidate-v1.3.0-#{source}",
    "artifact_digest"=>"sha256:#{Digest::SHA256.file(archive).hexdigest}",
    "provenance_filename"=>File.basename(provenance),
    "provenance_sha256"=>Digest::SHA256.file(provenance).hexdigest
  }
  File.write(output, JSON.pretty_generate(document) + "\n")
' "$BINDING" "$REPOSITORY" "$SOURCE_SHA" "$PLATFORM_ARCHIVE" "$PROVENANCE"
BINDING_SHA256="$(ruby -rdigest -e 'puts Digest::SHA256.file(ARGV.fetch(0)).hexdigest' "$BINDING")"
BINDING_ARTIFACT_RUN_ID=12003
BINDING_ARTIFACT_RUN_ATTEMPT=3
BINDING_ARTIFACT_ID=12004
BINDING_ARTIFACT_NAME="verdify-release-candidate-v1.3.0-${SOURCE_SHA}-binding"
(cd "$CANDIDATE" && zip -q -X "$BINDING_ARTIFACT_ARCHIVE" candidate-artifact-binding.json)
BINDING_ARTIFACT_DIGEST="sha256:$(ruby -rdigest -e 'puts Digest::SHA256.file(ARGV.fetch(0)).hexdigest' "$BINDING_ARTIFACT_ARCHIVE")"

release_transaction() {
  ruby "$ROOT/scripts/release-transaction.rb" \
    --binding "$BINDING" \
    --binding-sha256 "$BINDING_SHA256" \
    --artifact-archive "$PLATFORM_ARCHIVE" \
    --binding-artifact-archive "$BINDING_ARTIFACT_ARCHIVE" \
    --binding-artifact-id "$BINDING_ARTIFACT_ID" \
    --binding-artifact-run-id "$BINDING_ARTIFACT_RUN_ID" \
    --binding-artifact-run-attempt "$BINDING_ARTIFACT_RUN_ATTEMPT" \
    --binding-artifact-name "$BINDING_ARTIFACT_NAME" \
    --binding-artifact-digest "$BINDING_ARTIFACT_DIGEST" \
    --repository "$REPOSITORY" \
    "$@"
}

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
  release_transaction --sidecar "$SIDECAR" --facts "$facts" --ledger "$ledger" >/dev/null
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
ruby -rjson -rdigest -e '
  ledger, binding, provenance = ARGV
  d = JSON.parse(File.read(ledger)).dig("artifact", "actions")
  abort unless d.values_at("repository", "workflow_path", "source_branch") == ["VerdifyConsultancy/verdify-skills", ".github/workflows/publish-npm.yml", "main"]
  abort unless d.values_at("workflow_run_id", "workflow_run_attempt", "artifact_id") == [12001, 2, 12002]
  abort unless d["artifact_digest"].match?(/\Asha256:[0-9a-f]{64}\z/)
  abort unless d.values_at("binding_artifact_run_id", "binding_artifact_run_attempt", "binding_artifact_id") == [12003, 3, 12004]
  abort unless d["binding_artifact_digest"].match?(/\Asha256:[0-9a-f]{64}\z/)
  abort unless d["provenance_sha256"] == Digest::SHA256.file(provenance).hexdigest
  abort unless d["binding_sha256"] == Digest::SHA256.file(binding).hexdigest
' "$TMP/completed.ledger.json" "$BINDING" "$PROVENANCE"

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
  release_transaction \
    --sidecar "$retry_sidecar" \
    --binding "$retry/candidate-artifact-binding.json" \
    --facts "$TMP/retry-$fixture.facts.json" \
    --ledger "$TMP/retry-$fixture.ledger.json" >/dev/null
done

make_facts artifact_verified "$TMP/identity.facts.json"

# The post-upload binding is authoritative for the complete Actions identity.
# Every platform record, route, archive, and provenance mismatch must stop before
# a publish action can be emitted.
BINDING_FIELDS=(
  repository workflow_path source_branch source_sha workflow_run_id
  workflow_run_attempt artifact_id artifact_name artifact_digest provenance_sha256
)
for field in "${BINDING_FIELDS[@]}"; do
  fixture_dir="$TMP/binding-$field"
  cp -R "$CANDIDATE" "$fixture_dir"
  fixture_binding="$fixture_dir/candidate-artifact-binding.json"
  ruby -rjson -e '
    path, field = ARGV
    d = JSON.parse(File.read(path))
    case field
    when "repository" then d[field] = "OtherOrg/verdify-skills"
    when "workflow_path" then d[field] = ".github/workflows/other.yml"
    when "source_branch" then d[field] = "dev"
    when "source_sha" then d[field] = "0" * 40
    when "workflow_run_id", "workflow_run_attempt", "artifact_id" then d[field] += 1
    when "artifact_name" then d[field] = "verdify-release-candidate-v9.9.9-#{"0" * 40}"
    when "artifact_digest" then d[field] = "sha256:#{"0" * 64}"
    when "provenance_sha256" then d[field] = "0" * 64
    else abort "unknown binding field"
    end
    File.write(path, JSON.pretty_generate(d) + "\n")
  ' "$fixture_binding" "$field"
  fixture_sidecar="$fixture_dir/$(basename "$SIDECAR")"
  fixture_ledger="$TMP/binding-$field.ledger.json"
  if release_transaction --sidecar "$fixture_sidecar" --binding "$fixture_binding" --facts "$TMP/identity.facts.json" --ledger "$fixture_ledger" \
    >"$TMP/binding-$field.out" 2>"$TMP/binding-$field.err"; then
    echo "expected Actions binding $field mismatch to fail closed" >&2
    exit 1
  fi
  ruby -rjson -e 'd=JSON.parse(File.read(ARGV.fetch(0))); abort unless d["state"] == "failed" && d["next_action"] == "manual_reconcile"' "$fixture_ledger"
done

TAMPERED_ARCHIVE="$TMP/tampered-platform-artifact.zip"
cp "$PLATFORM_ARCHIVE" "$TAMPERED_ARCHIVE"
printf 'tamper\n' >> "$TAMPERED_ARCHIVE"
if release_transaction --sidecar "$SIDECAR" --artifact-archive "$TAMPERED_ARCHIVE" --facts "$TMP/identity.facts.json" --ledger "$TMP/tampered-archive.ledger.json" \
  >"$TMP/tampered-archive.out" 2>"$TMP/tampered-archive.err"; then
  echo "expected tampered platform artifact bytes to fail closed" >&2
  exit 1
fi
ruby -rjson -e 'd=JSON.parse(File.read(ARGV.fetch(0))); abort unless d["errors"].any? { |e| e.include?("Actions artifact archive digest") }' "$TMP/tampered-archive.ledger.json"

TAMPERED_BINDING_ARCHIVE="$TMP/tampered-binding-artifact.zip"
cp "$BINDING_ARTIFACT_ARCHIVE" "$TAMPERED_BINDING_ARCHIVE"
printf 'tamper\n' >> "$TAMPERED_BINDING_ARCHIVE"
if release_transaction --sidecar "$SIDECAR" --binding-artifact-archive "$TAMPERED_BINDING_ARCHIVE" \
  --facts "$TMP/identity.facts.json" --ledger "$TMP/tampered-binding-archive.ledger.json" \
  >"$TMP/tampered-binding-archive.out" 2>"$TMP/tampered-binding-archive.err"; then
  echo "expected tampered external-binding artifact bytes to fail closed" >&2
  exit 1
fi
ruby -rjson -e 'd=JSON.parse(File.read(ARGV.fetch(0))); abort unless d["errors"].any? { |e| e.include?("external-binding Actions artifact archive digest") }' "$TMP/tampered-binding-archive.ledger.json"

PROVENANCE_FIELDS=(repository workflow_path workflow_run_id workflow_run_attempt artifact_name source_sha sidecar_sha256)
for field in "${PROVENANCE_FIELDS[@]}"; do
  fixture_dir="$TMP/provenance-$field"
  cp -R "$CANDIDATE" "$fixture_dir"
  fixture_provenance="$fixture_dir/candidate-provenance.json"
  fixture_binding="$fixture_dir/candidate-artifact-binding.json"
  ruby -rjson -rdigest -e '
    provenance_path, binding_path, field = ARGV
    p = JSON.parse(File.read(provenance_path))
    case field
    when "repository" then p[field] = "OtherOrg/verdify-skills"
    when "workflow_path" then p[field] = ".github/workflows/other.yml"
    when "workflow_run_id", "workflow_run_attempt" then p[field] += 1
    when "artifact_name" then p[field] = "verdify-release-candidate-v9.9.9-#{"0" * 40}"
    when "source_sha" then p[field] = "0" * 40
    when "sidecar_sha256" then p[field] = "0" * 64
    else abort "unknown provenance field"
    end
    File.write(provenance_path, JSON.pretty_generate(p) + "\n")
    b = JSON.parse(File.read(binding_path))
    b["provenance_sha256"] = Digest::SHA256.file(provenance_path).hexdigest
    File.write(binding_path, JSON.pretty_generate(b) + "\n")
  ' "$fixture_provenance" "$fixture_binding" "$field"
  fixture_sidecar="$fixture_dir/$(basename "$SIDECAR")"
  fixture_ledger="$TMP/provenance-$field.ledger.json"
  fixture_binding_sha="$(ruby -rdigest -e 'puts Digest::SHA256.file(ARGV.fetch(0)).hexdigest' "$fixture_binding")"
  fixture_binding_archive="$TMP/provenance-$field.binding-artifact.zip"
  (cd "$fixture_dir" && zip -q -X "$fixture_binding_archive" candidate-artifact-binding.json)
  fixture_binding_artifact_digest="sha256:$(ruby -rdigest -e 'puts Digest::SHA256.file(ARGV.fetch(0)).hexdigest' "$fixture_binding_archive")"
  if release_transaction --sidecar "$fixture_sidecar" --binding "$fixture_binding" --binding-sha256 "$fixture_binding_sha" \
    --binding-artifact-archive "$fixture_binding_archive" --binding-artifact-digest "$fixture_binding_artifact_digest" \
    --facts "$TMP/identity.facts.json" --ledger "$fixture_ledger" \
    >"$TMP/provenance-$field.out" 2>"$TMP/provenance-$field.err"; then
    echo "expected candidate provenance $field mismatch to fail closed" >&2
    exit 1
  fi
  ruby -rjson -e 'd=JSON.parse(File.read(ARGV.fetch(0))); abort unless d["state"] == "failed" && d["next_action"] == "manual_reconcile"' "$fixture_ledger"
done

fixture_dir="$TMP/provenance-file"
cp -R "$CANDIDATE" "$fixture_dir"
printf '\n' >> "$fixture_dir/candidate-provenance.json"
if release_transaction --sidecar "$fixture_dir/$(basename "$SIDECAR")" --binding "$fixture_dir/candidate-artifact-binding.json" \
  --facts "$TMP/identity.facts.json" --ledger "$TMP/provenance-file.ledger.json" >"$TMP/provenance-file.out" 2>"$TMP/provenance-file.err"; then
  echo "expected tampered candidate provenance file to fail closed" >&2
  exit 1
fi
ruby -rjson -e 'd=JSON.parse(File.read(ARGV.fetch(0))); abort unless d["errors"].any? { |e| e.include?("provenance digest") }' "$TMP/provenance-file.ledger.json"
ruby -rjson -e 'd=JSON.parse(File.read(ARGV.fetch(0))); abort unless d["state"] == "npm_published" && d["next_action"] == "push_tag"' "$TMP/retry-npm_published.ledger.json"
ruby -rjson -e 'd=JSON.parse(File.read(ARGV.fetch(0))); abort unless d["state"] == "github_released" && d["next_action"] == "upload_release_assets"' "$TMP/retry-partial_release.ledger.json"

FAILED_FACTS="$TMP/failed.facts.json"
FAILED_LEDGER="$TMP/failed.ledger.json"
make_facts mismatch "$FAILED_FACTS"
if release_transaction --sidecar "$SIDECAR" --facts "$FAILED_FACTS" --ledger "$FAILED_LEDGER" >/dev/null 2>&1; then
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
  if release_transaction --sidecar "$mutated" --facts "$TMP/identity.facts.json" --ledger "$ledger" \
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
if release_transaction --sidecar "$SIDECAR" --facts "$UNKNOWN_FACTS" --ledger "$UNKNOWN_LEDGER" >/dev/null 2>&1; then
  echo "expected unknown authority state to stop recovery" >&2
  exit 1
fi
ruby -rjson -e 'd=JSON.parse(File.read(ARGV.fetch(0))); abort unless d["state"] == "failed" && d["resumable"] == true' "$UNKNOWN_LEDGER"

# An existing or corrupt partial ledger is never a resume prerequisite.
printf '{not valid json\n' > "$TMP/reconstructed.json"
make_facts npm_published "$TMP/reconstructed.facts.json"
release_transaction --sidecar "$SIDECAR" --facts "$TMP/reconstructed.facts.json" --ledger "$TMP/reconstructed.json" >/dev/null
cp "$TMP/reconstructed.json" "$TMP/reconstructed.first.json"
release_transaction --sidecar "$SIDECAR" --facts "$TMP/reconstructed.facts.json" --ledger "$TMP/reconstructed.json" >/dev/null
cmp "$TMP/reconstructed.first.json" "$TMP/reconstructed.json"

make_facts github_released "$TMP/finalize.facts.json"
release_transaction --sidecar "$SIDECAR" --facts "$TMP/finalize.facts.json" --ledger "$TMP/finalize.json" --finalize >/dev/null
ruby -rjson -e '
  d=JSON.parse(File.read(ARGV.fetch(0)))
  abort unless d["state"] == "completed" && d["next_action"] == "none"
  abort unless d.dig("authorities", "github_release", "completed_ledger_asset") == true
  abort unless d.dig("artifact", "actions", "binding_sha256")&.match?(/\A[0-9a-f]{64}\z/)
' "$TMP/finalize.json"
"$ROOT/bin/verdify" artifact validate --file "$TMP/finalize.json" >/dev/null

echo "Release transaction tests passed."
