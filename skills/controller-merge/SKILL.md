---
name: controller-merge
description: Reconciles completed Verdify lane branches after worker closeout and fresh critic review, then either prepares a merge/integration action or returns the lane for contract-scoped fixes. Use when a controller owns branch, PR, closeout, check, and critic evidence and must decide merge-ready versus fix-forward without self-certifying worker output.
compatibility: Requires Git, GitHub PR/check access, validated lane closeout, critic report, and an approved sprint or review packet. It never substitutes for independent criticism or runtime deployment verification.
metadata:
  author: Verdify
  version: "1.1.2"
---

# Controller Merge

Reconcile completed lane branches and decide whether each lane is ready to merge,
needs fix-forward work, or must stop for a gate. This skill is for the controller
after worker closeout and critic review; it is not a code-review skill and does
not approve its own output.

## Start

1. Read `../../COMMON_OPERATING_CONTRACT.md` when available.
2. Identify the sprint, lane ID, issue, PR, branch, baseline SHA, closeout,
   critic report, checks, review packet, and target integration branch.
3. Confirm the critic reviewed the current intended head and did not use the
   worker session or worker worktree.
4. Confirm required checks and PR-policy fields are current.

Read `references/reconcile-and-merge.md` before deciding the lane outcome.

## Procedure

1. **Collect evidence.** Read the PR body, branch head, closeout, critic report,
   check rollup, mergeability, changed paths, issue linkage, and review packet
   state.
2. **Compare authority.** Check that GitHub issue, lane contract, closeout,
   critic report, PR head, and check results refer to the same lane and intended
   revision.
3. **Classify outcome.**
   - `merge_ready`: closeout is ready, critic approves, checks pass or known
     release-only caveats are recorded, and no protected gate is open.
   - `return_for_fix`: critic requests changes, checks fail on implementation
     or policy evidence, or PR metadata is stale.
   - `blocked`: merge conflicts, missing evidence, protected decisions, or
     release/deployment gates prevent integration.
4. **Prepare merge or fix-forward.** For merge-ready lanes, record the exact
   merge action and target. For fixes, release the old worker lease as needed
   and ask `subagent-worktree` or `lane-delivery` for one sequential fix worker.
5. **Record evidence.** Write a concise merge/reconciliation note in the review
   packet or PR comment, including the action, evidence, caveats, and next
   lifecycle route.

## Required Outputs

- Merge/reconciliation decision summary with lane, issue, PR, branch, head SHA,
  checks, closeout, critic report, target branch, and outcome.
- Either a merge-ready handoff, a fix-forward instruction, or a blocking gate.
- Updated review packet or PR comment when the decision affects human review.

## Stop Conditions

Stop when:

- no fresh critic report exists;
- critic and closeout reviewed different heads without an explicit explanation;
- required checks are failing for implementation reasons;
- merge conflicts or shared registration conflicts need manual reconciliation;
- the action would merge to a protected release branch, deploy runtime changes,
  or approve a protected decision without human approval.

## Handoff

Hand off merge-ready lanes to `release-verification` for review inbox and
integration evidence. Hand off fix-needed lanes to `subagent-worktree` or
`lane-delivery` fix-forward. Hand off protected blockers to gates or
`sprint-planning` replanning.
