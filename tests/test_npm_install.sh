#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
for command in git node npm ruby; do
  command -v "$command" >/dev/null || { echo "$command is required for npm install tests" >&2; exit 1; }
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
TARBALL="${VERDIFY_TARBALL:-}"
SIDECAR="${VERDIFY_SIDECAR:-}"
if [[ -z "$TARBALL" ]]; then
  bash "$ROOT/scripts/build-release-candidate.sh" "$TMP/candidate" > "$TMP/candidate.outputs"
  TARBALL="$(sed -n 's/^tarball=//p' "$TMP/candidate.outputs")"
  SIDECAR="$(sed -n 's/^sidecar=//p' "$TMP/candidate.outputs")"
fi
[[ -f "$TARBALL" ]] || { echo "exact npm tarball is missing: $TARBALL" >&2; exit 1; }
if [[ -n "$SIDECAR" ]]; then
  ruby "$ROOT/scripts/verify-npm-tarball.rb" --tarball "$TARBALL" --sidecar "$SIDECAR" >/dev/null
fi

TOOL="$TMP/tool"
npm install --ignore-scripts --no-audit --no-fund --prefix "$TOOL" "$TARBALL" > "$TMP/npm-install.log"
PACKAGE_ROOT="$TOOL/node_modules/@verdify-cli/cli"
CLI="$TOOL/node_modules/.bin/verdify"
[[ -x "$CLI" ]]
npm test --prefix "$PACKAGE_ROOT" > "$TMP/installed-test.log"
[[ "$($CLI --version)" == "1.3.0" ]]
$CLI pack list --json > "$TMP/installed-packs.json"
ruby -rjson -e 'd=JSON.parse(File.read(ARGV.fetch(0))); abort unless d["count"] == 6' "$TMP/installed-packs.json"

make_repo() {
  local path="$1"
  mkdir -p "$path"
  git -C "$path" init -q -b main
  git -C "$path" config user.name "Verdify Test"
  git -C "$path" config user.email "verdify-test@example.invalid"
  printf '# Test project\n' > "$path/README.md"
  git -C "$path" add README.md
  git -C "$path" commit -qm "initial"
}

REPO="$TMP/project"
make_repo "$REPO"
$CLI init --repo "$REPO" > "$TMP/init.log"
$CLI init --repo "$REPO" > "$TMP/reinstall.log"

INSTALL="$REPO/.agent-skills/verdify-skills/1.3.0"
OLD_WORKFLOW_DIR=".ver""dify"
[[ -x "$INSTALL/bin/verdify" ]]
[[ -f "$REPO/.agent-workflow/config.yaml" ]]
[[ -f "$REPO/.agent-workflow/router/route-decision.yaml" ]]
[[ -L "$REPO/.agents/skills/project-router" ]]
[[ -L "$REPO/.agents/skills/crm-email" ]]
[[ -f "$REPO/AGENTS.md" ]]
[[ -f "$INSTALL/packs/crm-email/pack.yaml" ]]
[[ ! -e "$REPO/$OLD_WORKFLOW_DIR" ]]
ruby -e 'abort unless File.realpath(ARGV[0]) == File.realpath(ARGV[1])' "$REPO/.agents/skills/project-router" "$INSTALL/skills/project-router"
grep -q ".agent-workflow" "$REPO/AGENTS.md"
grep -q ".agent-skills/verdify-skills/1.3.0" "$REPO/AGENTS.md"
"$INSTALL/bin/verdify" doctor --repo "$REPO" --json > "$TMP/doctor.json" || true
ruby -rjson -e 'd=JSON.parse(File.read(ARGV[0])); abort unless d["checks"].any? { |c| c["name"] == "agent_workflow_initialized" && c["ok"] }' "$TMP/doctor.json"

