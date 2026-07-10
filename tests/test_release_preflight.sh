#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v ruby >/dev/null || ! command -v git >/dev/null; then
  echo "release preflight test skipped: ruby and git are required."
  exit 0
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

REPO="$TMP/project"
mkdir -p "$REPO"
git -C "$REPO" init -q -b main
git -C "$REPO" config user.name "Verdify Test"
git -C "$REPO" config user.email "verdify-test@example.invalid"

cat > "$REPO/package.json" <<'JSON'
{
  "name": "@verdify-cli/cli",
  "version": "1.1.0"
}
JSON
printf '1.1.0\n' > "$REPO/VERSION"
git -C "$REPO" add package.json VERSION
git -C "$REPO" commit -qm "release 1.1.0"
BASE="$(git -C "$REPO" rev-parse HEAD)"

ruby -rjson -e 'path=ARGV.fetch(0); data=JSON.parse(File.read(path)); data["version"]="1.1.1"; File.write(path, JSON.pretty_generate(data) + "\n")' "$REPO/package.json"
printf '1.1.1\n' > "$REPO/VERSION"

ruby "$ROOT/scripts/release-preflight.rb" --root "$REPO" --require-version-bump "$BASE" --skip-registry

cp "$REPO/package.json" "$TMP/package.json.ok"
printf '1.1.0\n' > "$REPO/VERSION"
if ruby "$ROOT/scripts/release-preflight.rb" --root "$REPO" --skip-registry >/dev/null 2>&1; then
  echo "expected mismatched package.json and VERSION to fail" >&2
  exit 1
fi
cp "$TMP/package.json.ok" "$REPO/package.json"
printf '1.1.1\n' > "$REPO/VERSION"

git -C "$REPO" checkout -q -- package.json VERSION
if ruby "$ROOT/scripts/release-preflight.rb" --root "$REPO" --require-version-bump "$BASE" --skip-registry >/dev/null 2>&1; then
  echo "expected an unchanged version to fail the version-bump check" >&2
  exit 1
fi

FAKE_BIN="$TMP/bin"
mkdir -p "$FAKE_BIN"
cat > "$FAKE_BIN/npm" <<'SH'
#!/usr/bin/env bash
echo "npm ERR! code E404" >&2
exit 1
SH
chmod +x "$FAKE_BIN/npm"
ruby -rjson -e 'path=ARGV.fetch(0); data=JSON.parse(File.read(path)); data["version"]="1.1.1"; File.write(path, JSON.pretty_generate(data) + "\n")' "$REPO/package.json"
printf '1.1.1\n' > "$REPO/VERSION"
PATH="$FAKE_BIN:$PATH" ruby "$ROOT/scripts/release-preflight.rb" --root "$REPO" --require-version-bump "$BASE" --require-unpublished
CREATE_RESULT="$(PATH="$FAKE_BIN:$PATH" ruby "$ROOT/scripts/release-preflight.rb" --root "$REPO" --release-pr-base "$BASE" --json)"
ruby -rjson -e 'd=JSON.parse(ARGV.fetch(0)); abort unless d["decision"] == "create" && d["reason"] == "new_unpublished_version"' "$CREATE_RESULT"

