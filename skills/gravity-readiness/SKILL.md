---
name: gravity-readiness
description: Gates Gravity implementation by inventorying Gravity product, architecture, source, tests, issues, dependencies, Onyx status, environments, credentials, observability, platform integration, and pilot criteria. Use when preparing Gravity for an autonomous pilot or reconciling Gravity against Agent Platform and Skills readiness; do not use for Gravity feature implementation.
compatibility: Requires read access to the Gravity repository, relevant Agent Platform and skills artifacts, GitHub state, and environment/readiness evidence. Jason and James approval is required before pilot execution.
metadata:
  author: Verdify
  version: "1.1.0"
---

# Gravity Readiness

Keep Gravity gated. Inventory, reconcile, and design the pilot; do not build
Gravity features from this skill.

## Canonical artifacts

- `.agent-workflow/gravity/gravity-readiness.yaml` - binary readiness checklist
- `.agent-workflow/gravity/gravity-readiness.md` - human-readable report
- `.agent-workflow/gravity/gravity-core-extraction-plan.yaml` - optional
  Sunshine-to-Gravity reusable core extraction plan
- Proposed Gravity readiness issues and gates

Validate YAML against `../../schemas/gravity-readiness.schema.yaml` and, when
core extraction is in scope,
`../../schemas/gravity-core-extraction-plan.schema.yaml`.

## Platform readiness precondition

ADR-0013 makes `platform-readiness` the authoritative owner for shared
environment and control-plane readiness. Before marking any platform-dependent
Gravity checklist area `pass`, link the current
`.agent-workflow/platform/platform-readiness.yaml`, verify `approval.status` is
`approved`, verify the required platform domains are `pass`, and record only the
platform artifact ref, verdict, timestamp, and consumed evidence IDs in
`.agent-workflow/gravity/`. If the platform artifact is missing, unapproved,
failed, or blocked, mark the Gravity area `fail` or `blocked` and route the
gap to `platform-readiness`; do not duplicate platform evidence or remediation
inside the Gravity artifact.

Use these concrete platform evidence sources for platform-dependent areas:

| Gravity area | Required platform evidence source before `pass` |
| --- | --- |
| worktree/session orchestration | `.agent-workflow/platform/platform-readiness.yaml` domain evidence for controller and worktree session lifecycle; `bin/verdify lane inspect --repo <repo> --lease-id <lease-id>` output for the exact lane when lane mechanics are part of the pilot. |
| credentials and RBAC | Platform readiness domain evidence for secrets and credential injection plus RBAC; Kubernetes or supplied snapshot evidence from `kubectl auth can-i`, service account, RoleBinding, SecretStore or equivalent credential-injection checks; Agent Platform control request authorization when API/MCP operations are proposed. |
| namespaces and quotas | Platform readiness domain evidence for namespace model, quotas, placement, service accounts, and PVCs; `environment-gitops-reconciliation.yaml` namespace controls and `kubectl get namespace,resourcequota,limitrange,serviceaccount,pvc -n <namespace>` or supplied snapshot. |
| CI/CD and review environment | Platform readiness domain evidence for CI/CD, image build, registry/cache, GitOps, Argo CD, and review inbox; GitHub Actions/check suite refs and review deployment URL evidence linked from the platform artifact. |
| rollback | Platform readiness `minimum_pilot` rollback criteria and environment GitOps rollback/remediation fields; wave release plan rollback refs when a Gravity pilot wave is being proposed. |
| observability and diagnostics | Platform readiness observability domain evidence; `observability-diagnostic-packet.yaml` with metrics, logs, traces, dashboards, alerts, correlation IDs, endpoint checks, and deployment markers. |
| browser inspection | Platform readiness browser-terminal domain evidence and Agent Platform control request terminal access fields; Authentik-protected route/session evidence when browser access crosses the SSO boundary. |

## Procedure

1. Read Gravity docs, source, tests, issues, architecture, installed Verdify
   artifacts, and platform integration notes.
2. Confirm whether Onyx remains a required foundation.
3. Map Gravity's intended product and service surface against Agent Platform and
   Skills contracts.
4. When Sunshine Club or another client implementation is a reuse source,
   produce a `gravity-core-extraction-plan.yaml` that inventories source
   objects, core/pack boundaries, contracts, migration risks, local filesystem
   ingestion pilot criteria, and readiness updates.
5. Link the approved platform-readiness artifact and apply the platform
   readiness precondition before assessing platform-dependent areas.
6. Assess the required readiness areas:
   - approved North Star;
   - repo hygiene;
   - lane and dependency planning;
   - worktree/session orchestration;
   - credentials and RBAC;
   - namespaces and quotas;
   - CI/CD and review environment;
   - rollback;
   - observability and diagnostics;
   - browser inspection;
   - human review and sign-off.
7. Mark every item `pass` or `fail`; use `blocked` only when evidence cannot be
   obtained.
8. Propose one small pilot wave that proves the whole lifecycle.
9. Stop until Jason and James approve the checklist and pilot plan.

## Stop conditions

Do not implement Gravity features, create lane worktrees for Gravity feature
work, mutate production/stage resources, or bypass the readiness checklist.

## Load references only when needed

- Read `references/readiness-checklist.md` for binary checklist rules and pilot
  constraints.
- Read `references/gravity-core-extraction.md` when Sunshine-to-Gravity reuse,
  generic core boundaries, pack boundaries, source-object identity, or local
  filesystem ingestion pilot planning is in scope.
