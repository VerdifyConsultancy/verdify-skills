# Controller Merge Demo

This demo describes the reconciliation path for the Ship Verify P0 skill PRs.

## Inputs

- PR: #94, #95, #96, or #97
- Closeout:
  `.agent-workflow/sprints/2026-06-27-ship-verify-skills/lanes/closeout/<lane>.closeout.yaml`
- Critic report:
  `.agent-workflow/sprints/2026-06-27-ship-verify-skills/critic/<lane>.critic.yaml`
- Target branch: `main` for review PRs, with release-version preflight caveat
  recorded when no package version bump is intended.

## Reconciliation

1. Validate implementation I, closeout-only E, and critic-report-only S; require
   different worker/critic agents and sessions.
2. Confirm PR body lane, contract, I/E/S metadata, and exact final S head.
3. Confirm a repository admin or maintainer other than the PR author has the
   latest effective `APPROVED` review on S.
4. Confirm GitHub checks and note whether failures are implementation failures
   or release-target policy caveats.
5. Confirm packet-only P, mergeability, and shared registration conflicts.
6. Return `merge_ready`, `return_for_fix`, or `blocked`; merge the lane PR
   individually, never the controller evidence branch.

## Expected Output

The controller writes a compact decision summary that lets Jason review why a
lane can merge, needs fix-forward, or is blocked for manual reconciliation.
