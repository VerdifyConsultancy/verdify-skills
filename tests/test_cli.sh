#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
REPO="$TMP/project"
mkdir -p "$REPO"
git -C "$REPO" init -q -b main
git -C "$REPO" config user.name "Verdify Test"
git -C "$REPO" config user.email "verdify-test@example.invalid"
printf '# Test project\n' > "$REPO/README.md"
git -C "$REPO" add README.md
git -C "$REPO" commit -qm "initial"
BASE="$(git -C "$REPO" rev-parse HEAD)"

"$ROOT/bin/verdify" doctor --repo "$REPO" --json > "$TMP/doctor.json" || true
ruby -rjson -e 'd=JSON.parse(File.read(ARGV[0])); abort unless d["checks"].any? { |c| c["name"] == "git_repository" && c["ok"] }' "$TMP/doctor.json"

"$ROOT/bin/verdify" init --repo "$REPO" >/dev/null
git -C "$REPO" check-ignore -q .agent-workflow/northstar/collateral/sources/example-source.md
"$ROOT/bin/verdify" route --repo "$REPO" --write --json > "$TMP/route.json"
ruby -rjson -e 'd=JSON.parse(File.read(ARGV[0])); abort unless d["next_skill"] == "project-definition" && d["next_mode"] == "discovery"' "$TMP/route.json"
"$ROOT/bin/verdify" artifact validate --file "$REPO/.agent-workflow/router/route-decision.yaml" >/dev/null

REPO_WITH_EVIDENCE="$TMP/project-with-evidence"
mkdir -p "$REPO_WITH_EVIDENCE/docs/northstar/evidence"
git -C "$REPO_WITH_EVIDENCE" init -q -b main
git -C "$REPO_WITH_EVIDENCE" config user.name "Verdify Test"
git -C "$REPO_WITH_EVIDENCE" config user.email "verdify-test@example.invalid"
printf '# Evidence project\n' > "$REPO_WITH_EVIDENCE/README.md"
printf '# Evidence\n\nReported transcript.\n' > "$REPO_WITH_EVIDENCE/docs/northstar/evidence/walk.md"
git -C "$REPO_WITH_EVIDENCE" add README.md docs/northstar/evidence/walk.md
git -C "$REPO_WITH_EVIDENCE" commit -qm "initial"
"$ROOT/bin/verdify" init --repo "$REPO_WITH_EVIDENCE" >/dev/null
"$ROOT/bin/verdify" route --repo "$REPO_WITH_EVIDENCE" --json > "$TMP/evidence-route.json"
ruby -rjson -e 'd=JSON.parse(File.read(ARGV[0])); abort unless d["next_skill"] == "transcript-replan" && d["next_mode"] == "ingest"' "$TMP/evidence-route.json"
mkdir -p "$REPO_WITH_EVIDENCE/.agent-workflow/intake"
ruby -ryaml -e '
  path = ARGV[0]
  d = {
    "schema_ref"=>"transcript-replan.schema.yaml",
    "kind"=>"TranscriptReplan",
    "schema_version"=>"1.0",
    "source_id"=>"SRC-TEST-001",
    "status"=>"routed",
    "generated_at"=>"2026-06-23T00:00:00Z",
    "repositories"=>["local/evidence"],
    "items"=>[],
    "conflicts"=>[],
    "proposed_artifact_changes"=>[],
    "issue_recommendations"=>[],
    "gate_recommendations"=>[],
    "handoff"=>{"next_skill"=>"northstar-planning", "next_mode"=>"intake", "reason"=>"test"},
    "approval"=>{"status"=>"pending", "approver"=>nil, "approved_at"=>nil}
  }
  File.write(path, YAML.dump(d))
