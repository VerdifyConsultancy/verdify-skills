# 2026-06-24 Skills Hardening Code Batch 1 Review

Independent critic review only. I did not implement, edit, merge, or checkout these PRs. For each PR I ran:

- `gh pr view <n> --repo VerdifyConsultancy/verdify-skills`
- `gh pr diff <n> --repo VerdifyConsultancy/verdify-skills`
- `gh pr checks <n> --repo VerdifyConsultancy/verdify-skills`

## Verdicts

| PR | Lane | Verdict | One-line reason |
| --- | --- | --- | --- |
| #44 | `lane-validator-engine` | CHANGES-REQUESTED | Issue #17 is not fully fixed: the PR leaves the `release-verification` cross-skill token as `skills/platform-readiness/...` and teaches the validator to accept it as repo-root, while filesystem-backed skill resources are resolved relative to the skill directory; #31 coverage and CI otherwise look good. |
| #45 | `lane-route-decision-enum` | CONCERN | The enum addition is correct, scoped, and CI-green, but the PR has no committed regression/validator guard for future `route-decision` vs `state-of-union` enum drift, which was part of issue #13's proposed fix. |
| #46 | `lane-eval-uplift` | APPROVE | Adds the high-risk eval cases named in issue #24 within `evaluations/*`, with JSON/validator/test evidence and passing CI. |
| #47 | `lane-controller-state-fields` | APPROVE | Adds controller/session liveness and wave-supervision persistence to the owned schemas, templates, and controller-loop docs, with validation evidence and passing CI. |
| #48 | `lane-orphan-artifacts` | APPROVE | Backs or removes the declared orphan artifacts/policies from issue #29 in the expected skill/schema/config surfaces, validates new examples/templates, and CI passes. |
| #49 | `lane-skill-count-drift` | APPROVE | Reconciles the 18 lifecycle plus 1 standalone skill framing, ADR index, traceability, research note, and changelog surfaces from issue #19, with validation and passing CI. |

## Overall Note

Observed GitHub checks were passing for all six PRs. I would not integrate #44 until the `release-verification` reference behavior is corrected or the skill-loading contract explicitly permits repo-root `skills/...` references. I would also avoid treating #45 as the complete anti-drift fix for #13 unless the enum consistency guard lands in another reviewed lane.
