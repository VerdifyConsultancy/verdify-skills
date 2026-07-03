---
name: subagent-worktree
description: Creates and supervises one local Codex or Claude subagent in one isolated Verdify lane worktree with a recorded lease, compiled prompt, closeout expectation, and critic handoff. Use when a controller must launch an internal local worker without relying on Agent Platform dynamic worktrees, while still preserving one issue, branch, worktree, worker session, and PR per lane.
compatibility: Requires Git, the Verdify lane CLI, an approved lane contract, and permission to create local worktrees, branches, leases, and worker prompts. It does not grant production, deployment, or protected decision authority.
metadata:
  author: Verdify
  version: "1.1.2"
---

# Subagent Worktree

Launch exactly one local Codex or Claude worker into exactly one leased Verdify
worktree. This skill is a local fallback and controller helper for environments
where Agent Platform dynamic worktree agents are unavailable or intentionally out
of scope.

## Start

1. Read `../../COMMON_OPERATING_CONTRACT.md` when available.
2. Confirm the sprint plan, lane contract, baseline SHA, branch, issue, owned
   paths, prohibited paths, validation commands, and escalation conditions.
3. Confirm a policy gate or plan approval authorizes local subagent dispatch
   when the runbook expected Agent Platform `add_worktree_agent`.
4. Confirm no active worker lease already owns the lane.

Read `references/local-dispatch.md` before launching a local subagent.

## Procedure

1. **Create or inspect the lease.** Use `bin/verdify lane create` with the lane
   contract, issue, session ID, agent name, base SHA, and explicit worktree
   path. Use `bin/verdify lane inspect` to verify the result.
2. **Compile the prompt.** Use `bin/verdify prompt compile --role worker` and
   pass only the compiled prompt, lease details, contract path, and worktree path
   to the subagent.
3. **Launch one worker.** Start one Codex or Claude subagent. The prompt must
   state that other workers may exist, that the worker must not revert others'
   work, and that all edits must stay in the leased worktree and owned paths.
4. **Monitor by evidence.** Poll the lease, branch, PR, closeout artifact,
   validation output, and worker status. Do not enter the worker's worktree to
   implement the lane unless a human explicitly reassigns the role.
5. **Handle blockers.** If the worker needs protected authority, prohibited
   paths, a schema/API decision, production access, or destructive action, open
   a gate or return to sprint planning.
6. **Close or hand off.** When the worker writes a valid closeout with
   `status: ready_for_critic`, release the worker lease when appropriate and
   hand the branch to `independent-critic`.

## Required Outputs

- Active or released lane lease in `.git/verdify/leases/`.
- Compiled worker prompt and manifest under the sprint prompt directory.
- Worker branch, PR, validation evidence, and closeout path.
- Controller status note naming the next step: critic review, fix-forward, gate,
  or replanning.

## Stop Conditions

Stop rather than launching or continuing a worker when:

- a worker lease already owns the lane;
- the worktree path exists but is not bound to the lease;
- the contract is unapproved, stale, or missing owned/prohibited paths;
- the user asks to use local subagents but no policy exception authorizes the
  fallback from Agent Platform dispatch;
- the worker requests production credentials, deployment authority, destructive
  operations, or protected decision approval.

## Handoff

Handoff to `lane-delivery` for worker execution and to `independent-critic` after
closeout. Include lease ID, session ID, worktree path, branch, PR, head SHA,
compiled prompt manifest, validation results, and closeout path.
