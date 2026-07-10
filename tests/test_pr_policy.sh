#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
BASE="1111111111111111111111111111111111111111"
HEAD="2222222222222222222222222222222222222222"
IMPL="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
EVID="bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"

cat > "$TMP/valid.md" <<EOF
## Backlog issue

Closes #123

## Lane contract

- Sprint: \`sprint-a\`
- Lane: \`issue-123-api\`
- Contract: \`.agent-workflow/sprints/sprint-a/lanes/contracts/issue-123-api.contract.yaml\`
- Baseline SHA: \`$BASE\`

## Outcome

Operators can identify the running revision.

## Scope proof

Only owned API and test paths changed.

## Evidence

The required test and check passed against the current head.

Implementation head SHA: \`$IMPL\`

Evidence head SHA: \`$EVID\`

Current head SHA: \`$HEAD\`

## Risk and deployment impact

Staging verification remains required.
EOF

ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/valid.md" --base "$BASE" --head "$HEAD"

# With --repo (the CI path), policy binds body metadata to committed v2
# artifacts and the implementation -> closeout -> critic Git chain.
EVIDENCE_REPO="$TMP/evidence-repo"
mkdir -p "$EVIDENCE_REPO"
git -C "$EVIDENCE_REPO" init -q -b main
git -C "$EVIDENCE_REPO" config user.name "Verdify Test"
git -C "$EVIDENCE_REPO" config user.email "verdify-test@example.invalid"
printf '# Evidence repo\n' > "$EVIDENCE_REPO/README.md"
git -C "$EVIDENCE_REPO" add README.md
git -C "$EVIDENCE_REPO" commit -qm "baseline"
CHAIN_BASE="$(git -C "$EVIDENCE_REPO" rev-parse HEAD)"
CHAIN_CONTRACT=".agent-workflow/sprints/sprint-a/lanes/contracts/issue-123-api.contract.yaml"
mkdir -p "$EVIDENCE_REPO/.agent-workflow/sprints/sprint-a/lanes/contracts"
ruby -ryaml -e '
  source, destination, baseline = ARGV
  document = YAML.safe_load(File.read(source), permitted_classes: [], aliases: false)
  document["sprint_id"] = "sprint-a"
  document["baseline_sha"] = baseline
  document["branch"] = "main"
  document["approval"] = {"status"=>"approved", "approver"=>"owner", "approved_at"=>"2026-07-09T00:00:00Z"}
  File.write(destination, YAML.dump(document))
' "$ROOT/examples/minimal-project/.agent-workflow/sprints/2026-06-22-a/lanes/contracts/issue-123-api.contract.yaml" \
  "$EVIDENCE_REPO/$CHAIN_CONTRACT" "$CHAIN_BASE"
git -C "$EVIDENCE_REPO" add "$CHAIN_CONTRACT"
git -C "$EVIDENCE_REPO" commit -qm "approved dispatch"
printf 'implemented\n' > "$EVIDENCE_REPO/implementation.txt"
git -C "$EVIDENCE_REPO" add implementation.txt
git -C "$EVIDENCE_REPO" commit -qm "implementation"
CHAIN_IMPL="$(git -C "$EVIDENCE_REPO" rev-parse HEAD)"
CHAIN_CLOSEOUT=".agent-workflow/sprints/sprint-a/lanes/closeout/issue-123-api.closeout.yaml"
mkdir -p "$EVIDENCE_REPO/.agent-workflow/sprints/sprint-a/lanes/closeout"
ruby -rdigest -ryaml -e '
  destination, contract, baseline, implementation = ARGV
  document = {
    "schema_ref"=>"lane-closeout.schema.yaml", "kind"=>"LaneCloseout", "schema_version"=>"2.0",
    "sprint_id"=>"sprint-a", "lane_id"=>"issue-123-api", "status"=>"ready_for_critic",
    "issue_ids"=>[123], "pull_request"=>123, "baseline_sha"=>baseline,
    "implementation_head_sha"=>implementation, "validated_head_sha"=>implementation,
    "contract_hash"=>Digest::SHA256.file(contract).hexdigest, "changed_paths"=>["implementation.txt"],
    "validation_results"=>[{"id"=>"test", "command"=>"true", "exit_status"=>0, "result"=>"passed", "executed_at"=>"2026-07-09T00:01:00Z", "artifact"=>nil}],
    "acceptance_evidence"=>[{"criterion_id"=>"LANE-AC-01", "evidence_ids"=>["test"], "assessment"=>"satisfied"}],
    "discovered_issues"=>[], "residual_risks"=>[], "worktree_clean"=>true,
    "worker_agent"=>"worker-agent", "worker_session_id"=>"worker-session",
    "completed_at"=>"2026-07-09T00:02:00Z", "limitations"=>[]
  }
  File.write(destination, YAML.dump(document))
' "$EVIDENCE_REPO/$CHAIN_CLOSEOUT" "$EVIDENCE_REPO/$CHAIN_CONTRACT" "$CHAIN_BASE" "$CHAIN_IMPL"
git -C "$EVIDENCE_REPO" add "$CHAIN_CLOSEOUT"
git -C "$EVIDENCE_REPO" commit -qm "closeout evidence"
CHAIN_EVID="$(git -C "$EVIDENCE_REPO" rev-parse HEAD)"
cp "$TMP/valid.md" "$TMP/chain.md"
ruby -e 'base, implementation, evidence, path = ARGV; text = File.read(path); text.sub!(/^- Baseline SHA: `[^`]+`$/, "- Baseline SHA: `#{base}`"); text.sub!(/^Implementation head SHA: `[^`]+`$/, "Implementation head SHA: `#{implementation}`"); text.sub!(/^Evidence head SHA: `[^`]+`$/, "Evidence head SHA: `#{evidence}`"); text.sub!(/^Current head SHA: `[^`]+`$/, "Current head SHA: `#{evidence}`"); File.write(path, text)' "$CHAIN_BASE" "$CHAIN_IMPL" "$CHAIN_EVID" "$TMP/chain.md"
ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/chain.md" --base "$CHAIN_BASE" --head "$CHAIN_EVID" --repo "$EVIDENCE_REPO"

