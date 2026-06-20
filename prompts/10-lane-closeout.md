# Prompt 10 — Lane Closeout and Adversarial Self-Audit

## Variables

- `{{SPRINT_ID}}`
- `{{LANE_ID}}`
- `{{LANE_CONTRACT_PATH}}`

## Prompt

Perform the complete closeout for lane `{{LANE_ID}}` in sprint `{{SPRINT_ID}}`.

Do not assume the lane is complete because implementation activity has stopped. Re-read `{{LANE_CONTRACT_PATH}}`, inspect the full diff from the lane baseline, and try to disprove your own completion claim.

### Required closeout sequence

1. **Scope audit**
   - list every changed file and classify it as owned, coordination-approved, or out of scope;
   - explain any contract deviation;
   - remove accidental or unrelated changes.
2. **Acceptance audit**
   - evaluate every criterion individually;
   - link each passing criterion to evidence;
   - do not mark an untested criterion as passed.
3. **Adversarial code review**
   - look for regressions, omitted edge cases, interface breakage, concurrency issues, error handling gaps, security problems, migration hazards, observability gaps, and misleading documentation;
   - inspect code paths not exercised by the happy path.
4. **Validation**
   - run every required command from the contract;
   - run additional targeted tests warranted by the diff;
   - capture commands, revisions, results, and artifact locations.
5. **Records**
   - update assigned issues, PR description, specifications, tasks, and docs as required;
   - create or draft separate issues for unrelated discoveries;
   - record deferred acceptance criteria explicitly.
6. **Git hygiene**
   - make coherent final commits;
   - push the branch;
   - confirm remote HEAD matches local HEAD;
   - confirm no intended work is uncommitted or untracked;
   - do not merge unless explicitly authorized.
7. **Evidence and handoff**
   - finalize `evidence.yaml`;
   - create `closure-report.md`;
   - set state to `READY_FOR_CRITIC` only if every mandatory gate passes.

The closure report must contain:

- objective and delivered outcome;
- commits and PR;
- changed interfaces/resources;
- acceptance-criteria table;
- test and validation results;
- issue/spec/doc updates;
- new follow-up issues;
- known limitations and residual risk;
- rollback or disablement considerations;
- exact Git cleanliness and push status.

If any mandatory gate fails, set state to `CHANGES_REQUESTED`, `BLOCKED`, or `DECISION_REQUIRED`; do not use `READY_FOR_CRITIC`.
