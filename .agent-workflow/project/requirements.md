# Verdify Skills Requirements

This view summarizes the approved requirements in `.agent-workflow/project/project-definition.yaml`; IDs and full traceability remain authoritative in YAML.

## Functional Requirements

- `FR-001`: deterministically route to the earliest incomplete lifecycle skill and mode.
- `FR-002`: register, hash, query, and synthesize transcript, research, review, and planning evidence.
- `FR-003`: carry approved intent through definition, architecture, strategy, planning, execution, review, release, and outcome acceptance.
- `FR-004`: map implementation to one issue, contract, branch, leased worktree, worker session, and PR.
- `FR-005`: persist controller, child-session, gate, event, dependency, wave, and handoff state outside chat.
- `FR-006`: reconcile closeout, criticism, current-head review, checks, issue state, and PR state before integration.
- `FR-007`: build, test, publish, and recover one exact new-version package artifact.
- `FR-008`: consume Agent Platform through capability-negotiated provider contracts.
- `FR-009`: consume Gravity through a versioned, tenant-scoped, cited, read-only HTTP API and MCP adapter.
- `FR-010`: govern Orbit context through least privilege, classification, audit, privacy, retention, and human controls.
- `FR-011`: inventory, preserve, disposition, and clean divergent Git work safely.
- `FR-012`: validate source, installed, upgraded, packed, and vendored package shapes.

## Non-Functional Requirements

- `NFR-001` traceability: stable links from source and decision through issue, contract, evidence, release, deployment, and outcome.
- `NFR-002` governance: typed authority and fail-closed gates for material actions.
- `NFR-003` security: least privilege, secret safety, resource isolation, audit, and untrusted-content handling.
- `NFR-004` privacy: identity, classification, minimization, retention, deletion, and approval for governed context.
- `NFR-005` operability: checks, observable state, support ownership, rollback, recovery, and stop conditions.
- `NFR-006` portability: supported source, installed, and vendored behavior without hidden local paths.
- `NFR-007` reproducibility: exact inputs, SHAs, hashes, commands, environments, and outputs.
- `NFR-008` maintainability: one canonical lifecycle and validated derivative views.
- `NFR-009` resilience: deterministic recovery without duplicates, ambiguity, or accepted-state corruption.
- `NFR-010` cost: issue-backed approval for paid services, privileged dependencies, quotas, and vendor commitments.

## Constraints

- GitHub and versioned artifacts retain typed authority.
- Normal work integrates through `dev`; `main` receives reviewed release promotion.
- One issue/lane/branch/worktree/session/PR is the default delivery unit.
- Workers do not self-certify, and merge does not prove deployment or outcome.
- Secrets and sensitive reproduction data stay out of Git and public delivery records.
- Agent Platform, Orbit, and Gravity work remains subject to owning-repository gates.
- Approved replacements carry no implicit compatibility obligation.
- Recovery refs are not accepted code until reviewed and integrated.

## Acceptance Evidence

The twelve acceptance criteria require deterministic routing, evidence-registry validation, schema and traceability checks, lease/contract enforcement, controller recovery, exact-head review reconciliation, exact-artifact release tests, provider/readiness probes, governed connector evidence, checked-in recovery disposition, and installed/package validation.