cp "$TMP/chain.md" "$TMP/missing-evidence-commit.md"
ruby -0pi -e 'sub(/^Evidence head SHA: `[^`]+`$/, "Evidence head SHA: `cccccccccccccccccccccccccccccccccccccccc`")' "$TMP/missing-evidence-commit.md"
if ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/missing-evidence-commit.md" --base "$CHAIN_BASE" --head "$CHAIN_EVID" --repo "$EVIDENCE_REPO" >/dev/null 2>&1; then
  echo "expected repo-aware PR policy to reject a nonexistent evidence commit" >&2
  exit 1
fi

CHAIN_CRITIC=".agent-workflow/sprints/sprint-a/critic/issue-123-api.critic.yaml"
mkdir -p "$EVIDENCE_REPO/.agent-workflow/sprints/sprint-a/critic"
ruby -rdigest -ryaml -e '
  destination, closeout, implementation, evidence = ARGV
  document = {
    "schema_ref"=>"critic-report.schema.yaml", "kind"=>"CriticReport", "schema_version"=>"2.0",
    "sprint_id"=>"sprint-a", "lane_id"=>"issue-123-api", "pull_request"=>123,
    "worker_agent"=>"worker-agent", "worker_session_id"=>"worker-session",
    "critic_agent"=>"critic-agent", "critic_session_id"=>"critic-session",
    "implementation_head_sha"=>implementation, "evidence_head_sha"=>evidence, "reviewed_head_sha"=>evidence,
    "closeout_path"=>".agent-workflow/sprints/sprint-a/lanes/closeout/issue-123-api.closeout.yaml",
    "closeout_sha256"=>Digest::SHA256.file(closeout).hexdigest, "review_worktree"=>"/tmp/review",
    "outcome"=>"approve", "findings"=>[],
    "acceptance_assessment"=>[{"criterion_id"=>"LANE-AC-01", "assessment"=>"satisfied", "evidence"=>["test"]}],
    "evidence_assessment"=>["valid"], "integration_risks"=>[], "residual_risks"=>[],
    "reviewed_at"=>"2026-07-09T00:03:00Z"
  }
  File.write(destination, YAML.dump(document))
