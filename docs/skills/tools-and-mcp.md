# Tools, CLI, MCP & GitHub primitives

The skills act through three tool surfaces: the dependency-light **`bin/verdify` CLI**
(ships with this package), the **Agent Platform MCP/API** (the runtime, owned by
`jvallery/agents`), and **GitHub** (the control plane).

## `bin/verdify` CLI

Dependency-light Ruby (`lib/verdify/`). Run `bin/verdify <command> --help` for options.

| Command | What it does | Used by |
|---|---|---|
| `doctor` | Check target-repo prerequisites | operator |
| `init` | Initialize `.agent-workflow` in a target repo (`project-config`) | install |
| `route [--sprint ID] [--write]` | Determine + write the next skill/mode; fail closed on invalid D/I/E/S lane evidence, review submissions, or controller packet history (`route-decision`) | project-router |
| `artifact validate --file P [--schema P]` | Validate an artifact against its `schema_ref` | every skill |
| `northstar ingest-research --file --title --summary [--id --type --status --source-uri --tag --claim --relevance --limitation]` | Register research as evidence | northstar-research-ingest |
| `northstar evidence list [--query --tag --json]` | Query the evidence registry | northstar-research-ingest, planning |
| `sprint init --id <id>` | Create a draft sprint skeleton + approval gate | sprint-planning |
| `lane create --sprint --lane-id --issue --session-id --agent` | Create + lock one worker worktree/lease | sprint-orchestrator |
| `lane review --lane-id --session-id --agent` | Fetch live PR evidence head E, require a critic agent and session distinct from the closeout's worker identity, validate I→E, and create a detached critic worktree/lease | independent-critic |
| `lane list` | List local leases + Git worktrees | controller-loop, orchestrator |
| `lane inspect --lease-id` | Inspect one lease + worktree status | lane-delivery, critic |
| `lane release [--keep-worktree]` | Release a lease (and normally remove its worktree) | orchestrator, fix-forward |
| `prompt compile --contract --role` | Compile a bounded worker/critic prompt + input hashes | orchestrator |
| `github bootstrap [--apply]` | Preview/apply standard Verdify labels | maintainer, orchestrator |
| `github snapshot` | Cache current issues + PRs locally (`github-snapshot`) | state-of-union, orchestrator |
| `github reconcile --sprint` | Compare lane contracts with the snapshot (`github-reconciliation`) | state-of-union, orchestrator |

## Agent Platform MCP / API (runtime — `jvallery/agents`)

Per [ADR-0016](../decisions/ADR-0016-package-platform-skill-reconciliation.md), the
**package owns the method; the platform owns the runtime.** Verdify skills do not call
runtime tools directly — they **model a proposed operation** as an
`agent-platform-control-request` artifact (requester, target, authorization, policy
verdict, mutation level, expected effects, result refs, review gate), and the
platform executes it. The real platform surface the skills target:

| Surface | Operation | Notes |
|---|---|---|
| In-pod stdio MCP | `add_worktree_agent`, `list_agents`, `remove_worktree_agent` | Create/list/remove a worktree worker session inside a repo pod. |
| Dashboard API | `POST /api/repos/{owner}/{name}/agents` | Network entrypoint for session creation (SSO-gated). |
| Terminals | `GET /api/tty` (`tty_bridge.py`) | Browser/tmux terminal visibility into a session. |
| Onboarding | `/install`, `/api/connect` | Operator onboarding boundary. |

`sprint-orchestrator` records these as runbook dispatch steps; `platform-readiness`
gates them; `controller-loop` ties each launched session into the `session-ledger`.
Routine orchestration is API/MCP-first; the dashboard UI is for inspection, review,
recovery, and operator override.

## GitHub primitives (control plane)

From [`../../config/github-primitives.yaml`](../../config/github-primitives.yaml).
GitHub Issues are the backlog; PRs/checks/reviews/deployments are delivery truth.

- **Issue model:** issues = backlog owner; default one issue per lane; native
  sub-issues + dependencies; close after verified outcome or explicit policy.
- **Labels:** `type:problem`, `type:decision`, and the `verdify:*` lifecycle labels
  (`sprint`, `lane`, `discovered-work`, `blocker`, `decision-required`,
  `ready-for-critic`, `changes-requested`, `ready-for-integration`,
  `deployment-ready`, `verified`, `policy-exempt`) plus `risk:high` / `risk:critical`.
- **Project fields:** Sprint, Lane, Workflow state, Risk, Target environment, Evidence.
- **Pull requests:** every implementation PR body must contain the sections
  `Backlog issue`, `Lane contract`, `Outcome`, `Scope proof`, `Evidence`, and
  `Risk and deployment impact`; a `Closes #` keyword; and exact
  `Implementation head SHA`, `Evidence head SHA`, and `Current head SHA`
  metadata. `Evidence head SHA: pending` is valid only while current head equals
  I. Otherwise I→E may add only the canonical closeout and E→S only the critic
  report. The protected-base `scripts/pr-policy.rb` enforces this as the
  `policy` check.
- **Review approval:** the latest effective review from the packet's recorded
  repository admin or maintainer must be `APPROVED` on S; that reviewer must not
  be the PR author. A later commit or later change-request invalidates it.
- **Controller evidence:** `controller/<sprint-id>` contains evidence only. The
  review packet is the sole path in packet commit P; only canonical
  release/outcome/status evidence may follow. Merge lane PRs individually and
  never use the controller branch as an integration candidate.
- **Branch protection (recommended):** required checks `validate` + `policy`, ≥1
  approving review, code-owner review, conversation resolution, no force-push/deletion,
  merge queue on busy repos.

Issue creation lives in `issue-triage`; `state-of-union` recommends but does not
create. See [`../github-operating-model.md`](../github-operating-model.md).
