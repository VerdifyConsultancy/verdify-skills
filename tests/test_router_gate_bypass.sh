#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

REPO="$TMP/project-definition-gate"
mkdir -p "$REPO"
git -C "$REPO" init -q -b main
git -C "$REPO" config user.name "Verdify Test"
git -C "$REPO" config user.email "verdify-test@example.invalid"
printf '# Project definition gate test\n' > "$REPO/README.md"
git -C "$REPO" add README.md
git -C "$REPO" commit -qm "initial"

"$ROOT/bin/verdify" init --repo "$REPO" >/dev/null
mkdir -p "$REPO/.agent-workflow/project"
cp "$ROOT/examples/minimal-project/.agent-workflow/project/project-definition.yaml" \
  "$REPO/.agent-workflow/project/project-definition.yaml"

ruby -ryaml -e '
  path = ARGV[0]
  project = YAML.safe_load(File.read(path), permitted_classes: [], aliases: false)
  project["status"] = "draft"
  project["stage_status"] = {
    "discovery" => "approved",
    "requirements" => "approved",
    "product" => "approved",
    "design_surface" => "approved"
  }
  project["approval"] = {"status" => "pending", "approver" => nil, "approved_at" => nil}
  File.write(path, YAML.dump(project))
' "$REPO/.agent-workflow/project/project-definition.yaml"

"$ROOT/bin/verdify" route --repo "$REPO" --write --json > "$TMP/self-cert-route.json"
ruby -rjson -e '
  route = JSON.parse(File.read(ARGV[0]))
  abort "expected PROJECT_DEFINITION_GATE, got #{route["current_state"]}" unless route["current_state"] == "PROJECT_DEFINITION_GATE"
  abort "expected project-definition, got #{route["next_skill"]}" unless route["next_skill"] == "project-definition"
  abort "expected gate-resolution, got #{route["next_mode"]}" unless route["next_mode"] == "gate-resolution"
  abort "must not advance to architecture-contracts" if route["next_skill"] == "architecture-contracts"
' "$TMP/self-cert-route.json"
"$ROOT/bin/verdify" artifact validate --file "$REPO/.agent-workflow/router/route-decision.yaml" >/dev/null

mkdir -p "$REPO/.agent-workflow/gates"
ruby -ryaml -rtime -e '
  path = ARGV[0]
  now = Time.now.utc.iso8601
  gate = {
    "schema_ref" => "human-gate.schema.yaml",
    "kind" => "HumanGate",
    "schema_version" => "1.0",
    "gate_id" => "project-definition-approval",
    "sprint_id" => nil,
    "lane_id" => nil,
    "type" => "project_definition",
    "status" => "approved",
    "question" => "Is the project definition approved for downstream architecture?",
    "owner" => "outcome_owner",
    "evidence_required" => ["project-definition review"],
    "allowed_decisions" => ["approved", "rejected"],
    "decision" => "approved",
    "rationale" => "Test approval gate.",
    "opened_at" => now,
    "resolved_at" => now,
    "resume_state" => "project-definition gate resolved"
  }
  File.write(path, YAML.dump(gate))
' "$REPO/.agent-workflow/gates/project-definition.yaml"

"$ROOT/bin/verdify" route --repo "$REPO" --json > "$TMP/gate-approved-route.json"
ruby -rjson -e '
  route = JSON.parse(File.read(ARGV[0]))
  abort "expected architecture handoff after approved gate, got #{route["current_state"]}" unless route["current_state"] == "ARCHITECTURE_INCOMPLETE"
  abort "expected architecture-contracts, got #{route["next_skill"]}" unless route["next_skill"] == "architecture-contracts"
' "$TMP/gate-approved-route.json"

echo "Router project-definition gate bypass regression passed."
