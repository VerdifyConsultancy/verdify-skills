#!/usr/bin/env bash
# gen-manifest.sh — regenerate MANIFEST.sha256, the integrity manifest for the skills tree.
#
# The canonical tracked file set comes from scripts/package-file-list.rb. Both this script and
# scripts/package.sh consume that selector, so ignored and untracked host state cannot enter the
# committed manifest or release archive.
#
#   gen-manifest.sh                       # regenerate ./MANIFEST.sha256 from the repo tree
#   gen-manifest.sh <src_dir> <out_file>  # regenerate a Git worktree or exported tree
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${1:-$ROOT}"
OUT="${2:-$ROOT/MANIFEST.sha256}"

if (( $# > 2 )); then
  echo "Usage: scripts/gen-manifest.sh [src_dir] [out_file]" >&2
  exit 2
fi

command -v ruby >/dev/null || { echo "ruby is required to generate MANIFEST.sha256" >&2; exit 1; }

# Resolve OUT to an absolute path before we cd into the staging dir.
OUT_DIR="$(cd "$(dirname "$OUT")" && pwd)"
OUT="$OUT_DIR/$(basename "$OUT")"

SNAPSHOT="$(mktemp -d)"
LIST="$SNAPSHOT/paths"
HASH_ROOT="$SRC"
trap 'rm -rf "$SNAPSHOT"' EXIT
if git_root="$(git -C "$SRC" rev-parse --show-toplevel 2>/dev/null)" && \
     [[ "$(cd "$git_root" && pwd -P)" == "$(cd "$SRC" && pwd -P)" ]]; then
  HASH_ROOT="$SNAPSHOT/tree"
  ruby "$ROOT/scripts/package-file-list.rb" --null --stage "$HASH_ROOT" "$SRC" > "$LIST"
else
  ruby "$ROOT/scripts/package-file-list.rb" --null --tree "$SRC" > "$LIST"
fi

ruby -rdigest -e '
  source, out, list = ARGV
  paths = File.binread(list).split("\0").reject(&:empty?)
  File.open(out, "w") do |manifest|
    paths.each do |path|
      full_path = File.join(source, path)
      stat = File.lstat(full_path)
      next if stat.symlink?
      abort "selected manifest path is not a regular file: #{path}" unless stat.file?
      manifest.puts "#{Digest::SHA256.file(full_path).hexdigest}  #{path}"
    end
  end
' "$HASH_ROOT" "$OUT" "$LIST"
