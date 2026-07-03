# Sprint Replan Markdown Output

Use this structure for every sprint-replan handoff. Keep it concise enough for a
human reviewer to approve or correct quickly.

```markdown
# <Sprint Name> Replan

## TLDR

- Include:
- Defer:
- Stop for review when:
- Route caveat:

## Included Scope

| Item | Issue / PR | Status | Why now |
|---|---|---|---|

## Deferred / External Work

| Item | Owner | Reason |
|---|---|---|

## Review Milestones

| Milestone | Owner | Evidence |
|---|---|---|

## Route Caveats

| Caveat | Evidence | Required decision |
|---|---|---|

## Validation And Demo Evidence

| Evidence | Command or artifact |
|---|---|

## Next Controller Action

One paragraph naming the next lifecycle skill, whether a plan gate is required,
and which issue-backed lanes are dependency-ready.
```

Rules:

- Keep GitHub Issues as backlog truth.
- Mark items without issues as `needs_issue`.
- Mark work owned by another agent or repository as `external_dependency`.
- Include exact artifact paths when a sprint-orchestrator will consume the
  handoff.
- Do not mark protected decisions approved unless the authorized human decision
  is already recorded.
