# ADR-0013: A lane is a dynamic write-conflict partition (amends ADR-0003)

- Status: accepted
- Date: 2026-06-25
- Amends: ADR-0003

## Context

In the transcript, James proposed one milestone per worktree; Jason proposed a lane as a
functional area of the codebase (API, frontend, database, backend) spanning a user story,
with lanes converging on a wave branch. The current model (ADR-0003 / `PRQ-011`) is one
issue = one lane = one branch = one worktree = one PR. The recommended-model critique
calls fixed functional silos "too static" and recommends deriving lanes per wave from the
dependency and file-conflict graphs, with functional areas as a starting heuristic only.

## Decision

A **lane is a temporary, per-wave execution partition**: a set of ready tasks that one
worker can own without colliding with other active writers. Lanes are derived for each
wave from the dependency graph and the expected write-set / file-conflict graph, **seeded**
from functional areas but not frozen as permanent silos.

Invariant: **one active writer per worktree and branch**; parallelize only tasks whose
dependencies are satisfied and whose expected write sets do not conflict. Tasks (GitHub
issues) remain the smallest independently implementable, reviewable, and mergeable unit
and keep their own PR and fresh-context review (ADR-0015); a **wave integration branch** is
the convergence point.

This amends ADR-0003: the lease still binds one coding session per worktree and preserves
worktree isolation, but lane identity is now a scheduling partition over a task set rather
than a permanent one-issue silo.

## Consequences

Resolves `SRC-NS-001` and `NSQ-002`. ADR-0003 remains in force for lease and worktree
isolation; the `PRQ-011` "one issue = one lane" default is superseded by the
dynamic-partition model with the same isolation guarantees. `schemas/task-contract.schema.yaml`
carries `write_scope` (`expected_paths` + `additional_paths_require_change_request`) so the
scheduler can compute conflict-free partitions. `sprint-planning` (`lane-transaction` mode)
computes lanes from the task DAG and conflict graph instead of fixed silos.

- Evidence: `NSE-20260625-walk-transcript-delivery-loop-topology`,
  `NSE-20260625-recommended-event-driven-sdlc-control-plane`,
  `NSE-20260623-kubernetes-gitops-cicd-cardinality`.
- Relates to: ADR-0003 (amends), ADR-0011, ADR-0015; `PRQ-011`, `NSQ-002`, `SRC-NS-001`.