# Install the real published 1.2.1 tarball, pinned to its registry digest, and
# run its initializer before upgrading that exact repository to this 1.3.0
# candidate.
UPGRADE_REPO="$TMP/upgrade-project"
make_repo "$UPGRADE_REPO"
OLD_PACKAGE_DIR="$TMP/published-1.2.1"
OLD_TOOL="$TMP/tool-1.2.1"
mkdir -p "$OLD_PACKAGE_DIR"
npm pack --json --pack-destination "$OLD_PACKAGE_DIR" @verdify-cli/cli@1.2.1 > "$TMP/npm-pack-1.2.1.json"
OLD_TARBALL="$OLD_PACKAGE_DIR/$(ruby -rjson -e 'puts JSON.parse(File.read(ARGV.fetch(0))).fetch(0).fetch("filename")' "$TMP/npm-pack-1.2.1.json")"
ruby -rbase64 -rdigest -rjson -e '
  result, tarball = ARGV
  artifact = JSON.parse(File.read(result)).fetch(0)
  expected_integrity = "sha512-rbIHSLe2cbP5gZGxn1pjWCDvSKEE9UfPu5LxpwhycWJwWk9Kd69v31tNchr3Nf/xZgdjCliMvlAaaFkWwjRMtw=="
  expected_shasum = "3afd4c64c21f7e4789d3bc56be9f85cd5b25557d"
  actual_integrity = "sha512-#{Base64.strict_encode64(Digest::SHA512.file(tarball).digest)}"
  abort unless artifact.fetch("integrity") == expected_integrity && actual_integrity == expected_integrity
  abort unless artifact.fetch("shasum") == expected_shasum && Digest::SHA1.file(tarball).hexdigest == expected_shasum
' "$TMP/npm-pack-1.2.1.json" "$OLD_TARBALL"
npm install --ignore-scripts --no-audit --no-fund --prefix "$OLD_TOOL" "$OLD_TARBALL" > "$TMP/npm-install-1.2.1.log"
OLD_CLI="$OLD_TOOL/node_modules/.bin/verdify"
[[ "$("$OLD_CLI" --version)" == "1.2.1" ]]
"$OLD_CLI" init --repo "$UPGRADE_REPO" > "$TMP/init-1.2.1.log"
[[ -d "$UPGRADE_REPO/.agent-skills/verdify-skills/1.2.1" ]]
[[ -L "$UPGRADE_REPO/.agents/skills/project-router" ]]
$CLI init --repo "$UPGRADE_REPO" --force > "$TMP/upgrade.log"
[[ ! -e "$UPGRADE_REPO/.agent-skills/verdify-skills/1.2.1" ]]
[[ -d "$UPGRADE_REPO/.agent-skills/verdify-skills/1.3.0" ]]
ruby -e 'abort unless File.realpath(ARGV[0]) == File.realpath(ARGV[1])' \
  "$UPGRADE_REPO/.agents/skills/project-router" \
  "$UPGRADE_REPO/.agent-skills/verdify-skills/1.3.0/skills/project-router"

PACK_REPO="$TMP/pack-project"
make_repo "$PACK_REPO"
$CLI dl research-analysis --repo "$PACK_REPO" --host codex > "$TMP/dl.log"
PACK_INSTALL="$PACK_REPO/.agent-skills/verdify-skills/1.3.0"
[[ -f "$PACK_INSTALL/packs/research-analysis/pack.yaml" ]]
[[ -L "$PACK_REPO/.agents/skills/northstar-research-ingest" ]]
[[ -L "$PACK_REPO/.agents/skills/northstar-question-resolution" ]]
[[ ! -e "$PACK_REPO/.agents/skills/project-router" ]]
[[ -f "$PACK_REPO/.agent-skills/verdify-packs/research-analysis.yaml" ]]
[[ ! -e "$PACK_REPO/.agent-workflow/config.yaml" ]]
grep -q 'Installed pack: `research-analysis`' "$PACK_REPO/AGENTS.md"

