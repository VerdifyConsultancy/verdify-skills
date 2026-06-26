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

ruby -rjson -e 'path=ARGV.fetch(0); data=JSON.parse(File.read(path)); data["version"]="1.1.1"; File.write(path, JSON.pretty_generate(data) + "\n")' "$REPO/package.json"
printf '1.1.1\n' > "$REPO/VERSION"

FAKE_BIN="$TMP/bin"
mkdir -p "$FAKE_BIN"
cat > "$FAKE_BIN/npm" <<'SH'
#!/usr/bin/env bash
printf '"1.1.1"\n'
SH
chmod +x "$FAKE_BIN/npm"
if PATH="$FAKE_BIN:$PATH" ruby "$ROOT/scripts/release-preflight.rb" --root "$REPO" --require-unpublished >/dev/null 2>&1; then
  echo "expected an already-published npm version to fail" >&2
  exit 1
fi

cat > "$FAKE_BIN/npm" <<'SH'
#!/usr/bin/env bash
echo "npm ERR! code E404" >&2
exit 1
SH
chmod +x "$FAKE_BIN/npm"
PATH="$FAKE_BIN:$PATH" ruby "$ROOT/scripts/release-preflight.rb" --root "$REPO" --require-unpublished

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

echo "release preflight tests passed."
