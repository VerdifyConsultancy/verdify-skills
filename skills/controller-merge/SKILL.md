---
name: controller-merge
description: Reconciles completed Verdify lane branches after worker closeout and fresh critic review, then either prepares a merge/integration action or returns the lane for contract-scoped fixes. Use when a controller owns branch, PR, closeout, check, and critic evidence and must decide merge-ready versus fix-forward without self-certifying worker output.
compatibility: Requires Git, GitHub PR/check access, a validated D/I/E/S chain, external approval on S, and complete packet commit P for the approved sprint. It never substitutes for independent criticism or runtime deployment verification.
metadata:
  author: Verdify
  version: "1.2.1"
---

# Controller Merge

Reconcile completed lane branches and decide whether each lane is ready to merge,
needs fix-forward work, or must stop for a gate. This skill is for the controller
after worker closeout and critic review; it is not a code-review skill and does
not approve its own output.

## Start

1. Read `../../COMMON_OPERATING_CONTRACT.md` when available.
2. Invoke the validator from the protected base checkout or the atomically
   installed controller package; never execute the candidate's validator as
   its own authority.
3. Identify the sprint, lane ID, issue, PR, branch, baseline SHA, closeout,
   critic report, checks, review packet, and target integration branch.
4. Run the lane review-chain validator. Confirm the critic's agent and session
   both differ from the worker agent/session recorded in the closeout, the
   critic reviewed closeout-only evidence head E from a separate worktree, and
   the critic report is the only later branch change at S.
5. Confirm a repository admin or maintainer other than the PR author supplied
   the latest effective `APPROVED` review on S, and required checks plus
   PR-policy fields are current.

Read `references/reconcile-and-merge.md` before deciding the lane outcome.

## Procedure

1. **Collect evidence.** Read the PR body, implementation I, closeout-only E,
   report-only S, worker/critic identities, external review, check rollup,
   mergeability, changed paths, issue linkage, and review packet state.
2. **Compare authority.** Check that GitHub issue, lane contract, closeout,
   critic report, PR head, review submission, and check results refer to the
   same lane and their correct implementation/evidence/report revisions.
3. **Classify outcome.**
   - `merge_ready`: the exact D/I/E/S chain validates, the external review on S is
     current, required checks pass, the final evidence packet is complete, and
     no protected gate is open.
   - `return_for_fix`: critic requests changes, checks fail on implementation
     or policy evidence, or PR metadata is stale.
   - `blocked`: merge conflicts, missing evidence, protected decisions, or
     release/deployment gates prevent integration.
4. **Prepare merge or fix-forward.** For merge-ready lanes, record the exact
   individual lane-PR merge action and target. Never use the controller evidence
   branch as the integration candidate. For fixes, release the old worker lease
   as needed
   and ask `subagent-worktree` or `lane-delivery` for one sequential fix worker.
5. **Record evidence.** Write a concise merge/reconciliation note as a PR
   comment or allowed canonical release/outcome/status evidence, including the action,
   evidence, caveats, and next lifecycle route. Never amend packet P after its
   atomic commit.

## Required Outputs

- Merge/reconciliation decision summary with lane, issue, PR, branch, D/I/E/S,
  worker and critic agent/session identities, external reviewer, checks,
  closeout, critic report, packet commit P, target branch, and outcome.
- Either a merge-ready handoff, a fix-forward instruction, or a blocking gate.
- PR comment or allowed canonical release/outcome/status evidence when the decision
  affects human review; packet P remains byte-for-byte unchanged.

## Stop Conditions

Stop when:

- no fresh critic report or complete final evidence packet exists;
- critic/worker agent or session identities are not distinct;
- the report, closeout, PR, or external approval refer to different heads;
- the latest effective external review is not `APPROVED` on S;
- required checks are failing for implementation reasons;
- merge conflicts or shared registration conflicts need manual reconciliation;
- the action would merge to a protected release branch, deploy runtime changes,
  or approve a protected decision without human approval.

## Handoff

Hand off merge-ready lanes and packet P to `release-verification` for individual
lane-PR integration and later runtime evidence. Hand off fix-needed lanes to `subagent-worktree` or
`lane-delivery` fix-forward. Hand off protected blockers to gates or
`sprint-planning` replanning.