' "$EVIDENCE_REPO/$CHAIN_CRITIC" "$EVIDENCE_REPO/$CHAIN_CLOSEOUT" "$CHAIN_IMPL" "$CHAIN_EVID"
git -C "$EVIDENCE_REPO" add "$CHAIN_CRITIC"
git -C "$EVIDENCE_REPO" commit -qm "critic evidence"
CHAIN_REPORT="$(git -C "$EVIDENCE_REPO" rev-parse HEAD)"
ruby -e 'head, path = ARGV; text = File.read(path); text.sub!(/^Current head SHA: `[^`]+`$/, "Current head SHA: `#{head}`"); File.write(path, text)' "$CHAIN_REPORT" "$TMP/chain.md"
ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/chain.md" --base "$CHAIN_BASE" --head "$CHAIN_REPORT" --repo "$EVIDENCE_REPO"

printf 'stale review\n' > "$EVIDENCE_REPO/post-review.txt"
git -C "$EVIDENCE_REPO" add post-review.txt
git -C "$EVIDENCE_REPO" commit -qm "post review change"
CHAIN_STALE="$(git -C "$EVIDENCE_REPO" rev-parse HEAD)"
cp "$TMP/chain.md" "$TMP/stale-chain.md"
ruby -e 'head, path = ARGV; text = File.read(path); text.sub!(/^Current head SHA: `[^`]+`$/, "Current head SHA: `#{head}`"); File.write(path, text)' "$CHAIN_STALE" "$TMP/stale-chain.md"
if ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/stale-chain.md" --base "$CHAIN_BASE" --head "$CHAIN_STALE" --repo "$EVIDENCE_REPO" >/dev/null 2>&1; then
  echo "expected repo-aware PR policy to reject a post-review substantive commit" >&2
  exit 1
fi

printf '{"pull_request":{"body":"stale event body","base":{"sha":"%s"},"head":{"sha":"3333333333333333333333333333333333333333"}}}\n' "$BASE" > "$TMP/event.json"
GITHUB_EVENT_PATH="$TMP/event.json" ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/valid.md" --base "$BASE" --head "$HEAD"

cp "$TMP/valid.md" "$TMP/invalid.md"
ruby -0pi -e 'gsub("Closes #123", "Related issue #123")' "$TMP/invalid.md"
if ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/invalid.md" --base "$BASE" --head "$HEAD" >/dev/null 2>&1; then
  echo "expected PR policy to reject a body without a closing issue link" >&2
  exit 1
fi

# A standard PR with no exact current head is rejected.
cp "$TMP/valid.md" "$TMP/nosha.md"
ruby -0pi -e 'sub(/\nCurrent head SHA: `[0-9a-f]+`\n/, "\n")' "$TMP/nosha.md"
if ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/nosha.md" --base "$BASE" --head "$HEAD" >/dev/null 2>&1; then
  echo "expected PR policy to reject a standard PR without Current head SHA" >&2
  exit 1
fi

# Before the closeout exists, evidence may be pending only at the implementation head.
cp "$TMP/valid.md" "$TMP/pending.md"
ruby -0pi -e 'sub(/^Evidence head SHA: `[0-9a-f]+`$/, "Evidence head SHA: `pending`"); sub(/^Current head SHA: `[0-9a-f]+`$/, "Current head SHA: `aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa`")' "$TMP/pending.md"
ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/pending.md" --base "$BASE" --head "$IMPL"

cp "$TMP/pending.md" "$TMP/stale-pending.md"
ruby -0pi -e 'sub(/^Current head SHA: `[0-9a-f]+`$/, "Current head SHA: `2222222222222222222222222222222222222222`")' "$TMP/stale-pending.md"
if ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/stale-pending.md" --base "$BASE" --head "$HEAD" >/dev/null 2>&1; then
  echo "expected pending evidence to be rejected after the implementation head" >&2
  exit 1
