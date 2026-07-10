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
[[ -L "$REPO/.agents/skills/crm-email" ]]
[[ -f "$REPO/AGENTS.md" ]]
[[ -f "$INSTALL/packs/crm-email/pack.yaml" ]]
[[ ! -e "$REPO/$OLD_WORKFLOW_DIR" ]]

ruby -e 'abort unless File.realpath(ARGV[0]) == File.realpath(ARGV[1])' \
  "$REPO/.agents/skills/project-router" "$INSTALL/skills/project-router"
grep -q ".agent-workflow" "$REPO/AGENTS.md"
grep -q ".agent-skills/verdify-skills/$(cat "$ROOT/VERSION")" "$REPO/AGENTS.md"

"$INSTALL/bin/verdify" doctor --repo "$REPO" --json > "$TMP/doctor.json" || true
ruby -rjson -e 'd=JSON.parse(File.read(ARGV[0])); abort unless d["checks"].any? { |c| c["name"] == "agent_workflow_initialized" && c["ok"] }' "$TMP/doctor.json"

PACK_REPO="$TMP/pack-project"
mkdir -p "$PACK_REPO"
git -C "$PACK_REPO" init -q -b main
git -C "$PACK_REPO" config user.name "Verdify Test"
git -C "$PACK_REPO" config user.email "verdify-test@example.invalid"
printf '# Pack project\n' > "$PACK_REPO/README.md"
git -C "$PACK_REPO" add README.md
git -C "$PACK_REPO" commit -qm "initial"
npx --yes --package "$ROOT" verdify dl research-analysis --repo "$PACK_REPO" --host codex > "$TMP/dl.log"
PACK_INSTALL="$PACK_REPO/.agent-skills/verdify-skills/$(cat "$ROOT/VERSION")"
[[ -f "$PACK_INSTALL/packs/research-analysis/pack.yaml" ]]
[[ -L "$PACK_REPO/.agents/skills/northstar-research-ingest" ]]
[[ -L "$PACK_REPO/.agents/skills/northstar-question-resolution" ]]
[[ ! -e "$PACK_REPO/.agents/skills/project-router" ]]
[[ -f "$PACK_REPO/.agent-skills/verdify-packs/research-analysis.yaml" ]]
[[ ! -e "$PACK_REPO/.agent-workflow/config.yaml" ]]
grep -q "Installed pack: \`research-analysis\`" "$PACK_REPO/AGENTS.md"

CRM_REPO="$TMP/crm-pack-project"
mkdir -p "$CRM_REPO"
git -C "$CRM_REPO" init -q -b main
git -C "$CRM_REPO" config user.name "Verdify Test"
git -C "$CRM_REPO" config user.email "verdify-test@example.invalid"
printf '# CRM pack project\n' > "$CRM_REPO/README.md"
git -C "$CRM_REPO" add README.md
git -C "$CRM_REPO" commit -qm "initial"
npx --yes --package "$ROOT" verdify dl crm-email --repo "$CRM_REPO" --host all > "$TMP/crm-dl.log"
[[ -L "$CRM_REPO/.agents/skills/crm-email" ]]
[[ -L "$CRM_REPO/.claude/skills/crm-email" ]]
[[ ! -e "$CRM_REPO/.agents/skills/project-router" ]]
[[ -f "$CRM_REPO/.agent-skills/verdify-packs/crm-email.yaml" ]]
[[ ! -e "$CRM_REPO/.agent-workflow/config.yaml" ]]
grep -q "Installed pack: \`crm-email\`" "$CRM_REPO/AGENTS.md"

PACK_INIT_REPO="$TMP/pack-init-project"
mkdir -p "$PACK_INIT_REPO"
git -C "$PACK_INIT_REPO" init -q -b main
git -C "$PACK_INIT_REPO" config user.name "Verdify Test"
git -C "$PACK_INIT_REPO" config user.email "verdify-test@example.invalid"
printf '# Pack init project\n' > "$PACK_INIT_REPO/README.md"
git -C "$PACK_INIT_REPO" add README.md
git -C "$PACK_INIT_REPO" commit -qm "initial"
npx --yes --package "$ROOT" verdify init --repo "$PACK_INIT_REPO" --pack crm-email --host codex > "$TMP/pack-init.log"
[[ -L "$PACK_INIT_REPO/.agents/skills/crm-email" ]]
[[ ! -e "$PACK_INIT_REPO/.agents/skills/project-router" ]]
[[ -f "$PACK_INIT_REPO/.agent-workflow/config.yaml" ]]
[[ -f "$PACK_INIT_REPO/.agent-skills/verdify-packs/crm-email.yaml" ]]

echo "npm install test passed."
