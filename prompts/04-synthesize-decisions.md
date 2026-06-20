# Prompt 04 — Synthesize Decisions

## Variables

- `{{SPRINT_ID}}`
- `{{RESPONSE_TRANSCRIPT_PATH}}`

## Prompt

Convert the human's interview responses at `{{RESPONSE_TRANSCRIPT_PATH}}`, together with the original review and project evidence, into durable decisions for sprint `{{SPRINT_ID}}`.

Do not merely summarize the transcript. Determine what was actually decided, what was suggested, what remains ambiguous, and what was deferred.

For each decision create a record with:

- unique ID;
- title;
- status: `PROPOSED`, `ACCEPTED`, `DEFERRED`, `SUPERSEDED`, or `REJECTED`;
- decision statement;
- desired outcome;
- rationale;
- alternatives considered;
- constraints and non-goals;
- consequences and risks;
- affected components/interfaces;
- affected issues/specifications;
- evidence and transcript question IDs;
- owner and review date;
- conditions that would require revisiting it.

Use explicit language. Do not turn a vague preference into an irreversible architecture decision.

Where responses conflict:

1. quote or paraphrase both interpretations briefly;
2. explain the impact of choosing incorrectly;
3. mark the decision `PROPOSED` or unresolved;
4. prepare one targeted follow-up question.

Create:

- `.verdify/sprints/{{SPRINT_ID}}/decisions/decision-register.yaml`
- ADR or decision Markdown files where the choice has lasting architectural impact;
- `.verdify/sprints/{{SPRINT_ID}}/decisions/unresolved.md`

Validate the register against `schemas/decision-register.schema.yaml`.

Conclude with exactly one planning status:

- `READY_TO_PLAN`
- `READY_TO_PLAN_WITH_DOCUMENTED_DEFAULTS`
- `BLOCKED_BY_DECISIONS`