fi

cp "$TMP/valid.md" "$TMP/no-evidence-head.md"
ruby -0pi -e 'sub(/\nEvidence head SHA: `[0-9a-f]+`\n/, "\n")' "$TMP/no-evidence-head.md"
if ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/no-evidence-head.md" --base "$BASE" --head "$HEAD" >/dev/null 2>&1; then
  echo "expected PR policy to reject missing evidence head metadata" >&2
  exit 1
fi

# A standard PR whose body "Current head SHA" no longer matches the real head
# is still rejected (the anti-stale check survives the optional field).
if ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/valid.md" --base "$BASE" --head "4444444444444444444444444444444444444444" >/dev/null 2>&1; then
  echo "expected PR policy to reject a stale body head SHA" >&2
  exit 1
fi

# A lightweight (docs-labelled) PR passes with a reduced body and no lane contract.
cat > "$TMP/light.md" <<EOF
## Backlog issue

Closes #200

## Outcome

Documentation clarified; no lane required.

## Evidence

\`make test\` passed locally.
EOF
ruby -rjson -e 'puts({"pull_request"=>{"body"=>File.read(ARGV[0]),"base"=>{"sha"=>ARGV[1]},"head"=>{"sha"=>ARGV[2]},"labels"=>[{"name"=>"type:docs"}]}}.to_json)' "$TMP/light.md" "$BASE" "$HEAD" > "$TMP/light-event.json"
ruby "$ROOT/scripts/pr-policy.rb" --event "$TMP/light-event.json"

# In the trusted CI path, docs/chore labels only qualify for lightweight mode
# when the actual candidate diff is documentation-only. The explicit
# verdify:policy-exempt label remains the auditable privileged exception.
LIGHT_REPO="$TMP/lightweight-repo"
mkdir -p "$LIGHT_REPO"
git -C "$LIGHT_REPO" init -q -b main
git -C "$LIGHT_REPO" config user.name "Verdify Test"
git -C "$LIGHT_REPO" config user.email "verdify-test@example.invalid"
mkdir -p "$LIGHT_REPO/docs"
printf '# Baseline\n' > "$LIGHT_REPO/docs/guide.md"
git -C "$LIGHT_REPO" add docs/guide.md
git -C "$LIGHT_REPO" commit -qm "baseline"
LIGHT_BASE="$(git -C "$LIGHT_REPO" rev-parse HEAD)"
printf '# Baseline\n\nDocs update.\n' > "$LIGHT_REPO/docs/guide.md"
git -C "$LIGHT_REPO" add docs/guide.md
git -C "$LIGHT_REPO" commit -qm "docs update"
LIGHT_DOCS_HEAD="$(git -C "$LIGHT_REPO" rev-parse HEAD)"
ruby -rjson -e 'puts({"pull_request"=>{"body"=>File.read(ARGV[0]),"base"=>{"sha"=>ARGV[1]},"head"=>{"sha"=>ARGV[2]},"labels"=>[{"name"=>"type:docs"}]}}.to_json)' "$TMP/light.md" "$LIGHT_BASE" "$LIGHT_DOCS_HEAD" > "$TMP/light-docs-event.json"
ruby "$ROOT/scripts/pr-policy.rb" --event "$TMP/light-docs-event.json" --repo "$LIGHT_REPO"

# Receipt mode is selected by its exact marker/path, never by a lightweight
# label. A marker without the generated canonical receipt transaction fails
# closed even when the PR is labelled as docs.
cat > "$TMP/receipt-incomplete.md" <<EOF
<!-- verdify-terminal-receipt:test-sprint:$LIGHT_BASE -->

Closes #135
EOF
ruby -rjson -e 'repo={"full_name"=>"VerdifyConsultancy/verdify-skills"}; puts({"pull_request"=>{"body"=>File.read(ARGV[0]),"base"=>{"sha"=>ARGV[1],"ref"=>"dev","repo"=>repo},"head"=>{"sha"=>ARGV[2],"ref"=>"receipt/test-sprint/#{ARGV[1][0,12]}","repo"=>repo},"labels"=>[{"name"=>"type:docs"}]},"repository"=>repo}.to_json)' "$TMP/receipt-incomplete.md" "$LIGHT_BASE" "$LIGHT_DOCS_HEAD" > "$TMP/receipt-incomplete.json"
if ruby "$ROOT/scripts/pr-policy.rb" --event "$TMP/receipt-incomplete.json" --repo "$LIGHT_REPO" > /dev/null 2> "$TMP/receipt-incomplete.err"; then
  echo "expected an incomplete receipt marker transaction to fail closed" >&2
  exit 1
fi
grep -Eq 'receipt sprint IDs|canonical artifact set|resolve exactly' "$TMP/receipt-incomplete.err"
printf 'puts :substantive\n' > "$LIGHT_REPO/app.rb"
git -C "$LIGHT_REPO" add app.rb
git -C "$LIGHT_REPO" commit -qm "substantive code under docs label"
LIGHT_CODE_HEAD="$(git -C "$LIGHT_REPO" rev-parse HEAD)"
ruby -rjson -e 'puts({"pull_request"=>{"body"=>File.read(ARGV[0]),"base"=>{"sha"=>ARGV[1]},"head"=>{"sha"=>ARGV[2]},"labels"=>[{"name"=>"type:docs"}]}}.to_json)' "$TMP/light.md" "$LIGHT_BASE" "$LIGHT_CODE_HEAD" > "$TMP/light-code-event.json"
if ruby "$ROOT/scripts/pr-policy.rb" --event "$TMP/light-code-event.json" --repo "$LIGHT_REPO" > /dev/null 2> "$TMP/light-code.err"; then
  echo "expected docs-labelled substantive code to require the full lane policy" >&2
  exit 1
fi
grep -q 'docs-only diff or the explicit verdify:policy-exempt label' "$TMP/light-code.err"

git -C "$LIGHT_REPO" reset -q --hard "$LIGHT_DOCS_HEAD"
mkdir -p "$LIGHT_REPO/skills/example"
printf '%s\n' '# Executable skill policy' > "$LIGHT_REPO/skills/example/SKILL.md"
git -C "$LIGHT_REPO" add skills/example/SKILL.md
git -C "$LIGHT_REPO" commit -qm "executable markdown under docs label"
LIGHT_SKILL_HEAD="$(git -C "$LIGHT_REPO" rev-parse HEAD)"
ruby -rjson -e 'puts({"pull_request"=>{"body"=>File.read(ARGV[0]),"base"=>{"sha"=>ARGV[1]},"head"=>{"sha"=>ARGV[2]},"labels"=>[{"name"=>"type:docs"}]}}.to_json)' "$TMP/light.md" "$LIGHT_BASE" "$LIGHT_SKILL_HEAD" > "$TMP/light-skill-event.json"
if ruby "$ROOT/scripts/pr-policy.rb" --event "$TMP/light-skill-event.json" --repo "$LIGHT_REPO" > /dev/null 2> "$TMP/light-skill.err"; then
  echo "expected executable SKILL.md to require the full lane policy" >&2
  exit 1
fi
grep -q 'docs-only diff or the explicit verdify:policy-exempt label' "$TMP/light-skill.err"

# The same reduced body WITHOUT an exempt label is rejected (missing lane contract).
ruby -rjson -e 'puts({"pull_request"=>{"body"=>File.read(ARGV[0]),"base"=>{"sha"=>ARGV[1]},"head"=>{"sha"=>ARGV[2]},"labels"=>[]}}.to_json)' "$TMP/light.md" "$BASE" "$HEAD" > "$TMP/light-noexempt.json"
if ruby "$ROOT/scripts/pr-policy.rb" --event "$TMP/light-noexempt.json" >/dev/null 2>&1; then
  echo "expected a non-exempt reduced body to be rejected" >&2
  exit 1
fi

VERSION="$(cat "$ROOT/VERSION")"
PACKAGE="$(ruby -rjson -e 'data=JSON.parse(File.read(ARGV.fetch(0))); puts "#{data.fetch("name")}@#{data.fetch("version")}"' "$ROOT/package.json")"
cat > "$TMP/release.md" <<EOF
<!-- verdify-release-candidate:$PACKAGE -->

## Backlog issue

Closes #456

## Release candidate

Promote \`dev\` to \`main\`.

## Version

- VERSION: \`$VERSION\`
- Package: \`$PACKAGE\`
- Source branch: \`dev\`
- Target branch: \`main\`

## Evidence

Required checks must pass before merge.

Current head SHA: \`$HEAD\`

## Risk and rollback

npm versions are immutable; rollback requires a newer version.
EOF

ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/release.md" --base "$BASE" --head "$HEAD" --base-ref main --head-ref dev

ruby -rjson -e 'repo={"full_name"=>"VerdifyConsultancy/verdify-skills"}; puts({"pull_request"=>{"body"=>File.read(ARGV[0]),"base"=>{"sha"=>ARGV[1],"ref"=>"main","repo"=>repo},"head"=>{"sha"=>ARGV[2],"ref"=>"dev","repo"=>repo},"labels"=>[]},"repository"=>repo}.to_json)' "$TMP/release.md" "$BASE" "$HEAD" > "$TMP/release-same-repo.json"
ruby "$ROOT/scripts/pr-policy.rb" --event "$TMP/release-same-repo.json"

# The policy program and configuration come from the trusted base checkout,
# while release identity must come from the separately checked-out candidate.
RELEASE_CANDIDATE="$TMP/release-candidate"
mkdir -p "$RELEASE_CANDIDATE"
git -C "$RELEASE_CANDIDATE" init -q -b dev
git -C "$RELEASE_CANDIDATE" config user.name "Verdify Test"
git -C "$RELEASE_CANDIDATE" config user.email "verdify-test@example.invalid"
printf '{"name":"@verdify/candidate","version":"9.9.9"}\n' > "$RELEASE_CANDIDATE/package.json"
printf '9.9.9\n' > "$RELEASE_CANDIDATE/VERSION"
git -C "$RELEASE_CANDIDATE" add package.json VERSION
git -C "$RELEASE_CANDIDATE" commit -qm "candidate release version"
RELEASE_CANDIDATE_HEAD="$(git -C "$RELEASE_CANDIDATE" rev-parse HEAD)"
cat > "$TMP/release-candidate.md" <<EOF
<!-- verdify-release-candidate:@verdify/candidate@9.9.9 -->

## Backlog issue

Closes #457

## Release candidate

Promote the separately checked-out candidate.

## Version

- VERSION: \`9.9.9\`
- Package: \`@verdify/candidate@9.9.9\`
- Source branch: \`dev\`
- Target branch: \`main\`

## Evidence

Trusted policy validated candidate release identity.

Current head SHA: \`$RELEASE_CANDIDATE_HEAD\`

## Risk and rollback

The candidate version differs intentionally from the trusted base checkout.
EOF
ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/release-candidate.md" --base "$BASE" --head "$RELEASE_CANDIDATE_HEAD" --base-ref main --head-ref dev --repo "$RELEASE_CANDIDATE"

SYMLINK_CANDIDATE="$TMP/symlink-release-candidate"
mkdir -p "$SYMLINK_CANDIDATE"
git -C "$SYMLINK_CANDIDATE" init -q -b dev
git -C "$SYMLINK_CANDIDATE" config user.name "Verdify Test"
git -C "$SYMLINK_CANDIDATE" config user.email "verdify-test@example.invalid"
printf '{"name":"@verdify/candidate","version":"9.9.9"}\n' > "$SYMLINK_CANDIDATE/package.json"
ln -s "$TMP/release.md" "$SYMLINK_CANDIDATE/VERSION"
git -C "$SYMLINK_CANDIDATE" add package.json VERSION
git -C "$SYMLINK_CANDIDATE" commit -qm "symlinked release identity"
SYMLINK_HEAD="$(git -C "$SYMLINK_CANDIDATE" rev-parse HEAD)"
if ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/release-candidate.md" --base "$BASE" --head "$SYMLINK_HEAD" --base-ref main --head-ref dev --repo "$SYMLINK_CANDIDATE" > /dev/null 2> "$TMP/symlink.err"; then
  echo "expected symlinked candidate release identity to be rejected" >&2
  exit 1
fi
grep -q 'regular top-level candidate file: VERSION' "$TMP/symlink.err"

cp "$TMP/release.md" "$TMP/release-invalid.md"
ruby -0pi -e 'gsub(/- VERSION: `[^`]+`/, "- VERSION: `0.0.0`")' "$TMP/release-invalid.md"
if ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/release-invalid.md" --base "$BASE" --head "$HEAD" --base-ref main --head-ref dev >/dev/null 2>&1; then
  echo "expected PR policy to reject a release PR with the wrong version" >&2
  exit 1
