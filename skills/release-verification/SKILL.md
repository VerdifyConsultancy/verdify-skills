---
name: release-verification
description: Integrates critic-approved lanes, validates the whole system, verifies the intended revision in an authorized deployment environment, and completes human outcome review. Use after all required lanes are ready for integration, for deployment incidents, or when a merged release still needs runtime proof and acceptance.
compatibility: Requires fresh integration context, GitHub checks/reviews, repository release tooling, and separately authorized deployment access. Production credentials must not come from worker lanes.
metadata:
  author: Verdify
  version: "1.0.0"
  lifecycle-order: "9"
---

# Release Verification

Combine accepted lane outputs, prove runtime reality, and close the human outcome loop. Keep integration, deployment, and outcome as explicit modes even though they share one skill.

## Mode 1: integration

1. Start a fresh integration session.
2. Verify every required lane has current critic approval, required checks, clean issue/contract reconciliation, and no unresolved blocker.
3. Determine dependency-aware merge order. Use the repository merge queue when configured.
4. Resolve conflicts without violating lane/module contracts; material conflict-driven redesign returns to planning or architecture.
5. Run full-system, cross-module, migration, packaging, security, and release validation required by the sprint.
6. Produce release notes, known issues, integrated commit SHA, artifact/image identity, and rollback prerequisites.

Read `references/integration.md`.

## Mode 2: deployment verification

1. Obtain the required deployment approval through the authorized environment/policy.
2. Deploy the exact integrated revision/artifact using separately scoped credentials.
3. Verify commit SHA, image digest, configuration, migrations, health, logs, routes/UI behavior, data state, observability, and rollback readiness.
4. Compare runtime behavior with sprint acceptance criteria.
5. Roll back or open an incident gate when policy requires.
6. Write `.agent-workflow/sprints/<sprint-id>/release/release-verification.yaml` and validate against `../../schemas/release-verification.schema.yaml`.

Read `references/deployment-verification.md` and `references/rollback.md`.

## Mode 3: outcome review

Explain to the human what changed, what evidence proves it, what remains incomplete, what risks remain, and which follow-up issues were created. Record accepted, accepted-with-risks, rejected, or incomplete. Only then reconcile sprint/issue status according to policy.

Write `.agent-workflow/sprints/<sprint-id>/outcome/outcome-review.yaml` and validate against `../../schemas/outcome-review.schema.yaml`. Read `references/outcome-review.md`.

## Boundaries

- A merged PR is not deployment proof.
- A healthy process is not acceptance proof.
- Do not let the worker self-deploy with production credentials.
- Do not close unresolved follow-up work by hiding it in release notes.
- Do not claim success when the running revision cannot be identified.

## Handoff

After accepted outcome and reconciled records, return to `project-router` for the next lifecycle decision.
