# Kubernetes Agent Pod Handoff

This document is for the agent or operator that manages Verdify Kubernetes agent pods. It defines how each pod should fetch and expose the Verdify skill package when launching an agent against a target repository.

## Objective

When an agent pod starts for a target repository, it must:

1. Clone the target project repository into the pod workspace.
2. Clone `verdify-skills` into the same ephemeral workspace at an approved ref.
3. Expose `skills/verdify-agentic-sprint` through the selected agent runtime's skill discovery path before the agent process starts.
4. Launch the agent with an explicit Verdify skill invocation and assigned GitHub issue or lane context.
5. Treat GitHub Issues, pull requests, Actions, checks, and deployment records as the source of truth for work state and evidence.

Do not vendor `verdify-skills` into target repositories. The skills repository is a runtime dependency of the agent pod, not application source code.

## Recommended Pod Workspace

Use an ephemeral volume, normally `emptyDir`, mounted by the checkout/init step and the agent container:

```text
/workspace/
  project/                 # target repository checkout
  verdify-skills/          # Verdify skills checkout at pinned ref
  agent-home/              # ephemeral HOME and runtime config
```

The pod may discard the entire workspace after the run. Durable state belongs in GitHub issues, pull requests, commits, CI/CD artifacts, and `.verdify/` artifacts committed or attached where the workflow requires them.

## Required Inputs

The pod launcher should provide these values explicitly:

```text
TARGET_REPO_URL        Git URL for the target project.
TARGET_REF             Branch, tag, or commit to check out.
VERDIFY_SKILLS_REPO    Git URL for verdify-skills.
VERDIFY_SKILLS_REF     Approved branch, tag, or commit for the skill package.
AGENT_RUNTIME          codex or claude.
GITHUB_OWNER           Repository owner or organization.
GITHUB_REPO            Repository name.
GITHUB_ISSUE_IDS       One or more GitHub issues assigned to the lane.
SPRINT_ID              Verdify sprint identifier.
LANE_ID                Verdify lane identifier.
```

Prefer a pinned tag or commit for `VERDIFY_SKILLS_REF` in production. Use a branch only for development environments.

## Bootstrap Sequence

Run this before the agent starts:

```bash
set -euo pipefail

: "${TARGET_REPO_URL:?}"
: "${TARGET_REF:?}"
: "${VERDIFY_SKILLS_REPO:?}"
: "${VERDIFY_SKILLS_REF:?}"
: "${AGENT_RUNTIME:?}"

rm -rf /workspace/project /workspace/verdify-skills /workspace/agent-home
mkdir -p /workspace /workspace/agent-home

git clone --filter=blob:none "$TARGET_REPO_URL" /workspace/project
git -C /workspace/project checkout "$TARGET_REF"

git clone --filter=blob:none "$VERDIFY_SKILLS_REPO" /workspace/verdify-skills
git -C /workspace/verdify-skills checkout "$VERDIFY_SKILLS_REF"

test -f /workspace/verdify-skills/skills/verdify-agentic-sprint/SKILL.md

export HOME=/workspace/agent-home
export CODEX_HOME=/workspace/agent-home/.codex

mkdir -p "$HOME/.agents/skills" "$HOME/.claude/skills" "$CODEX_HOME"

ln -sfn /workspace/verdify-skills/skills/verdify-agentic-sprint \
  "$HOME/.agents/skills/verdify-agentic-sprint"

ln -sfn /workspace/verdify-skills/skills/verdify-agentic-sprint \
  "$HOME/.claude/skills/verdify-agentic-sprint"
```

If the image includes Ruby, run the repository validator before launch:

```bash
ruby /workspace/verdify-skills/scripts/validate-repo.rb
```

## Runtime Skill Exposure

### Codex

Codex must see the skill before the Codex process starts.

Expose the skill at:

```text
$HOME/.agents/skills/verdify-agentic-sprint
```

Use an ephemeral Codex home for pod-level guidance:

```bash
export CODEX_HOME=/workspace/agent-home/.codex
mkdir -p "$CODEX_HOME"
```

Write this global guidance before launch:

