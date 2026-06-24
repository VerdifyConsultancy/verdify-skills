# ADR-0012: Define controller-loop and sprint-orchestrator ownership

- Status: accepted
- Date: 2026-06-24
- Resolves: #9, #23

## Context

`controller-loop` and `sprint-orchestrator` both participate in long-running
Verdify execution. `controller-loop` persists lifecycle state, wave state,
child sessions, gates, status events, and handoffs independently of model
conversation history. `sprint-orchestrator` moves an approved sprint into lane
worktrees and worker sessions, monitors lane events, reconciles GitHub state,
and routes closeout to critic and release roles.

Issues #9 and #23 identified that the shared "controller" vocabulary left two
risks unresolved:

- two skills could both appear responsible for session-ledger, controller, gate,
  lease, or GitHub reconciliation writes;
- controller-loop child-session launch could bypass the
  `agent-platform-control-request` policy artifact that sprint-orchestrator
  already requires for Agent Platform session operations.

The decision must preserve one authoritative writer per event class while still
allowing both skills to observe, report, and hand off durable evidence.

## Decision

`controller-loop` is the durable lifecycle controller. It is the only
authoritative writer for controller state and session-ledger events, including
events emitted during active sprint execution. `sprint-orchestrator` is the
active sprint execution coordinator. It is the authoritative writer for sprint
execution status and active-sprint GitHub reconciliation records, and it invokes
the Verdify lane lease commands for lane lease lifecycle changes.

### Event Ownership Matrix

| Event or state class | Authoritative writer | Required handoff or read behavior |
| --- | --- | --- |
| Session-ledger events | `controller-loop` | `sprint-orchestrator`, workers, critics, and release roles provide typed refs and concise event facts; controller-loop appends the ledger event or records an explicit ledger exception. |
| Controller state | `controller-loop` | Other skills read controller state and hand off status changes; they do not write controller state directly. |
| Sprint status | `sprint-orchestrator` | `controller-loop` reads sprint status and links to it from controller state or ledger events. |
| Lane lease state | `sprint-orchestrator` through `bin/verdify lane` lease commands | The lease file remains the local ownership record. `controller-loop` may observe lease state and record recovery events, but it does not edit lease files directly. |
| Gate state during active sprint execution | `controller-loop` after the authorized gate owner or human reviewer decides | `sprint-orchestrator` opens or reports the gate and pauses affected lanes; controller-loop records the gate state transition and ledger event. |
| GitHub reconciliation records for active sprint execution | `sprint-orchestrator` | GitHub remains the delivery control plane. `controller-loop` stores issue, PR, check, deployment, and reconciliation refs rather than duplicating GitHub state. |

### Handoff Sequence

| Transition | Sequence |
| --- | --- |
| Dispatch | `controller-loop` confirms durable prerequisites and opens or verifies any required Agent Platform control request; `sprint-orchestrator` dispatches the lane, invokes `bin/verdify lane create`, updates sprint status and GitHub refs, then hands lease, prompt, branch, issue, PR, and session refs to `controller-loop` for ledger append. |
| Heartbeat or status update | Worker or platform reports status; `sprint-orchestrator` records active sprint status; `controller-loop` appends the lifecycle-significant ledger event when the status changes controller-visible state. |
| Blocker | Worker reports blocker; `sprint-orchestrator` classifies whether it is within contract, coordination, scope change, or gate; `controller-loop` records blocked controller state and ledger event when work pauses or a gate is needed. |
| Closeout | Worker writes closeout; `sprint-orchestrator` verifies branch, PR, checks, closeout path, and sprint status; `controller-loop` appends worker-closeout and handoff events. |
| Critic result | Critic records approval or requested changes; `sprint-orchestrator` routes the lane to fix-forward or release verification; `controller-loop` records critic outcome and next controller action. |
| CI failure | GitHub check fails; `sprint-orchestrator` owns GitHub/check reconciliation and routes the failure to the lane owner; `controller-loop` records the CI observation only when it changes lane, gate, or wave state. |
| Lease expiry | `sprint-orchestrator` inspects lease state and determines whether a lane is expired or abandoned; `controller-loop` records session loss, recovery, or abandonment in controller state and the session ledger. |
| Gate decision | Gate owner or human reviewer decides; `controller-loop` writes gate state and ledger event; `sprint-orchestrator` resumes, reroutes, or blocks sprint execution according to that state. |
| Integration handoff | After required critic and review evidence, `sprint-orchestrator` hands approved lane refs to release verification or integration; `controller-loop` records the handoff event and next role. |
| Session loss | Platform, terminal, or worker session becomes unreachable; `sprint-orchestrator` gathers lease, PR, branch, and artifact evidence; `controller-loop` determines recoverable, abandoned, or blocked state and appends the session-loss ledger event. |

### Trigger Disambiguation

Invoke `sprint-orchestrator` when an approved sprint or wave needs lane
dispatch, lane polling, lease/worktree coordination, PR/check reconciliation,
worker closeout routing, critic routing, CI failure routing, or review
deployment readiness coordination.

Invoke `controller-loop` when the work is to reconstruct or persist durable
lifecycle state across model context loss, maintain controller state, maintain
the session ledger, manage wave state, record gate transitions, recover from
session loss, or coordinate handoffs across lifecycle phases.

When a request says "controller loop" but asks for lane agents, polling, MCP
dispatch, tmux or browser terminal supervision, CI/CD observation, or active
sprint execution, route the execution work to `sprint-orchestrator` and route
durable controller-state and session-ledger writes to `controller-loop`.

### Child Session Launch Gate

`controller-loop` must not launch a child session through Agent Platform API,
MCP, local operator shell, or any other privileged session-creation mechanism
unless a matching `AgentPlatformControlRequest` artifact exists or a referenced
approved runbook explicitly covers that exact session-create operation. The
request must cover the session surface, requester, target repository, lane or
wave refs, authorization, policy decision, expected effects, result handling,
review, and handoff.

If no matching control request or runbook authorization exists,
`controller-loop` stops and opens the required gate instead of launching the
session. A documented manual handoff may transfer responsibility to an operator
or to `sprint-orchestrator`, but if that handoff creates a child session, it is
also subject to the same `AgentPlatformControlRequest` requirement.

## Consequences

- `controller-loop` becomes the single durable state and session-ledger writer,
  which makes session recovery and audit reconstruction deterministic.
- `sprint-orchestrator` remains the skill that actively runs approved sprint
  execution and reconciles GitHub delivery state.
- Active sprint execution must hand concise refs and event facts to
  `controller-loop` rather than writing competing controller or ledger state.
- Controller-loop child-session launches are gated by the same policy artifact
  family used for other Agent Platform session operations, closing the ungated
  launch concern in #23.
- Downstream updates to skill descriptions, router wording, runbook templates,
  and examples should conform to this ADR, but this decision does not require a
  schema change.
