# Workflow

The canonical machine-readable workflow is `verdify.workflow.yaml`. Human-readable lifecycle guidance is in `docs/lifecycle.md`.

The workflow keeps all 17 detailed stages while exposing nine coherent skills:

1. `project-router`
2. `project-definition` — discovery, requirements, product, design surface
3. `architecture-contracts` — architecture and black-box module contracts
4. `state-of-union` — backlog alignment, strategy, and next sprint candidates
5. `sprint-planning` — issue selection, sprint planning, lane decomposition, lane-contract compilation
6. `sprint-orchestrator`
7. `lane-delivery` — worker execution and closeout
8. `independent-critic`
9. `release-verification` — integration, deployment verification, and outcome review

GitHub controls backlog and delivery state; versioned Verdify artifacts define approved intent and execution contracts; local lane leases control worktree ownership.
