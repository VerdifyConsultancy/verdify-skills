# Reconcile And Merge

Use this checklist before a controller marks a lane merge-ready or returns it for
fix-forward.

## Evidence Checklist

- GitHub issue still matches the lane outcome.
- PR body contains:
  - `- Lane: <lane-id>`
  - `- Contract: <contract-path>`
  - `Current head SHA: <current-pr-head>`
- Worker closeout exists and validates.
- Fresh critic report exists, validates, and uses a different session from the
  worker.
- Critic verdict is approved or approved-with-recorded-risk.
- Required checks pass, or any release-only caveat is explicitly recorded.
- Changed paths stay inside owned or coordinated paths.
- Mergeability is not blocked by conflicts.
- Review packet is updated or ready to be updated.

## Outcomes

`merge_ready`: all required evidence is current and no protected gate is open.

`return_for_fix`: implementation checks fail, critic requests changes, metadata
is stale, closeout is incomplete, or evidence is missing but can be fixed inside
the lane contract.

`blocked`: merge conflicts, protected decisions, release/deployment approval, or
scope changes require human gates or sprint replanning.

## Fix-Forward Rule

Use one sequential worker session. Release the previous worker lease according to
the lane-delivery procedure, create a new lease for the same lane, and ask the
worker to address only the cited findings.
