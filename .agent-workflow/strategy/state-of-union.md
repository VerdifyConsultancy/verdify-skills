# State of Union — Skills Self-Hardening (2026-06-24)

_Generated view of `state-of-union.yaml` (canonical). Baseline `main@fa8fb8a`. Status: approved._

## What was checked
- **Fresh:** git (`main@fa8fb8a`, clean), GitHub issues (34 open), PRs (0 open), live platform audit of `jvallery/agents`.
- **Stale/incomplete:** North Star (iteration 22, `changes_requested`, gate cancelled), project-definition (`draft`).
- **Missing:** repo-level architecture/module contracts for the skills package itself.
- **Not applicable:** runtime/deployment health (this is a library/CLI; runtime belongs to consuming repos).

## North-star alignment
Goal: *a correct, internally consistent, platform-grounded, secure lifecycle-skills package that can safely drive the jvallery/agents SDLC fleet.* **Alignment: drift** — package validates and tests pass, but 34 issues span a critical grounding gap, correctness/schema bugs, security-enforcement gaps, consistency drift, weak evals, and new capabilities. Product-direction lock is a **separate, non-blocking track**.

## Issue triage (34 open)
- **Decisions / ADRs (resolve first):** #8, #9, #10, #11, #23, #25, #36
- **Candidates (ready or near-ready):** #7, #12, #13, #14, #15, #16, #17, #18, #19, #20, #21, #24, #26, #27, #28, #29, #30, #31, #32, #33, #34
- **Deferred (large new builds):** #1, #3, #35
- **Done:** #4 (delivered as `northstar-question-resolution` → close)

## Recommended sequence (8 waves)
| Wave | Outcome | Issues |
| --- | --- | --- |
| SEQ-001 | Resolve blocking decisions / ADRs | 8, 9, 10, 11, 23, 25, 36 |
| SEQ-002 | Harden the validation engine (safety net) | 31, 17, 20, 30 |
| SEQ-003 | Schema/contract correctness | 13, 14, 28, 29, 33 |
| SEQ-004 | Security enforcement + CLI hardening | 15, 16, 21, 32, 34 |
| SEQ-005 | Reground orchestrator/platform/controller | 12, 18, 22, 27, 2 |
| SEQ-006 | Reconcile lifecycle definitions / counts / docs | 7, 19, 26 |
| SEQ-007 | Eval uplift (+ runner if decided) | 24, 25 |
| SEQ-008 | New capabilities | 1, 3, 35 |

## Next sprint candidates (ready)
1. **Validation-engine hardening** — #31, #17, #20, #30 (one single-owner coupled lane group; shared `scripts/validate-repo.rb` + `lib/verdify/schema_validator.rb`).
2. **Schema/contract correctness** — #13, #14, #28 (lane per issue, sequenced after the engine lane).
3. **Decision track (gates)** — #36, #8, #9 modeled as ADR/decision lanes in parallel.

## Key delivery risks
- High file-surface contention on `scripts/validate-repo.rb`, `lib/verdify/*.rb`, `config/lifecycle.yaml`, `schemas/` → lanes must be owned/sequenced to avoid collisions.
- Seven decisions shape dependent lanes → resolve first.
- Regrounding lanes depend on evolving live platform contracts (agents #1776/#1948).

## Handoff
→ **`sprint-planning` (issue-readiness)**: create the lane map, per-issue lane contracts, shared-surface ownership boundaries, review plan, and plan-approval gate. Treat #8/#9/#10/#11/#23/#25/#36 as decision lanes (deliverable = ADR). Close #4. Product North Star lock remains a separate non-blocking track (GAP-005).
