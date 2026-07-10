# Review Inbox Packet

Use this reference when a lane, wave, release candidate, or OpenClaw
`sdlc-review-inbox` workflow claims review-ready status.

The review inbox is a promoted capability contract, not a new canonical
lifecycle skill yet. `release-verification` owns the first executable packet
shape because it already separates integration, deployment verification,
rollback, and outcome review.

## Inputs

- North Star IDs, sprint ID, lane IDs, issue IDs, PR or merge request URL, target
  base ref, deterministic `controller/<sprint-id>` head ref, implementation
  head, closeout-only evidence head, critic-report head, and one exact
  commit-bound review submission per lane with reviewer login and immutable
  GitHub user ID.
- Wave release plan path when present, especially required checks, preview or
  review environment, GitOps desired state, release-health signals, rollback,
  and telemetry expectations.
- Critic report, lane closeout, changed artifacts, test plan, migration notes,
  risk notes, and open human questions.
- Check runs, workflow runs, build artifacts, package validation, local tests,
  security scans, and CI URLs.
- Preview or review deployment URL, environment name, environment protection
  state, deployment ID, observed revision, desired-state ref, reconciliation
  evidence, and deployment logs when applicable.
- Telemetry links: dashboards, logs, metrics, traces, endpoint health, runtime
  checks, and missing-telemetry findings.
- Observability diagnostic packet when runtime evidence is material to the
  review decision.
- Rollback procedure, known-good revision, and rollback evidence.
- Preview generator controls when PR-driven environments are used, including
  source-of-truth ownership, hard-coded project restrictions, secret exposure
  review, and admin-only ApplicationSet or equivalent configuration.

## Procedure

1. Verify each PR or merge request identity and exact head SHA before using any
   check, preview, or critic evidence. Each live head, critic-report commit, and
   external review-submission commit must match; the latest effective review
   from the recorded reviewer must be `APPROVED`.
2. Collect required checks and workflow results by name. Every configured
   required check must have a live `SUCCESS` result on that exact head; do not
   summarize them as "CI passed" without URLs or observed timestamps.
3. Record review or preview deployment evidence separately from merge state.
   Include desired-state refs and observed runtime or reconciliation evidence
   for GitOps-managed environments.
4. Record human test steps and targeted review URLs. If source-to-preview route
   maps exist, include them as reviewer guidance.
5. Review privileged access, secrets, production mutation, and preview generator
   controls. Treat unresolved critical security findings as blockers.
6. Record rollback readiness before marking a packet review-ready.
7. Build the deterministic pushed `controller/<sprint-id>` branch as an
   evidence-only history from the SprintPlan baseline. Copy only the approved
   sprint transaction, canonical lane closeouts, critic reports, and release
   evidence; never merge or copy lane implementation changes into this branch.
8. Write `.agent-workflow/sprints/<sprint-id>/review/review-inbox-packet.yaml`,
   validate it against `../../schemas/review-inbox-packet.schema.yaml`, and
   commit it as the only changed path in packet commit P. The packet is never
   committed onto a lane PR branch, and the controller branch is never an
   integration candidate.
9. Set the recommendation to `approve`, `request_changes`, `reject`, or
   `escalate`.
10. Route feedback to exactly one next action: fix lane, replan, architecture
   review, release verification, human signoff, issue creation, or hold.

After P, keep the packet bytes unchanged. Only linear commits limited to
`release/release-verification.yaml`, `outcome/outcome-review.yaml`,
`status.yaml`, or an atomic terminalization of only `sprint-plan.yaml` plus
`status.yaml` may follow. Merge or queue each approved lane PR individually
against its approved base, then verify the integrated runtime separately.

A valid critic outcome is necessary but not sufficient for integration. Each S
also needs external approval, and integration waits for a complete review packet
with an approve recommendation or an explicit policy exception recorded through
the appropriate gate.

## Completeness Rules

Mark `evidence_completeness.verdict` as `complete` only when:

- PR/MR identity, per-lane review-submission head, authorized admin/maintainer
  login and immutable user ID, and linked issue/lane/sprint IDs are present.
- The packet bytes are the sole change in P, P is on the pushed declared
  `controller/<sprint-id>` evidence branch, and any post-P suffix contains only
  the allowed canonical delivery artifacts.
- Required checks have observed statuses, conclusions, and evidence URLs.
- Required preview, review, staging, or production deployment evidence is
  present, or the packet explicitly records a non-environment reason.
- Human test steps are specific enough for a reviewer to execute.
- Telemetry links or missing-telemetry findings are explicit.
- Rollback readiness is recorded.
- Critical security findings are resolved or routed as blockers.

Use `incomplete` for missing non-blocking evidence. Use `blocked` when review
would be misleading or unsafe.

## Stop Conditions

Stop and route to `fix_lane`, `replan`, `architecture_review`, or `hold` when:

- any per-lane review-submission head or authorized reviewer identity is missing
  or does not match the live open PR, latest `APPROVED` GitHub review, required
  checks, critic report, or preview deployment;
- required checks or workflow runs are missing or failing;
- a required preview/review deployment is absent or cannot identify the
  observed revision;
- rollback readiness is missing for a release-impacting change;
- secret exposure, broad production mutation, or preview generator controls are
  unresolved;
- the packet would require the reviewer to reconstruct hidden chat context.
