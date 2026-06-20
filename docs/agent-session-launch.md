# Launching Verdify Agent Sessions

Verdify skills should be fetched at session startup rather than copied into every target project. The managing layer should treat `verdify-skills` as a remote dependency:

1. Fetch this repository at a pinned ref or approved branch.
2. Expose `skills/verdify-agentic-sprint` to the selected agent host before the agent starts.
3. Launch the TUI or noninteractive session in the target project.
4. Remove the temporary clone when the session exits.

This preserves one source of truth for the workflow while keeping target repositories focused on their own code, GitHub issues, pull requests, and CI/CD state.

For Kubernetes agent pods, use the dedicated handoff: [kubernetes-agent-handoff.md](kubernetes-agent-handoff.md). It defines the workspace layout, init or entrypoint bootstrap sequence, runtime skill paths, and GitHub-only delivery boundary.

## Bootstrap Script

Use the checked-in bootstrapper directly when developing this repository:

```bash
./scripts/bootstrap-agent-session.sh codex /path/to/project
./scripts/bootstrap-agent-session.sh claude /path/to/project
```

Use it from GitHub without first cloning this repository:

```bash
curl -fsSL https://raw.githubusercontent.com/VerdifyConsultancy/verdify-skills/main/scripts/bootstrap-agent-session.sh \
  | bash -s -- codex /path/to/project
```

```bash
curl -fsSL https://raw.githubusercontent.com/VerdifyConsultancy/verdify-skills/main/scripts/bootstrap-agent-session.sh \
  | bash -s -- claude /path/to/project
```

Pin the skill package for reproducible runs:

```bash
VERDIFY_SKILLS_REF=v0.1.0 \
curl -fsSL https://raw.githubusercontent.com/VerdifyConsultancy/verdify-skills/main/scripts/bootstrap-agent-session.sh \
  | bash -s -- codex /path/to/project
```

Use an enterprise mirror or private fork:

```bash
VERDIFY_SKILLS_REPO=git@github.com:VerdifyConsultancy/verdify-skills.git \
VERDIFY_SKILLS_REF=main \
./scripts/bootstrap-agent-session.sh claude /path/to/project
```

Set `VERDIFY_KEEP_SKILLS=1` to keep the temporary clone after the session for debugging.

## Codex

Codex discovers skills from `.agents/skills` at startup. Because skill discovery happens before the interactive TUI begins, a prompt-time clone is too late for first-class `$verdify-agentic-sprint` invocation.

The bootstrapper handles that ordering:

1. It clones `verdify-skills` into a temporary session directory.
2. It creates a temporary symlink at `<project>/.agents/skills/verdify-agentic-sprint`.
3. It starts `codex` from the project directory.
4. It removes the symlink and temporary clone after Codex exits.

Start Codex:

```bash
./scripts/bootstrap-agent-session.sh codex /path/to/project
```

Then invoke the skill:

```text
$verdify-agentic-sprint start a Verdify test sprint for this repository with sprint id 2026-06-20-test. Create planning artifacts only and stop at the first human gate.
```

## Claude Code

Claude Code can load skills from `.claude/skills` inside a directory passed through `--add-dir`. The bootstrapper uses this to avoid writing a project skill link:

1. It clones `verdify-skills` into a temporary session directory.
2. It creates a temporary host directory containing `.claude/skills/verdify-agentic-sprint`.
3. It starts `claude --add-dir <temporary-host>` from the project directory.
4. It removes the temporary clone after Claude exits.

Start Claude:

```bash
./scripts/bootstrap-agent-session.sh claude /path/to/project
```

Then invoke the skill:

```text
/verdify-agentic-sprint start a Verdify test sprint for this repository with sprint id 2026-06-20-test. Create planning artifacts only and stop at the first human gate.
```

## Local Repository Development

This repository still contains host links for local development:

```text
.agents/skills/verdify-agentic-sprint -> ../../skills/verdify-agentic-sprint
.claude/skills/verdify-agentic-sprint -> ../../skills/verdify-agentic-sprint
```

Use these only when working inside `verdify-skills` itself:

```bash
./scripts/launch-codex.sh
./scripts/launch-claude.sh
```

Check local development wiring:

```bash
ruby scripts/setup-agent-hosts.rb --check
ruby scripts/validate-repo.rb
```
