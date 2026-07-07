#!/usr/bin/env bash
# gen-manifest.sh — regenerate MANIFEST.sha256, the integrity manifest for the skills tree.
#
# Single source of truth for the manifest's file set (the exclude list) and hashing, shared by
# scripts/package.sh (the in-zip manifest) and `make manifest` / `make manifest-check` (the committed
# root manifest + its CI gate). Fixes #109: the committed MANIFEST.sha256 was hand-generated and never
# regenerated in the release path, so it froze at an old commit (95/296 stale, 102 files missing).
#
#   gen-manifest.sh                       # regenerate ./MANIFEST.sha256 from the repo tree
#   gen-manifest.sh <src_dir> <out_file>  # regenerate a manifest of <src_dir> into <out_file>
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${1:-$ROOT}"
OUT="${2:-$ROOT/MANIFEST.sha256}"

command -v ruby  >/dev/null || { echo "ruby is required to generate MANIFEST.sha256"  >&2; exit 1; }
command -v rsync >/dev/null || { echo "rsync is required to generate MANIFEST.sha256" >&2; exit 1; }

# Resolve OUT to an absolute path before we cd into the staging dir.
OUT_DIR="$(cd "$(dirname "$OUT")" && pwd)"
OUT="$OUT_DIR/$(basename "$OUT")"

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

# The manifest covers the shipped skills tree only — the same exclude set the package uses. Keep this
# list identical to the one consumed by scripts/package.sh (it sources this script), so the in-zip and
# committed manifests can never diverge.
rsync -a \
  --exclude '/.git' \
  --exclude '/.agent-skills' \
  --exclude '/.agent-workflow' \
  --exclude '/dist' \
  --exclude '/MANIFEST.sha256' \
  --exclude '/node_modules' \
  "$SRC/" "$STAGE/"

(
  cd "$STAGE"
  ruby -rdigest -e '
    out = ARGV.fetch(0)
    paths = Dir.glob("**/*", File::FNM_DOTMATCH).select do |path|
      File.file?(path) && !File.symlink?(path) && path != "MANIFEST.sha256"
    end.sort
    File.open(out, "w") do |manifest|
      paths.each { |path| manifest.puts "#{Digest::SHA256.file(path).hexdigest}  #{path}" }
    end
  ' "$OUT"
)
