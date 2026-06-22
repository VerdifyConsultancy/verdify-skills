# Verdify Lifecycle Skills

Verdify is an end-to-end, GitHub-native operating system for moving software work from uncertain project context to verified deployment. It packages nine coherent Agent Skills, deterministic repository tooling, schemas, GitHub templates, and a lane/worktree execution model.

The repository is deliberately not one giant sprint prompt. Each skill owns a bounded lifecycle responsibility, consumes durable artifacts, produces durable artifacts, and hands off without relying on hidden chat history.

## Lifecycle

```text
project-router
  -> project-definition
       discovery -> requirements -> product -> design surface
  -> architecture-contracts
       north-star architecture -> black-box module contracts
  -> state-of-union
       backlog alignment -> execution strategy -> next sprint candidates
  -> sprint-planning
       issue selection -> sprint plan -> lane topology -> lane contracts
  -> sprint-orchestrator
       dispatch -> monitor -> reconcile
       |-> lane-delivery (one worker session in one worktree)
       |-> independent-critic (fresh session and review worktree)
  -> release-verification
       integration -> deployment verification -> outcome review
  -> project-router
```

The 17 detailed stages from the original outline remain represented in `verdify.workflow.yaml`; the nine top-level skills reduce activation ambiguity and context overhead.

## Non-negotiable operating model

- **GitHub is the control plane.** Issues, pull requests, checks, reviews, releases, and deployments are the operational source of truth.
- **GitHub Issues are the backlog.** Every approved implementation lane maps to an issue. Discovered work becomes another issue rather than unapproved scope.
- **Typed authority prevents competing truths.** Issues own backlog intent; lane contracts own executable scope; pull requests own proposed code; the default branch owns accepted code; ADRs own architecture decisions; checks and deployment records own evidence.
- **One issue = one lane = one branch = one worktree = one pull request** by default. A coupled multi-issue lane requires an explicit justification and approval.
- **One coding agent/session per worktree.** A local lease prevents two worker sessions from owning the same lane. Critics use a fresh session and a separate detached review worktree.
- **Worktrees are disposable execution locations, not durable identity.** Lane ID, issue, branch, baseline SHA, contract, and lease identify work.
- **No self-certification.** Deterministic checks and a fresh critic precede integration.
- **Merge is not deployment.** The intended revision must be proven in the target environment before outcome acceptance.

See `config/authority-matrix.yaml`, `COMMON_OPERATING_CONTRACT.md`, and `docs/lane-worktrees.md` for the precise rules.

## Repository contents

```text
skills/                     Nine canonical Agent Skills
.agents/skills/             Codex discovery links
.claude/skills/             Claude Code discovery links
bin/verdify                 Dependency-free lifecycle CLI
lib/verdify/                CLI, Git, schema, and routing implementation
schemas/                    Canonical artifact schemas
config/                     Authority, lifecycle, GitHub, and policy defaults
.github/                    Issue forms, PR template, CODEOWNERS, workflows
examples/minimal-project/   A complete validated artifact chain
verdify.workflow.yaml       Full lifecycle and lane child workflow
```

There are no duplicated root prompt packs or schema copies inside individual skills. Skill detail is progressively disclosed through focused `references/` files.

## Validate this package

Requirements: Ruby 3.1+, Git, and Bash. Node.js/npm are required for the `npx` installer test. GitHub CLI is required only for GitHub synchronization commands.

```bash
make test
```

The validator checks skill frontmatter, references, host links, workflow transitions, schemas, example artifacts, issue forms, evaluations, executable scripts, and duplicate-content guardrails.

Release archives include `MANIFEST.sha256`. Verify an archive after download with:

```bash
bash scripts/verify-package.sh /path/to/verdify-lifecycle-skills-v1.0.0.zip
```

## Install in a target repository

Run one command from the target repository root:

```bash
npx @verdify/cli@latest init
```

Pin the version for reproducible setup:

