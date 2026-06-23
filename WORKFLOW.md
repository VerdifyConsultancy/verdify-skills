# Workflow

The canonical machine-readable workflow is `verdify.workflow.yaml`. Human-readable lifecycle guidance is in `docs/lifecycle.md`.

The workflow keeps all 17 original delivery stages while exposing seventeen
coherent skills, including readiness loops required by the North Star evidence:

1. `project-router`
2. `transcript-replan` - transcript intake, routed proposals, conflicts, issues, and gates
3. `northstar-research-ingest` - research files, collateral copies, evidence registry, and query
4. `northstar-planning` - self-improving evidence, research, product/architecture drafts, feedback, and final lock approval
5. `northstar-interview` - North Star review findings, prioritized questions, proposed defaults, and answer routing
6. `project-definition` - discovery, requirements, product, design surface
7. `architecture-contracts` - architecture and black-box module contracts
8. `state-of-union` - backlog alignment, strategy, and next sprint candidates
9. `repo-hygiene` - Wave 0 repository compliance before feature work
10. `sprint-planning` - issue selection, sprint planning, lane decomposition, lane-contract compilation
11. `sprint-orchestrator`
12. `controller-loop` - durable outer-loop state, session ledger, and wave supervision
13. `platform-readiness` - Agent Platform, Kubernetes, CI/CD, secrets, observability, and review readiness
14. `gravity-readiness` - Gravity inventory, readiness checklist, and pilot design gate
15. `lane-delivery` - worker execution and closeout
16. `independent-critic`
17. `release-verification` - integration, deployment verification, and outcome review

GitHub controls backlog and delivery state; versioned Verdify artifacts define approved intent and execution contracts; local lane leases control worktree ownership.
