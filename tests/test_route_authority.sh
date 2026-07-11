#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

make_repo() {
  local repo="$1"
  mkdir -p "$repo"
  git -C "$repo" init -q -b main
  git -C "$repo" config user.name "Verdify Test"
  git -C "$repo" config user.email "verdify-test@example.invalid"
  printf '# Route authority fixture\n' > "$repo/README.md"
  git -C "$repo" add README.md
  git -C "$repo" commit -qm "initial"
  "$ROOT/bin/verdify" init --repo "$repo" >/dev/null
}

copy_foundations() {
  local repo="$1"
  mkdir -p \
    "$repo/.agent-workflow/project" \
    "$repo/.agent-workflow/architecture" \
    "$repo/.agent-workflow/modules/contracts"
  cp "$ROOT/examples/minimal-project/.agent-workflow/project/project-definition.yaml" \
    "$repo/.agent-workflow/project/project-definition.yaml"
  cp "$ROOT/examples/minimal-project/.agent-workflow/architecture/architecture.yaml" \
    "$repo/.agent-workflow/architecture/architecture.yaml"
  cp "$ROOT/examples/minimal-project/.agent-workflow/modules/contracts/api-adapter.contract.yaml" \
    "$repo/.agent-workflow/modules/contracts/api-adapter.contract.yaml"
}

assert_route() {
  local repo="$1"
  local expected_state="$2"
  local expected_skill="$3"
  local expected_mode="$4"
  local output="$5"
  "$ROOT/bin/verdify" route --repo "$repo" --json > "$output"
  ruby -rjson -e '
    route = JSON.parse(File.read(ARGV.fetch(0)))
    expected = ARGV.drop(1)
    actual = route.values_at("current_state", "next_skill", "next_mode")
    abort "expected #{expected.inspect}, got #{actual.inspect}" unless actual == expected
  ' "$output" "$expected_state" "$expected_skill" "$expected_mode"
}

write_wrong_schema() {
  local path="$1"
  mkdir -p "$(dirname "$path")"
  printf '%s\n' \
    '---' \
    'schema_ref: route-decision.schema.yaml' \
    'kind: RouteDecision' \
    "marker: route-authority-private-sentinel" > "$path"
}

write_valid_intake() {
  local path="$1"
  mkdir -p "$(dirname "$path")"
  printf '%s\n' \
    '---' \
    'schema_ref: transcript-replan.schema.yaml' \
    'kind: TranscriptReplan' \
    "schema_version: '1.0'" \
    'source_id: route-authority-fixture' \
    'status: routed' \
    "generated_at: '2026-07-10T00:00:00Z'" \
    'repositories: [example/route-authority]' \
    'items: []' \
    'conflicts: []' \
    'proposed_artifact_changes: []' \
    'issue_recommendations: []' \
    'gate_recommendations: []' \
    'handoff:' \
    '  next_skill: northstar-planning' \
    '  next_mode: intake' \
    '  reason: Route the fixture.' \
    'approval:' \
    '  status: pending' \
    '  approver: null' \
    '  approved_at: null' > "$path"
}

write_strategy() {
  local repo="$1"
  local baseline="$2"
  local mode="$3"
  local skill="${4:-sprint-planning}"
  mkdir -p "$repo/.agent-workflow/strategy"
  cp "$ROOT/examples/minimal-project/.agent-workflow/strategy/state-of-union.yaml" \
    "$repo/.agent-workflow/strategy/state-of-union.yaml"
  ruby -ryaml -e '
    path, baseline, mode, skill = ARGV
    strategy = YAML.safe_load(File.read(path), permitted_classes: [], aliases: false)
    strategy["baseline_sha"] = baseline
    strategy["handoff"]["next_skill"] = skill
    strategy["handoff"]["next_mode"] = mode
    File.write(path, YAML.dump(strategy))
  ' "$repo/.agent-workflow/strategy/state-of-union.yaml" "$baseline" "$mode" "$skill"
}