' "$REPO_WITH_EVIDENCE/.agent-workflow/intake/transcript-replan.yaml"
"$ROOT/bin/verdify" route --repo "$REPO_WITH_EVIDENCE" --json > "$TMP/northstar-route.json"
ruby -rjson -e 'd=JSON.parse(File.read(ARGV[0])); abort unless d["next_skill"] == "northstar-planning" && d["next_mode"] == "intake"' "$TMP/northstar-route.json"
ruby -rtime -ryaml -e '
  path = ARGV[0]
  d = {
    "schema_ref"=>"northstar-plan.schema.yaml",
    "kind"=>"NorthStarPlan",
    "schema_version"=>"1.0",
    "project_id"=>"local/evidence",
    "status"=>"approved",
    "generated_at"=>Time.now.utc.iso8601,
    "sources"=>[],
    "goals"=>[],
    "requirements"=>[],
    "user_stories"=>[],
    "architecture_principles"=>[],
    "milestones"=>[],
    "risks"=>[],
    "adversarial_findings"=>[],
    "open_questions"=>[],
    "conflicts"=>[],
    "traceability"=>[],
    "proposed_artifact_changes"=>[],
    "issue_recommendations"=>[],
    "gate_recommendations"=>[],
    "handoff"=>{"next_skill"=>"project-definition", "next_mode"=>"discovery", "reason"=>"test"},
    "approval"=>{"status"=>"approved", "approver"=>"test-owner", "approved_at"=>Time.now.utc.iso8601}
  }
  File.write(path, YAML.dump(d))
' "$REPO_WITH_EVIDENCE/.agent-workflow/northstar/northstar-plan.yaml"
"$ROOT/bin/verdify" artifact validate --file "$REPO_WITH_EVIDENCE/.agent-workflow/northstar/northstar-plan.yaml" >/dev/null
"$ROOT/bin/verdify" route --repo "$REPO_WITH_EVIDENCE" --json > "$TMP/northstar-artifacts-missing-route.json"
ruby -rjson -e 'd=JSON.parse(File.read(ARGV[0])); abort unless d["current_state"] == "NORTHSTAR_ARTIFACTS_MISSING" && d["next_skill"] == "northstar-planning" && d["next_mode"] == "artifact-loop"' "$TMP/northstar-artifacts-missing-route.json"
printf '# North Star Product\n\nStatus: `approved`\n' > "$REPO_WITH_EVIDENCE/.agent-workflow/northstar/NORTHSTAR_PRODUCT.md"
printf '# North Star Architecture\n\nStatus: `approved`\n' > "$REPO_WITH_EVIDENCE/.agent-workflow/northstar/NORTHSTAR_ARCHITECTURE.md"
ruby -rtime -ryaml -e '
  path = ARGV[0]
  now = Time.now.utc.iso8601
  d = {
    "schema_ref"=>"northstar-artifacts.schema.yaml",
    "kind"=>"NorthStarArtifacts",
    "schema_version"=>"1.0",
    "project_id"=>"local/evidence",
    "status"=>"iterating",
    "iteration"=>1,
    "generated_at"=>now,
    "updated_at"=>now,
    "product"=>{"path"=>".agent-workflow/northstar/NORTHSTAR_PRODUCT.md", "status"=>"draft", "summary"=>"test", "section_ids"=>[], "source_ids"=>[], "open_question_ids"=>["NSQ-001"]},
    "architecture"=>{"path"=>".agent-workflow/northstar/NORTHSTAR_ARCHITECTURE.md", "status"=>"draft", "summary"=>"test", "section_ids"=>[], "source_ids"=>[], "open_question_ids"=>["NSQ-001"]},
    "evidence_references"=>[],
    "cross_links"=>[],
    "open_questions"=>[{"id"=>"NSQ-001", "artifact"=>"both", "question"=>"Who approves?", "owner"=>"test-owner", "blocking"=>false, "status"=>"open", "source_ids"=>[], "proposed_resolution"=>"Continue planning; final approval is required only before lock and downstream handoff."}],
    "review"=>{"requested_at"=>nil, "reviewers"=>["test-owner"], "status"=>"not_requested", "approvals"=>[], "signoff_required_for_downstream"=>true},
    "handoff"=>{"next_skill"=>"northstar-planning", "next_mode"=>"artifact-loop", "reason"=>"test"}
  }
  File.write(path, YAML.dump(d))
