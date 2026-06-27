# Ship Verify Skills Replan Demo

## TLDR

- Include: sprint-replan, subagent-worktree, controller-merge, and
  adversarial-audit P0 skill lanes.
- Defer: Sunshine research skill implementation and review, because another
  agent owns that work.
- Stop for review when: each P0 PR has validation, closeout, and a fresh critic
  report, and the review inbox packet is complete.
- Route caveat: the router can still require North Star artifact-loop; execution
  requires an explicit bounded exception or an approved sprint transaction.

## Included Scope

| Item | Issue / PR | Status | Why now |
|---|---|---|---|
| sprint-replan | #90 | include | Gives controllers one standard Markdown replan handoff. |
| subagent-worktree | #91 | include | Defines local Codex/Claude worker isolation without platform dynamic worktrees. |
| controller-merge | #92 | include | Gives controllers a merge/reconcile or return-for-fix surface. |
| adversarial-audit | #93 | include | Adds product, engineering, security, and business lenses for plans and handoffs. |

## Deferred / External Work

| Item | Owner | Reason |
|---|---|---|
| Sunshine research skill | external agent | User clarified another agent is already building it. |
| Cross-agent proposal/review loop | future sprint | Useful but not required for the P0 review milestone. |

## Review Milestones

| Milestone | Owner | Evidence |
|---|---|---|
| Per-P0 PR review | fresh critic | PR, validation, closeout, and critic report for each lane. |
| Demo review | Jason | Demo references for replan, subagent worktree, controller merge, and adversarial audit. |
| Human review inbox | Jason | `.agent-workflow/sprints/2026-06-27-ship-verify-skills/review/review-inbox-packet.yaml`. |

## Route Caveats

| Caveat | Evidence | Required decision |
|---|---|---|
| Router may still point at North Star artifact-loop | `bin/verdify route` | Explicit bounded execution approval or plan approval gate. |
| Shared registration surfaces can conflict across PRs | lane contracts | Serial review or controller merge reconciliation. |

## Validation And Demo Evidence

| Evidence | Command or artifact |
|---|---|
| Repository validation | `ruby scripts/validate-repo.rb` |
| Regression suite | `make test` |
| Sprint-replan demo | this file |

## Next Controller Action

Use `sprint-orchestrator` only after the bounded exception or approved sprint
transaction is recorded. Dispatch one issue-backed lane per branch/worktree and
stop when all P0 PRs are critic-reviewed and ready for Jason's review.
