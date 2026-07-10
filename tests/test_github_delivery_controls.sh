#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
MOCK="$TMP/mock"
REPO_DIR="$MOCK/VerdifyConsultancy_verdify-skills"
SNAPSHOT="$TMP/pre-release-snapshot.json"
mkdir -p "$REPO_DIR"

cat > "$REPO_DIR/main.json" <<'JSON'
{
  "required_status_checks": {"strict": true, "contexts": ["validate", "pull-request-policy", "compliance / compliance"]},
  "enforce_admins": {"enabled": false},
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": false,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 0,
    "require_last_push_approval": false
  },
  "restrictions": {
    "users": [{"login": "legacy-owner"}],
    "teams": [{"slug": "legacy-team"}],
    "apps": [{"slug": "legacy-app"}]
  },
  "required_conversation_resolution": {"enabled": false},
  "allow_force_pushes": {"enabled": false},
  "allow_deletions": {"enabled": false}
}
JSON
cp "$REPO_DIR/main.json" "$TMP/main.before.json"

CONTROL=(ruby "$ROOT/scripts/github-delivery-controls.rb" --repository VerdifyConsultancy/verdify-skills --mock-api "$MOCK")

ruby -ryaml -e '
  root = ARGV.fetch(0)
  owner_logins = %w[@jvallery @jrvallery]
  entries = File.readlines(File.join(root, ".github/CODEOWNERS"), chomp: true).filter_map do |line|
    line = line.strip
    next if line.empty? || line.start_with?("#")
    pattern, *owners = line.split
    abort "unexpected CODEOWNERS owner set" unless owners == owner_logins
    [pattern.delete_prefix("/"), owners]
  end
  matcher = lambda do |path|
    entries.select do |pattern, _owners|
      pattern.end_with?("/**") ? path.start_with?(pattern.delete_suffix("**")) : path == pattern
    end.last
  end
  protected_paths = %w[
    .github/CODEOWNERS
    .github/workflows/delivery-gate.yml
    .github/workflows/new/no-op-critic-gate.yml
    config/github-delivery-controls.yaml
    config/github-primitives.yaml
    lib/verdify.rb
    lib/verdify/lane_review_validator.rb
    schemas/critic-report.schema.yaml
    scripts/delivery-gate.rb
    scripts/github-delivery-controls.rb
    scripts/pr-policy.rb
    scripts/validate-repo.rb
  ]
  protected_paths.each { |path| abort "unowned protected path: #{path}" unless matcher.call(path)&.last == owner_logins }
  %w[README.md docs/guide.md skills/example/SKILL.md implementation.txt].each do |path|
    abort "ordinary lane path unexpectedly owned: #{path}" if matcher.call(path)
  end

  controls = YAML.safe_load_file(File.join(root, "config/github-delivery-controls.yaml"), permitted_classes: [], aliases: false)
  restrictions = {"users"=>%w[jvallery jrvallery], "teams"=>[], "apps"=>[]}
  controls.fetch("phases").each_value do |phase|
    dev = phase.fetch("branches").fetch("dev")
    main = phase.fetch("branches").fetch("main")
    dev_reviews = dev.fetch("required_pull_request_reviews")
    main_reviews = main.fetch("required_pull_request_reviews")
    abort unless dev_reviews.values_at("required_approving_review_count", "dismiss_stale_reviews", "require_code_owner_reviews") == [0, true, true]
    abort unless main_reviews.values_at("required_approving_review_count", "dismiss_stale_reviews", "require_code_owner_reviews") == [1, true, true]
    abort unless dev.fetch("restrictions") == restrictions && main.fetch("restrictions") == restrictions
    abort unless dev.dig("required_status_checks", "contexts").include?("critic-gate")
    # A candidate no-op critic-gate rewrite hits CODEOWNERS and cannot satisfy
    # either branch rule without an owner review. Ordinary paths remain
    # unowned, zero-review, and still require critic-gate on dev.
    abort unless matcher.call(".github/workflows/delivery-gate.yml") && dev_reviews["require_code_owner_reviews"]
    abort unless main_reviews["require_code_owner_reviews"] && main_reviews["required_approving_review_count"] == 1
    abort if matcher.call("implementation.txt")
  end
' "$ROOT"

"${CONTROL[@]}" --phase pre-release --mode dry-run > "$TMP/dry-run.json"
ruby -rjson -e '
  d=JSON.parse(File.read(ARGV.fetch(0)))
  abort unless d["mode"] == "dry-run" && d["matches"] == false
  abort unless d["branches"].all? { |branch| branch["changed"] }
' "$TMP/dry-run.json"
cmp "$TMP/main.before.json" "$REPO_DIR/main.json"
[[ ! -e "$REPO_DIR/dev.json" ]]

if "${CONTROL[@]}" --phase pre-release --mode verify > /dev/null 2>&1; then
  echo "expected verify to fail before apply" >&2
  exit 1