' "$REPO_WITH_EVIDENCE/.agent-workflow/northstar/northstar-artifacts.yaml"
"$ROOT/bin/verdify" artifact validate --file "$REPO_WITH_EVIDENCE/.agent-workflow/northstar/northstar-artifacts.yaml" >/dev/null
"$ROOT/bin/verdify" route --repo "$REPO_WITH_EVIDENCE" --json > "$TMP/northstar-questions-open-route.json"
ruby -rjson -e 'd=JSON.parse(File.read(ARGV[0])); abort unless d["current_state"] == "NORTHSTAR_ARTIFACTS_INCOMPLETE" && d["next_skill"] == "northstar-planning" && d["next_mode"] == "artifact-loop"' "$TMP/northstar-questions-open-route.json"
ruby -rtime -ryaml -e '
  path = ARGV[0]
  now = Time.now.utc.iso8601
  d = {
    "schema_ref"=>"northstar-artifacts.schema.yaml",
    "kind"=>"NorthStarArtifacts",
    "schema_version"=>"1.0",
    "project_id"=>"local/evidence",
    "status"=>"approved",
    "iteration"=>1,
    "generated_at"=>now,
    "updated_at"=>now,
    "product"=>{"path"=>".agent-workflow/northstar/NORTHSTAR_PRODUCT.md", "status"=>"approved", "summary"=>"test", "section_ids"=>[], "source_ids"=>[], "open_question_ids"=>[]},
    "architecture"=>{"path"=>".agent-workflow/northstar/NORTHSTAR_ARCHITECTURE.md", "status"=>"approved", "summary"=>"test", "section_ids"=>[], "source_ids"=>[], "open_question_ids"=>[]},
    "evidence_references"=>[],
    "cross_links"=>[],
    "open_questions"=>[],
    "review"=>{"requested_at"=>now, "reviewers"=>["test-owner"], "status"=>"approved", "approvals"=>[{"reviewer"=>"test-owner", "decision"=>"approved", "decided_at"=>now, "notes"=>"test"}], "signoff_required_for_downstream"=>true},
    "handoff"=>{"next_skill"=>"project-definition", "next_mode"=>"discovery", "reason"=>"test"}
  }
  File.write(path, YAML.dump(d))
' "$REPO_WITH_EVIDENCE/.agent-workflow/northstar/northstar-artifacts.yaml"
"$ROOT/bin/verdify" artifact validate --file "$REPO_WITH_EVIDENCE/.agent-workflow/northstar/northstar-artifacts.yaml" >/dev/null
"$ROOT/bin/verdify" route --repo "$REPO_WITH_EVIDENCE" --json > "$TMP/signed-northstar-route.json"
ruby -rjson -e 'd=JSON.parse(File.read(ARGV[0])); abort unless d["next_skill"] == "project-definition" && d["next_mode"] == "discovery"' "$TMP/signed-northstar-route.json"

printf '# Platform observability research\n\nNamespace dashboards should expose endpoint health.\n' > "$TMP/research.md"
"$ROOT/bin/verdify" northstar ingest-research \
  --repo "$REPO_WITH_EVIDENCE" \
  --file "$TMP/research.md" \
  --title "Platform observability research" \
  --summary "Shows why namespace-level endpoint health belongs in planning evidence." \
  --tag platform,observability \
  --tag skills \
  --claim "Namespace dashboards should expose endpoint health." \
  --relevance "Supports platform readiness and observability requirements." \
  --json > "$TMP/research-ingest.json"
ruby -rjson -e '
  d = JSON.parse(File.read(ARGV[0]))
  abort unless d["id"].start_with?("NSE-")
  abort unless d["reference"].start_with?("northstar://evidence/NSE-")
  abort unless d["item_path"].end_with?(".yaml")
  File.write(ARGV[1], d["item_path"])
  File.write(ARGV[2], d["copied_source_path"])
