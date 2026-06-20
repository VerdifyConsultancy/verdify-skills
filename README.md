# Verdify Agentic Sprint Workflow v0.1

This package turns the Jason–James conversation about controller agents, lane-based execution, worktrees, voice-driven sprint reviews, adversarial review, reusable skills, integration, deployment, and sprint closure into a repeatable operating procedure.

It is intentionally **tool-neutral**. It can be run manually today with Claude Code, Codex, Cursor, Aider, OpenHands, or another coding agent, then converted into an Agent Skill and a durable workflow later.

## The central design

This is not one giant prompt. It is a stateful software-delivery workflow with four layers:

1. **Durable project truth** — code, Git history, GitHub issues/PRs, GitHub CI/CD, specifications, architecture records, and deployment evidence.
2. **Reusable procedures** — phase-specific prompts that later become skills.
3. **Isolated execution** — one logical lane per bounded responsibility, normally executed in its own Git worktree and agent session.
4. **Deterministic gates** — tests, CI, policy checks, clean Git state, review evidence, and deployment verification decide whether the workflow advances.

The model may recommend what should happen next. Deterministic checks and explicit human gates decide whether it is allowed to happen.

## Important definitions

- **Controller**: the agent responsible for reconstructing project state, planning the sprint, decomposing work, supervising lanes, reconciling outputs, and closing the sprint.
- **Lane**: a logical stream of responsibility bounded by domain, interfaces, acceptance criteria, and change ownership.
- **Backlog**: the set of GitHub issues and milestones that define candidate and approved work. Other inputs can propose backlog changes, but GitHub Issues remain the backlog source of truth.
- **Worktree**: a disposable Git isolation mechanism used to execute work for a lane. A lane and a worktree are related but are not synonymous.
- **Lane worker**: the coding agent executing one lane contract.
- **Critic**: a fresh-context reviewer that independently checks a lane against its contract and evidence.
- **Integrator**: a fresh controller session responsible for merge order, conflict resolution, whole-system tests, and release readiness.
- **Deployment verifier**: an agent or deterministic job that confirms the intended revision is actually running and behaving correctly.
- **Sprint contract**: the approved statement of the sprint objective, scope, non-goals, risks, acceptance criteria, and lane topology.
- **Lane contract**: the authoritative machine-readable definition of one lane, including its assigned GitHub issue IDs. The short worker prompt is compiled from this contract.
- **Integration controller**: the fresh session that merges approved lane branches/PRs in dependency order, resolves conflicts, and requires GitHub CI/CD evidence before deployment.

## Package contents

- `COMMON_OPERATING_CONTRACT.md` — rules every agent receives.
- `WORKFLOW.md` — complete step-by-step operating procedure.
- `verdify.workflow.yaml` — a draft state machine for later automation.
- `.agents/skills/verdify-agentic-sprint` — repo-scoped Codex skill entry point.
- `.claude/skills/verdify-agentic-sprint` — project-scoped Claude Code skill entry point.
- `AGENTS.md` — Codex repository guidance that routes Verdify work into the skill.
- `CLAUDE.md` — Claude Code repository guidance that routes Verdify work into the skill.
- `skills/verdify-agentic-sprint/` — canonical Agent Skills package.
- `prompts/` — exact prompts for each phase.
- `schemas/` — structured artifacts used to carry state between sessions.
- `templates/` — human-facing input and handoff templates.
- `docs/human-gates.md` — human and managing-agent gate model.
- `docs/agent-session-launch.md` — Codex and Claude session launch instructions.
- `evaluations/` — skill-level regression scenarios.
- `scripts/validate-repo.rb` — no-dependency repository validator.
- `scripts/setup-agent-hosts.rb` — checks or repairs Codex/Claude skill links.
- `scripts/launch-codex.sh` and `scripts/launch-claude.sh` — launch wrappers that check skill wiring before starting a session.
- `scripts/bootstrap-agent-session.sh` — remote-first launcher that fetches this repository into an ephemeral session directory before starting Codex or Claude.

## Quick manual use

1. Fetch this package through a launcher, workflow engine, or managing agent before the target agent session starts.
2. Create a sprint ID, for example `2026-06-20-a`.
3. Start a fresh controller session and provide:
   - `COMMON_OPERATING_CONTRACT.md`
   - `prompts/00-controller-bootstrap.md`
   - the repository path and sprint ID.
4. Run the prompts in numeric order, pausing only at explicit human gates.
5. Start every lane worker, critic, and integration controller in a fresh session.
6. Carry state between sessions through files, issues, pull requests, and evidence—not through hidden chat history.

## Remote-first session bootstrap

Verdify is intended to stay in its own repository. Target projects should not vendor or permanently copy the skills package. A session launcher should fetch this repository at startup, expose `skills/verdify-agentic-sprint` to the agent host, then remove the temporary clone when the session exits.

From any target project:

```bash
curl -fsSL https://raw.githubusercontent.com/VerdifyConsultancy/verdify-skills/main/scripts/bootstrap-agent-session.sh \
  | bash -s -- codex "$PWD"
```

For Claude Code:

```bash
curl -fsSL https://raw.githubusercontent.com/VerdifyConsultancy/verdify-skills/main/scripts/bootstrap-agent-session.sh \
  | bash -s -- claude "$PWD"
```

Pin a release, tag, branch, or commit for reproducible sessions:

```bash
VERDIFY_SKILLS_REF=v0.1.0 \
curl -fsSL https://raw.githubusercontent.com/VerdifyConsultancy/verdify-skills/main/scripts/bootstrap-agent-session.sh \
  | bash -s -- codex "$PWD"
```

