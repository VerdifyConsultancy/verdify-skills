# Prompt 02 — Ingest and Correlate the Human Sprint Review

## Variables

- `{{SPRINT_ID}}`
- `{{TRANSCRIPT_PATH}}`

## Prompt

You are the same Controller that completed the current-state audit for sprint `{{SPRINT_ID}}`.

Read the raw human review transcript at `{{TRANSCRIPT_PATH}}`. Preserve its meaning, including uncertainty, frustration, incomplete ideas, and contradictions. Do not treat every statement as a requirement or fact.

Correlate the transcript with the repository and runtime evidence already collected.

Classify each material statement as one or more of:

- `OBSERVATION` — something the human believes they saw;
- `DESIRED_OUTCOME` — a result they want;
- `PROPOSED_SOLUTION` — a suggested implementation, not automatically a requirement;
- `CONCERN` — risk, defect, or dissatisfaction;
- `DECISION` — an explicit choice;
- `PRIORITY_SIGNAL` — urgency or relative importance;
- `HYPOTHESIS` — a possible explanation that needs validation;
- `CONSTRAINT` — a boundary the plan must respect;
- `NON_GOAL` — something intentionally excluded;
- `CONTRADICTION` — tension with another statement or current evidence;
- `UNKNOWN` — meaning cannot yet be determined.

For every item:

1. Preserve a short paraphrase of the human's meaning.
2. Link it to supporting or contradicting evidence.
3. State whether it can be resolved from the repository without asking the human.
4. Identify the decision, issue, specification, or lane that it may affect.
5. Do not silently convert a proposed solution into the final architecture.

Create:

- `.verdify/sprints/{{SPRINT_ID}}/review/review-synthesis.md`
- `.verdify/sprints/{{SPRINT_ID}}/review/claim-correlation.yaml`
- `.verdify/sprints/{{SPRINT_ID}}/review/question-candidates.md`

The synthesis must contain:

- dominant themes;
- desired outcomes;
- validated concerns;
- unvalidated hypotheses;
- explicit decisions already made;
- contradictions and ambiguities;
- likely sprint candidates;
- items that should become follow-up backlog rather than current sprint work.

End by reporting the number of candidate questions in these groups:

- blocking product decisions;
- blocking architecture decisions;
- scope and priority decisions;
- risk/deployment decisions;
- non-blocking clarification.
