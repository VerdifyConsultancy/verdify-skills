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
| `route [--write]` | Determine + write the next skill/mode (`route-decision`) | project-router |
| `artifact validate --file P [--schema P]` | Validate an artifact against its `schema_ref` | every skill |
| `northstar ingest-research --file --title --summary [--id --type --status --source-uri --tag --claim --relevance --limitation]` | Register research as evidence | northstar-research-ingest |
| `northstar evidence list [--query --tag --json]` | Query the evidence registry | northstar-research-ingest, planning |
| `sprint init --id <id>` | Create a draft sprint skeleton + approval gate | sprint-planning |
| `lane create --sprint --lane-id --issue --session-id --agent` | Create + lock one worker worktree/lease | sprint-orchestrator |
| `lane review --lane-id --session-id --agent` | Create a fresh detached critic worktree/lease | independent-critic |
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
- **Pull requests:** every PR body must contain the sections `Backlog issue`,
  `Lane contract`, `Outcome`, `Scope proof`, `Evidence`, `Risk and deployment impact`,
  a `Closes #` keyword, and `Current head SHA` — enforced by `scripts/pr-policy.rb`
  (the `policy` check).
- **Branch protection (recommended):** required checks `validate` + `policy`, ≥1
  approving review, code-owner review, conversation resolution, no force-push/deletion,
  merge queue on busy repos.

Issue creation lives in `issue-triage`; `state-of-union` recommends but does not
create. See [`../github-operating-model.md`](../github-operating-model.md).
