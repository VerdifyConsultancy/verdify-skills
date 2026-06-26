# ADR-0011: A wave is a versioned delivery envelope on a durable state machine

- Status: accepted
- Date: 2026-06-25

## Context

The walk transcript (`NSE-20260625-walk-transcript-delivery-loop-topology`) and the
recommended-model critique (`NSE-20260625-recommended-event-driven-sdlc-control-plane`)
define the runtime delivery loop. James framed two loops (planning, implementation);
Jason framed the operating contract (North Star, traceability, approvals, CI/CD gates,
human feedback). An earlier reconciliation drew the wave as a loop node with
planning/implementation branches, which conflates the review-cadence object with the
control flow.

## Decision

A wave is **not** a loop. A wave is a versioned, bounded **delivery envelope** — a set
of user stories, committed tasks, dependencies, risk limits, and exit evidence — that is
one turn of the controller's loop:

`PLAN -> EXECUTE -> VERIFY -> REVIEW`, cycling on review feedback.

PLAN folds in observe/draft/approve; VERIFY folds in integrate and preview/deploy;
REVIEW returns the landed wave to a human/Orbit and restarts PLAN. Planning and
implementation are **beats of one loop**, not separate loops. The wave is the unit
presented for human/Orbit review.

Once approved, the wave is versioned. Material scope change requires a wave amendment
with an audit record, a task decommit, or a replanned successor wave — never silent
in-flight scope growth ("while I'm here" work). CI green is necessary but not
sufficient; the wave exit gates are: all committed tasks terminal, integration CI green,
cumulative security review passed, acceptance scenarios passed, preview deployment
healthy, and evidence bundle complete.

## Consequences

`schemas/wave-contract.schema.yaml` captures the envelope, exit gates, and state. The
wave state machine is owned by the deterministic controller (ADR-0012). `sprint-planning`
produces an immutable proposed wave plan; `release-verification` proves the exit gates.
This resolves the `SRC-NS-001` / `NSQ-002` ambiguity in favour of a wave-scoped delivery
envelope with a wave integration branch; the existing `wave-release-plan.schema.yaml`
(`branch_model: wave_branch`) is the deployment facet of this envelope.

- Evidence: `NSE-20260625-walk-transcript-delivery-loop-topology`,
  `NSE-20260625-recommended-event-driven-sdlc-control-plane`,
  `NSE-20260623-cicd-sdlc-agent-orchestration-human-governed-delivery`.
- Relates to: ADR-0012, ADR-0014, ADR-0015; `PRQ-006`, `ARQ-006`, `NSQ-002`,
  `SRC-NS-001`; `PRODUCT-007` Waves.