write_candidate_state() {
  local fixture="$1"
  local output="$2"
  ruby -rjson -e '
    fixture, output = ARGV
    marker = "<!-- verdify-release-candidate:@verdify-cli/cli@1.1.1 -->"
    issue = {"number"=>10, "state"=>"open", "body"=>marker}
    repository = "VerdifyConsultancy/verdify-skills"
    pull = {
      "number"=>20, "state"=>"open", "merged_at"=>nil, "body"=>marker,
      "base"=>"main", "base_repo"=>repository, "head"=>"dev", "head_repo"=>repository
    }
    document = {"issues"=>[issue], "pull_requests"=>[pull]}
    case fixture
    when "open"
    when "closed-unmerged"
      issue["state"] = "closed"
      pull["state"] = "closed"
    when "merged"
      pull["state"] = "closed"
      pull["merged_at"] = "2026-07-10T00:00:00Z"
    when "duplicate-issue"
      document["issues"] << issue.merge("number"=>11)
    when "duplicate-pull"
      document["pull_requests"] << pull.merge("number"=>21)
    when "route-conflict"
      document["pull_requests"] << pull.merge("number"=>21, "body"=>"<!-- verdify-release-candidate:@verdify-cli/cli@9.9.9 -->")
    else
      route_case, state = fixture.match(/\A(wrong-base|wrong-head|wrong-head-repo|wrong-base-repo|fork-lookalike)-(open|closed|merged)\z/)&.captures
      abort "unknown candidate fixture" unless route_case
      case route_case
      when "wrong-base" then pull["base"] = "feature"
      when "wrong-head" then pull["head"] = "release"
      when "wrong-head-repo" then pull["head_repo"] = "OtherOrg/verdify-skills"
      when "wrong-base-repo" then pull["base_repo"] = "OtherOrg/verdify-skills"
      when "fork-lookalike" then pull["head_repo"] = "VerdifyConsultancy/verdify-skills-fork"
      end
      if state == "closed"
        pull["state"] = "closed"
      elsif state == "merged"
        pull["state"] = "closed"
        pull["merged_at"] = "2026-07-10T00:00:00Z"
      end
    end
    File.write(output, JSON.generate(document) + "\n")
  ' "$fixture" "$output"
}

for fixture in open closed-unmerged merged; do
  state="$TMP/$fixture.candidates.json"
  write_candidate_state "$fixture" "$state"
  result="$(PATH="$FAKE_BIN:$PATH" ruby "$ROOT/scripts/release-preflight.rb" --root "$REPO" --release-pr-base "$BASE" --candidate-state "$state" --json)"
  ruby -rjson -e '
    fixture, result = ARGV
    d = JSON.parse(result)
    candidate = d.fetch("candidate")
    case fixture
    when "open"
      abort unless d["decision"] == "create" && candidate["issue_action"] == "reuse" && candidate["pull_request_action"] == "reuse"
    when "closed-unmerged"
      abort unless d["decision"] == "create" && candidate["issue_action"] == "reopen" && candidate["pull_request_action"] == "reopen"
    when "merged"
      abort unless d["decision"] == "skip" && d["reason"] == "candidate_already_merged" && candidate["pull_request_action"] == "stop_merged"
    end
  ' "$fixture" "$result"
done

CONFLICT_FIXTURES=(duplicate-issue duplicate-pull route-conflict)
ROUTE_FIXTURES=(wrong-base wrong-head wrong-head-repo wrong-base-repo fork-lookalike)
for route_fixture in "${ROUTE_FIXTURES[@]}"; do
  for state in open closed merged; do
    CONFLICT_FIXTURES+=("${route_fixture}-${state}")
  done
done

for fixture in "${CONFLICT_FIXTURES[@]}"; do
  state="$TMP/$fixture.candidates.json"
  write_candidate_state "$fixture" "$state"
  if PATH="$FAKE_BIN:$PATH" ruby "$ROOT/scripts/release-preflight.rb" --root "$REPO" --release-pr-base "$BASE" --candidate-state "$state" --json \
    >"$TMP/$fixture.out" 2>"$TMP/$fixture.err"; then
    echo "expected $fixture durable candidate identity to fail closed" >&2
    exit 1
  fi
  ruby -rjson -e '
    d=JSON.parse(File.read(ARGV.fetch(0)))
    abort unless d["decision"] == "error" && d["reason"] == "candidate_identity_conflict"
    abort unless d.dig("candidate", "pull_request_action") == "conflict" || ARGV.fetch(1) == "duplicate-issue"
  ' "$TMP/$fixture.out" "$fixture"
done