fi

# A release PR without the generated "Current head SHA" line is rejected
# (the body SHA is only optional for lane and lightweight PRs).
cp "$TMP/release.md" "$TMP/release-nosha.md"
ruby -0pi -e 'sub(/\nCurrent head SHA: `[0-9a-f]+`\n/, "\n")' "$TMP/release-nosha.md"
if ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/release-nosha.md" --base "$BASE" --head "$HEAD" --base-ref main --head-ref dev >/dev/null 2>&1; then
  echo "expected PR policy to reject a release PR without a head SHA line" >&2
  exit 1
fi

# Release mode wins over exempt labels: a dev -> main PR with a docs label and
# only the reduced body is still held to the release contract.
ruby -rjson -e 'repo={"full_name"=>"example/test"}; puts({"pull_request"=>{"body"=>File.read(ARGV[0]),"base"=>{"sha"=>ARGV[1],"ref"=>"main","repo"=>repo},"head"=>{"sha"=>ARGV[2],"ref"=>"dev","repo"=>repo},"labels"=>[{"name"=>"type:docs"}]},"repository"=>repo}.to_json)' "$TMP/light.md" "$BASE" "$HEAD" > "$TMP/release-labelled.json"
if ruby "$ROOT/scripts/pr-policy.rb" --event "$TMP/release-labelled.json" >/dev/null 2>&1; then
  echo "expected an exempt label not to demote a dev->main release PR" >&2
  exit 1
