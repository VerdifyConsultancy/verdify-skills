#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
repo="${1:-$PWD}"
[[ $# -eq 0 ]] || shift
"$ROOT/bin/verdify" doctor --repo "$repo"
codex_bin="$(command -v codex)"
cd "$repo"
exec env -i \
  HOME="$HOME" \
  USER="${USER:-}" \
  LOGNAME="${LOGNAME:-${USER:-}}" \
  SHELL="${SHELL:-/bin/bash}" \
  TERM="${TERM:-xterm-256color}" \
  TMPDIR="${TMPDIR:-/tmp}" \
  PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
  PWD="$repo" \
  VERDIFY_SKILLS_ROOT="$ROOT" \
  VERDIFY_WORKER_ENV="allowlisted" \
  "$codex_bin" "$@"
