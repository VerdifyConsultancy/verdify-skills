# Issue Reconciliation And Duplicate-Search Evidence

Status: `complete`
Lane: `issue-119-northstar-review-feedback`
Snapshot: `2026-07-09T23:28:41Z`
GitHub authority: live `gh issue list` and direct issue reads as `jvallery`

## Method

Each proposed gap was searched in its owning repository before a new issue was
accepted. Searches included closed issues so a retired or stale tracker would
not be missed. The reproducible command shape was:

```text
gh issue list --repo OWNER/REPO --state all --limit 20 \
  --search "TERMS" --json number,title,state,url
```

Search is lexical and can return no result for a known semantic match, so the
audit also inspected exact issues named by the current-state audits. Existing
issues were updated or reopened when they owned the gap; a new issue was kept
only when no existing issue had the same desired outcome and acceptance scope.

## Live Search Results

| Query ID | Repository | Search terms | Material results | Disposition |
| --- | --- | --- | --- | --- |
| DQ-001 | `VerdifyConsultancy/verdify-skills` | `July 9 review feedback North Star` | #119, #71, closed #9 | #119 is the unique iteration-25 synthesis lane; #71 is a narrower transition defect. |
| DQ-002 | `VerdifyConsultancy/verdify-skills` | `four project root planner North Star` | #12 | #12 owns provider dispatch, not the portfolio North Star; retain #119. |
| DQ-003 | `VerdifyConsultancy/verdify-skills` | `installer exact packed artifact atomic` | #120 | Exact duplicate found; use #120 and the private advisory, create nothing else. |
| DQ-004 | `VerdifyConsultancy/verdify-skills` | `dev main release promotion branch` | #121 | Exact duplicate found; use #121. |
| DQ-005 | `VerdifyConsultancy/verdify-skills` | `capability dispatch worker Agent Platform` | #12, closed #23, closed #9 | Reopened and reframed #12; do not duplicate historical controller-overlap issues. |
| DQ-006 | `jvallery/agents` | `root planner co-equal pilot North Star` | #2890 | Exact result is the newly filed unique Agents North Star reconciliation. |
| DQ-007 | `jvallery/agents` | `capability discovery semantic dispatch worker MCP` | no lexical result | Required the alternate searches and direct #655/#2497 inspection below. |
| DQ-008 | `jvallery/agents` | `MCP API control contract planning agent` | #2337, #1815, #2497, #2336, closed related issues | #2497 owns worker/session dispatch; #2337 owns runtime-kind MCP parity; #2336 owns knowledge-vault integration. No new provider issue. |
| DQ-009 | `jvallery/agents` | `fixed worker task surface worktree` | #2497, #2709 | #2497 is the provider implementation tracker; #2709 remains the Gravity fan-out gate epic. |
| DQ-010 | `jvallery/agents` | `shared MCP skills surface runtime kinds` | #2337, #2288, #2336, closed #2302/#2342 | Reopened #2337 from current runtime evidence; no duplicate created. |
| DQ-011 | `jvallery/orbit` | `personal context fleet actuation trust domain` | #193 | Unique security boundary issue retained. |
| DQ-012 | `jvallery/orbit` | `private material source repo personal data` | #194 | Unique privacy migration issue retained. |
| DQ-013 | `jvallery/orbit` | `personal source data contract read audit` | #195, #188 | #195 is the implementation contract; #188 is broad backlog re-triage, not a duplicate. |
| DQ-014 | `jvallery/orbit` | `enterprise document connectors ACL tenant` | #196, #195 | #196 owns connector implementation; #195 owns shared governance. Keep both as dependency-linked scopes. |
| DQ-015 | `jvallery/orbit` | `Gravity MCP live endpoint` | #43, closed #78 | Retarget existing #43 to current Gravity; do not create a new Orbit/Gravity issue. |
| DQ-016 | `jvallery/orbit` | `OAuth routing grant lifecycle` | #116, #134, #138 | Update #116 for the current repo-pod broker; broader recovery epics are not duplicates. |
| DQ-017 | `VerdifyConsultancy/gravity` | `co-equal active pilot root planner North Star` | #406 | Unique Gravity North Star reconciliation retained. |
| DQ-018 | `VerdifyConsultancy/gravity` | `evidence span citations API MCP parity` | #407, #184 | #407 owns the concrete citation/parity defect; #184 remains the Gate B umbrella. |
| DQ-019 | `VerdifyConsultancy/gravity` | `Gate B API MCP integration evidence` | #184, #407 | Confirms the parent/child split; no transport-only duplicate created. |
| DQ-020 | `jvallery/orbit` | `root planner co-equal North Star` | no result before creation; #197 after creation | The search proved #193-#196 did not own the protected Orbit authority reframe; created #197 as the unique North Star reconciliation issue. |
| DQ-021 | `VerdifyConsultancy/verdify-skills` | `deprecated simplify remove capability` | #76, #119 | #76 owns durable simplification enforcement; #119 owns this review-feedback synthesis. Keep both. |
| DQ-022 | `VerdifyConsultancy/verdify-skills` | `one SDLC lifecycle workflow` | #116, #12 | #116 owns one-SDLC convergence; #12 owns provider capability dispatch. Keep both. |

