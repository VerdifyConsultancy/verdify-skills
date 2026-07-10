# Verdify Skills Lifecycle Readiness

This view summarizes the lifecycle section of the approved canonical project definition.

## Coverage

All seventeen required areas are recorded with no material `unknown`:

- Covered: product outcome; users, stakeholders, and relationships; domain data model; scope and non-goals; design surfaces; security/privacy/compliance; infrastructure/hosting; environments/configuration; integrations/dependencies; deployment/release/rollback; operations/observability/support; quality/testing/evidence; governance/ownership/approvals; documentation/enablement; cost/procurement/risk; migration/legacy; accessibility/localization.

Coverage means the project definition establishes the required outcome, owner, constraint, interface, evidence, or downstream gate. It does not claim Agent Platform, Orbit, Gravity, release-safety, or recovery implementation is complete.

## Relationships

- Jason owns product and North Star lock authority.
- Jason or James may approve package releases after independent evidence.
- Agent Platform owns runtime providers, workers, sessions, and operational state.
- Orbit owns governed personal and engineering context.
- Gravity owns versioned cited evidence processing and API/MCP access.
- GitHub owns backlog and delivery state.
- npm and consumer repositories own package distribution and adoption boundaries.

## Delivery And Operations

- Local/source validation uses isolated worktrees and scoped mutable resources.
- `dev` is the integration branch; `main` is the release branch; installed and vendored consumers are separate test environments.
- Integration, package publication, target deployment, runtime health, and outcome acceptance are separate transitions.
- Git reverts source; immutable packages roll forward; target runtimes use owning release plans; partial publication resumes from a ledger.
- Controller events, exact revisions, logs, metrics, traces, probes, diagnostics, support owners, and incident gates provide operational evidence.

## Nonblocking Owner-Routed Gaps

- #120: exact packed-artifact and resumable release transaction.
- #121: protected dev integration and effective current-head review enforcement.
- #126: historian/evidence recovery and branch cleanup.
- #130: reproducible manifest/archive file selection independent of local host state.
- Agent Platform: supported provider capabilities and runtime readiness.
- Gravity: versioned API/MCP and readiness evidence.
- Orbit: connector identity, classification, retention, privacy, and human controls.

These gaps block their respective implementation or release boundaries, not project-definition approval.

## Handoff Readiness

- Architecture contracts: ready, with explicit cross-project ownership and quality constraints.
- Sprint planning: not ready until architecture/module contracts, current strategy, and hygiene evidence are approved.
- Release verification: not ready until #120 is implemented, `dev` has a genuinely new version, required checks pass, and an independent release approval covers the exact artifact.
