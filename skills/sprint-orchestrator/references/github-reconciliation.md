# GitHub reconciliation

For each lane verify:

- issue exists and remains in approved scope;
- issue is not assigned to another lane;
- branch matches the contract;
- pull request targets the intended base branch and links the issue;
- implementation validation reflects I, while live required checks report
  `SUCCESS` on final critic-report head S;
- PR metadata distinguishes the implementation, closeout-only evidence, and current critic-report heads;
- critic decision refers to the evidence head, uses a different worker agent/session, and is committed as the only later path;
- the latest effective review from the packet's recorded repository
  admin/maintainer other than the PR author is `APPROVED`, commit-bound to S, and no later
  commit exists;
- every configured required check is present with live `SUCCESS` on that head;
- labels/Project fields match the lifecycle state;
- merged/closed state does not overstate deployment verification.

Refresh the snapshot before acting on a discrepancy. Write a reconciliation report; never resolve disagreement by silently editing both sides.

When the discrepancy affects backlog strategy or future sprint candidates, also
consume or update the state-of-union
`.agent-workflow/strategy/github-backlog-sync.yaml` artifact so issue, PR, lane,
and delivery findings share one typed reconciliation record.
