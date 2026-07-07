#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(cat "$ROOT/VERSION")"
OUT="${1:-$ROOT/dist}"
NAME="verdify-lifecycle-skills-v${VERSION}"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

for command in ruby rsync zip; do
  command -v "$command" >/dev/null || { echo "$command is required to package Verdify" >&2; exit 1; }
done

mkdir -p "$OUT" "$STAGE/$NAME"
OUT="$(cd "$OUT" && pwd)"
make -C "$ROOT" test >&2
rsync -a \
  --exclude '/.git' \
  --exclude '/.agent-skills' \
  --exclude '/.agent-workflow' \
  --exclude '/dist' \
  --exclude '/MANIFEST.sha256' \
  --exclude '/node_modules' \
  "$ROOT/" "$STAGE/$NAME/"
# Generate the in-zip manifest via the shared generator so it can never diverge from the committed
# root MANIFEST.sha256 (same exclude set + hashing). #109
bash "$ROOT/scripts/gen-manifest.sh" "$STAGE/$NAME" "$STAGE/$NAME/MANIFEST.sha256"
(
  cd "$STAGE"
  zip -qry "$OUT/$NAME.zip" "$NAME"
)
ruby -rdigest -e 'path=ARGV.fetch(0); File.write(path + ".sha256", "#{Digest::SHA256.file(path).hexdigest}  #{File.basename(path)}\n")' "$OUT/$NAME.zip"
printf '%s\n' "$OUT/$NAME.zip"