```bash
npx @verdify/cli@1.0.0 init
```

The installer creates a small, explicit agent footprint:

```text
.agent-skills/
  verdify-skills/
    1.0.0/
.agent-workflow/
  config.yaml
  router/
  project/
  architecture/
  sprints/
.agents/
  skills/
AGENTS.md
```

`.agent-skills` contains the installed Verdify skills package. `.agent-workflow` contains durable project workflow artifacts such as route decisions, definitions, contracts, sprint records, status, and evidence. `.agents/skills` contains host discovery symlinks into the installed package.

Use the Ruby CLI directly when developing against a local checkout:

```bash
/path/to/verdify-skills/bin/verdify init --repo /path/to/target
/path/to/verdify-skills/bin/verdify doctor --repo /path/to/target
/path/to/verdify-skills/bin/verdify route --repo /path/to/target --write
```

Start a sprint after project and module contracts are approved:

```bash
bin/verdify sprint init --repo /path/to/target --id 2026-06-22-a
```

After `sprint-planning` creates an approved lane contract, dispatch exactly one worker session:

```bash
bin/verdify lane create \
  --repo /path/to/target \
  --sprint 2026-06-22-a \
  --lane-id issue-123-api \
  --issue 123 \
  --session-id codex-20260622-001 \
  --agent codex
```

Compile a bounded worker prompt from authoritative inputs:

```bash
bin/verdify prompt compile \
  --repo /path/to/target \
  --contract .agent-workflow/sprints/2026-06-22-a/lanes/contracts/issue-123-api.contract.yaml \
  --role worker
```

Create a fresh detached worktree for independent review:

```bash
bin/verdify lane review \
  --repo /path/to/target \
  --lane-id issue-123-api \
  --session-id critic-20260622-001 \
  --agent codex
```

## GitHub bootstrap and reconciliation

Preview the idempotent label setup:

```bash
bin/verdify github bootstrap --repo OWNER/REPOSITORY
```

Apply it explicitly:

```bash
bin/verdify github bootstrap --repo OWNER/REPOSITORY --apply
```

Capture a local cache of current issues and pull requests, then compare it with lane contracts:

```bash
bin/verdify github snapshot --repo OWNER/REPOSITORY --target /path/to/target
bin/verdify github reconcile --repo-path /path/to/target --sprint 2026-06-22-a
```

GitHub remains authoritative; `.agent-workflow/github/snapshot.json` is an ignored cache.

## Agent host setup

This repository exposes every canonical skill to Codex and Claude Code through symlinks:

```bash
ruby scripts/setup-agent-hosts.rb --check
```

For ephemeral use from another repository, pin an immutable release or commit:

```bash
VERDIFY_SKILLS_REF=v1.0.0 \
curl -fsSL https://raw.githubusercontent.com/VerdifyConsultancy/verdify-skills/v1.0.0/scripts/bootstrap-agent-session.sh \
  | bash -s -- codex "$PWD"
```

The bootstrapper rejects moving refs such as `main` unless `VERDIFY_ALLOW_MOVING_REF=1` is explicitly set.

## Repository-specific setup still required

Before enforcing code-owner review, replace the commented example in `.github/CODEOWNERS`. Repository administrators should also configure a ruleset or protected branch with required checks, at least one approving review, conversation resolution, and—on busy repositories—a merge queue. Deployment environments and their approvers remain project-specific.

## Design documentation

- `docs/lifecycle.md` — stages, handoffs, and gates
- `docs/authority-model.md` — typed source-of-truth boundaries
- `docs/github-operating-model.md` — issues, PRs, Projects, checks, and deployments
- `docs/lane-worktrees.md` — lane leases, worktrees, runtime namespaces, and cleanup
- `docs/security-and-permissions.md` — least privilege and production separation
- `docs/research/industry-alignment.md` — primary-source design rationale
- `docs/migration-from-v0.1.md` — migration from the original single sprint skill
