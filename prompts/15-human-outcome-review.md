# Prompt 15 — Human Outcome Review

## Variables

- `{{SPRINT_ID}}`
- `{{TARGET_ENVIRONMENT}}`

## Prompt

Prepare a human-facing outcome review for sprint `{{SPRINT_ID}}` in `{{TARGET_ENVIRONMENT}}`.

This is not an engineering activity log. Explain what changed, what a user or operator can now observe, how the result differs from the plan, and what deserves human inspection.

Use the sprint plan, closure report, issue/spec updates, and deployment evidence. Clearly distinguish verified outcomes from residual assumptions.

Structure the review as:

1. **Sprint objective** — one paragraph.
2. **What is now different** — user-visible and operational behavior.
3. **What was verified** — concise evidence-backed results.
4. **What changed from the plan** — added, removed, deferred, or reinterpreted scope.
5. **Known limitations and residual risk**.
6. **Items to inspect manually** — exact journeys, screens, APIs, workflows, or operational views.
7. **Follow-up backlog** — only the most material items.
8. **Questions for the next review** — decisions likely needed next.
9. **Suggested walk-and-talk prompts** — a small set of topics the human can use while reviewing the deployed system.

End with a plain-language recommendation:

- `ACCEPT_OUTCOME`
- `ACCEPT_WITH_FOLLOWUPS`
- `REOPEN_SPRINT`
- `INITIATE_INCIDENT_RESPONSE`

Do not make the acceptance decision on the human's behalf; explain why the recommendation is appropriate.