' "$TMP/research-ingest.json" "$TMP/research-item-path" "$TMP/research-source-path"
"$ROOT/bin/verdify" artifact validate --file "$REPO_WITH_EVIDENCE/.agent-workflow/northstar/evidence-registry.yaml" >/dev/null
"$ROOT/bin/verdify" artifact validate --file "$REPO_WITH_EVIDENCE/$(cat "$TMP/research-item-path")" >/dev/null
git -C "$REPO_WITH_EVIDENCE" check-ignore -q "$(cat "$TMP/research-source-path")"
"$ROOT/bin/verdify" northstar evidence list \
  --repo "$REPO_WITH_EVIDENCE" \
  --query observability \
  --tag platform \
  --json > "$TMP/research-list.json"
ruby -rjson -e '
  d = JSON.parse(File.read(ARGV[0]))
  abort unless d["count"] == 1
  e = d["evidence"].first
  abort unless e["reference"].start_with?("northstar://evidence/NSE-")
  abort unless e["tags"].include?("platform") && e["tags"].include?("observability")
' "$TMP/research-list.json"

{
  printf '# Secret fixture\n\n'
  printf 'Leaked token: %s%s%s\n' "gh" "p_" "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
} > "$TMP/secret-research.md"
if "$ROOT/bin/verdify" northstar ingest-research \
  --repo "$REPO_WITH_EVIDENCE" \
  --file "$TMP/secret-research.md" \
  --id NSE-20260624-secret-fixture \
  --title "Secret fixture" \
  --summary "Should be blocked before source copy." \
  --tag security \
  --claim "This fixture should not be ingested." \
  --json > "$TMP/secret-ingest.out" 2> "$TMP/secret-ingest.err"; then
  echo "expected secret-bearing research ingest to fail" >&2
  exit 1
fi
grep -q '^verdify: research source failed secret scan:' "$TMP/secret-ingest.err"
[[ ! -e "$REPO_WITH_EVIDENCE/.agent-workflow/northstar/collateral/sources/NSE-20260624-secret-fixture-secret-research-md" ]]
[[ ! -e "$REPO_WITH_EVIDENCE/.agent-workflow/northstar/collateral/NSE-20260624-secret-fixture.yaml" ]]
if grep -q 'NSE-20260624-secret-fixture' "$REPO_WITH_EVIDENCE/.agent-workflow/northstar/evidence-registry.yaml"; then
  echo "expected rejected secret fixture to be absent from evidence registry" >&2
  exit 1
fi

MALFORMED_EVIDENCE_REPO="$TMP/project-with-malformed-evidence"
mkdir -p "$MALFORMED_EVIDENCE_REPO"
git -C "$MALFORMED_EVIDENCE_REPO" init -q -b main
git -C "$MALFORMED_EVIDENCE_REPO" config user.name "Verdify Test"
git -C "$MALFORMED_EVIDENCE_REPO" config user.email "verdify-test@example.invalid"
printf '# Malformed evidence project\n' > "$MALFORMED_EVIDENCE_REPO/README.md"
git -C "$MALFORMED_EVIDENCE_REPO" add README.md
git -C "$MALFORMED_EVIDENCE_REPO" commit -qm "initial"
"$ROOT/bin/verdify" init --repo "$MALFORMED_EVIDENCE_REPO" >/dev/null
cat > "$MALFORMED_EVIDENCE_REPO/.agent-workflow/northstar/evidence-registry.yaml" <<YAML
schema_ref: northstar-evidence-registry.schema.yaml
kind: NorthStarEvidenceRegistry
schema_version: "1.0"
project_id: local/malformed
generated_at: "2026-06-24T00:00:00Z"
updated_at: "2026-06-24T00:00:00Z"
evidence:
  - id: NSE-20260624-malformed-title
    reference: northstar://evidence/NSE-20260624-malformed-title
    title:
    evidence_type: research_note
    evidence_status: observed
    ingested_at: "2026-06-24T00:00:00Z"
    item_path: .agent-workflow/northstar/collateral/NSE-20260624-malformed-title.yaml
    copied_source_path: .agent-workflow/northstar/collateral/sources/malformed.md
    source_uri:
    source_sha256: 0000000000000000000000000000000000000000000000000000000000000000
    summary: Malformed title fixture.
    tags: []
    claims: []
    planning_relevance: []
