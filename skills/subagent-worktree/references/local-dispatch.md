# Local Subagent Dispatch

Use this checklist when Agent Platform dynamic worktree dispatch is unavailable
or out of scope.

## Preconditions

- Approved sprint plan and lane contract.
- Explicit local-subagent policy gate or user-approved route exception.
- No active worker lease for the lane.
- Worktree path does not already exist, or it belongs to the same inspected
  lease.
- Baseline SHA resolves to the contract baseline unless stale-baseline approval
  is recorded.

## Commands

```bash
bin/verdify lane create \
  --repo <controller-repo> \
  --sprint <sprint-id> \
  --lane-id <lane-id> \
  --issue <issue-number> \
  --session-id <worker-session-id> \
  --agent <codex-or-claude> \
  --base <baseline-sha> \
  --path <worktree-path>

bin/verdify prompt compile \
  --repo <controller-repo> \
  --contract <lane-contract> \
  --role worker \
  --out <prompt-path>
```

## Worker Prompt Minimums

Tell the worker:

- the exact worktree path, branch, issue, lease ID, and session ID;
- to read the compiled prompt and lane contract first;
- that other agents may be active and their work must not be reverted;
- to edit only owned paths and stop on prohibited paths;
- to run required validation commands;
- to push the branch, open or update one PR, and write a valid closeout with
  `status: ready_for_critic`.

## Evidence To Record

- lease ID and path;
- prompt manifest path and hash;
- branch and PR URL;
- validation command results;
- closeout artifact path;
- blocker, gate, or fix-forward route when the worker cannot complete.