fi

# A fork branch named dev is not the trusted same-repository release source.
ruby -rjson -e 'base_repo={"full_name"=>"example/test"}; head_repo={"full_name"=>"attacker/fork"}; puts({"pull_request"=>{"body"=>File.read(ARGV[0]),"base"=>{"sha"=>ARGV[1],"ref"=>"main","repo"=>base_repo},"head"=>{"sha"=>ARGV[2],"ref"=>"dev","repo"=>head_repo},"labels"=>[]},"repository"=>base_repo}.to_json)' "$TMP/release.md" "$BASE" "$HEAD" > "$TMP/fork-release.json"
if ruby "$ROOT/scripts/pr-policy.rb" --event "$TMP/fork-release.json" > /dev/null 2> "$TMP/fork-release.err"; then
  echo "expected a fork dev->main PR to be rejected" >&2
  exit 1
fi
grep -q 'cross-repository pull requests cannot use the privileged release path' "$TMP/fork-release.err"

# Main is release-only, and every other ordinary base is rejected.
ruby -rjson -e 'repo={"full_name"=>"example/test"}; puts({"pull_request"=>{"body"=>File.read(ARGV[0]),"base"=>{"sha"=>ARGV[1],"ref"=>"main","repo"=>repo},"head"=>{"sha"=>ARGV[2],"ref"=>"feature","repo"=>repo},"labels"=>[]},"repository"=>repo}.to_json)' "$TMP/valid.md" "$BASE" "$HEAD" > "$TMP/ordinary-main.json"
if ruby "$ROOT/scripts/pr-policy.rb" --event "$TMP/ordinary-main.json" >/dev/null 2>&1; then
  echo "expected ordinary PR to main to be rejected" >&2
  exit 1
