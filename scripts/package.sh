#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(cat "$ROOT/VERSION")"
OUT="${1:-$ROOT/dist}"
NAME="verdify-lifecycle-skills-v${VERSION}"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

for command in ruby zip; do
  command -v "$command" >/dev/null || { echo "$command is required to package Verdify" >&2; exit 1; }
done

mkdir -p "$OUT" "$STAGE/$NAME"
OUT="$(cd "$OUT" && pwd)"
if [[ "${VERDIFY_PACKAGE_SKIP_TESTS:-0}" != "1" ]]; then
  make -C "$ROOT" test >&2
fi
ruby "$ROOT/scripts/package-file-list.rb" --stage "$STAGE/$NAME" "$ROOT" >/dev/null
# The staged tree is the immutable Git-object snapshot. Hash that exact exported
# tree so a later worktree or index change cannot alter the archive manifest.
bash "$ROOT/scripts/gen-manifest.sh" "$STAGE/$NAME" "$STAGE/$NAME/MANIFEST.sha256"

# ZIP stores filesystem metadata as well as file bytes. Normalize it before
# archiving and feed zip an explicitly sorted member list so rebuilding the same
# source commit produces byte-identical release assets on every runner.
ruby -e '
  root = ARGV.fetch(0)
  epoch = Time.at(315_532_800).utc
  paths = [root] + Dir.glob("#{root}/**/*", File::FNM_DOTMATCH).reject { |path| path.end_with?("/.", "/..") }
  paths.each do |path|
    File.chmod(0o755, path) if File.directory?(path) && !File.symlink?(path)
    if File.symlink?(path) && File.respond_to?(:lutime)
      File.lutime(epoch, epoch, path)
    else
      File.utime(epoch, epoch, path)
    end
  end
' "$STAGE/$NAME"
rm -f "$OUT/$NAME.zip"
(
  cd "$STAGE"
  TZ=UTC LC_ALL=C ruby -e '
    root = ARGV.fetch(0)
    paths = [root] + Dir.glob("#{root}/**/*", File::FNM_DOTMATCH).reject { |path| path.end_with?("/.", "/..") }
    abort "archive member contains a newline" if paths.any? { |path| path.include?("\n") }
    puts paths.sort
  ' "$NAME" | TZ=UTC LC_ALL=C zip -Xq -y "$OUT/$NAME.zip" -@
)
ruby -rdigest -e 'path=ARGV.fetch(0); File.write(path + ".sha256", "#{Digest::SHA256.file(path).hexdigest}  #{File.basename(path)}\n")' "$OUT/$NAME.zip"
printf '%s\n' "$OUT/$NAME.zip"
