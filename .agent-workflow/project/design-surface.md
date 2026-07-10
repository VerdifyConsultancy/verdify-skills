# Verdify Skills Design Surfaces

This view summarizes the interaction contracts in the approved canonical YAML. Architecture owns component design; this document defines observable behavior.

## Surfaces

- `SURF-001` Skill: a routed or human-triggered agent executes one bounded workflow and returns artifacts, GitHub actions, evidence, and handoff.
- `SURF-002` CLI: roles route, validate, ingest, assess, lease, coordinate, and compile prompts with structured results and errors.
- `SURF-003` Artifact: lifecycle roles persist approved intent, state, evidence, gaps, and handoffs as schema-valid YAML plus aligned views.
- `SURF-004` GitHub control plane: issues, branches, commits, PRs, checks, reviews, releases, and deployments own delivery state.
- `SURF-005` Agent Platform provider: capability requests produce isolated session handles, events, evidence, or explicit unsupported-capability errors.
- `SURF-006` Gravity API/MCP: authorized tenant queries return versioned cited read-only evidence or permission/availability errors.
- `SURF-007` Orbit connector plane: governed context requests return cited briefs, audit events, approval requests, or denied-scope errors.
- `SURF-008` Package release: a new-version dev revision and exact tarball produce a package, provenance, tag, release, and completed or resumable ledger.
- `SURF-009` Review inbox: exact stories, test steps, environments, risks, and evidence produce approval, changes, rejection, or outcome acceptance.
- `SURF-010` Observability/support: logs, metrics, traces, revisions, probes, and events produce diagnostics, incident gates, rollback, or remediation.

## Primary Flows

1. Evidence to authority: register sources, lock North Star, approve project definition and architecture, reconcile strategy, then select a sprint.
2. Issue to integration: approve one lane, lease one worktree, implement, close out, criticize the exact head, reconcile checks/reviews, then merge to `dev`.
3. Dev to release: build and exercise one exact new-version artifact, approve the release, merge the generated promotion, and reconcile npm/tag/release/ledger state.
4. Four-project coordination: Skills supplies method, Agent Platform supplies execution, Orbit supplies governed context, and Gravity supplies cited evidence.
5. Recovery: inventory refs, classify them, port useful content forward, persist disposition, and only then delete redundancy.

## Human Gates

- Jason approves North Star lock and material project intent.
- An authorized non-worker reviewer or deterministic equivalent approves current-head integration evidence.
- Jason or James approves release promotion after exact-artifact checks.
- Typed owners approve security, production, destructive, privileged-dependency, scope, and readiness decisions.
- Outcome owners accept deployed outcomes separately from merge and deployment.

## Error States

The system fails closed on authority contradiction, invalid or stale artifacts, invalid leases or ownership, stale/self-authored review evidence, duplicate or mismatched release identity, missing provider/connector/evidence capability, and recovery that would overwrite newer state or delete the final useful copy.