fi
ruby -rjson -e 'repo={"full_name"=>"example/test"}; puts({"pull_request"=>{"body"=>File.read(ARGV[0]),"base"=>{"sha"=>ARGV[1],"ref"=>"staging","repo"=>repo},"head"=>{"sha"=>ARGV[2],"ref"=>"feature","repo"=>repo},"labels"=>[]},"repository"=>repo}.to_json)' "$TMP/valid.md" "$BASE" "$HEAD" > "$TMP/ordinary-staging.json"
if ruby "$ROOT/scripts/pr-policy.rb" --event "$TMP/ordinary-staging.json" >/dev/null 2>&1; then
  echo "expected ordinary PR to a non-dev base to be rejected" >&2
  exit 1
fi

# Only the exact durable marker is allowed; malformed, duplicate, or unresolved
# template comments fail closed.
cp "$TMP/release.md" "$TMP/release-bad-marker.md"
ruby -0pi -e 'sub(/verdify-release-candidate:/, "verdify-release-candidate:wrong-")' "$TMP/release-bad-marker.md"
if ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/release-bad-marker.md" --base "$BASE" --head "$HEAD" --base-ref main --head-ref dev >/dev/null 2>&1; then
  echo "expected malformed release marker to be rejected" >&2
  exit 1
fi
cp "$TMP/release.md" "$TMP/release-placeholder.md"
printf '\n<!-- unresolved -->\n' >> "$TMP/release-placeholder.md"
if ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/release-placeholder.md" --base "$BASE" --head "$HEAD" --base-ref main --head-ref dev >/dev/null 2>&1; then
  echo "expected unresolved release placeholder to be rejected" >&2
  exit 1
