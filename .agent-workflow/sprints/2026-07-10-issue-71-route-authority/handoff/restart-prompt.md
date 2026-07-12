# Restart Prompt For The Next ROOT Agent

You are the new ROOT agent taking over Jason's autonomous platform program. Treat this as a cold restart, not a continuation of conversational momentum.

Repository: `/Users/jason/repos/verdify-skills`

Start through `$project-router` and obey the repository `AGENTS.md`, `COMMON_OPERATING_CONTRACT.md`, and `config/authority-matrix.yaml`. GitHub Issues are the backlog authority. Use one issue, lane, branch, worktree, worker session, and PR for implementation. One fresh independent critic is sufficient by default. Required CI, exact-head evidence, protected-dev merge, terminal receipt, and post-merge route verification remain mandatory. Do not add routine human gates when machine-verifiable authority is sufficient.

First, page in current truth:

```bash
cd /Users/jason/repos/verdify-skills
git fetch --all --prune
git status --short --branch
git ls-remote origin refs/heads/dev
git show origin/handoff/autonomous-platform-reset-2026-07-11:.agent-workflow/sprints/2026-07-10-issue-71-route-authority/handoff/sprint-handoff.yaml
gh pr view 227 --repo VerdifyConsultancy/verdify-skills --json state,isDraft,headRefOid,baseRefOid,statusCheckRollup,files,body
gh pr list --repo VerdifyConsultancy/verdify-skills --state open --limit 100
gh pr view 226 --repo VerdifyConsultancy/verdify-skills --json state,isDraft,headRefOid,baseRefOid,mergeStateStatus,statusCheckRollup,files,body
gh issue view 211 --repo VerdifyConsultancy/verdify-skills --json state,comments,url
gh issue view 73 --repo VerdifyConsultancy/verdify-skills --json state,body,comments,url
gh issue view 225 --repo VerdifyConsultancy/verdify-skills --json state,body,url
gh issue view 70 --repo VerdifyConsultancy/verdify-skills --json state,comments,url
gh issue view 2884 --repo jvallery/agents --json state,title,url
gh issue view 2887 --repo jvallery/agents --json state,title,url
gh issue view 2906 --repo jvallery/agents --json state,title,url
ruby scripts/validate-repo.rb
bin/verdify route
ruby -Ilib -rverdify -e 'v=Verdify::SprintTerminalReceipt.new(repo: Dir.pwd); p v.integrated_unterminated_sprints(ref: "HEAD")'
```

Expected protected-dev baseline at handoff is `4fe6ff65338bb129cbfbeb2451cb5a5fa696533d`. Verify it; do not assume it stayed fixed.

Completed program floor:

- Issue #135 terminal sprint authority is closed and terminal.
- Issue #215 authenticated receipt CI is closed and terminal.
- Issue #71 route authority is closed and terminal.
- Issue #71 canonical evidence is D `5a44681f`, I2 `ea176990`, E3 `12d26d89`, S2 `3f2db1e6`, evidence merge `8487e662`, receipt `4eb47bb9`, and receipt merge `4fe6ff65`.
- `integrated_unterminated_sprints` was empty at shutdown.

Checkpointed planning:

- Draft PR #226, branch `planning/post-71-state-of-union`, head `46318545fd04930e8d3e711de2e1e1c974f9ab5f`.
- It changes exactly `.agent-workflow/strategy/state-of-union.yaml`, `.agent-workflow/strategy/state-of-union.md`, and `.agent-workflow/strategy/github-backlog-sync.yaml`.
- Both YAML artifacts and repository validation passed locally.
- Its intent is to record #71 terminal, make #73 the sole next candidate, preserve the full sequence, preserve Agents #2884/#2887/#2906 as Stage 0 stops, and track issue #225 as a nonblocking schema follow-up.
- PR #226 was draft and blocked at capture. Compliance and validate passed; policy, delivery-policy, and critic-gate failed on the known planning-only evidence mismatch. Re-probe. Do not blindly merge.
- Issue #211 is open only as the strategy-refresh owner and should close only after the strategy actually merges and post-merge route verification passes.

Immediate decision for the new agent:

1. Inspect PR #226 and this handoff.
2. Re-run project-router from protected dev.
3. Either finish PR #226 as the bounded three-artifact refresh or supersede it explicitly with a cleaner refresh. Do not silently abandon or duplicate it.
4. If finishing it requires the existing planning-only policy exception, record the exception narrowly, restore protection immediately, and keep issue #70 as the durable policy owner. Do not fabricate an implementation lane or critic for planning-only output.
5. After merge, verify project-router returns `STATE_OF_UNION_HANDOFF -> sprint-planning/lane-transaction` for issue #73.

Issue #73 bounded acceptance is recorded at https://github.com/VerdifyConsultancy/verdify-skills/issues/73#issuecomment-4940929833:

- `approve` and `approve_with_risks` require non-empty assessment;
- approving criterion IDs exactly equal LaneContract criterion IDs, order-independently and without duplicates;
- every approving assessment is `satisfied` with non-empty evidence;
- non-approving reports may remain empty or partial, but supplied IDs are unique and contract-valid;
- closeout IDs are a unique contract-valid subset because E cannot claim future S, CI, integration, deployment, or outcome evidence;
- empty verified-release `integration_results` remains rejected;
- `request_fixes` with an empty assessment remains valid;
- add coverage proving vacuous evidence cannot authorize review inbox, merge, or terminal receipt.

Issue #225 owns structured lifecycle-phase schema. Do not infer phase from free text and do not expand #73 silently.

Critical incidents and policy context:

- PR #221 merged before critic evidence.
- PR #222 merged the fix before corrected closeout and re-review.
- PR #223 integrated exact E3/S2 under a recorded exception and has zero GitHub reviews.
- These are issue #70 evidence, not compliant precedent.
- Latest dev-push delivery run `29133631578` was red only because no promotion PR existed. Issue #70 owns typed no-op promotion semantics.
- The user's intent is clear schema, accountability, and high-quality outputs without heavy process. One critic, green CI, deterministic receipts, and typed stops are the balance to codify.

Continue this authorized sequence after #73:

1. Verdify #75 and #74.
2. Verdify #43 and #70.
3. Agents #2884, #2887, #2906, #2890, #2905.
4. Verdify #12/#116 plus Agents #2497/#655.
5. Gravity #184/#407.
6. Orbit #193-#198 and #43.
7. One complete four-project transaction with a single correlation ID.
8. Failure drills and seven unattended days before broader fleet autonomy.

Hard stop: do not begin the four-project vertical slice while Agents #2884, #2887, or #2906 remains open.

Shutdown hygiene at capture:

- Root `dev` checkout was clean and matched `origin/dev`.
- All issue #135 and #71 worker/critic leases were released.
- No active implementation session remained.
- Strategy WIP was committed and pushed.
- `origin/quarantine/issue71-root-artifact-misapply` is forensic only. Never merge it.
- Do not print or copy raw credentials; use existing credential references and auth homes.
