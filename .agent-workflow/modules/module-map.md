# Verdify Skills Module Map

The module contracts under `contracts/` define exclusive implementation ownership for nine local black boxes.

| Module | Responsibility | Primary Dependencies |
|---|---|---|
| `governance-routing` | Authority, lifecycle, route, gate, and CLI boundary | none |
| `evidence-northstar` | Evidence ingestion and approved North Star loop | governance-routing |
| `definition-architecture-strategy` | Project definition, architecture, module contracts, and strategy | governance-routing, evidence-northstar |
| `planning-hygiene` | Bootstrap, hygiene, backlog reconciliation, sprint/lane planning | governance-routing, definition-architecture-strategy |
| `execution-control` | Controller, worktree/lease, session, orchestration, and recovery | governance-routing, planning-hygiene |
| `lane-assurance` | Worker closeout, exact-head criticism, review validation, adversarial audit | governance-routing, execution-control |
| `readiness-integration` | Agent Platform and Gravity readiness contracts | definition-architecture-strategy, execution-control |
| `release-package` | Review/deployment verification, packaging, publication, and recovery | governance-routing, lane-assurance |
| `quality-enablement` | Repository/schema integrity, docs, examples, evaluations, and host discovery | governance-routing; soft dependency on all modules |

Agent Platform, Orbit, and Gravity are external architecture components. They are represented by versioned interfaces and readiness evidence, not local implementation modules.
