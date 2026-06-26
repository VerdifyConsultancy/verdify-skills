# ADR-0017: Delivery vocabulary — wave, task, attempt (retire "sprint" as scope owner)

- Status: accepted
- Date: 2026-06-25

## Context

In the transcript, "wave," "sprint," "goal," and "milestone" all competed for scope
ownership, and the recurring question was "who decides?". The recommended-model critique
recommends removing "sprint" from the agent vocabulary and fixing explicit decision rights.

## Decision

Canonical delivery vocabulary:

- **Milestone** — an observable capability/outcome that can be demonstrated and accepted.
  Never a branch or worktree.
- **Wave** — the approved, bounded delivery envelope (ADR-0011) and the human/Orbit review
  cadence; owns committed scope.
- **User story** — integrated user-observable behavior with acceptance scenarios; generally
  vertical even when implementation crosses lanes.
- **Task / issue** — the smallest committed implementation unit.
- **Lane** — a per-wave write-conflict partition (ADR-0013).
- **Attempt** — one worker run against a task contract; a failed attempt does not change
  the task's committed objective.

"Sprint" is retired as a **scope-owning** concept: the wave owns committed scope and the
planner owns sequencing. Decision rights (detailed in the North Star loop-topology section):
the planner proposes wave objective, stories, and tasks; the scheduler assigns lanes; the
worker chooses local implementation; the controller authorizes scope changes via versioned
change requests; deterministic checks plus an independent verifier decide task completion;
CI, security, and acceptance decide wave releasability; human/Orbit decides product-intent
acceptance and high-risk production.

## Consequences

Existing skill and directory **names** (`sprint-planning`, `sprint-orchestrator`,
`.agent-workflow/sprints/`) are **retained** to avoid a breaking rename of the validated
package; their documentation adopts the wave/task/attempt semantics, and a "sprint"
artifact is defined as the durable record of one wave's execution. A future migration may
rename if warranted. A glossary is added to the North Star loop-topology section and a
shared `skills/<skill>/references/loop-glossary.md` reference.

- Evidence: `NSE-20260625-recommended-event-driven-sdlc-control-plane`,
  `NSE-20260625-walk-transcript-delivery-loop-topology`.
- Relates to: ADR-0011, ADR-0013; `ARCH-002`, `PRODUCT-007`.
