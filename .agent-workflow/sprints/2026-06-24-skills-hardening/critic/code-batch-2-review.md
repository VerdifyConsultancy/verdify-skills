# 2026-06-24 Skills Hardening Code Batch 2 Review

Independent critic review only. I did not implement, edit PR code, merge, or checkout these PRs. For each PR I ran:

- `gh pr view <n> --repo VerdifyConsultancy/verdify-skills`
- `gh pr diff <n> --repo VerdifyConsultancy/verdify-skills`
- `gh pr checks <n> --repo VerdifyConsultancy/verdify-skills`

I also compared changed paths against the approved lane contracts and read ADR-0016 plus the local Agent Platform `add_worktree_agent` contract evidence for PR #52.

## Verdicts

| PR | Lane | Verdict | One-line reason |
| --- | --- | --- | --- |
| #50 | `lane-router-gate-bypass` | CONCERN | The router fix is correctly scoped, tested, and CI-green, but issue/contract AC-02's `architecture-contracts` human-gate hardening is not implemented and is only recorded as coordination. |
| #51 | `lane-schema-contradictions` | CONCERN | The four concrete schema/reference/template contradictions are fixed with targeted tests and green CI, but the contract's `scripts/validate-repo.rb` drift guard is absent/deferred to another lane. |
| #52 | `lane-platform-control-regrounding` | CHANGES-REQUESTED | The PR renames dispatch to `add_worktree_agent` and adds the protected-write/release guards, but it still does not emit or link the real `add_worktree_agent(branch, runtime?, name?)` payload: control requests leave `inputs.redacted_payload_ref` nil and only store a prose `parameters_summary`, so ADR-0016/#12 regrounding is incomplete. |
| #53 | `lane-qr-schemarefs` | CONCERN | The bogus `.v1` schema refs are replaced, matching schemas/tests validate the three artifacts, and CI is green, but contract/issue follow-through for SemanticValidator cases and `MANIFEST.sha256` entries is absent/deferred. |

## Overall Note

All four PRs have passing `pull-request-policy` and `validate` checks, and none of the diffs touched a prohibited path I found in the lane contracts. I would not integrate #52 until the control-request generator records an actual payload/ref compatible with the Agent Platform `add_worktree_agent` MCP/API contract. For #50, #51, and #53, the code changes look technically correct within their narrowed lane scope, but they should not be treated as complete closure of their full issue/contract acceptance unless the deferred coordination items are explicitly owned by reviewed follow-up lanes.
