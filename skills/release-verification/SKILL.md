---
name: release-verification
description: Assembles review-ready evidence packets, records observability diagnostics for planning/review/release health, integrates externally approved lane heads, validates the whole system, verifies the intended revision in an authorized deployment environment, and completes human outcome review. Use after critic review, when a lane or wave claims review-ready status, when planning or state-of-union needs live deployment/log health evidence, after all required lanes are ready for integration, for deployment incidents, or when a merged release still needs runtime proof and acceptance.
compatibility: Requires fresh integration context, GitHub checks/reviews, repository release tooling, and separately authorized deployment access. Production credentials must not come from worker lanes.
metadata:
  author: Verdify
  version: "1.3.0"
---

# Release Verification

Combine accepted lane outputs, prove runtime reality, and close the human outcome loop. Keep integration, deployment, and outcome as explicit modes even though they share one skill.

## Mode 0: review inbox packet

1. Verify each lane's dispatch D, PR identity, I/E/S chain, distinct worker/critic agent and
   session identities, exact critic-report head S, and successful current-head
   `critic-gate` for `dev`. Protected delivery/control-plane diffs additionally
   require current non-author code-owner approval. A `main` promotion separately requires the latest
   effective `APPROVED` review by an allowed non-author owner. Also verify linked
   issues, lane/sprint IDs, North Star IDs, checks, preview or review deployment,
   telemetry, rollback, risks, and open human questions.
2. Block review-ready status when the exact SHA, required checks, required
   preview/review deployment, critical security disposition, rollback evidence,
   or reviewer test steps are missing.
3. On the evidence-only pushed `controller/<sprint-id>` branch, write
   `.agent-workflow/sprints/<sprint-id>/review/review-inbox-packet.yaml`, validate
   it against `../../schemas/review-inbox-packet.schema.yaml`, and commit it as
   the only changed path in packet commit P. Do not use this branch as an
   integration candidate.
4. Route the recommendation to `approve`, `request_changes`, `reject`, or
   `escalate`; route follow-up to fix lane, replan, architecture review,
   release verification, human signoff, issue creation, or hold.

Read `references/review-inbox.md`.

## Cross-mode: observability diagnostics

1. Use diagnostics when strategy refresh, review-ready status, release health,
   platform readiness, or user feedback depends on runtime evidence.
2. Record scope, correlation IDs, hypotheses, telemetry links, signal
   assessments, runtime checks, deployment markers, findings, missing
   instrumentation, recommendation, and feedback route.
3. Write
   `.agent-workflow/sprints/<sprint-id>/release/observability-diagnostic-packet.yaml`
   and validate against `../../schemas/observability-diagnostic-packet.schema.yaml`.
4. Route to state-of-union, review inbox, release verification, platform
   readiness, lane delivery, sprint planning, incident handling, or no action.

Read `references/observability-diagnostics.md`.

## Mode 1: integration

1. Start a fresh integration session.
2. Using a protected-base or atomically installed validator, verify every required lane has a valid implementation/evidence/critic-report chain, live current-head `SUCCESS` for `critic-gate` and every configured required check, phase-appropriate code-owner approval, clean issue/contract reconciliation, and no unresolved blocker. When the target is `main`, also require the real current-head non-author owner approval; never substitute a workflow review.
3. Determine dependency-aware merge order. Merge or queue every lane PR
   individually against its approved base; never merge the controller evidence
   branch. Use the repository merge queue when configured.
4. Resolve conflicts without violating lane/module contracts; material conflict-driven redesign returns to planning or architecture.
5. Run full-system, cross-module, migration, packaging, security, and release validation required by the sprint.
6. Produce release notes, known issues, integrated commit SHA, artifact/image identity, and rollback prerequisites.

Read `references/integration.md`.

## Mode 2: deployment verification

1. Obtain the required deployment approval through the authorized environment/policy.
2. Deploy the exact integrated revision/artifact using separately scoped credentials.
3. Verify commit SHA, image digest, configuration, migrations, health, logs, routes/UI behavior, data state, observability, and rollback readiness.
4. Use an environment GitOps reconciliation record when desired state,
   controller state, namespace controls, deployment evidence, runtime health,
   drift, rollback, or cleanup behavior materially affect verification.
5. Compare runtime behavior with sprint acceptance criteria.
6. Roll back or open an incident gate when policy requires.
7. Write `.agent-workflow/sprints/<sprint-id>/release/release-verification.yaml` and validate against `../../schemas/release-verification.schema.yaml`.

Read `references/deployment-verification.md`,
`references/environment-gitops.md`, and
`references/rollback.md`.

## Mode 3: outcome review

Explain to the human what changed, what evidence proves it, what remains incomplete, what risks remain, and which follow-up issues were created. Record accepted, accepted-with-risks, rejected, or incomplete. Only then reconcile sprint/issue status according to policy.

Write `.agent-workflow/sprints/<sprint-id>/outcome/outcome-review.yaml` and validate against `../../schemas/outcome-review.schema.yaml`. Read `references/outcome-review.md`.

Preserve review, diagnostic, integration, deployment, rollback, and outcome
artifact refs plus GitHub check/deployment/release refs for controller-loop
session-ledger events.

## Boundaries

- A merged PR is not deployment proof.
- A controller evidence branch is not an integration candidate.
- A healthy process is not acceptance proof.
- Do not let the worker self-deploy with production credentials.
- Do not close unresolved follow-up work by hiding it in release notes.
- Do not claim success when the running revision cannot be identified.

## Handoff

After accepted outcome and reconciled records, return to `project-router` for the next lifecycle decision.
