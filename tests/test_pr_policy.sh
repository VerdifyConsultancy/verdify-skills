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

VERSION="$(cat "$ROOT/VERSION")"
PACKAGE="$(ruby -rjson -e 'data=JSON.parse(File.read(ARGV.fetch(0))); puts "#{data.fetch("name")}@#{data.fetch("version")}"' "$ROOT/package.json")"
cat > "$TMP/release.md" <<EOF
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

cp "$TMP/release.md" "$TMP/release-invalid.md"
ruby -0pi -e 'gsub(/- VERSION: `[^`]+`/, "- VERSION: `0.0.0`")' "$TMP/release-invalid.md"
if ruby "$ROOT/scripts/pr-policy.rb" --body "$TMP/release-invalid.md" --base "$BASE" --head "$HEAD" --base-ref main --head-ref dev >/dev/null 2>&1; then
  echo "expected PR policy to reject a release PR with the wrong version" >&2
  exit 1
fi

echo "PR policy tests passed."