# Every upstream authority caller uses a fixed expected schema and routes a
# substituted document to the artifact's producer without echoing artifact data.
declare -a matrix=(
  'transcript|.agent-workflow/intake/transcript-replan.yaml|TRANSCRIPT_REPLAN_INVALID|transcript-replan|ingest'
  'registry|.agent-workflow/northstar/evidence-registry.yaml|NORTHSTAR_EVIDENCE_REGISTRY_INVALID|northstar-research-ingest|ingest-research'
  'project|.agent-workflow/project/project-definition.yaml|PROJECT_DEFINITION_INVALID|project-definition|discovery'
)
for row in "${matrix[@]}"; do
  IFS='|' read -r name relative state skill mode <<< "$row"
  repo="$TMP/$name"
  make_repo "$repo"
  write_wrong_schema "$repo/$relative"
  assert_route "$repo" "$state" "$skill" "$mode" "$TMP/$name.json"
  ! grep -q 'route-authority-private-sentinel' "$TMP/$name.json"
  grep -q 'expected_schema=' "$TMP/$name.json"
done

PLAN_REPO="$TMP/northstar-plan"
make_repo "$PLAN_REPO"
write_valid_intake "$PLAN_REPO/.agent-workflow/intake/transcript-replan.yaml"
write_wrong_schema "$PLAN_REPO/.agent-workflow/northstar/northstar-plan.yaml"
assert_route "$PLAN_REPO" NORTHSTAR_PLAN_INVALID northstar-planning synthesis "$TMP/northstar-plan.json"

ARTIFACT_REPO="$TMP/northstar-artifacts"
make_repo "$ARTIFACT_REPO"
mkdir -p "$ARTIFACT_REPO/.agent-workflow/intake" "$ARTIFACT_REPO/.agent-workflow/northstar"
write_valid_intake "$ARTIFACT_REPO/.agent-workflow/intake/transcript-replan.yaml"
printf '# Product\n' > "$ARTIFACT_REPO/.agent-workflow/northstar/NORTHSTAR_PRODUCT.md"
printf '# Architecture\n' > "$ARTIFACT_REPO/.agent-workflow/northstar/NORTHSTAR_ARCHITECTURE.md"
write_wrong_schema "$ARTIFACT_REPO/.agent-workflow/northstar/northstar-artifacts.yaml"
assert_route "$ARTIFACT_REPO" NORTHSTAR_ARTIFACTS_INVALID northstar-planning artifact-loop "$TMP/northstar-artifacts.json"

ARCH_REPO="$TMP/architecture"
make_repo "$ARCH_REPO"
copy_foundations "$ARCH_REPO"
write_wrong_schema "$ARCH_REPO/.agent-workflow/architecture/architecture.yaml"
assert_route "$ARCH_REPO" ARCHITECTURE_INVALID architecture-contracts north-star-architecture "$TMP/architecture.json"

MODULE_REPO="$TMP/module"
make_repo "$MODULE_REPO"
copy_foundations "$MODULE_REPO"
write_wrong_schema "$MODULE_REPO/.agent-workflow/modules/contracts/api-adapter.contract.yaml"
assert_route "$MODULE_REPO" MODULE_CONTRACT_INVALID architecture-contracts module-contracts "$TMP/module.json"

STRATEGY_REPO="$TMP/strategy"
make_repo "$STRATEGY_REPO"
copy_foundations "$STRATEGY_REPO"
write_wrong_schema "$STRATEGY_REPO/.agent-workflow/strategy/state-of-union.yaml"
assert_route "$STRATEGY_REPO" STATE_OF_UNION_INVALID state-of-union strategy-review "$TMP/strategy.json"

HYGIENE_REPO="$TMP/hygiene"
make_repo "$HYGIENE_REPO"
copy_foundations "$HYGIENE_REPO"
write_wrong_schema "$HYGIENE_REPO/.agent-workflow/hygiene/repo-hygiene.yaml"
git -C "$HYGIENE_REPO" add .agent-workflow
git -C "$HYGIENE_REPO" commit -qm "seed foundation and invalid hygiene"
HYGIENE_BASE="$(git -C "$HYGIENE_REPO" rev-parse HEAD)"
write_strategy "$HYGIENE_REPO" "$HYGIENE_BASE" issue-readiness
git -C "$HYGIENE_REPO" add .agent-workflow/strategy/state-of-union.yaml
git -C "$HYGIENE_REPO" commit -qm "approve strategy"
assert_route "$HYGIENE_REPO" REPO_HYGIENE_INVALID repo-hygiene assess "$TMP/hygiene.json"

# Invalid YAML, missing required fields, and semantic invalidity are distinct
# fail-closed inputs. No parser text or fixture marker reaches route evidence.
YAML_REPO="$TMP/invalid-yaml"
make_repo "$YAML_REPO"
mkdir -p "$YAML_REPO/.agent-workflow/project"
printf 'schema_ref: project-definition.schema.yaml\nkind: [route-yaml-private-sentinel\n' \
  > "$YAML_REPO/.agent-workflow/project/project-definition.yaml"
