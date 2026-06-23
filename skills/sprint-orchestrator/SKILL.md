---
name: sprint-orchestrator
description: Coordinates an approved Verdify sprint by reconciling GitHub, dispatching dependency-ready lane worktrees and sessions, handling gates, monitoring status, and routing completed lanes to criticism and release. Use only after sprint and lane contracts are approved.
compatibility: Requires Git, the Verdify CLI, approved sprint artifacts, and GitHub CLI for live reconciliation. It coordinates but does not implement lane code or review its own work.
metadata:
  author: Verdify
  version: "1.0.0"
  lifecycle-order: "6"
---

# Sprint Orchestrator

Act as conductor, not worker, critic, or deployment operator.

## Start

1. Read the approved sprint plan, wave release plan when present, plan gate,
   lane contracts, module contracts, and dependency order.
2. Refresh GitHub state:

   ```bash
   ../../bin/verdify github snapshot --repo OWNER/REPO --target <repository>
   ../../bin/verdify github reconcile --repo-path <repository> --sprint <sprint-id>
   ```

3. Confirm the baseline, issue state, branch naming, required checks, and authorized agents.
4. Mark only dependency-ready lanes as dispatchable.

## Dispatch

For each ready lane, create exactly one worker worktree and lease:

```bash
../../bin/verdify lane create \
  --repo <repository> \
  --sprint <sprint-id> \
  --lane-id <lane-id> \
  --issue <issue-number> \
  --session-id <unique-session-id> \
  --agent <agent-name>
```

Compile the worker prompt from the contract. Record lease ID, branch, PR, issue, and agent session in sprint status. Never dispatch two workers into the same worktree.

## Monitor events

Handle durable events rather than polling chat narratives:

- heartbeat/status update;
- blocker;
- decision required;
- scope-change request;
- worker closeout;
- critic changes requested or approval;
- CI failure;
- dependency completion;
- lease expiry or abandoned worktree.

Coordinate with `controller-loop` so dispatch, lease, closeout, critic,
review, deployment, gate, and handoff transitions have session-ledger events or
explicit exceptions.

Read `references/state-machine.md` and `references/gate-management.md`.

## Reconcile

At every material transition, compare issue, PR, checks, contract, lease, and artifact state. GitHub is authoritative for backlog and delivery; the lane contract is authoritative for scope; the lease is authoritative only for local worktree ownership.

Read `references/github-reconciliation.md`.

## Role boundaries

- Do not modify lane implementation files.
- Do not use the worker's session or worktree as the critic.
- Do not approve your own material plan exception.
- Do not bypass required checks, reviews, or deployment approvals.
- Do not close a sprint before release verification and outcome review.

## Handoffs

- Ready worker -> `lane-delivery`
- Worker closeout -> fresh `independent-critic`
- Critic changes requested -> original or newly leased `lane-delivery` session per policy
- All required lanes approved -> `release-verification` review-inbox packet mode
- Material replan -> `sprint-planning`
