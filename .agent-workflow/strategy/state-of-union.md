# State of Union: Delivery Controls and 1.3.0 Release

Assessed at `dev@e7029118bc8108f2fc1e2deaa27a1d423ce9a0b4` on
2026-07-10T09:29:52Z.

## Verdict

Recovery, package integrity, and release safety are integrated and terminal on
`dev`. `main`, npm, and the latest GitHub release remain at 1.2.1. Issue #121 is
the sole ready sprint candidate and the only blocker for James-authored release
PR #189.

Delivery health is degraded because `dev` is unprotected, `main` has no review
requirement, CODEOWNERS is ineffective, and main's current 1.2.1 policy cannot
validate the 1.3.0 candidate. No product or architecture decision is missing.

## Current Truth

- `dev`: `e7029118bc8108f2fc1e2deaa27a1d423ce9a0b4`, version 1.3.0.
- `main`: `898d7c78845f11a4cec29556e698ebd27aa58ef1`, version 1.2.1.
- npm/GitHub release: `@verdify-cli/cli@1.2.1` / `v1.2.1`.
- Release candidate: issue #188 and PR #189, `dev -> main`, author `jrvallery`, no review.
- Live protection: main requires three checks and admin/conversation enforcement but no review; dev is unprotected.
- Workflow token: read default and cannot approve PR reviews.
- Retained recovery sources: `fe1f94e`, `f425515`, and `22f81bdc35e4f1e5a70797624c93bc86bc66056c`.

## Sequence

1. Plan and execute one issue #121 lane.
2. Merge #121 to dev after fresh criticism and the recorded bootstrap exception.
3. Apply and verify pre-release branch protections without locking out PR #189.
4. Jason approves current-head PR #189 authored by James.
5. Promote 1.3.0 and verify npm, tag, GitHub release, retained artifact, provenance, checksums, and completed ledger.
6. Reconcile #120/#126/#130/#142 and clean rescue handles only after final proof.

## Sprint Candidate

Issue #121 is ready. Its contract must cover:

- effective `@jvallery @jrvallery` CODEOWNERS;
- ordinary PRs targeting protected `dev` only;
- same-repository `dev -> main` release promotions only;
- transport-neutral current-head critic status on dev;
- real current-head non-author owner approval on main;
- a candidate-side bootstrap `delivery-policy` check for PR #189;
- idempotent dry-run/apply live protection tooling with pre-release and steady-state phases;
- deterministic tests, fresh criticism, live GET verification, and rollback.

The next skill is `sprint-planning` in `lane-transaction` mode.