CRM_REPO="$TMP/crm-pack-project"
make_repo "$CRM_REPO"
$CLI dl crm-email --repo "$CRM_REPO" --host all > "$TMP/crm-dl.log"
[[ -L "$CRM_REPO/.agents/skills/crm-email" ]]
[[ -L "$CRM_REPO/.claude/skills/crm-email" ]]
[[ ! -e "$CRM_REPO/.agents/skills/project-router" ]]
[[ -f "$CRM_REPO/.agent-skills/verdify-packs/crm-email.yaml" ]]
[[ ! -e "$CRM_REPO/.agent-workflow/config.yaml" ]]
grep -q 'Installed pack: `crm-email`' "$CRM_REPO/AGENTS.md"

PACK_INIT_REPO="$TMP/pack-init-project"
make_repo "$PACK_INIT_REPO"
$CLI init --repo "$PACK_INIT_REPO" --pack crm-email --host codex > "$TMP/pack-init.log"
[[ -L "$PACK_INIT_REPO/.agents/skills/crm-email" ]]
[[ ! -e "$PACK_INIT_REPO/.agents/skills/project-router" ]]
[[ -f "$PACK_INIT_REPO/.agent-workflow/config.yaml" ]]
[[ -f "$PACK_INIT_REPO/.agent-skills/verdify-packs/crm-email.yaml" ]]

# A later link collision must leave no links, manifest, package copy, or AGENTS block.
COLLISION_REPO="$TMP/collision-project"
make_repo "$COLLISION_REPO"
mkdir -p "$COLLISION_REPO/.agents/skills/northstar-question-resolution"
printf 'operator owned\n' > "$COLLISION_REPO/.agents/skills/northstar-question-resolution/owner.txt"
if $CLI dl research-analysis --repo "$COLLISION_REPO" --host codex > "$TMP/collision.out" 2> "$TMP/collision.err"; then
  echo "expected exact-tarball collision install to fail" >&2
  exit 1
fi
[[ "$(cat "$COLLISION_REPO/.agents/skills/northstar-question-resolution/owner.txt")" == "operator owned" ]]
[[ ! -e "$COLLISION_REPO/.agents/skills/northstar-research-ingest" ]]
[[ ! -e "$COLLISION_REPO/.agents/skills/northstar-interview" ]]
[[ ! -e "$COLLISION_REPO/.agent-skills/verdify-packs/research-analysis.yaml" ]]
[[ ! -e "$COLLISION_REPO/.agent-skills/verdify-skills/1.3.0" ]]
if [[ -f "$COLLISION_REPO/AGENTS.md" ]]; then
  ! grep -q 'BEGIN VERDIFY SKILL PACKS' "$COLLISION_REPO/AGENTS.md"
fi

ROLLBACK_REPO="$TMP/rollback-project"
make_repo "$ROLLBACK_REPO"
mkdir -p "$ROLLBACK_REPO/.agents/skills/northstar-research-ingest"
printf 'operator link\n' > "$ROLLBACK_REPO/.agents/skills/northstar-research-ingest/owner.txt"
mkdir -p "$ROLLBACK_REPO/.agent-skills/verdify-packs"
printf 'operator manifest\n' > "$ROLLBACK_REPO/.agent-skills/verdify-packs/research-analysis.yaml"
mkdir -p "$ROLLBACK_REPO/.agent-skills/verdify-skills/1.3.0"
printf 'prior same-version install\n' > "$ROLLBACK_REPO/.agent-skills/verdify-skills/1.3.0/operator.txt"
if VERDIFY_TESTING=1 VERDIFY_TEST_PACK_FAILURE=before-manifest \
  $CLI dl research-analysis --repo "$ROLLBACK_REPO" --host codex --force > "$TMP/rollback.out" 2> "$TMP/rollback.err"; then
  echo "expected exact-tarball rollback fixture to fail" >&2
  exit 1