YAML
if "$ROOT/bin/verdify" northstar evidence list --repo "$MALFORMED_EVIDENCE_REPO" > "$TMP/malformed-evidence.out" 2> "$TMP/malformed-evidence.err"; then
  echo "expected malformed evidence registry to fail with a typed error" >&2
  exit 1
fi
grep -q '^verdify: northstar evidence registry failed validation:' "$TMP/malformed-evidence.err"
if grep -Eq 'NoMethodError|lib/verdify/cli\.rb:[0-9]+:in' "$TMP/malformed-evidence.err"; then
  echo "expected malformed evidence registry error without a Ruby stack trace" >&2
  cat "$TMP/malformed-evidence.err" >&2
  exit 1
fi

REPO_WITH_RAW_RESEARCH="$TMP/project-with-raw-research"
mkdir -p "$REPO_WITH_RAW_RESEARCH/docs/northstar/research"
git -C "$REPO_WITH_RAW_RESEARCH" init -q -b main
git -C "$REPO_WITH_RAW_RESEARCH" config user.name "Verdify Test"
git -C "$REPO_WITH_RAW_RESEARCH" config user.email "verdify-test@example.invalid"
printf '# Raw research project\n' > "$REPO_WITH_RAW_RESEARCH/README.md"
printf '# Raw research\n\nUnregistered finding.\n' > "$REPO_WITH_RAW_RESEARCH/docs/northstar/research/raw.md"
git -C "$REPO_WITH_RAW_RESEARCH" add README.md docs/northstar/research/raw.md
git -C "$REPO_WITH_RAW_RESEARCH" commit -qm "initial"
"$ROOT/bin/verdify" init --repo "$REPO_WITH_RAW_RESEARCH" >/dev/null
"$ROOT/bin/verdify" route --repo "$REPO_WITH_RAW_RESEARCH" --json > "$TMP/raw-research-route.json"
ruby -rjson -e 'd=JSON.parse(File.read(ARGV[0])); abort unless d["next_skill"] == "northstar-research-ingest" && d["next_mode"] == "ingest-research"' "$TMP/raw-research-route.json"

"$ROOT/bin/verdify" sprint init --repo "$REPO" --id sprint-a >/dev/null
"$ROOT/bin/verdify" artifact validate --file "$REPO/.agent-workflow/sprints/sprint-a/sprint-plan.yaml" >/dev/null

mkdir -p "$REPO/.agent-workflow/sprints/sprint-a/lanes/contracts"
ruby -rtime -ryaml -e '
  src, dst, sha = ARGV
  d = YAML.safe_load(File.read(src), permitted_classes: [], aliases: false)
  d["sprint_id"] = "sprint-a"
  d["lane_id"] = "issue-123-api"
  d["status"] = "approved"
  d["baseline_sha"] = sha
  d["branch"] = "lane/123-health-api"
  d["approval"] = {"status"=>"approved", "approver"=>"test-owner", "approved_at"=>Time.now.utc.iso8601}
  File.write(dst, YAML.dump(d))
' "$ROOT/examples/minimal-project/.agent-workflow/sprints/2026-06-22-a/lanes/contracts/issue-123-api.contract.yaml" \
  "$REPO/.agent-workflow/sprints/sprint-a/lanes/contracts/issue-123-api.contract.yaml" "$BASE"
