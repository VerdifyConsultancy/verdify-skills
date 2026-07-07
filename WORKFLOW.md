# Workflow

The canonical machine-readable workflow is `verdify.workflow.yaml`. Human-readable lifecycle guidance is in `docs/lifecycle.md`.

The workflow keeps all 17 original delivery stages while exposing twenty-five
coherent lifecycle skills (plus the standalone `issue-triage` skill), including
readiness loops required by the North Star evidence. `config/lifecycle.yaml` is
the canonical source for this list and its ordering:

1. `project-router`
2. `repo-bootstrap` - repository self-discovery, bootstrap packet, AGENTS.md delta, and gap backlog
3. `transcript-replan` - transcript intake, routed proposals, conflicts, issues, and gates
4. `northstar-research-ingest` - research files, collateral copies, evidence registry, and query
5. `northstar-planning` - self-improving evidence, research, product/architecture drafts, feedback, and final lock approval
6. `northstar-interview` - North Star review findings, prioritized questions, proposed defaults, and answer routing
7. `northstar-question-resolution` - large question inventories, research, delegated answers, and human escalation packs
8. `project-definition` - discovery, requirements, product, design surface
9. `architecture-contracts` - architecture and black-box module contracts
10. `state-of-union` - source freshness, backlog alignment, health triage, strategy, and next sprint candidates
11. `repo-hygiene` - Wave 0 repository compliance before feature work
12. `sprint-planning` - issue selection, sprint planning, lane decomposition, ownership/review plan, lane-contract compilation
13. `sprint-replan` - scope replans, standard Markdown handoffs, and route caveats before dispatch
14. `sprint-orchestrator` - execution runbook, Agent Platform lane dispatch, terminal/session supervision, CI/CD and deployment readiness
15. `controller-loop` - durable outer-loop state, session ledger, and wave supervision
16. `subagent-worktree` - local worker dispatch with lease, compiled prompt, monitoring, and critic handoff
17. `platform-readiness` - Agent Platform, Kubernetes, CI/CD, secrets, observability, and review readiness
18. `gravity-readiness` - Gravity inventory, readiness checklist, and pilot design gate
19. `lane-delivery` - worker execution and closeout
20. `independent-critic`
21. `controller-merge` - lane reconciliation to merge-ready or fix-forward after critic review
22. `release-verification` - review inbox, diagnostics, integration, deployment verification, and outcome review
23. `sprint-handoff` - sprint-boundary status record, next-plan summary, agent handoff, and human-attention list
24. `adversarial-audit` - product, engineering, security, and business lens review of plans and handoffs
25. `consensus-audit-workflow` - skill-architecture audit, adversarial review loops, and consensus decision records

GitHub controls backlog and delivery state; versioned Verdify artifacts define
approved intent and execution contracts; the sprint execution runbook defines
Agent Platform lane session orchestration; local lane leases control worktree
ownership.
