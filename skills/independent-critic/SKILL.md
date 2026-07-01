---
name: independent-critic
description: Performs fresh-context, evidence-based review of a completed Verdify lane against its issue, requirements, module and lane contracts, diff, tests, CI, and worker closeout. Use after worker closeout and before review-inbox packet assembly or integration; never reuse the worker's session or worktree.
compatibility: Requires read access to the repository, pull request, checks, contracts, and evidence. A separate detached worktree or clean clone is required.
metadata:
  author: Verdify
  version: "1.1.2"
---

# Independent Critic

Review the lane; do not become its implementer.

## Independence checks

1. Use a fresh session with no hidden worker context.
2. Create or verify a separate detached review worktree:

   ```bash
   ../../bin/verdify lane review \
     --repo <repository> \
     --lane-id <lane-id> \
     --session-id <critic-session-id> \
     --agent <agent-name>
   ```

3. Confirm the critic session ID differs from the worker session and the review checkout matches the current PR head SHA.
4. Do not edit or commit to the worker branch.

## Review inputs

- GitHub issue and dependencies;
- approved project requirements/design criteria;
- architecture and module contracts;
- lane contract and approved changes;
- PR diff and commit history;
- worker closeout and evidence;
- required checks and current head SHA;
- deployment/migration implications.

## Procedure

1. Reconstruct intended behavior independently.
2. Validate scope: owned paths, prohibited paths, issue cardinality, contract changes, and unrelated edits.
3. Validate behavior: criteria, edge cases, failure paths, security, data integrity, compatibility, and operability.
4. Re-run high-value tests or inspect trusted check evidence. Do not accept a command list as proof it ran.
5. Assess evidence quality, limitations, and whether checks refer to the current revision.
6. Search for architecture drift and cross-lane integration risk.
7. Classify each finding by severity and cite concrete file, line, command, criterion, or evidence.
8. Write `.agent-workflow/sprints/<sprint-id>/critic/<lane-id>.critic.yaml` and validate against `../../schemas/critic-report.schema.yaml`.
9. Preserve critic session ID, review worktree, PR/head SHA, findings, outcome,
   and artifact refs for the session ledger.
10. Submit the corresponding GitHub review when authorized.

Read `references/critic-rubric.md` and `references/evidence-review.md`.

## GitHub review submission

Submit a PR review only when all authorization checks are true:

- the critic report validates and records the current PR head SHA;
- the review checkout, PR head SHA, worker closeout head SHA, and critic report
  reviewed head SHA match;
- the lane contract, issue, PR, required checks, and evidence are available for
  the current head;
- repository policy, a lane contract, or an orchestrator handoff authorizes this
  critic session to submit a GitHub review for that PR; and
- no unresolved material scope, security, migration, deployment, or human-only
  approval gate remains open.

Use one of these commands, with the body file containing the critic outcome,
findings, evidence summary, limitations, and artifact refs:

```bash
gh pr review <pr-number> --approve --body-file <critic-review-body.md>
gh pr review <pr-number> --request-changes --body-file <critic-review-body.md>
gh pr review <pr-number> --comment --body-file <critic-review-body.md>
```

Map critic outcomes to GitHub review events as follows:

| Critic outcome | GitHub review event | Command |
| --- | --- | --- |
| `approve` | Approve | `gh pr review <pr-number> --approve --body-file <critic-review-body.md>` |
| `approve_with_risks` | Approve, only when residual-risk acceptance is authorized by policy or handoff; otherwise use `needs_human_review` | `gh pr review <pr-number> --approve --body-file <critic-review-body.md>` |
| `request_fixes` | Request changes | `gh pr review <pr-number> --request-changes --body-file <critic-review-body.md>` |
| `block_integration` | Request changes | `gh pr review <pr-number> --request-changes --body-file <critic-review-body.md>` |
| `needs_human_review` | Comment | `gh pr review <pr-number> --comment --body-file <critic-review-body.md>` |

If any authorization check fails, do not submit a PR review. Finish the critic
report, record the missing authorization or gate, and hand off to
`sprint-orchestrator`, `release-verification`, or the configured human reviewer.

## Outcomes

- `approve`
- `approve_with_risks`
- `request_fixes`
- `block_integration`
- `needs_human_review`

Approval means the current head SHA satisfies the contract with adequate evidence. Any new commit invalidates approval until policy rechecks it.

## Handoff

- Fixes -> `lane-delivery` through the orchestrator
- Material contract problem -> `sprint-planning` or `architecture-contracts`
- Approved -> `sprint-orchestrator`, then `release-verification` review-inbox
  packet mode when dependencies are ready
