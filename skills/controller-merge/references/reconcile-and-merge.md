# Reconcile And Merge

Use this checklist before a controller marks a lane merge-ready or returns it for
fix-forward.

## Evidence Checklist

- GitHub issue still matches the lane outcome.
- PR body contains:
  - `- Lane: <lane-id>`
  - `- Contract: <contract-path>`
  - `Implementation head SHA: <last-substantive-head>`
  - `Evidence head SHA: <closeout-only-head>`
  - `Current head SHA: <current-pr-head>`
- Worker closeout exists and validates.
- Fresh critic report exists, validates, and records both a critic agent and
  critic session that differ from the closeout's worker agent and session.
- The implementation-to-evidence suffix changes only the canonical closeout,
  and the evidence-to-current suffix changes only the canonical critic report.
- The latest effective GitHub review by the packet's recorded repository
  admin/maintainer is `APPROVED` and commit-bound to exact final PR head S;
  the reviewer is not the PR author and no later commit exists.
- Critic verdict is approved or approved-with-recorded-risk.
- Every configured required check has a live `SUCCESS` result on S.
- Changed paths stay inside owned or coordinated paths.
- Mergeability is not blocked by conflicts.
- The final review packet is complete and exists as the only changed path in
  packet commit P on the pushed `controller/<sprint-id>` evidence branch.
- The controller branch is not an integration candidate; merge or queue this
  lane PR individually against its approved base.

## Outcomes

`merge_ready`: all required evidence, external approval, required checks, and
packet P are current and no protected gate is open.

`return_for_fix`: implementation checks fail, critic requests changes, metadata
or a revision backlink is stale, a suffix contains unauthorized paths, closeout
is incomplete, or evidence is missing but can be fixed inside the lane contract.

`blocked`: merge conflicts, protected decisions, release/deployment approval, or
scope changes require human gates or sprint replanning.

## Fix-Forward Rule

Use one sequential worker session. Release the previous worker lease according to
the lane-delivery procedure, create a new lease for the same lane, and ask the
worker to address only the cited findings.