cat > "$FAKE_BIN/npm" <<'SH'
#!/usr/bin/env bash
printf '"1.1.1"\n'
SH
chmod +x "$FAKE_BIN/npm"
if PATH="$FAKE_BIN:$PATH" ruby "$ROOT/scripts/release-preflight.rb" --root "$REPO" --require-unpublished >/dev/null 2>&1; then
  echo "expected an already-published npm version to fail" >&2
  exit 1
fi
PUBLISHED_RESULT="$(PATH="$FAKE_BIN:$PATH" ruby "$ROOT/scripts/release-preflight.rb" --root "$REPO" --release-pr-base "$BASE" --json)"
ruby -rjson -e 'd=JSON.parse(ARGV.fetch(0)); abort unless d["decision"] == "skip" && d["reason"] == "already_published"' "$PUBLISHED_RESULT"

cat > "$FAKE_BIN/npm" <<'SH'
#!/usr/bin/env bash
echo "npm ERR! code E404" >&2
exit 1
SH
chmod +x "$FAKE_BIN/npm"
PATH="$FAKE_BIN:$PATH" ruby "$ROOT/scripts/release-preflight.rb" --root "$REPO" --require-unpublished

git -C "$REPO" checkout -q -- package.json VERSION
UNBUMPED_RESULT="$(PATH="$FAKE_BIN:$PATH" ruby "$ROOT/scripts/release-preflight.rb" --root "$REPO" --release-pr-base "$BASE" --json)"
ruby -rjson -e 'd=JSON.parse(ARGV.fetch(0)); abort unless d["decision"] == "skip" && d["reason"] == "version_not_bumped"' "$UNBUMPED_RESULT"

cat > "$FAKE_BIN/npm" <<'SH'
#!/usr/bin/env bash
echo "npm ERR! code E500" >&2
exit 1
SH
chmod +x "$FAKE_BIN/npm"
if PATH="$FAKE_BIN:$PATH" ruby "$ROOT/scripts/release-preflight.rb" --root "$REPO" --require-unpublished >/dev/null 2>&1; then
  echo "expected an inconclusive npm registry response to fail" >&2
  exit 1
fi
if PATH="$FAKE_BIN:$PATH" ruby "$ROOT/scripts/release-preflight.rb" --root "$REPO" --release-pr-base "$BASE" --json >/dev/null 2>&1; then
  echo "expected release PR preflight to fail on an inconclusive registry response" >&2
  exit 1
fi

ruby -e '
  workflow = File.read(ARGV.fetch(0))
  preflight = workflow.index("release-preflight.rb --release-pr-base") or abort "release PR preflight is missing"
  reconcile = workflow.index("--candidate-state") or abort "durable candidate reconciliation is missing"
  mutations = [workflow.index("gh issue create"), workflow.index("gh pr edit"), workflow.index("gh pr create")]
  abort "release PR mutation precedes npm preflight" unless mutations.all? { |position| position && position > preflight }
  abort "release PR mutation precedes candidate reconciliation" unless mutations.all? { |position| position > reconcile }
  abort "release PR author gate is missing" unless workflow.include?(%q{AUTHOR="$(gh api user --jq .login)"}) && workflow.include?(%q{!= "jrvallery"})
  abort "candidate inventory is bounded or open-only" unless workflow.include?("--paginate --slurp") && workflow.include?("issues?state=all&per_page=100") && workflow.include?("pulls?state=all&per_page=100")
  abort "candidate snapshot discards repository ownership" unless workflow.include?(%q{"base_repo"=>pull.dig("base", "repo", "full_name")}) && workflow.include?(%q{"head_repo"=>pull.dig("head", "repo", "full_name")})
  abort "candidate preflight does not bind the repository" unless workflow.scan(%q{--repository "${GITHUB_REPOSITORY}"}).length == 2
  abort "title scans remain candidate identity authority" if workflow.include?("gh issue list") || workflow.include?("gh pr list")
' "$ROOT/.github/workflows/release-pr.yml"

echo "release preflight tests passed."