assert_route "$YAML_REPO" PROJECT_DEFINITION_INVALID project-definition discovery "$TMP/invalid-yaml.json"
grep -q 'type=parse_invalid' "$TMP/invalid-yaml.json"
! grep -q 'route-yaml-private-sentinel' "$TMP/invalid-yaml.json"

MISSING_REPO="$TMP/missing-field"
make_repo "$MISSING_REPO"
copy_foundations "$MISSING_REPO"
ruby -ryaml -e '
  path = ARGV.fetch(0)
  project = YAML.safe_load(File.read(path), permitted_classes: [], aliases: false)
  project.delete("requirements")
  File.write(path, YAML.dump(project))
' "$MISSING_REPO/.agent-workflow/project/project-definition.yaml"
assert_route "$MISSING_REPO" PROJECT_DEFINITION_INVALID project-definition discovery "$TMP/missing-field.json"

SEMANTIC_REPO="$TMP/semantic"
make_repo "$SEMANTIC_REPO"
copy_foundations "$SEMANTIC_REPO"
ruby -ryaml -e '
  path = ARGV.fetch(0)
  project = YAML.safe_load(File.read(path), permitted_classes: [], aliases: false)
  project["stage_status"]["discovery"] = "draft"
  File.write(path, YAML.dump(project))
' "$SEMANTIC_REPO/.agent-workflow/project/project-definition.yaml"
assert_route "$SEMANTIC_REPO" PROJECT_DEFINITION_INVALID project-definition discovery "$TMP/semantic.json"
grep -q 'type=semantic_invalid' "$TMP/semantic.json"

# Valid foundations preserve the prior first-missing route.
VALID_REPO="$TMP/valid"
make_repo "$VALID_REPO"
copy_foundations "$VALID_REPO"
assert_route "$VALID_REPO" STATE_OF_UNION_MISSING state-of-union strategy-review "$TMP/valid.json"

# A schema-valid and globally declared pair that is unreachable from
# REVIEW_STRATEGY routes back to its producer instead of entering implementation.
HANDOFF_REPO="$TMP/handoff"
make_repo "$HANDOFF_REPO"
copy_foundations "$HANDOFF_REPO"
git -C "$HANDOFF_REPO" add .agent-workflow
git -C "$HANDOFF_REPO" commit -qm "seed approved foundations"
HANDOFF_BASE="$(git -C "$HANDOFF_REPO" rev-parse HEAD)"
write_strategy "$HANDOFF_REPO" "$HANDOFF_BASE" implementation lane-delivery
git -C "$HANDOFF_REPO" add .agent-workflow/strategy/state-of-union.yaml
git -C "$HANDOFF_REPO" commit -qm "record invalid handoff"
assert_route "$HANDOFF_REPO" STATE_OF_UNION_HANDOFF_INVALID state-of-union strategy-review "$TMP/handoff-invalid.json"

# An allowed target skill still needs a declared mode.
MODE_REPO="$TMP/invalid-handoff-mode"
make_repo "$MODE_REPO"
copy_foundations "$MODE_REPO"
git -C "$MODE_REPO" add .agent-workflow
git -C "$MODE_REPO" commit -qm "seed approved foundations"
MODE_BASE="$(git -C "$MODE_REPO" rev-parse HEAD)"
write_strategy "$MODE_REPO" "$MODE_BASE" impossible-mode
git -C "$MODE_REPO" add .agent-workflow/strategy/state-of-union.yaml
git -C "$MODE_REPO" commit -qm "record invalid handoff mode"
assert_route "$MODE_REPO" STATE_OF_UNION_HANDOFF_INVALID state-of-union strategy-review "$TMP/handoff-invalid-mode.json"

LEGAL_REPO="$TMP/legal-handoff"
make_repo "$LEGAL_REPO"
copy_foundations "$LEGAL_REPO"
git -C "$LEGAL_REPO" add .agent-workflow
git -C "$LEGAL_REPO" commit -qm "seed approved foundations"
LEGAL_BASE="$(git -C "$LEGAL_REPO" rev-parse HEAD)"
write_strategy "$LEGAL_REPO" "$LEGAL_BASE" issue-readiness
git -C "$LEGAL_REPO" add .agent-workflow/strategy/state-of-union.yaml
git -C "$LEGAL_REPO" commit -qm "record legal handoff"
assert_route "$LEGAL_REPO" REPO_HYGIENE_MISSING repo-hygiene assess "$TMP/handoff-valid.json"

