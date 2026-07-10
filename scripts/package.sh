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
# Hash the staged bytes using the same Git-index selection that populated the stage.
bash "$ROOT/scripts/gen-manifest.sh" "$STAGE/$NAME" "$STAGE/$NAME/MANIFEST.sha256" "$ROOT"
(
  cd "$STAGE"
  zip -qry -y "$OUT/$NAME.zip" "$NAME"
)
ruby -rdigest -e 'path=ARGV.fetch(0); File.write(path + ".sha256", "#{Digest::SHA256.file(path).hexdigest}  #{File.basename(path)}\n")' "$OUT/$NAME.zip"
printf '%s\n' "$OUT/$NAME.zip"
