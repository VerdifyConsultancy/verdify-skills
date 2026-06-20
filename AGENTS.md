# Verdify Agent Instructions

## Default Workflow

Use the `verdify-agentic-sprint` skill for any work involving:

- repository discovery or audit;
- GitHub issue backlog reconciliation;
- sprint planning;
- lane decomposition;
- lane execution or status;
- independent critic review;
- integration across lanes;
- deployment verification;
- sprint closure.

The skill is available to Codex from `.agents/skills/verdify-agentic-sprint`.

## Operating Rules

- Treat GitHub Issues as the backlog source of truth.
- Do not plan executable work unless it maps to GitHub issues or approved issue updates.
- Assign every approved GitHub issue to exactly one lane.
- Keep lane workers focused on their assigned issues.
- Use feature branches and pull requests for lane work.
- Bring work back through integration in dependency order.
- Require GitHub CI/CD evidence before deployment verification.
- Record human or managing-agent gates under `.verdify/sprints/<sprint-id>/gates/`.

## Validation

Before claiming this repository is ready for agent use, run:

```bash
ruby scripts/validate-repo.rb
```