"$ROOT/bin/verdify" artifact validate --file "$REPO/.agent-workflow/sprints/sprint-a/lanes/contracts/issue-123-api.contract.yaml" >/dev/null
ruby -rtime -ryaml -e '
  src, dst, sha = ARGV
  d = YAML.safe_load(File.read(src), permitted_classes: [], aliases: false)
  d["sprint_id"] = "sprint-a"
  d["lane_id"] = "issue-124-race"
  d["issue_ids"] = [124]
  d["status"] = "approved"
  d["baseline_sha"] = sha
  d["branch"] = "lane/124-race"
  d["approval"] = {"status"=>"approved", "approver"=>"test-owner", "approved_at"=>Time.now.utc.iso8601}
  File.write(dst, YAML.dump(d))
' "$ROOT/examples/minimal-project/.agent-workflow/sprints/2026-06-22-a/lanes/contracts/issue-123-api.contract.yaml" \
  "$REPO/.agent-workflow/sprints/sprint-a/lanes/contracts/issue-124-race.contract.yaml" "$BASE"
"$ROOT/bin/verdify" artifact validate --file "$REPO/.agent-workflow/sprints/sprint-a/lanes/contracts/issue-124-race.contract.yaml" >/dev/null

WORKTREE="$TMP/worker"
"$ROOT/bin/verdify" lane create --repo "$REPO" --sprint sprint-a --lane-id issue-123-api --issue 123 \
  --session-id worker-test --agent test-agent --path "$WORKTREE" >/dev/null
[[ -d "$WORKTREE" ]]
"$ROOT/bin/verdify" lane inspect --repo "$REPO" --lease-id issue-123-api > "$TMP/lease.json"
ruby -rjson -e 'd=JSON.parse(File.read(ARGV[0])); abort unless d["role"] == "worker" && d["worktree_exists"]' "$TMP/lease.json"

if "$ROOT/bin/verdify" lane create --repo "$REPO" --sprint sprint-a --lane-id issue-123-api --issue 123 \
  --session-id second-worker --agent test-agent --path "$TMP/worker-2" >/dev/null 2>&1; then
  echo "expected duplicate worker lease to be rejected" >&2
  exit 1
fi

RACE_WORKTREE_A="$TMP/race-worker-a"
RACE_WORKTREE_B="$TMP/race-worker-b"
"$ROOT/bin/verdify" lane create --repo "$REPO" --sprint sprint-a --lane-id issue-124-race --issue 124 \
  --session-id race-worker-a --agent test-agent --path "$RACE_WORKTREE_A" > "$TMP/race-a.out" 2> "$TMP/race-a.err" &
RACE_PID_A=$!
"$ROOT/bin/verdify" lane create --repo "$REPO" --sprint sprint-a --lane-id issue-124-race --issue 124 \
  --session-id race-worker-b --agent test-agent --path "$RACE_WORKTREE_B" > "$TMP/race-b.out" 2> "$TMP/race-b.err" &
RACE_PID_B=$!
RACE_STATUS_A=0
RACE_STATUS_B=0
wait "$RACE_PID_A" || RACE_STATUS_A=$?
wait "$RACE_PID_B" || RACE_STATUS_B=$?
if [[ $(( (RACE_STATUS_A == 0) + (RACE_STATUS_B == 0) )) -ne 1 ]]; then
  echo "expected exactly one concurrent lane create to succeed" >&2
  cat "$TMP/race-a.err" "$TMP/race-b.err" >&2
  exit 1
fi
grep -h 'verdify: lane already has active worker lease issue-124-race' "$TMP/race-a.err" "$TMP/race-b.err" >/dev/null
ruby -rjson -e '
  repo, common = ARGV
  common = File.expand_path(common, repo) unless common.start_with?("/")
  leases = Dir[File.join(common, "verdify/leases/*.json")].map { |path| JSON.parse(File.read(path)) }
  active = leases.count { |lease| lease["role"] == "worker" && lease["lane_id"] == "issue-124-race" && lease["status"] == "active" }
  abort "expected one active race worker lease, got #{active}" unless active == 1
' "$REPO" "$(git -C "$REPO" rev-parse --git-common-dir)"

