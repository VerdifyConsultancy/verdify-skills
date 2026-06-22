# Workflow

The canonical machine-readable workflow is `verdify.workflow.yaml`. Human-readable lifecycle guidance is in `docs/lifecycle.md`.

The workflow keeps all 17 detailed stages while exposing eight coherent skills:

1. `project-router`
2. `project-definition` — discovery, requirements, product, design surface
3. `architecture-contracts` — architecture and black-box module contracts
4. `sprint-planning` — issue selection, sprint planning, lane decomposition, lane-contract compilation
5. `sprint-orchestrator`
6. `lane-delivery` — worker execution and closeout
7. `independent-critic`
8. `release-verification` — integration, deployment verification, and outcome review

GitHub controls backlog and delivery state; versioned Verdify artifacts define approved intent and execution contracts; local lane leases control worktree ownership.
