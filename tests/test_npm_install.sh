#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v node >/dev/null || ! command -v npm >/dev/null; then
  echo "npm install test skipped: node and npm are required."
  exit 0
fi

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

npx --yes --package "$ROOT" verdify init --repo "$REPO" > "$TMP/install.log"

INSTALL="$REPO/.agent-skills/verdify-skills/$(cat "$ROOT/VERSION")"
OLD_WORKFLOW_DIR=".ver""dify"
[[ -x "$INSTALL/bin/verdify" ]]
[[ -f "$REPO/.agent-workflow/config.yaml" ]]
[[ -f "$REPO/.agent-workflow/router/route-decision.yaml" ]]
[[ -L "$REPO/.agents/skills/project-router" ]]
[[ -f "$REPO/AGENTS.md" ]]
[[ ! -e "$REPO/$OLD_WORKFLOW_DIR" ]]

ruby -e 'abort unless File.realpath(ARGV[0]) == File.realpath(ARGV[1])' \
  "$REPO/.agents/skills/project-router" "$INSTALL/skills/project-router"
grep -q ".agent-workflow" "$REPO/AGENTS.md"
grep -q ".agent-skills/verdify-skills/$(cat "$ROOT/VERSION")" "$REPO/AGENTS.md"

"$INSTALL/bin/verdify" doctor --repo "$REPO" --json > "$TMP/doctor.json" || true
ruby -rjson -e 'd=JSON.parse(File.read(ARGV[0])); abort unless d["checks"].any? { |c| c["name"] == "agent_workflow_initialized" && c["ok"] }' "$TMP/doctor.json"

echo "npm install test passed."