fi
if "${CONTROL[@]}" --phase pre-release --mode apply --snapshot "$SNAPSHOT" > /dev/null 2>&1; then
  echo "expected apply without repository confirmation to fail" >&2
  exit 1
fi

"${CONTROL[@]}" --phase pre-release --mode apply \
  --confirm-repository VerdifyConsultancy/verdify-skills \
  --snapshot "$SNAPSHOT" > "$TMP/apply.json"
"${CONTROL[@]}" --phase pre-release --mode verify > "$TMP/verify.json"
ruby -rjson -e '
  apply=JSON.parse(File.read(ARGV.fetch(0)))
  verify=JSON.parse(File.read(ARGV.fetch(1)))
  abort unless apply["matches"] && verify["matches"]
  dev=verify["branches"].find { |branch| branch["branch"] == "dev" }.fetch("desired")
  main=verify["branches"].find { |branch| branch["branch"] == "main" }.fetch("desired")
  abort unless dev.dig("required_pull_request_reviews", "required_approving_review_count") == 0
  abort unless dev.dig("required_pull_request_reviews", "dismiss_stale_reviews") == true
  abort unless dev.dig("required_pull_request_reviews", "require_code_owner_reviews") == true
  abort unless dev.dig("required_status_checks", "contexts") == ["compliance / compliance", "critic-gate", "pull-request-policy", "validate"]
  abort unless main.dig("required_pull_request_reviews", "required_approving_review_count") == 1
  abort unless main.dig("required_pull_request_reviews", "dismiss_stale_reviews") == true
  abort unless main.dig("required_pull_request_reviews", "require_code_owner_reviews") == true
  abort unless main.dig("required_status_checks", "contexts") == ["compliance / compliance", "critic-gate", "delivery-policy", "validate"]
  [dev, main].each do |branch|
    abort unless branch["enforce_admins"] && branch["required_conversation_resolution"]
    abort unless branch["allow_force_pushes"] == false && branch["allow_deletions"] == false
    abort unless branch["restrictions"] == {"users"=>%w[jrvallery jvallery], "teams"=>[], "apps"=>[]}
  end
' "$TMP/apply.json" "$TMP/verify.json"

SNAPSHOT_HASH="$(shasum -a 256 "$SNAPSHOT" | cut -d' ' -f1)"
"${CONTROL[@]}" --phase pre-release --mode apply \
  --confirm-repository VerdifyConsultancy/verdify-skills \
  --snapshot "$SNAPSHOT" > "$TMP/second-apply.json"
[[ "$SNAPSHOT_HASH" == "$(shasum -a 256 "$SNAPSHOT" | cut -d' ' -f1)" ]]
ruby -rjson -e '
  d=JSON.parse(File.read(ARGV.fetch(0)))
  abort unless d["matches"] && d["branches"].none? { |branch| branch["changed"] }
' "$TMP/second-apply.json"

"${CONTROL[@]}" --phase steady-state --mode dry-run > "$TMP/steady-dry-run.json"
ruby -rjson -e '
  d=JSON.parse(File.read(ARGV.fetch(0)))
  dev=d["branches"].find { |branch| branch["branch"] == "dev" }
  main=d["branches"].find { |branch| branch["branch"] == "main" }
  abort unless dev["changed"] == false && main["changed"] == true
  abort unless main.dig("desired", "required_status_checks", "contexts").include?("pull-request-policy")
' "$TMP/steady-dry-run.json"
"${CONTROL[@]}" --phase steady-state --mode apply \
  --confirm-repository VerdifyConsultancy/verdify-skills \
  --snapshot "$TMP/steady-snapshot.json" > "$TMP/steady-apply.json"
"${CONTROL[@]}" --phase steady-state --mode verify > /dev/null

"${CONTROL[@]}" --phase pre-release --mode rollback \
  --confirm-repository VerdifyConsultancy/verdify-skills \
  --snapshot "$SNAPSHOT" > "$TMP/rollback.json"
ruby -rjson -e 'd=JSON.parse(File.read(ARGV.fetch(0))); abort unless d["matches"]' "$TMP/rollback.json"
[[ ! -e "$REPO_DIR/dev.json" ]]
ruby -rjson -e '
  d=JSON.parse(File.read(ARGV.fetch(0)))
  abort unless d.dig("enforce_admins") == false
  abort unless d.dig("required_pull_request_reviews", "required_approving_review_count") == 0
  abort unless d.dig("required_status_checks", "contexts") == ["compliance / compliance", "pull-request-policy", "validate"]
  abort unless d["restrictions"] == {"users"=>["legacy-owner"], "teams"=>["legacy-team"], "apps"=>["legacy-app"]}
' "$REPO_DIR/main.json"

echo "GitHub delivery control tests passed."
