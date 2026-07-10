# Sprint: Delivery Controls

Baseline: `dev@91828dd4f0b632a2833a3d4f62cf4f92c1e35901`

## Included

One lane owns issue #121. It implements effective CODEOWNERS, dev-only ordinary
integration, release-only main promotion, current-head critic status, real
non-author release approval, candidate-side bootstrap policy, declarative branch
protection, deterministic tests, and lifecycle documentation.

## Deferred

The worker does not merge PR #189, publish npm, push a tag, create a GitHub
release, apply live rules, or clean rescue refs. ROOT performs live
reconciliation after reviewed integration. Final release and cleanup are
separate verification actions.

## Lane

| Lane | Issue | Branch | Owner | Reviewer | Responsibility |
| --- | --- | --- | --- | --- | --- |
| `issue-121-delivery-controls` | #121 | `lane/121-delivery-controls` | delivery-controls-worker | fresh-independent-critic | Implement code, tests, desired rules, and documentation without live mutation. |

## Order

1. Dispatch the single leased worker lane.
2. Run route, review, review-history, branch-payload, idempotency, workflow, full, and security tests.
3. Obtain a fresh report-only critic result.
4. Record the bootstrap admin exception because the PR author cannot self-approve.
5. Merge to dev, dry-run and apply pre-release rules, and verify live branch GET state.
6. Jason reviews current-head PR #189 authored by James; release verification owns promotion and publication proof.

## Bootstrap Boundary

Main still contains version 1.2.1 policy and cannot validate the 1.3.0 candidate.
Pre-release main protection therefore requires a distinct candidate-side
`delivery-policy` check. After 1.3.0 reaches main, steady-state protection adds
the normal trusted-base `pull-request-policy` context.

## Approval

Jason authorized autonomous completion, PR administration, and the explicit
bootstrap exception. No self-review or workflow-generated human approval is
represented as a GitHub approval.
