---
name: independent-critic
description: Performs fresh-context, evidence-based review of a completed Verdify lane against its issue, requirements, module and lane contracts, diff, tests, CI, and worker closeout. Use after worker closeout and before review-inbox packet assembly or integration; never reuse the worker's session or worktree.
compatibility: Requires read access to the repository, pull request, checks, contracts, and evidence, plus narrowly scoped permission to commit only the canonical critic report. A separate detached worktree or clean clone is required; advancing approval comes afterward from a repository admin or maintainer other than the PR author.
metadata:
  author: Verdify
  version: "1.2.1"
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

3. Confirm `critic_agent` and `critic_session_id` both differ from the committed closeout's worker agent/session even if the worker lease has been released, and confirm the detached checkout is the live PR evidence head.
4. Do not edit implementation or worker evidence. The only authorized branch write after review is the canonical critic report path.

## Review inputs

- GitHub issue and dependencies;
- approved project requirements/design criteria;
- architecture and module contracts;
- separate approved dispatch commit D, lane contract, and approved changes;
- PR diff and commit history;
- worker closeout and evidence;
- required implementation checks at I and live PR evidence head E;
- deployment/migration implications.

## Procedure

1. Reconstruct intended behavior independently.
2. Validate dispatch and scope: D is the first post-baseline commit, contains
   only the approved plan/wave/contract transaction, those artifacts do not
   change afterward, and implementation respects owned/prohibited paths and
   issue cardinality.
3. Validate behavior: criteria, edge cases, failure paths, security, data integrity, compatibility, and operability.
4. Re-run high-value tests or inspect trusted check evidence. Do not accept a command list as proof it ran.
5. Assess evidence quality, limitations, and whether checks refer to `implementation_head_sha`; verify every commit from implementation head through evidence head is linear and changes only the canonical closeout path.
6. Search for architecture drift and cross-lane integration risk.
7. Classify each finding by severity and cite concrete file, line, command, criterion, or evidence.
8. Write `.agent-workflow/sprints/<sprint-id>/critic/<lane-id>.critic.yaml` with `worker_agent`/`worker_session_id` backlinks, distinct `critic_agent`/`critic_session_id`, the PR, implementation head, evidence/reviewed head, canonical closeout path, and closeout SHA-256; validate it against `../../schemas/critic-report.schema.yaml`.
9. Commit that report as the only changed path after the evidence head, push it, and update the PR's exact current-head metadata. This report commit is the final PR head for review submission.
10. Preserve critic session ID, review worktree, PR/head SHA, findings, outcome,
   and artifact refs for the session ledger.
11. Hand the final report head to an authorized repository admin or maintainer other than the PR author for a commit-bound GitHub approval. Do not commit anything afterward.

Read `references/critic-rubric.md` and `references/evidence-review.md`.

## GitHub review submission

An advancing PR approval is valid only when all authorization checks are true:

- the critic report validates, its reviewed head equals the closeout-only evidence head, and its implementation plus worker-agent/session backlinks match the closeout;
- the implementation-to-evidence suffix changes only the closeout and the evidence-to-report suffix changes only the critic report;
- the live PR head equals the commit containing the critic report;
- the lane contract, issue, PR, required checks, and evidence are available for
  the current head;
- the submitting GitHub account has current repository `admin` or `maintain`
  permission and is not the PR author;
- no unresolved material scope, security, migration, deployment, or human-only
  approval gate remains open.

The authorized admin/maintainer uses this command, with the body file containing
the critic outcome, findings, evidence summary, limitations, and artifact refs:

```bash
gh pr review <pr-number> --approve --body-file <critic-review-body.md>
gh pr review <pr-number> --request-changes --body-file <critic-review-body.md>
```

Map critic outcomes to GitHub review events as follows:

| Critic outcome | GitHub review event | Command |
| --- | --- | --- |
| `approve` | Approve | `gh pr review <pr-number> --approve --body-file <critic-review-body.md>` |
| `approve_with_risks` | Approve, only when residual-risk acceptance is authorized by policy or handoff; otherwise use `needs_human_review` | `gh pr review <pr-number> --approve --body-file <critic-review-body.md>` |
| `request_fixes` | Request changes | `gh pr review <pr-number> --request-changes --body-file <critic-review-body.md>` |
| `block_integration` | Request changes | `gh pr review <pr-number> --request-changes --body-file <critic-review-body.md>` |
| `needs_human_review` | No advancing approval | Record the critic report and route to the named human reviewer. |

If any authorization check fails, do not treat a comment or self-review as
approval. Finish the critic report, record the missing authorization or gate, and hand off to
`sprint-orchestrator`, `release-verification`, or the configured human reviewer.

## Outcomes

- `approve`
- `approve_with_risks`
- `request_fixes`
- `block_integration`
- `needs_human_review`

Approval means the implementation head satisfies the contract, the evidence and report suffixes contain only their canonical artifacts, and a distinct repository admin/maintainer's latest effective GitHub review is `APPROVED` on the final report head. Any new commit or later change-request review invalidates approval until the full chain is rebuilt and re-reviewed.

## Handoff

- Fixes -> `lane-delivery` through the orchestrator
- Material contract problem -> `sprint-planning` or `architecture-contracts`
- Approving critic outcome -> external admin/maintainer approval on S, then
  `sprint-orchestrator` and `release-verification` packet-only P when
  dependencies are ready
