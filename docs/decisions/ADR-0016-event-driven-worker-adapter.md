# ADR-0016: Event-driven orchestration via a vendor-neutral worker adapter

- Status: accepted
- Date: 2026-06-25

## Context

The transcript polled lane terminals every five minutes and noted the difference between
Claude in-session fan-out and Codex multi-session execution. The current `sprint-orchestrator`
dispatch references MCP tool names that do not exist on the live platform
(`VerdifyConsultancy/verdify-skills#12`). The recommended-model critique calls terminal
polling brittle and prescribes structured worker events through a normalized adapter.

## Decision

Lane orchestration is **event-driven** through one **vendor-neutral worker adapter**
interface:

- `start(task, workspace, policy) -> RunId`
- `events(runId) -> stream of normalized RunEvents`
  (`run.started`, `plan.created`, `command.started`, `file.changed`, `test.completed`,
  `progress.reported`, `decision.requested`, `task.blocked`, `candidate.completed`,
  `run.failed`, `run.stopped`)
- `send(runId, message)`
- `cancel(runId, reason)`
- `collect(runId) -> ResultPacket`

Both substrates implement it — Claude (Agent SDK / in-session fan-out) and Codex
(`exec --json` / SDK threads) — and the controller selects per host (resolves `NSQ-011`).
Polling and heartbeats exist only to detect lost workers. Provider hooks are local
guardrails; cross-vendor invariants live in the controller, sandbox, and CI.

## Consequences

`schemas/worker-run-event.schema.yaml` defines the normalized event and controller-message
vocabulary. `sprint-orchestrator` is regrounded from invented MCP calls to the adapter
contract plus the validated `agent-platform-control-request` path, directly addressing
`#12`. The adapter **runtime** is a platform responsibility (ADR-0018); verdify-skills owns
the event and result contract. The Codex/Claude SDK capability claims in the source are
post-cutoff and must be verified against live documentation before implementation.

- Evidence: `NSE-20260625-recommended-event-driven-sdlc-control-plane`,
  `NSE-20260625-walk-transcript-delivery-loop-topology`,
  `NSE-20260623-agent-platform-control-implementation-be`.
- Relates to: ADR-0012, ADR-0018; `#12`, `#36`, `NSQ-011`; `ARQ-017`, `IFACE-012`,
  `IFACE-020`.