ruby -rjson -rfileutils -e '
  repo, common = ARGV
  common = File.expand_path(common, repo) unless common.start_with?("/")
  dir = File.join(common, "verdify/leases")
  FileUtils.mkdir_p(dir)
  runtime = {
    "compose_project"=>"verdify_stale_valid",
    "database_suffix"=>"stale_valid",
    "kubernetes_namespace"=>"lane-stale-valid",
    "port_offset"=>1234,
    "cache_prefix"=>"verdify:stale-valid:"
  }
  valid = {
    "schema_ref"=>"lane-lease.schema.yaml",
    "kind"=>"LaneLease",
    "schema_version"=>"1.0",
    "lease_id"=>"stale-valid",
    "sprint_id"=>"sprint-a",
    "lane_id"=>"stale-valid",
    "issue_ids"=>[125],
    "role"=>"worker",
    "agent"=>"test-agent",
    "session_id"=>"stale-valid",
    "branch"=>"lane/stale-valid",
    "baseline_sha"=>"test-baseline",
    "contract_path"=>File.join(repo, ".agent-workflow/sprints/sprint-a/lanes/contracts/issue-123-api.contract.yaml"),
    "contract_hash"=>"test-contract-hash",
    "worktree_path"=>File.join(repo, "stale-valid-worktree"),
    "created_at"=>"2026-06-23T00:00:00Z",
    "expires_at"=>"2026-06-23T00:00:00Z",
    "released_at"=>nil,
    "status"=>"active",
    "runtime_namespace"=>runtime
  }
  invalid = valid.merge(
    "lease_id"=>"stale-invalid",
    "lane_id"=>"stale-invalid",
    "session_id"=>"stale-invalid"
  )
  invalid.delete("runtime_namespace")
  File.write(File.join(dir, "stale-valid.json"), JSON.pretty_generate(valid) + "\n")
  File.write(File.join(dir, "stale-invalid.json"), JSON.pretty_generate(invalid) + "\n")
' "$REPO" "$(git -C "$REPO" rev-parse --git-common-dir)"
"$ROOT/bin/verdify" lane list --repo "$REPO" > "$TMP/lane-list-with-invalid-lease.out"
ruby -rjson -e '
  repo, common = ARGV
  common = File.expand_path(common, repo) unless common.start_with?("/")
  dir = File.join(common, "verdify/leases")
  valid = JSON.parse(File.read(File.join(dir, "stale-valid.json")))
  invalid = JSON.parse(File.read(File.join(dir, "stale-invalid.json")))
  abort "expected valid stale lease to expire" unless valid["status"] == "expired"
  abort "expected malformed stale lease to remain readable" unless invalid["status"] == "active"
' "$REPO" "$(git -C "$REPO" rev-parse --git-common-dir)"

"$ROOT/bin/verdify" prompt compile --repo "$REPO" \
  --contract .agent-workflow/sprints/sprint-a/lanes/contracts/issue-123-api.contract.yaml \
  --role worker --out .agent-workflow/sprints/sprint-a/prompts/worker.md >/dev/null
[[ -f "$REPO/.agent-workflow/sprints/sprint-a/prompts/worker.md" ]]
[[ -f "$REPO/.agent-workflow/sprints/sprint-a/prompts/worker.manifest.json" ]]

REVIEW="$TMP/review"
"$ROOT/bin/verdify" lane review --repo "$REPO" --lane-id issue-123-api \
  --session-id critic-test --agent critic-agent --path "$REVIEW" >/dev/null
[[ -d "$REVIEW" ]]
CRITIC_LEASE="critic-issue-123-api-critic-test"
"$ROOT/bin/verdify" lane release --repo "$REPO" --lease-id "$CRITIC_LEASE" --session-id critic-test >/dev/null
"$ROOT/bin/verdify" lane release --repo "$REPO" --lease-id issue-123-api --session-id worker-test >/dev/null
[[ ! -e "$WORKTREE" ]]
[[ ! -e "$REVIEW" ]]

bash "$ROOT/tests/test_router_gate_bypass.sh"

echo "CLI lifecycle tests passed."
