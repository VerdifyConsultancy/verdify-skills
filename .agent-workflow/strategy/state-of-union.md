# State of Union: Post-73 Autonomous Platform Program

Canonical authority: `.agent-workflow/strategy/state-of-union.yaml`
Assessed at protected `dev@ad2d39926a37a89875ce6b062614d21b6862047b`
on 2026-07-12.

## Verdict

Issues #135, #215, #71, and #73 are complete with canonical terminal receipts.
Issue #73 shipped exact non-vacuous critic and closeout evidence: PR #230
merged with all five required checks green at the exact fresh-critic head —
the first lane to pass the full policy chain legitimately — and receipt PR
#231 terminalized the sprint. The planning-only policy gap and the
code-owner-review exception remain issue #70 evidence, not precedent.

Jason approved the 2026-07 SOTA benchmark keep/kill/simplify direction on
2026-07-12 (evidence `NSE-20260712-sota-benchmark-2026-07-verdify-skills-vs`;
recorded on issues #211, #70, #76, #12, and #43) and directed autonomous
execution of the backlog through validation, packaging, and release readiness.
Fresh independent criticism remains mandatory for implementation output;
deterministic planning, receipt, routing, and merge transitions consume
existing authority and evidence instead of manufacturing more approvals.

The four-project vertical slice remains prohibited. Agents #2884, #2887, and
#2906 are all still open P0 Stage 0 security stops.

## Immediate Route

Issue #70 is the sole ready next sprint candidate: evidence-proportionate
change classes (lightweight = issue + diff + critic finding, ~3 artifacts, one
PR), a planning-only class, typed no-op promotion, typed merge authority, a
protected-path override, and the weekly human sampling sweep. The validated
draft sprint transaction is staged.

Structured lifecycle phase ownership remains recorded separately on #225; the
issue-73 residual risks (denylist-evasion tripwire, evidence-content
non-resolution) are owned by #70 and #225.

## Issue Sequence (re-approved 2026-07-12)

1. **Trusted evidence floor (DONE 2026-07-12):** Verdify #73 terminal; #225
   remains the nonblocking schema follow-up.
2. **Proportional process and simplification:** Verdify #70 (change classes:
   lightweight = issue + diff + critic finding, ~3 artifacts, one PR; risk
   from findings/paths, never line count; protected paths always full-chain;
   planning-only class; weekly human sampling sweep), #43 (loop contract
   replaced by four guardrails: budget caps, max-iterations, watchdog,
   markdown resume note), and #76 pulled forward and expanded (kill list:
   consensus/adversarial-audit machinery, controller-loop and
   sprint-orchestrator prose machines, bespoke release ledger, crm-email,
   timeline-historian; consolidation: skills 28→~12–15, schemas 49→~10–12,
   artifacts per lane →3–4, receipt/strategy PRs folded into the lane PR).
3. **Merge-blocking evaluation floor for the slimmed core:** Verdify #75, #74.
4. **Agent Platform security and authority:** Agents #2884, #2887, #2906,
   #2890, #2905.
5. **Platform-native dispatch (re-scoped #12):** GitHub-native Claude/Codex
   workers as the default adapter; Verdify keeps dispatch commits, contracts,
   the critic gate, and protected-base policy; Verdify #116 and Agents
   #2497/#655 for what remains.
6. **Gravity citation/API/MCP readiness:** Gravity #407, then #184 acceptance.
7. **Orbit trust and lifecycle repair:** Orbit #197, #193-#196, #198, then #43.
8. **One correlated transaction, then durability drills** — only after every
   Stage 0 stop is closed with live proof.

## Process Balance

The target operating model is evidence-proportionate:

- one issue/lane/worktree/session/PR for implementation;
- one fresh critic for implementation output, not repeated critics for the same
  exact artifact;
- required CI and exact-head evidence before integration;
- deterministic receipt, routing, and merge actions advance automatically when
  their declared evidence is valid;
- human decisions are reserved for protected product/architecture authority,
  irreversible or credential-sensitive operations, and unresolved high-impact
  tradeoffs;
- runtime-changing work still requires proof from the runtime, separately from
  merge success.

Issues #70, #43, and #76 own codifying change classes, the four loop
guardrails, and the slimmed surface in the skills package. The strategy does
not silently weaken review, evidence, or security requirements.

## Current Risks

| Risk | Durable owner |
| --- | --- |
| Critic evidence exactness shipped; residual tripwire/allowlist follow-up | Verdify #70/#225 |
| Acceptance criteria do not declare lifecycle phase ownership | Verdify #225 |
| Planning-only PRs still require recorded admin exceptions | Verdify #70 |
| Unexercised skill/schema surface keeps accruing maintenance and doc drift | Verdify #76 |
| Eval packs lack a deterministic runner contract | Verdify #75 |
| Consumer CI cannot enforce an undefined runner | Verdify #74 |
| No-promotion dev pushes are red and receipt auto-merge is undeclared | Verdify #70 |
| PRs #221/#222 bypassed evidence sequencing and PR #223 used a non-author-review exception | Verdify #70 |
| Stage 0 request, archive-secret, and probe-destination security stops | Agents #2884/#2887/#2906 |
| Provider ownership beyond platform-native dispatch | Verdify #12/#116; Agents #2497/#655 |
| Citation, trust, lifecycle, and correlated runtime proof are missing | Gravity #184/#407; Orbit #193-#198/#43 |

## Handoff

After this planning-only refresh merges to protected `dev`, run
`project-router`. The expected handoff is `sprint-planning` in
`lane-transaction` mode for Verdify #70. No broad fan-out is authorized.
