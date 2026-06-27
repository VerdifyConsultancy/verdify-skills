# Adversarial Audit Demo: Ship Verify Skills Sprint

Verdict: approve_with_risks

## Reviewed Evidence

- Artifact: `.agent-workflow/sprints/2026-06-27-ship-verify-skills/sprint-plan.yaml`
- Issues / PRs: #90, #91, #92, #93
- Commands: `bin/verdify artifact validate` for sprint plan, lane map, gates,
  contracts, and runbook
- Missing evidence: fresh critic reports are pending until lane PRs complete

## Product Lens

| Severity | Finding | Evidence | Required action |
|---|---|---|---|
| medium | The sprint is useful only if Jason gets a reviewable packet, not just four PRs. | HR-01 review milestone | Build the review inbox after critic reports. |

## Engineering Lens

| Severity | Finding | Evidence | Required action |
|---|---|---|---|
| high | All four lanes touch lifecycle registration surfaces and will conflict at integration. | lane contracts coordinated paths | Use controller-merge reconciliation or serial integration. |

## Security Lens

| Severity | Finding | Evidence | Required action |
|---|---|---|---|
| low | No production or secret access is required. | non-goals and validation-only scope | Keep worker prompts scoped to local repo/worktree evidence. |

## Business Lens

| Severity | Finding | Evidence | Required action |
|---|---|---|---|
| medium | Release-target PRs to `main` may fail version preflight even when package tests pass. | validate workflow policy | Treat version bump as release packaging, not P0 skill correctness. |

## Required Changes

- Keep Sunshine research skill review out of this sprint because another agent
  owns it.
- Preserve shared-registration conflict risk in every lane closeout.

## Open Questions

- Whether final integration should be a combined branch or serial PR merge.

## Residual Risks

- Critic findings may require fix-forward lanes before Jason review.

## Next Route

After all P0 lane PRs have closeouts, route to `independent-critic` and then
`release-verification` review inbox preparation.
