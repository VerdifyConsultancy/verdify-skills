#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  bootstrap-agent-session.sh codex [project-dir] [-- codex-args...]
  bootstrap-agent-session.sh claude [project-dir] [-- claude-args...]

Environment:
  VERDIFY_SKILLS_REPO   Git repository to fetch. Default:
                        https://github.com/VerdifyConsultancy/verdify-skills.git
  VERDIFY_SKILLS_REF    Branch, tag, or commit to fetch. Default: main
  VERDIFY_KEEP_SKILLS   Set to 1 to keep the temporary clone for debugging.

Examples:
  bootstrap-agent-session.sh codex ~/code/my-project
  bootstrap-agent-session.sh claude ~/code/my-project -- "/verdify-agentic-sprint plan from GitHub issues"
USAGE
}

runtime="${1:-}"
if [[ -z "$runtime" || "$runtime" == "-h" || "$runtime" == "--help" ]]; then
  usage
  exit 0
fi
shift

case "$runtime" in
  codex|claude) ;;
  *)
    usage >&2
    exit 2
    ;;
esac

project_dir="${PWD}"
if [[ $# -gt 0 && "${1:-}" != "--" ]]; then
  project_dir="$1"
  shift
fi

if [[ $# -gt 0 && "${1:-}" == "--" ]]; then
  shift
fi

project_dir="$(cd "$project_dir" && pwd)"
repo_url="${VERDIFY_SKILLS_REPO:-https://github.com/VerdifyConsultancy/verdify-skills.git}"
repo_ref="${VERDIFY_SKILLS_REF:-main}"

session_root="$(mktemp -d "${TMPDIR:-/tmp}/verdify-skills-session.XXXXXX")"
skills_repo="${session_root}/verdify-skills"
cleanup_paths=()

cleanup() {
  local path
  for path in "${cleanup_paths[@]}"; do
    rm -f "$path"
  done

  rmdir "${project_dir}/.agents/skills" 2>/dev/null || true
  rmdir "${project_dir}/.agents" 2>/dev/null || true

  if [[ "${VERDIFY_KEEP_SKILLS:-0}" != "1" ]]; then
    rm -rf "$session_root"
  else
    printf 'Kept Verdify skills clone at %s\n' "$skills_repo" >&2
  fi
}

trap cleanup EXIT INT TERM

git init --quiet "$skills_repo"
git -C "$skills_repo" remote add origin "$repo_url"
git -C "$skills_repo" fetch --quiet --depth 1 origin "$repo_ref"
git -C "$skills_repo" checkout --quiet --detach FETCH_HEAD

skill_dir="${skills_repo}/skills/verdify-agentic-sprint"
if [[ ! -f "${skill_dir}/SKILL.md" ]]; then
  printf 'Fetched repository does not contain %s\n' "$skill_dir" >&2
  exit 1
fi

case "$runtime" in
  codex)
    codex_skill_dir="${project_dir}/.agents/skills"
    codex_skill_link="${codex_skill_dir}/verdify-agentic-sprint"

    mkdir -p "$codex_skill_dir"
    if [[ -e "$codex_skill_link" || -L "$codex_skill_link" ]]; then
      printf 'Codex skill path already exists: %s\n' "$codex_skill_link" >&2
      printf 'Remove it or run from a clean project to use ephemeral Verdify skills.\n' >&2
      exit 1
    fi

    ln -s "$skill_dir" "$codex_skill_link"
    cleanup_paths+=("$codex_skill_link")

    cd "$project_dir"
    codex "$@"
    ;;

  claude)
    claude_host="${session_root}/claude-host"
    mkdir -p "${claude_host}/.claude/skills"
    ln -s "$skill_dir" "${claude_host}/.claude/skills/verdify-agentic-sprint"
    cleanup_paths+=("${claude_host}/.claude/skills/verdify-agentic-sprint")

    cd "$project_dir"
    claude --add-dir "$claude_host" "$@"
    ;;
esac
