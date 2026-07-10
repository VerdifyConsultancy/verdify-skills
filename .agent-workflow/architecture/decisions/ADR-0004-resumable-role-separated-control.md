# ADR-0004: Resumable Role-Separated Control

Status: Approved

## Decision

Persist controller, session, lease, event, gate, closeout, critic, release, deployment, and outcome state outside conversation history. Separate planner, controller, worker, critic, release verifier, and outcome-owner authority; bind evidence to exact SHAs and identities.

## Alternatives

- One long-lived agent session owns all phases: rejected because it permits self-certification and loses state on interruption.
- Persist only Git branches: rejected because branches do not encode gates, resource ownership, reviews, or recovery state.

## Consequences

Transitions require durable artifacts and GitHub reconciliation. Recovery selects one deterministic next action. Role and reviewer availability become explicit operational dependencies.