# REVIEW_STRATEGY's complete target-skill set comes from the workflow graph.
# Every mode declared for those targets is legal; every other lifecycle skill
# remains illegal even when its mode is globally valid.
ruby -I"$ROOT/lib" -rverdify -ryaml -e '
  cli = Verdify::CLI.new([])
  producer = "REVIEW_STRATEGY"
  expected = %w[
    architecture-contracts gravity-readiness platform-readiness
    project-definition project-router repo-hygiene sprint-planning
  ].sort
  actual = cli.send(:workflow_transition_target_skills, producer).sort
  abort "workflow target mismatch: #{actual.inspect}" unless actual == expected

  lifecycle = YAML.safe_load(File.read(File.join(ARGV.fetch(0), "config/lifecycle.yaml")), permitted_classes: [], aliases: false)
  modes = Array(lifecycle["skills"]).to_h { |entry| [entry.fetch("name"), Array(entry.fetch("modes"))] }
  expected.each do |skill|
    modes.fetch(skill).each do |mode|
      abort "expected legal #{skill}/#{mode}" unless cli.send(:legal_workflow_handoff?, producer, skill, mode)
    end
  end
  (modes.keys - expected).each do |skill|
    modes.fetch(skill).each do |mode|
      abort "expected illegal #{skill}/#{mode}" if cli.send(:legal_workflow_handoff?, producer, skill, mode)
    end
  end
' "$ROOT"

# Route views are ignored derived cache. YAML and Markdown agree on every stable
# authority field, while the volatile generation timestamp is YAML-only.
CACHE_REPO="$TMP/cache"
make_repo "$CACHE_REPO"
"$ROOT/bin/verdify" route --repo "$CACHE_REPO" --write --json > "$TMP/cache-route.json"
"$ROOT/bin/verdify" artifact validate \
  --file "$CACHE_REPO/.agent-workflow/router/route-decision.yaml" >/dev/null
git -C "$CACHE_REPO" check-ignore -q .agent-workflow/router/route-decision.yaml
git -C "$CACHE_REPO" check-ignore -q .agent-workflow/router/route-decision.md
test -z "$(git -C "$CACHE_REPO" ls-files .agent-workflow/router/route-decision.yaml .agent-workflow/router/route-decision.md)"
ruby -ryaml -e '
  yaml_path, markdown_path = ARGV
  route = YAML.safe_load(File.read(yaml_path), permitted_classes: [], aliases: false)
  markdown = File.read(markdown_path)
  expected = {
    "current_state" => markdown[/^- Current state: `([^`]+)`$/, 1],
    "next_skill" => markdown[/^- Next skill: `([^`]+)`$/, 1],
    "next_mode" => markdown[/^- Next mode: `([^`]+)`$/, 1]
  }
  expected.each { |field, value| abort "#{field} mismatch" unless route[field] == value }
  abort "reason mismatch" unless markdown.include?("\n#{route.fetch("reason")}\n")
  abort "generated_at became Markdown authority" if markdown.include?(route.fetch("generated_at")) || markdown.include?("generated_at")
' "$CACHE_REPO/.agent-workflow/router/route-decision.yaml" \
  "$CACHE_REPO/.agent-workflow/router/route-decision.md"

# Repository validation must reject either cache path if a future commit adds it
# back. A temporary index proves the guard without mutating the worker index.
test -z "$(git -C "$ROOT" ls-files .agent-workflow/router/route-decision.yaml .agent-workflow/router/route-decision.md)"
TEMP_INDEX="$TMP/retracked.index"
GIT_INDEX_FILE="$TEMP_INDEX" git -C "$ROOT" read-tree HEAD
BLOB="$(printf '%s\n' 'derived route fixture' | git -C "$ROOT" hash-object -w --stdin)"
GIT_INDEX_FILE="$TEMP_INDEX" git -C "$ROOT" update-index \
  --add --cacheinfo "100644,$BLOB,.agent-workflow/router/route-decision.yaml"
if GIT_INDEX_FILE="$TEMP_INDEX" ruby "$ROOT/scripts/validate-repo.rb" > "$TMP/retracked.out" 2> "$TMP/retracked.err"; then
  echo "expected repository validation to reject a tracked route cache" >&2
  exit 1
fi
grep -q 'derived route cache must be ignored and untracked' "$TMP/retracked.out"

echo "Route authority validation regression passed."