fi

# The token-bearing workflow must authorize the protected base before checkout
# or execution; script-level PR routing is too late to establish code trust.
ruby -ryaml - "$ROOT" <<'RUBY'
root = ARGV.fetch(0)
workflow = YAML.safe_load(File.read(File.join(root, ".github/workflows/policy.yml")), aliases: false)
normalize = ->(value) { value.to_s.gsub(/\s+/, " ").strip }
expected_guard = normalize.call(<<~GUARD)
  github.event.pull_request.base.repo.full_name == github.repository &&
  (github.event.pull_request.base.ref == 'dev' ||
   github.event.pull_request.base.ref == 'main')
GUARD
trigger = workflow.dig(true, "pull_request")
abort "policy workflow base filter is not exact" unless Array(trigger["branches"]).sort == %w[dev main]
job = workflow.dig("jobs", "pull-request-policy")
abort "policy workflow protected-base guard is not exact" unless normalize.call(job["if"]) == expected_guard
step = Array(job["steps"]).find { |item| item["name"] == "Check Verdify pull request contract" }
expected_env = {
  "BASE_REF" => "${{ github.event.pull_request.base.ref }}",
  "BASE_REPOSITORY" => "${{ github.event.pull_request.base.repo.full_name }}",
  "REPOSITORY" => "${{ github.repository }}"
}
expected_env.each { |name, value| abort "policy workflow #{name} binding drifted" unless step.dig("env", name) == value }
run = step.fetch("run")
ordering = [
  '[[ "${BASE_REPOSITORY}" == "${REPOSITORY}" ]]', 'case "${BASE_REF}" in', "dev|main)",
  "ruby trusted-policy/scripts/pr-policy.rb"
].map { |token| run.index(token) }
abort "policy workflow invokes trusted code before identity guards" unless ordering.all? && ordering == ordering.sort
Array(job["steps"]).select { |item| item["uses"].to_s.start_with?("actions/checkout@") }.each do |checkout|
  abort "policy checkout persists credentials" unless checkout.dig("with", "persist-credentials") == false
end
RUBY

echo "PR policy tests passed."
