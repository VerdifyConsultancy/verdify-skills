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
' "$TMP/research-ingest.json" "$TMP/research-item-path"
"$ROOT/bin/verdify" artifact validate --file "$REPO_WITH_EVIDENCE/.agent-workflow/northstar/evidence-registry.yaml" >/dev/null
"$ROOT/bin/verdify" artifact validate --file "$REPO_WITH_EVIDENCE/$(cat "$TMP/research-item-path")" >/dev/null
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