fi
[[ "$(cat "$ROLLBACK_REPO/.agents/skills/northstar-research-ingest/owner.txt")" == "operator link" ]]
[[ "$(cat "$ROLLBACK_REPO/.agent-skills/verdify-packs/research-analysis.yaml")" == "operator manifest" ]]
[[ ! -e "$ROLLBACK_REPO/.agents/skills/northstar-question-resolution" ]]
[[ ! -e "$ROLLBACK_REPO/.agents/skills/northstar-interview" ]]
[[ "$(cat "$ROLLBACK_REPO/.agent-skills/verdify-skills/1.3.0/operator.txt")" == "prior same-version install" ]]

node18_cli() {
  if [[ -n "${VERDIFY_NODE18_BIN:-}" ]]; then
    "$VERDIFY_NODE18_BIN" "$PACKAGE_ROOT/npm/bin/verdify.js" "$@"
  elif command -v fnm >/dev/null && fnm list 2>/dev/null | grep -q 'v18\.'; then
    fnm exec --using=18 node "$PACKAGE_ROOT/npm/bin/verdify.js" "$@"
  else
    npm exec --yes --package=node@18 -- node "$PACKAGE_ROOT/npm/bin/verdify.js" "$@"
  fi
}

node18_cli --version > "$TMP/node18-version.txt"
[[ "$(cat "$TMP/node18-version.txt")" == "1.3.0" ]]
node18_cli pack list --json > "$TMP/node18-packs.json"
ruby -rjson -e 'd=JSON.parse(File.read(ARGV.fetch(0))); abort unless d["count"] == 6' "$TMP/node18-packs.json"

NODE18_REPO="$TMP/node18-project"
make_repo "$NODE18_REPO"
node18_cli init --repo "$NODE18_REPO" > "$TMP/node18-init.log"
node18_cli doctor --repo "$NODE18_REPO" --json > "$TMP/node18-doctor.json" || true
ruby -rjson -e 'd=JSON.parse(File.read(ARGV.fetch(0))); abort unless d["checks"].any? { |check| check["name"] == "agent_workflow_initialized" && check["ok"] }' "$TMP/node18-doctor.json"

NODE18_PACK_REPO="$TMP/node18-pack-project"
make_repo "$NODE18_PACK_REPO"
node18_cli dl research-analysis --repo "$NODE18_PACK_REPO" --host codex > "$TMP/node18-pack.log"
[[ -L "$NODE18_PACK_REPO/.agents/skills/northstar-research-ingest" ]]
[[ -f "$NODE18_PACK_REPO/.agent-skills/verdify-packs/research-analysis.yaml" ]]

NODE18_ROLLBACK_REPO="$TMP/node18-rollback-project"
make_repo "$NODE18_ROLLBACK_REPO"
mkdir -p "$NODE18_ROLLBACK_REPO/.agents/skills/northstar-research-ingest"
printf 'node 18 operator link\n' > "$NODE18_ROLLBACK_REPO/.agents/skills/northstar-research-ingest/owner.txt"
mkdir -p "$NODE18_ROLLBACK_REPO/.agent-skills/verdify-packs"
printf 'node 18 operator manifest\n' > "$NODE18_ROLLBACK_REPO/.agent-skills/verdify-packs/research-analysis.yaml"
if VERDIFY_TESTING=1 VERDIFY_TEST_PACK_FAILURE=before-manifest \
  node18_cli dl research-analysis --repo "$NODE18_ROLLBACK_REPO" --host codex --force \
    > "$TMP/node18-rollback.out" 2> "$TMP/node18-rollback.err"; then
  echo "expected Node 18 rollback fixture to fail" >&2
  exit 1
fi
[[ "$(cat "$NODE18_ROLLBACK_REPO/.agents/skills/northstar-research-ingest/owner.txt")" == "node 18 operator link" ]]
[[ "$(cat "$NODE18_ROLLBACK_REPO/.agent-skills/verdify-packs/research-analysis.yaml")" == "node 18 operator manifest" ]]
[[ ! -e "$NODE18_ROLLBACK_REPO/.agents/skills/northstar-question-resolution" ]]

echo "npm install tests passed."
