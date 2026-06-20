# Prompt 14 — Reconcile Records and Close the Sprint

## Variables

- `{{SPRINT_ID}}`
- `{{DEPLOYMENT_OUTCOME}}`
- `{{ISSUE_WRITE_POLICY}}`
- `{{SPEC_SYSTEM}}`
- `{{BRANCH_CLEANUP_POLICY}}`

## Prompt

Perform the final record reconciliation and closure for sprint `{{SPRINT_ID}}` after deployment outcome `{{DEPLOYMENT_OUTCOME}}`.

Your job is to make project systems reflect reality. Do not close issues merely because code was merged, and do not archive proposed behavior into current truth unless deployment verification supports it.

### Reconcile

1. **Code and Git**
   - record final integration/default-branch SHA;
   - confirm intended commits are present;
   - confirm no dirty worktrees or unpushed sprint work remain;
   - apply `{{BRANCH_CLEANUP_POLICY}}` only after preserving required history.
2. **Pull requests**
   - ensure merged, closed, or deferred state is correct;
   - ensure descriptions and links identify the issues/specs/lanes delivered.
3. **Issues and milestones**
   - close only fully delivered and verified issues;
   - update partially delivered issues accurately;
   - create follow-up issues for known defects, debt, or deferred criteria;
   - remove stale labels/assignments and update the sprint milestone.
4. **Specifications and architecture**
   - update `{{SPEC_SYSTEM}}` to current deployed truth;
   - archive approved change proposals only when verified;
   - update ADR/decision status and supersession links;
   - correct documentation drift discovered during the sprint.
5. **Evidence and risk**
   - link final CI, critic, integration, deployment, and runtime evidence;
   - record residual risk, accepted exceptions, rollback status, and unresolved incidents.
6. **Workflow state**
   - mark every lane terminal;
   - record cancelled/deferred scope;
   - create carryover entries for the next sprint;
   - set sprint state to `COMPLETE`, `COMPLETE_WITH_FOLLOWUPS`, `ROLLED_BACK`, or `FAILED`.

Create:

- `.verdify/sprints/{{SPRINT_ID}}/closure/sprint-closure-report.md`
- `.verdify/sprints/{{SPRINT_ID}}/closure/carryover.yaml`
- `.verdify/sprints/{{SPRINT_ID}}/closure/final-evidence.yaml`

The closure report must clearly state:

- planned outcome;
- delivered and verified outcome;
- work not delivered;
- merged PRs and final revision;
- deployment result;
- issues closed/updated/created;
- specs/docs/decisions updated;
- residual risk and follow-ups;
- repository/worktree cleanliness;
- next recommended human review.

Do not use `COMPLETE` when mandatory acceptance or deployment verification failed.
