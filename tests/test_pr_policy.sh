#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
BASE="1111111111111111111111111111111111111111"
HEAD="2222222222222222222222222222222222222222"

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

Current head SHA: \`$HEAD\`

## Risk and deployment impact

Staging verification remains required.
EOF

ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/valid.md" --base "$BASE" --head "$HEAD"

printf '{"pull_request":{"body":"stale event body","base":{"sha":"%s"},"head":{"sha":"3333333333333333333333333333333333333333"}}}\n' "$BASE" > "$TMP/event.json"
GITHUB_EVENT_PATH="$TMP/event.json" ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/valid.md" --base "$BASE" --head "$HEAD"

cp "$TMP/valid.md" "$TMP/invalid.md"
ruby -0pi -e 'gsub("Closes #123", "Related issue #123")' "$TMP/invalid.md"
if ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/invalid.md" --base "$BASE" --head "$HEAD" >/dev/null 2>&1; then
  echo "expected PR policy to reject a body without a closing issue link" >&2
  exit 1
fi

# A standard PR with no "Current head SHA" line still passes (that field is now optional).
cp "$TMP/valid.md" "$TMP/nosha.md"
ruby -0pi -e 'sub(/\nCurrent head SHA: `[0-9a-f]+`\n/, "\n")' "$TMP/nosha.md"
ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/nosha.md" --base "$BASE" --head "$HEAD"

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

# The same reduced body WITHOUT an exempt label is rejected (missing lane contract).
ruby -rjson -e 'puts({"pull_request"=>{"body"=>File.read(ARGV[0]),"base"=>{"sha"=>ARGV[1]},"head"=>{"sha"=>ARGV[2]},"labels"=>[]}}.to_json)' "$TMP/light.md" "$BASE" "$HEAD" > "$TMP/light-noexempt.json"
if ruby "$ROOT/scripts/pr-policy.rb" --event "$TMP/light-noexempt.json" >/dev/null 2>&1; then
  echo "expected a non-exempt reduced body to be rejected" >&2
  exit 1
fi

echo "PR policy tests passed."
