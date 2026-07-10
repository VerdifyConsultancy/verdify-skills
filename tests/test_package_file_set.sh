#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for command in git node ruby unzip zip; do
  command -v "$command" >/dev/null || { echo "$command is required for package file-set tests" >&2; exit 1; }
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
FIXTURE="$TMP/repository"

# Build an isolated tracked copy so this test never creates, edits, or removes Jason's host-local files.
ruby "$ROOT/scripts/package-file-list.rb" --stage "$FIXTURE" "$ROOT" >/dev/null
# Preserve the existing two-argument manifest interface for exported trees without .git metadata.
bash "$FIXTURE/scripts/gen-manifest.sh" "$FIXTURE" "$TMP/exported-tree.manifest"
[[ -s "$TMP/exported-tree.manifest" ]]
git -C "$FIXTURE" init -q -b main
git -C "$FIXTURE" config user.name "Verdify Test"
git -C "$FIXTURE" config user.email "verdify-test@example.invalid"

# Tracked runtime/build roots remain outside the shipped package boundary too.
mkdir -p "$FIXTURE/.agent-workflow" "$FIXTURE/.agent-skills" "$FIXTURE/dist" "$FIXTURE/node_modules"
printf 'controller state\n' > "$FIXTURE/.agent-workflow/local.yaml"
printf 'installed copy\n' > "$FIXTURE/.agent-skills/local.txt"
printf 'old archive\n' > "$FIXTURE/dist/old.zip"
printf 'dependency\n' > "$FIXTURE/node_modules/local.js"
git -C "$FIXTURE" add -f .
git -C "$FIXTURE" commit -qm "package fixture"

LINK_PATH=".agents/skills/project-router"
[[ -L "$FIXTURE/$LINK_PATH" ]]
LINK_TARGET="$(readlink "$FIXTURE/$LINK_PATH")"

ruby "$FIXTURE/scripts/package-file-list.rb" "$FIXTURE" > "$TMP/paths.before"
bash "$FIXTURE/scripts/gen-manifest.sh" "$FIXTURE" "$TMP/manifest.before"

cat >> "$FIXTURE/.git/info/exclude" <<'EOF'
.claude/scheduled_tasks.lock
.cache/
EOF
mkdir -p "$FIXTURE/.cache"
printf 'host scheduler state\n' > "$FIXTURE/.claude/scheduled_tasks.lock"
printf 'host cache\n' > "$FIXTURE/.cache/session.tmp"
printf 'untracked operator notes\n' > "$FIXTURE/operator-notes.txt"

ruby "$FIXTURE/scripts/package-file-list.rb" "$FIXTURE" > "$TMP/paths.after"
bash "$FIXTURE/scripts/gen-manifest.sh" "$FIXTURE" "$TMP/manifest.after"
cmp "$TMP/paths.before" "$TMP/paths.after"
cmp "$TMP/manifest.before" "$TMP/manifest.after"

if grep -Eq '(^|/)(scheduled_tasks\.lock|session\.tmp|operator-notes\.txt)$' "$TMP/paths.after"; then
  echo "host-local file entered the canonical package list" >&2
  exit 1
fi
if grep -Eq '^(\.agent-workflow|\.agent-skills|dist|node_modules)(/|$)' "$TMP/paths.after"; then
  echo "excluded tracked root entered the canonical package list" >&2
  exit 1
fi

ARCHIVE="$(VERDIFY_PACKAGE_SKIP_TESTS=1 bash "$FIXTURE/scripts/package.sh" "$TMP/package")"
bash "$FIXTURE/scripts/verify-package.sh" "$ARCHIVE" >/dev/null

ARCHIVE_ROOT="verdify-lifecycle-skills-v$(cat "$FIXTURE/VERSION")"
unzip -Z1 "$ARCHIVE" | ruby -e '
  root = ARGV.fetch(0) + "/"
  paths = STDIN.each_line(chomp: true).filter_map do |entry|
    next unless entry.start_with?(root)
    next if entry == root || entry.end_with?("/")
    entry.delete_prefix(root)
  end
  puts paths.sort
' "$ARCHIVE_ROOT" > "$TMP/archive.paths"

{ cat "$TMP/paths.before"; echo MANIFEST.sha256; } | sort > "$TMP/expected-archive.paths"
cmp "$TMP/expected-archive.paths" "$TMP/archive.paths"

EXTRACTED="$TMP/extracted"
mkdir -p "$EXTRACTED"
unzip -q "$ARCHIVE" -d "$EXTRACTED"
cmp "$TMP/manifest.before" "$EXTRACTED/$ARCHIVE_ROOT/MANIFEST.sha256"
ruby -e '
  link, expected = ARGV
  abort "discovery link was dereferenced" unless File.symlink?(link)
  abort "discovery link target changed" unless File.readlink(link) == expected
' "$EXTRACTED/$ARCHIVE_ROOT/$LINK_PATH" "$LINK_TARGET"

ruby -e '
  root, selected_file, manifest_file = ARGV
  expected = File.readlines(selected_file, chomp: true).select do |path|
    stat = File.lstat(File.join(root, path))
    stat.file? && !stat.symlink?
  end
  actual = File.readlines(manifest_file, chomp: true).map { |line| line.split(/  /, 2).fetch(1) }
  abort "manifest paths differ from selected regular files" unless actual == expected
' "$FIXTURE" "$TMP/paths.before" "$TMP/manifest.before"

echo "Package file-set tests passed."
