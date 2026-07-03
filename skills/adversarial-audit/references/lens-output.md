# Lens Output Contract

Use this Markdown structure for focused adversarial audits.

```markdown
# Adversarial Audit: <artifact>

Verdict: <approve | approve_with_risks | changes_required | blocked | decision_required>

## Reviewed Evidence

- Artifact:
- Issues / PRs:
- Commands:
- Missing evidence:

## Product Lens

| Severity | Finding | Evidence | Required action |
|---|---|---|---|

## Engineering Lens

| Severity | Finding | Evidence | Required action |
|---|---|---|---|

## Security Lens

| Severity | Finding | Evidence | Required action |
|---|---|---|---|

## Business Lens

| Severity | Finding | Evidence | Required action |
|---|---|---|---|

## Required Changes

- 

## Open Questions

- 

## Residual Risks

- 

## Next Route

One paragraph naming the owner and lifecycle route.
```

Rules:

- Do not publish secrets, credentials, customer personal data, or exploit-ready
  vulnerability detail.
- Keep machine findings separate from human approval.
- Prefer concrete artifact refs and command output over broad opinion.
- Label unsupported claims instead of treating them as facts.
