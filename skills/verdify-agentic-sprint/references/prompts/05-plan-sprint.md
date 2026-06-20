# Prompt 05 — Reconcile the Backlog and Plan the Sprint

## Variables

- `{{SPRINT_ID}}`
- `{{TARGET_CADENCE}}` — for example, one meaningful sprint per working day
- `{{ISSUE_WRITE_POLICY}}` — `DRAFT_ONLY` or `AUTHORIZED_TO_UPDATE`
- `{{SPEC_SYSTEM}}` — `OPENSPEC`, another system, or `MARKDOWN`

## Prompt

Create the proposed sprint plan for `{{SPRINT_ID}}` using the verified baseline, human review, accepted decisions, GitHub issue backlog, and `{{TARGET_CADENCE}}`.

The goal is a coherent outcome, not maximum issue count. Do not include work solely to keep every agent busy. Do not force tightly coupled work into parallel lanes.

GitHub Issues are the backlog source of truth. Sprint scope must be represented by GitHub issues before it can be dispatched to lane workers. Reviews, audits, and decisions may propose backlog changes, but they do not become executable work until reconciled into GitHub issues.

### Planning sequence

1. Define one primary sprint outcome in behavior or operational terms.
2. Define measurable acceptance criteria for the whole sprint.
3. State non-goals and explicitly deferred ideas.
4. Identify all required specification or change-proposal updates in `{{SPEC_SYSTEM}}`.
5. Reconcile existing GitHub issues:
   - keep and refine relevant issues;
   - split issues that contain multiple independently verifiable outcomes;
   - merge duplicates conceptually without losing history;
   - close only issues already proven complete;
   - draft new issues for missing work;
   - identify stale or misleading issue states.
6. Identify dependencies, sequencing, risk, migration needs, deployment implications, and rollback requirements.
7. Separate current-sprint work from follow-up backlog.
8. Identify which work needs human approval during execution.

Every included item must have:

- GitHub issue ID or URL;
- outcome;
- scope;
- acceptance criteria;
- dependencies;
- risk;
- evidence required;
- reason it belongs in this sprint.

If `{{ISSUE_WRITE_POLICY}}` is `AUTHORIZED_TO_UPDATE`, update issues and milestones carefully and record every change. Otherwise generate exact proposed issue edits without applying them.

Create:

- `.verdify/sprints/{{SPRINT_ID}}/plan/sprint-plan.yaml`
- `.verdify/sprints/{{SPRINT_ID}}/plan/sprint-plan.md`
- `.verdify/sprints/{{SPRINT_ID}}/plan/backlog-reconciliation.md`
- specification/change-proposal artifacts appropriate to `{{SPEC_SYSTEM}}`

Validate the YAML against `schemas/sprint-plan.schema.yaml`.

End with:

- primary outcome;
- number of included issues/changes;
- number of deferred items;
- blocking dependencies;
- highest risks;
- readiness for lane decomposition.