For private forks or enterprise mirrors, set `VERDIFY_SKILLS_REPO`.

```bash
VERDIFY_SKILLS_REPO=git@github.com:VerdifyConsultancy/verdify-skills.git \
VERDIFY_SKILLS_REF=main \
./scripts/bootstrap-agent-session.sh codex /path/to/project
```

## Local Codex development

Codex scans repo-scoped skills from `.agents/skills`. This repository exposes the Verdify skill there as a symlink to the canonical package under `skills/verdify-agentic-sprint`.

Start a fresh Codex session in the repository and invoke the skill explicitly:

```text
$verdify-agentic-sprint start a test sprint for this repository with sprint id 2026-06-20-test. Create planning artifacts only and stop at the first human gate.
```

Or use the checked launch wrapper:

```bash
./scripts/launch-codex.sh
```

Run repository validation before committing:

```bash
ruby scripts/validate-repo.rb
```

## Local Claude Code development

Claude Code scans project skills from `.claude/skills`. This repository exposes the same Verdify skill there as a symlink to the canonical package under `skills/verdify-agentic-sprint`.

Start a fresh Claude Code session in the repository and invoke the skill explicitly:

```text
/verdify-agentic-sprint start a test sprint for this repository with sprint id 2026-06-20-test. Create planning artifacts only and stop at the first human gate.
```

Or use the checked launch wrapper:

```bash
./scripts/launch-claude.sh
```

Check both Codex and Claude links after cloning:

```bash
ruby scripts/setup-agent-hosts.rb --check
```

## Recommended source-of-truth boundaries

| Information | Authoritative location |
|---|---|
| Current implementation | Git default branch and tagged deployment revision |
| Current intended behavior | Living specifications, preferably OpenSpec or an equivalent |
| Proposed behavior change | Change proposal/spec delta |
| Backlog, work status, and discussion | GitHub issues and pull requests |
| Architecture decisions | Decision register and ADRs |
| Sprint orchestration state | `.verdify/sprints/<sprint-id>/state.yaml` or a workflow engine |
| Test, review, and deployment proof | Evidence manifests and GitHub CI/CD artifacts |
| Reusable organizational procedure | `skills/verdify-agentic-sprint/` |

## GitHub backlog and CI/CD model

Verdify treats GitHub Issues as the backlog source of truth. Audits, sprint reviews, and architecture interviews can identify missing, stale, duplicate, or incorrectly scoped work, but the sprint plan must reconcile those findings back into GitHub issues before work is dispatched.

Each approved issue is assigned to exactly one lane. A lane may contain multiple tightly related issues only when they share one coherent acceptance path and merge boundary. Lane workers operate on feature branches, open pull requests, keep assigned issues current, and stop for a scope-change gate before touching unassigned issue work.

Integration is PR-based: approved lane branches are merged in dependency order, conflicts are resolved with ownership rules from the lane contracts, repository-wide validation is run, and GitHub CI/CD must pass before deployment verification begins. Target repositories are assumed to test and deploy through GitHub Actions or equivalent GitHub-hosted CI/CD checks.

## Gate enforcement model

Human-in-the-loop gates are procedural in a plain skill session and mechanical only when paired with host controls, scripts, CI, a managing agent, or a workflow engine. Verdify records every gate as a structured artifact under `.verdify/sprints/<sprint-id>/gates/` so the same process can run manually today and become a durable interrupt later.

## Suggested command names for the eventual skill

- `/verdify:start-sprint`
- `/verdify:audit`
- `/verdify:ingest-review`
- `/verdify:interview`
- `/verdify:decide`
- `/verdify:plan`
- `/verdify:decompose`
- `/verdify:dispatch`
- `/verdify:lane-status`
- `/verdify:lane-close`
- `/verdify:critic`
- `/verdify:integrate`
- `/verdify:deploy`
- `/verdify:close-sprint`

## Research-derived design choices

This workflow adopts several established patterns rather than inventing them from scratch:

- Agent Skills package reusable procedures as a `SKILL.md` folder with optional scripts, references, and assets.
- Spec-driven development separates current truth from proposed changes, which is especially valuable in an existing codebase.
- Long-running workflows need durable state and explicit human-interrupt points rather than relying on one uninterrupted chat session.
- Independent review should use a fresh context and compare evidence to a contract rather than accepting a worker's self-report.

Relevant official projects include Agent Skills, OpenSpec, Temporal, and LangGraph. These are implementation options, not hard dependencies of this manual workflow.

## Recommended adoption sequence

### Stage 1 — Manual prompt pack

Use this package exactly as written. Learn where the prompts are too vague, where agents need tools, and which artifacts actually help.

### Stage 2 — Scripted context and validation

Add scripts that collect Git status, recent commits, issues, PRs, test commands, deployment metadata, and evidence. Validate every YAML/JSON artifact against a schema.

### Stage 3 — Agent Skill

Keep shared instructions in `SKILL.md`, keep large procedures in `references/`, and put deterministic operations in `scripts/`. Expose phase commands rather than one monolithic command.

### Stage 4 — Durable orchestration

Implement the state machine in Temporal, LangGraph, or another durable workflow runtime. Trigger agents as activities or child workflows, pause at human gates, and resume from persisted state.

### Stage 5 — Multi-project operating system

Run multiple project sprints concurrently, with a central dashboard showing only decision requests, blockers, deployment readiness, and sprint completion.
