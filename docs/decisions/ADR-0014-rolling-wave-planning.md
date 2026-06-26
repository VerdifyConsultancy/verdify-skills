# ADR-0014: Rolling-wave planning with issues as a planning output

- Status: accepted
- Date: 2026-06-25

## Context

The transcript called for North Star traceability all the way down to every future button,
API, and GitHub issue. The recommended-model critique warns that exhaustive future
decomposition becomes stale and that issues should be an output of planning, not the raw
plan.

## Decision

Adopt **rolling-wave planning**. Maintain complete **outcome-level** traceability across
the whole roadmap (North Star -> milestone -> wave), but decompose only the **next one or
two waves** to issue/task-level contracts. Issues are an **output** of the planning pass,
not its raw input.

Canonical planning-pass order:

1. Snapshot facts: merged code, open PRs, CI state, telemetry, feedback, backlog,
   unresolved decisions, current North Star.
2. Select the next outcome and define the wave objective.
3. Define user stories and their acceptance evidence.
4. Discover the implementation delta.
5. Derive or update tasks and dependencies.
6. Compute write conflicts, sequencing, risk, and capacity.
7. Materialize or update GitHub issues.
8. Produce an immutable proposed wave plan.
9. Approve it. 10. Execute it.

## Consequences

`sprint-planning` (`issue-readiness`, `sprint-plan`, `lane-transaction` modes) follows this
order and bounds decomposition depth to the active and next wave. Traceability is complete
for what is currently committed, not falsely detailed for hypothetical features.
`northstar-planning` retains roadmap-level traceability and the North Star maintainer role.

- Evidence: `NSE-20260625-recommended-event-driven-sdlc-control-plane`,
  `NSE-20260625-walk-transcript-delivery-loop-topology`,
  `NSE-20260624-comprehensive-planning-and-review-loop-b`.
- Relates to: ADR-0011; `PRODUCT-006` Milestones, `PRODUCT-007` Waves, `ARCH-012`.
