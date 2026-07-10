---
name: lane-delivery
description: Implements and closes out one approved lane contract inside one leased Git worktree and one coding-agent session. Use only when assigned a specific lane, issue, contract, branch, worktree, and lease; also use for contract-scoped fixes requested by an independent critic.
compatibility: Requires Git, an active Verdify worker lease, repository build tools, and permission to push the lane branch and update its pull request.
metadata:
  author: Verdify
  version: "1.3.0"
---

# Lane Delivery

You are a bounded worker. Implement one lane and finish its closeout in the same session.

## Start checks

1. Read `../../COMMON_OPERATING_CONTRACT.md` and the assigned lane/module contracts.
2. Inspect the active lease:

   ```bash
   ../../bin/verdify lane inspect --repo <repository> --lease-id <lease-id>
   ```

3. Confirm session ID, worktree, branch, issue, baseline, contract status, owned paths, prohibited paths, dependencies, and runtime namespaces.
4. Confirm the first commit after the contract baseline is the CLI-created
   dispatch commit containing only the approved SprintPlan, wave release plan
   when required, and canonical lane contract. Stop if any dispatch artifact
   changed afterward.
5. Reconstruct relevant code and tests before editing.
6. Stop if the lease does not belong to this session or the contract is stale/unapproved.

Read `references/worker-procedure.md` before implementation.

## Implementation mode

- Work only inside the leased worktree.
- Treat the seeded dispatch artifacts as immutable implementation inputs; do
  not edit the SprintPlan, wave release plan, or lane contract while coding.
- Modify only owned paths/interfaces unless a recorded coordination rule permits otherwise.
- Preserve public/module contracts.
- Use the lease's isolated database, container, cache, port, and namespace values.
- Start workers with the approved allowlisted environment only; worker lanes do
  not inherit production credentials and must not request them.
- Run validation incrementally.
- Keep commits coherent and attributable.
- Create or update one PR linked to the issue and lane contract.
- Create/propose a GitHub issue for discovered work; do not smuggle it into this lane.

## Scope and decision changes

Stop and open a gate for missing upstream contracts, public API/schema changes, migrations, security-boundary changes, destructive operations, new privileged dependencies, ownership conflicts, or acceptance criteria that cannot be met as written.

Read `references/scope-change.md`. Do not patch the contract after implementation merely to match the diff.

## Closeout mode

Closeout is the final worker action, not a separate skill.

1. Run every required validation command and capture exact results.
2. Compare the diff with owned/prohibited paths and the baseline SHA, keeping
   the approved dispatch commit D distinct from substantive implementation I.
3. Map evidence to every lane acceptance criterion.
4. Finish all substantive edits and validation, commit them, and record that commit as `implementation_head_sha` and `validated_head_sha`. Open or update the draft PR with that implementation head, `Evidence head SHA: pending`, and an exact current head.
5. Record untracked files, residual risks, discovered issues, and deployment implications.
6. Write the closeout file with `status: ready_for_critic` at `.agent-workflow/sprints/<sprint-id>/lanes/closeout/<lane-id>.closeout.yaml`, including the implementation/validated heads and the lease-backed `worker_agent` and `worker_session_id`, and validate it against `../../schemas/lane-closeout.schema.yaml`.
7. Commit the closeout as the only changed path after the implementation head. That commit is the evidence head; push it and update the PR's `Evidence head SHA` and exact `Current head SHA` to it.
8. Stop writing to the lane branch. The route engine treats closeout-file presence with no critic file as readiness for criticism only when the closeout-only evidence chain validates. Do not write any integrated or complete status.

Read `references/closeout-procedure.md`.

## Fix-forward mode

When the critic requests contract-scoped fixes, the controller uses one canonical worktree/lease procedure: release the prior worker lease with `bin/verdify lane release --keep-worktree`, then create one new sequential worker lease for the same lane and worktree path with a new `--session-id`. The fix-forward worker starts only after `bin/verdify lane inspect` shows that new lease is active and no other active worker lease owns the lane/worktree. Address only cited findings, rerun affected and required validation, update the closeout, and return to fresh criticism.

## Handoff

Provide contract, issue, PR, implementation and evidence heads, closeout, evidence, known risks, session
ID, lease/worktree refs, and artifact refs to `independent-critic` and
`controller-loop` for session-ledger events. Do not reuse this session as
critic.
