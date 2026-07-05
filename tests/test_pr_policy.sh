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

# The same reduced body WITHOUT an exempt label is rejected (missing lane contract).
ruby -rjson -e 'puts({"pull_request"=>{"body"=>File.read(ARGV[0]),"base"=>{"sha"=>ARGV[1]},"head"=>{"sha"=>ARGV[2]},"labels"=>[]}}.to_json)' "$TMP/light.md" "$BASE" "$HEAD" > "$TMP/light-noexempt.json"
if ruby "$ROOT/scripts/pr-policy.rb" --event "$TMP/light-noexempt.json" >/dev/null 2>&1; then
  echo "expected a non-exempt reduced body to be rejected" >&2
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
ruby -rjson -e 'puts({"pull_request"=>{"body"=>File.read(ARGV[0]),"base"=>{"sha"=>ARGV[1],"ref"=>"main"},"head"=>{"sha"=>ARGV[2],"ref"=>"dev"},"labels"=>[{"name"=>"type:docs"}]}}.to_json)' "$TMP/light.md" "$BASE" "$HEAD" > "$TMP/release-labelled.json"
if ruby "$ROOT/scripts/pr-policy.rb" --event "$TMP/release-labelled.json" >/dev/null 2>&1; then
  echo "expected an exempt label not to demote a dev->main release PR" >&2
  exit 1
fi

echo "PR policy tests passed."
