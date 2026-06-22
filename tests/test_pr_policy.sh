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

cp "$TMP/valid.md" "$TMP/invalid.md"
ruby -0pi -e 'gsub("Closes #123", "Related issue #123")' "$TMP/invalid.md"
if ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/invalid.md" --base "$BASE" --head "$HEAD" >/dev/null 2>&1; then
  echo "expected PR policy to reject a body without a closing issue link" >&2
  exit 1
fi

echo "PR policy tests passed."
