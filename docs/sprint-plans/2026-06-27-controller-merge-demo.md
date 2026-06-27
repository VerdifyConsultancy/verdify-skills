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

1. Validate closeout and critic report.
2. Confirm PR body lane, contract, and current head SHA.
3. Confirm GitHub checks and note whether failures are implementation failures
   or release-target policy caveats.
4. Confirm mergeability and shared registration conflicts.
5. Return `merge_ready`, `return_for_fix`, or `blocked`.

## Expected Output

The controller writes a compact decision summary that lets Jason review why a
lane can merge, needs fix-forward, or is blocked for manual reconciliation.
