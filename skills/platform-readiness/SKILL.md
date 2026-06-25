---
name: platform-readiness
description: Inventories and gates Agent Platform readiness across Kubernetes namespaces, RBAC, secrets, credentials, CI/CD, GitOps, ingress, DNS, observability, browser terminals, review inbox, Agent Platform API or MCP contracts, and non-Gravity pilot criteria. Use before autonomous platform execution, before a Gravity pilot, or when environment and control-plane readiness is uncertain.
compatibility: Requires authorized read access to platform repositories, Kubernetes/GitOps state or supplied snapshots, credential location inventory, and CI/CD state. Production changes require a separate approved operator.
metadata:
  author: Verdify
  version: "1.1.0"
---

# Platform Readiness

Prove the delivery platform before using it on Gravity. Inventory and design;
do not apply production changes from this skill.

## Canonical artifacts

- `.agent-workflow/platform/platform-readiness.yaml` - readiness matrix
- `.agent-workflow/platform/platform-readiness.md` - human-readable report
- Optional observability diagnostic packets when runtime evidence or missing
  instrumentation affects readiness
- Optional environment GitOps reconciliation records when desired state,
  controller state, namespace controls, deployment evidence, runtime health,
  drift, rollback, or cleanup materially affect readiness
- Optional Agent Platform control requests when API/MCP operations need
  authorization, policy, target, and evidence records
- Proposed ADRs, issues, and gates for platform gaps

Validate YAML against `../../schemas/platform-readiness.schema.yaml` and
diagnostic packets against
`../../schemas/observability-diagnostic-packet.schema.yaml`. Validate control
requests against `../../schemas/agent-platform-control-request.schema.yaml`.
Validate environment GitOps reconciliation records against
`../../schemas/environment-gitops-reconciliation.schema.yaml`.

## Mode 0: inventory

- Purpose: collect observed Agent Platform, Kubernetes, GitOps, CI/CD,
  credential, edge, Authentik SSO, observability, browser-terminal, review, and
  controller evidence without approving readiness.
- Inputs: project/platform docs, Agent Platform contracts, GitHub and CI state,
  k3s and GitOps snapshots, credential location inventory, DNS/Traefik/TLS/SSO
  evidence, and existing `.agent-workflow/platform/` artifacts.
- Outputs: a draft `platform-readiness.yaml` domain matrix with observed
  evidence, gaps, blockers, and proposed issues or gates.
- Exit condition: every domain in `references/readiness-domains.md` has an
  observed, missing, or blocked evidence entry, and no readiness pass is claimed
  without inspected evidence.

## Mode 1: target-contract

- Purpose: define the target readiness contract that current platform evidence
  will be measured against.
- Inputs: approved North Star, project definition, architecture decisions
  including ADR-0013, Agent Platform API or MCP contracts, GitOps/environment
  contracts, and the real edge/SSO target of k3s Traefik ingress plus
  Authentik.
- Outputs: domain-level target statements, required evidence sources, minimum
  non-Gravity pilot entry and exit criteria, and gates for unresolved target
  ownership or platform policy.
- Exit condition: each platform domain has an explicit target, evidence source,
  owner, and stop condition, with unresolved material decisions routed to a
  gate instead of hidden in the readiness matrix.

## Mode 2: readiness-gate

- Purpose: decide whether the platform can safely support autonomous lifecycle
  execution or a Gravity-readiness handoff.
- Inputs: the current target contract, the latest platform-readiness artifact,
  environment GitOps reconciliation records, Agent Platform control requests,
  observability diagnostic packets, GitHub/CI results, Kubernetes evidence, and
  Traefik/Authentik route and authentication checks.
- Outputs: `pass`, `warn`, `fail`, or `blocked` for each required domain,
  overall `ready`, `not_ready`, or `blocked` status, linked evidence IDs, gates
  for blockers, and a handoff naming the next skill and mode.
- Exit condition: every required platform domain has inspected evidence and a
  status, approval records the platform verdict, and any blocked or failed
  domain is routed to an issue, gate, or authorized operator path.

## Mode 3: pilot-plan

- Purpose: define the minimum non-Gravity pilot that proves the platform before
  Gravity-specific pilot approval.
- Inputs: readiness-gate results, issue/PR/review/deployment flow evidence,
  rollback expectations, observability and diagnostic requirements, controller
  session-ledger requirements, and human review/sign-off constraints.
- Outputs: `minimum_pilot` criteria covering intake, planning, worktree,
  CI/CD, preview, review inbox, fix/replan, rollback, observability, human
  sign-off, and controller ledger capture.
- Exit condition: the pilot can be scheduled only when the readiness gate is
  approved and required domains pass, or it remains blocked with explicit gaps,
  owners, and follow-up routes.

## Procedure

1. Read current project/platform docs, Agent Platform contracts, GitOps
   manifests, CI/CD config, namespace declarations, and observability docs.
2. Inventory the domains in `references/readiness-domains.md`.
3. Compare current state with target state:
   - repository as application;
   - environment-scoped namespaces;
   - dev-write and stage/prod promotion;
   - runtime secret injection without prompt/log exposure;
   - observability by default;
   - browser terminal inspection;
   - review-ready deployed pull requests;
   - controller and child-session APIs or MCP tools.
4. Mark each domain `pass`, `warn`, `fail`, or `blocked`.
5. Use an observability diagnostic packet when telemetry, runtime checks,
   deployment markers, or missing instrumentation determine readiness.
6. Use an environment GitOps reconciliation record when desired state,
   controller state, namespace controls, deployment evidence, runtime health,
   drift, remediation, rollback, or cleanup policy determine readiness.
7. Use an Agent Platform control request when a repo/session/worktree/GitHub/
   CI/CD/k3s/GitOps/review/telemetry operation needs an API/MCP contract,
   authorization, policy verdict, target identity, rollback or recovery path,
   and evidence capture.
8. Define the minimum non-Gravity pilot that proves intake, planning, worktree,
   CI/CD, preview, human review, fix/replan, sign-off, and ledger capture.
9. Write the readiness artifact and open gates for blocked domains.

## Stop conditions

Stop before production edge changes, secrets copying, broad RBAC grants,
unreviewed namespace writes outside development, or Gravity implementation.

## Load references only when needed

- Read `references/readiness-domains.md` for the required readiness matrix.
- Read `references/environment-gitops.md` before creating or evaluating an
  environment GitOps reconciliation record.
- Read `references/agent-platform-control.md` before creating or evaluating an
  Agent Platform API/MCP control request.
