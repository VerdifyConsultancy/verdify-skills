# Vendor-neutral worker adapter and event-driven orchestration

How the orchestrator dispatches and supervises lane workers. Decision: ADR-0016.
Event shape: `../../schemas/worker-run-event.schema.yaml`.

## Why an adapter

Terminal polling every five minutes is a prototype fallback, not the primary
protocol. Lane orchestration is event-driven through one vendor-neutral worker
adapter so the controller logic is identical regardless of execution engine.
Claude Code and Codex are replaceable execution engines, never the durable
controller or source of truth.

## Adapter interface

```text
start(task, workspace, policy) -> RunId
events(runId)                  -> stream of normalized RunEvent
send(runId, message)           -> deliver a controller message
cancel(runId, reason)          -> stop a run
collect(runId)                 -> ResultPacket
```

## Normalized RunEvent types

`run.started`, `task.oriented`, `plan.created`, `command.started`,
`file.changed`, `test.completed`, `progress.reported`, `decision.requested`,
`task.blocked`, `candidate.completed`, `run.failed`, `run.stopped`.

Each event may carry a `proposal` (the controller-message vocabulary):
`candidate_done`, `blocked`, `scope_change_requested`,
`human_decision_required`, `retry_recommended`. The controller validates the
proposal against state and policy and records the authorized `state_transition`
(ADR-0012). Workers never mutate authoritative state directly.

## Substrates (controller picks per host)

- **Claude** — Agent SDK / in-session subagent fan-out; in-session eventing when
  a lane agent finishes. Teams suit independent tasks; keep file ownership
  distinct.
- **Codex** — `codex exec --json` for a process adapter that emits a structured
  JSONL stream, or the SDK for durable/resumable threads. Subagents are requested
  explicitly and suit read-heavy exploration/test/review work.

Common policy: one active writer per worktree and branch; parallelize only tasks
whose dependencies are satisfied and whose expected write sets do not conflict.
Provider hooks are local guardrails; cross-vendor invariants live in the
controller, sandbox, and CI.

> The provider capability claims above derive from a post-cutoff source
> (`NSE-20260625-recommended-event-driven-sdlc-control-plane`) and must be
> verified against live Codex/Claude documentation before implementation.

## Polling is liveness-only

A periodic process detects expired leases, missing heartbeats, lost jobs, stale
PRs, undelivered CI events, and GitHub/controller state mismatches. It does not
scrape terminal text to infer progress.

## Layer boundary

The adapter and event-store **runtime** are Agent Platform responsibilities
(`jvallery/agents`); regrounding the orchestrator from invented MCP tool names to
this adapter contract plus the validated
`../../schemas/agent-platform-control-request.schema.yaml` path is the resolution
path for `VerdifyConsultancy/verdify-skills#12` and `#36` (ADR-0018).
