# ADR-0012: The controller is a deterministic reconciler, not a model "god of the repo"

- Status: accepted
- Date: 2026-06-25

## Context

The transcript proposed a controller agent as the "god of the repo," holding goals and
state inside one model context and polling lane agents every five minutes. The
recommended-model critique calls this too much authority and hidden state in a single
model context.

## Decision

The repository controller is a **deterministic state machine backed by a durable event
log**, not an LLM conversation. Models are workers/proposers: they emit events
(`candidate_done`, `blocked`, `scope_change_requested`, `human_decision_required`,
`retry_recommended`), and the control plane:

1. loads current durable state,
2. validates the event against state and policy,
3. applies an idempotent transition,
4. schedules newly-ready tasks,
5. enforces retry/cost/risk/time budgets, and
6. persists the decision with evidence.

A model never mutates authoritative state from `running` to `done` directly. A periodic
process detects expired leases, missing heartbeats, lost jobs, stale PRs, undelivered CI
events, and GitHub/controller state mismatches — **liveness only**, not progress inferred
by scraping terminal text.

Sources of truth are separated: **Git** owns approved intent (plans, ADRs, code, skills);
**GitHub** owns backlog and delivery collaboration (issues, PRs, reviews, deployments);
the **runtime state store** owns execution state (claims, leases, attempts, events, costs,
heartbeats, normalized provider state); **CI and policy** are the gate authority.

## Consequences

`controller-loop` is specified as a reconciler runtime (`state-machine` mode) that consumes
`schemas/worker-run-event.schema.yaml` events and persists transitions to the session
ledger. The control-plane state machine, event/state store, and scheduler are **platform**
responsibilities (`jvallery/agents` loop-runtime / loop-state, epic `#1816`) per the layer
boundary in ADR-0018; verdify-skills owns the contracts and gates. This directly advances
`#36` and replaces the "god of the repo" framing.

- Evidence: `NSE-20260625-recommended-event-driven-sdlc-control-plane`,
  `NSE-20260625-walk-transcript-delivery-loop-topology`,
  `NSE-20260623-session-ledger-implementation-best-pract`,
  `NSE-20260624-agentic-loop-sdlc-best-practices`.
- Relates to: ADR-0016, ADR-0018; `#36`, `#43`; `ARQ-005`, `ARQ-025`, `ARQ-028`,
  `ARCH-013`.
