# Launching Verdify Agent Sessions

This repository is wired for both Codex and Claude Code to discover the same canonical skill package under `skills/verdify-agentic-sprint`.

## Codex

Codex discovers the repo-scoped skill through:

```text
.agents/skills/verdify-agentic-sprint -> ../../skills/verdify-agentic-sprint
```

Codex also reads `AGENTS.md` before work starts. That file instructs Codex to use `verdify-agentic-sprint` for repository discovery, GitHub issue backlog planning, lane work, integration, deployment verification, and sprint closure.

Launch from the repository root:

```bash
./scripts/launch-codex.sh
```

Smoke test prompt:

```text
Start a Verdify test sprint for this repository with sprint id 2026-06-20-test. Create planning artifacts only and stop at the first human gate.
```

Explicit invocation remains available:

```text
$verdify-agentic-sprint start a sprint from GitHub issues #12 #13 #14
```

## Claude Code

Claude Code discovers the project skill through:

```text
.claude/skills/verdify-agentic-sprint -> ../../skills/verdify-agentic-sprint
```

Claude also reads `CLAUDE.md` before work starts. That file instructs Claude to use `/verdify-agentic-sprint` for the same workflow phases.

Launch from the repository root:

```bash
./scripts/launch-claude.sh
```

Smoke test prompt:

```text
/verdify-agentic-sprint start a Verdify test sprint for this repository with sprint id 2026-06-20-test. Create planning artifacts only and stop at the first human gate.
```

## Setup Check

Run this after cloning or changing skill wiring:

```bash
ruby scripts/setup-agent-hosts.rb --check
ruby scripts/validate-repo.rb
```

Use `--repair` if either symlink is missing:

```bash
ruby scripts/setup-agent-hosts.rb --repair
```
