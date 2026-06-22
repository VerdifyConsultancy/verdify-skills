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

"$ROOT/bin/verdify" doctor --repo "$REPO" --json > "$TMP/doctor.json"
ruby -rjson -e 'd=JSON.parse(File.read(ARGV[0])); abort unless d["checks"].any? { |c| c["name"] == "git_repository" && c["ok"] }' "$TMP/doctor.json"

"$ROOT/bin/verdify" init --repo "$REPO" >/dev/null
"$ROOT/bin/verdify" route --repo "$REPO" --write --json > "$TMP/route.json"
ruby -rjson -e 'd=JSON.parse(File.read(ARGV[0])); abort unless d["next_skill"] == "project-definition" && d["next_mode"] == "discovery"' "$TMP/route.json"
"$ROOT/bin/verdify" artifact validate --file "$REPO/.verdify/router/route-decision.yaml" >/dev/null

"$ROOT/bin/verdify" sprint init --repo "$REPO" --id sprint-a >/dev/null
"$ROOT/bin/verdify" artifact validate --file "$REPO/.verdify/sprints/sprint-a/sprint-plan.yaml" >/dev/null

mkdir -p "$REPO/.verdify/sprints/sprint-a/lanes/contracts"
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
' "$ROOT/examples/minimal-project/.verdify/sprints/2026-06-22-a/lanes/contracts/issue-123-api.contract.yaml" \
  "$REPO/.verdify/sprints/sprint-a/lanes/contracts/issue-123-api.contract.yaml" "$BASE"
"$ROOT/bin/verdify" artifact validate --file "$REPO/.verdify/sprints/sprint-a/lanes/contracts/issue-123-api.contract.yaml" >/dev/null

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
  --contract .verdify/sprints/sprint-a/lanes/contracts/issue-123-api.contract.yaml \
  --role worker --out .verdify/sprints/sprint-a/prompts/worker.md >/dev/null
[[ -f "$REPO/.verdify/sprints/sprint-a/prompts/worker.md" ]]
[[ -f "$REPO/.verdify/sprints/sprint-a/prompts/worker.manifest.json" ]]

REVIEW="$TMP/review"
"$ROOT/bin/verdify" lane review --repo "$REPO" --lane-id issue-123-api \
  --session-id critic-test --agent critic-agent --path "$REVIEW" >/dev/null
[[ -d "$REVIEW" ]]
CRITIC_LEASE="critic-issue-123-api-critic-test"
"$ROOT/bin/verdify" lane release --repo "$REPO" --lease-id "$CRITIC_LEASE" --session-id critic-test >/dev/null
"$ROOT/bin/verdify" lane release --repo "$REPO" --lease-id issue-123-api --session-id worker-test >/dev/null
[[ ! -e "$WORKTREE" ]]
[[ ! -e "$REVIEW" ]]

echo "CLI lifecycle tests passed."