## Direct Existing-Issue Reconciliation

| Repository | Existing issues | Current action |
| --- | --- | --- |
| Verdify Skills | #71-#76 | Added July 9 coherence, critic, evidence-minimum, merge-blocking validation, executable-eval, and deprecated-surface simplification evidence. |
| Verdify Skills | #72 / PR #123 | Closed and merged into `dev`; supplies immutable dispatch, v2 closeout/critic, current-head review, and cross-reviewer change-request enforcement. |
| Verdify Skills | #98 | Broadened Orbit to thin governed personal-assistant and chief-of-staff facades; prohibited raw source material in a repo-root vault. |
| Verdify Skills | #116 | Retained as the one-SDLC convergence owner; current optional adapters must delegate to the minimal supported lifecycle graph. |
| Verdify Skills | #117 | Recorded Jason-only North Star lock and separate Jason-or-James release approval. |
| Agent Platform | #655, #2497 | Retained as control-contract and supported dispatch owners; #2890 handles the protected North Star change. |
| Agent Platform | #2336 | Corrected Gravity ownership and rejected Git-backed raw personal/enterprise vault assumptions. |
| Agent Platform | #2337 | Reopened because live runtime-kind MCP operations remain degraded. |
| Agent Platform | #2889 | Updated with the current legacy sprint-transaction inventory; owns one-active-transaction designation plus validated terminal/archive migration. |
| Orbit | #43 | Retargeted from the legacy Gravity path to the current versioned HTTP/MCP consumer boundary. |
| Orbit | #116 | Retargeted OAuth acceptance to the current repo-pod broker and connector security requirements. |
| Orbit | #198 | Created after exact-head routing proved W27B plan/contract mismatch and missing wave authority; owns reconciliation or truthful terminalization. |
| Gravity | #184 | Kept as the Gate B integration umbrella and linked to #406/#407. |
| Gravity | #406 | Updated with current readiness/lifecycle transaction evidence; remains distinct from #407 cited API/MCP parity. |

## New-Issue Verdicts

| Issue | Verdict | Why it is not a duplicate |
| --- | --- | --- |
| Verdify Skills #119 | unique | Owns iteration-25 synthesis and review state, not implementation of one provider or validator defect. |
| Verdify Skills #120 | unique at creation; now canonical | Owns the complete exact-artifact publication/install transaction; sensitive detail stays private. |
| Verdify Skills #121 | unique at creation; now canonical | Owns protected `dev` integration and release-only `main` promotion. |
| Agents #2890 | unique | Owns the protected Agents North Star hierarchy change; #655/#2497 remain implementation contracts. |
| Orbit #193 | unique | Owns principal/trust-domain separation. |
| Orbit #194 | unique | Owns private-data storage and Git-history migration. |
| Orbit #195 | unique | Owns source governance and connector read-audit contract. |
| Orbit #196 | unique | Owns enterprise-document connector implementation and ACL preservation. |
| Orbit #197 | unique | Owns the protected Orbit North Star reframe and root-planner authority boundary; #193-#196 own security, privacy, source, and connector implementation. |
| Orbit #198 | unique | Owns the concrete W27B plan/contract/wave transaction mismatch; #193-#197 do not own exact dispatch reconciliation. |
| Gravity #406 | unique | Owns the protected Gravity North Star and authority reconciliation. |
| Gravity #407 | unique | Owns citation hydration and HTTP/MCP parity beneath existing Gate B #184. |

## Post-#72 Lock Refresh

- Verdify Skills #72 is closed by merged PR #123 at `dev` merge
  `c90801f97646238a3d7b3bfb064c799038d40c68`.
- Agents #2889, Orbit #198, and Gravity #406 contain the verified owning-repo
  lifecycle/readiness gaps discovered by the repaired fail-closed router.
- Agents #2890, Orbit #197, and Gravity #407 remain separate authority or cited
  interface scopes and are not duplicates of those transaction gaps.
- No new issue is required for the North Star decision: #119 now owns the
  explicit iteration-25 lock and reconstruction of PR #122.

## Limitations And Refresh Rule

- GitHub lexical search can miss semantically related issues, as DQ-007 shows;
  direct issue inspection and current repository/runtime audits remain required.
- Results are a live snapshot from the timestamp above and can drift after new
  issues, title edits, closures, or transfers.
- The Agents audit recorded #2337 as closed at its earlier snapshot. It was
  reopened at `2026-07-09T19:13:19Z` after live regression confirmation and is
  open in this packet; the two records describe different points in time.
- `state-of-union` must refresh the owning-repository searches before selecting
  implementation lanes; this packet proves the July 9 planning reconciliation,
  not permanent duplicate absence.
