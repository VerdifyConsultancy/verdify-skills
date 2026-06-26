# 2026-06-24 Skills Hardening Code Batch 3 Review

Independent critic review only. I did not implement, edit PR code, merge, or
checkout these PRs. I wrote only this requested critic report.

For each PR I ran:

- `gh pr view <n> --repo VerdifyConsultancy/verdify-skills`
- `gh pr diff <n> --repo VerdifyConsultancy/verdify-skills`
- `gh pr checks <n> --repo VerdifyConsultancy/verdify-skills`

I also read the linked issues (#26, #21, #2), the three approved lane contracts,
and ADR-0012/#9 for the controller-loop ownership dependency on PR #57. Before
writing this report, `ruby scripts/validate-repo.rb` passed in the report
checkout.

## Verdicts

| PR | Lane | Verdict | One-line reason |
| --- | --- | --- | --- |
| #55 | `lane-lane-delivery-correctness` | APPROVE | Correctly replaces the ungrounded `READY_FOR_CRITIC` instruction with `status: ready_for_critic`, specifies a sequential fix-forward lease/worktree procedure, removes `complete-with-risks` from the eval, stays scoped to lane-delivery/eval plus regression test and closeout metadata, and current checks pass. |
| #56 | `lane-prompt-injection-guidance` | APPROVE | Content-trust guidance is concrete rather than vague: transcript/source/web/issue/PR/log/tool text is treated as untrusted data, embedded instructions are refused, prompt-injection is a stop-and-gate condition, the diff is limited to the approved markdown surfaces plus closeout metadata, and current checks pass. |
| #57 | `lane-controller-recovery` | CHANGES-REQUESTED | The recovery/context-reset/loop contract is mostly complete and CI-green, but `skills/controller-loop/assets/loop-record.recoverable-failure.example.yaml` records `pull_request_refs: [52]` and status-event `pull_request: 52` while representing `lane-controller-recovery` / issue #2 / PR #57, making the durable PR reference example internally inconsistent. |

## Overall Note

Current `gh pr checks` shows `pull-request-policy` and `validate` passing for
all three PRs. #55 and #56 are still draft PRs, so they need to be marked ready
before integration even though the reviewed content is approval-ready. I would
not approve #57 until the recoverable-failure example's PR reference is corrected
and checks are rerun.