```bash
cat > "$CODEX_HOME/AGENTS.md" <<'EOF'
# Verdify Pod Guidance

Use the verdify-agentic-sprint skill for backlog, sprint, lane, critic, integration, deployment evidence, and closure workflows.

GitHub Issues are the backlog source of truth. Work only on assigned issues for this lane. Use feature branches and pull requests. Treat GitHub Actions, checks, and deployment records as the authoritative evidence for tests and delivery state.

Do not assume local deployments or local tests are available in this pod.
EOF
```

Launch examples:

```bash
cd /workspace/project

codex exec \
  --cd /workspace/project \
  "$VERDIFY_CODEX_PROMPT"
```

Recommended prompt shape:

```text
$verdify-agentic-sprint execute lane <LANE_ID> for sprint <SPRINT_ID> using GitHub issues <GITHUB_ISSUE_IDS>. Use GitHub as the backlog and CI/CD source of truth. Open or update the lane PR, monitor GitHub checks, record evidence, and stop at any human gate.
```

### Claude Code

Expose the skill at:

```text
$HOME/.claude/skills/verdify-agentic-sprint
```

Launch examples:

```bash
cd /workspace/project

claude -p "$VERDIFY_CLAUDE_PROMPT"
```

Recommended prompt shape:

```text
/verdify-agentic-sprint execute lane <LANE_ID> for sprint <SPRINT_ID> using GitHub issues <GITHUB_ISSUE_IDS>. Use GitHub as the backlog and CI/CD source of truth. Open or update the lane PR, monitor GitHub checks, record evidence, and stop at any human gate.
```

Claude Code can also load `.claude/skills` from a directory passed through `--add-dir`, but `$HOME/.claude/skills` is the simplest pod-wide convention.

## GitHub-Only Delivery Boundary

Agent pods are isolated execution environments. They should not rely on local deployments or local test runs as delivery evidence.

The expected delivery loop is:

1. Read assigned GitHub issues and current repository state.
2. Create or update a lane branch.
3. Commit focused changes for the assigned issues only.
4. Open or update the lane pull request.
5. Let GitHub Actions and repository checks run.
6. Poll GitHub checks, workflow runs, and deployment records.
7. Record evidence in the PR, issue comments, and Verdify artifacts.
8. Stop at any human gate, policy exception, scope change, failing required check, or merge conflict requiring ownership decisions.

The pod can run lightweight local inspection commands such as `git status`, `git diff`, `rg`, schema validation, or static artifact checks. It must not treat local app startup, local tests, or local deployment simulation as the source of truth for completion.

## Minimal Kubernetes Shape

Use one shared workspace volume:

```yaml
volumes:
  - name: workspace
    emptyDir: {}
```

Use either:

```text
initContainer checkout/bootstrap -> agent container
```

or:

```text
single agent container entrypoint performs checkout/bootstrap, then execs the agent runtime
```

The entrypoint approach is usually simpler unless the cluster already has a standard Git checkout init container.

The agent container needs:

```text
git
ssh or HTTPS Git credentials
codex and/or claude runtime
gh CLI or GitHub API access
network access to GitHub
write access to the emptyDir workspace
```

Store credentials in Kubernetes Secrets and mount them as environment variables or files. Prefer GitHub App installation tokens with narrow repository access.

## Acceptance Criteria For Cluster Implementation

The Kubernetes agent launcher is complete when:

1. A pod can launch against any approved GitHub repository and issue assignment.
2. `verdify-skills` is cloned at a pinned ref for each run.
3. Codex can invoke `$verdify-agentic-sprint` from inside `/workspace/project`.
4. Claude Code can invoke `/verdify-agentic-sprint` from inside `/workspace/project`.
5. The target repository is not modified with persistent skill-package files unless the lane itself intentionally changes project code.
6. The agent creates or updates branches and PRs through GitHub.
7. Required checks and deployment evidence are collected from GitHub.
8. Human gates are recorded before work advances past planning, scope changes, integration, deployment approval, or sprint closure.

## Anti-Patterns

Avoid these patterns:

- Committing `verdify-skills` into each target repository.
- Asking the agent to clone the skill package after its session starts and expecting first-class skill discovery.
- Relying on local tests or local deployments as completion evidence.
- Launching with an unpinned `VERDIFY_SKILLS_REF` in production.
- Giving a lane agent more GitHub issues than its lane contract assigns.
- Letting a lane agent merge its own PR without critic and integration steps.
