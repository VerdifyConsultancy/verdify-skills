---
name: sprint-planning
description: Selects approved GitHub Issues for a bounded sprint and atomically creates the sprint plan, lane topology, and executable lane contracts. Use after approved state-of-union strategy identifies ready candidate issues, when planning the next delivery slice, or when an existing sprint must be replanned before dispatch.
compatibility: Requires Git, approved project/module artifacts, and GitHub issue access or a current snapshot. No worktree is created until the complete plan transaction is approved.
metadata:
  author: Verdify
  version: "1.0.0"
  lifecycle-order: "5"
---

# Sprint Planning

Turn backlog problems into an approved, executable sprint transaction. GitHub Issues remain the backlog; the sprint plan records the approved delivery snapshot.

## Default unit

```text
one issue -> one lane -> one contract -> one branch -> one worktree -> one worker session -> one PR
```

Use multiple issues in one lane only when they are inseparable at acceptance and merge boundaries. Record `coupling_justification` and obtain explicit plan approval.

## Prerequisites

- approved project definition;
- approved architecture and relevant module contracts;
- approved current state-of-union strategy naming candidate issues;
- current GitHub issues, dependencies, and priorities;
- baseline SHA and repository conventions;
- no unresolved decision that invalidates the proposed scope.

## Planning transaction

Perform these steps as one transaction:

1. **Issue readiness.** Verify each candidate issue describes a problem/outcome, acceptance intent, risk, dependencies, and exclusions. Create or propose missing issues rather than inventing private backlog items.
2. **Sprint selection.** Choose a bounded outcome and explicit non-goals. Record milestone/Project links, baseline, acceptance criteria, risks, deployment expectations, and human gates.
3. **Lane topology.** Assign each issue to exactly one lane by default. Decide parallel versus serial execution based on contracts and dependency risk, not desired agent count.
4. **Lane contracts.** Compile objective, ownership, dependencies, runtime namespace policy, validation, evidence, Git policy, escalation triggers, and definition of done.
5. **Cross-lane review.** Detect overlapping paths, interfaces, runtime resources, database migrations, and incompatible baselines.
6. **Validation.** Validate the sprint plan and every lane contract.
7. **Approval.** Present the complete plan, topology, contracts, risks, and exceptions as one gate. Do not dispatch before approval.

Read `references/issue-readiness.md`, `references/planning-method.md`, and `references/lane-transaction.md` as needed.

## Canonical outputs

- `.agent-workflow/sprints/<sprint-id>/sprint-plan.yaml`
- `.agent-workflow/sprints/<sprint-id>/sprint-plan.md`
- `.agent-workflow/sprints/<sprint-id>/lanes/lane-map.yaml`
- `.agent-workflow/sprints/<sprint-id>/lanes/contracts/<lane-id>.contract.yaml`
- `.agent-workflow/sprints/<sprint-id>/gates/plan-approval.yaml`

Use `../../schemas/sprint-plan.schema.yaml`, `../../schemas/lane-contract.schema.yaml`, and `../../schemas/human-gate.schema.yaml`.

## Handoff

After approval, hand off to `sprint-orchestrator`. The orchestrator, not the planner, creates leases/worktrees when dependencies are ready.

## Replanning

If a dispatched lane requires material scope, interface, baseline, or dependency changes, pause affected lanes. Replan the transaction, version changed contracts, record approvals, and reconcile GitHub before resuming.
