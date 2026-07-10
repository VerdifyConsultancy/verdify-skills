# State of Union: Four-Project Autonomous Development Platform

Assessed at `dev@314516e1ba110fa981a235b21f09750bcbc42500` on
2026-07-10. Canonical strategy:
`.agent-workflow/strategy/state-of-union.yaml`.

## Verdict

The North Star is coherent and the component foundations are real, but the
integrated platform is not ready for unattended operation.

- Verdify Skills has the strongest control surface: approved iteration-25
  product/architecture, 28 validating skills, 48 schemas, independent review,
  protected delivery, and a proven exact-artifact 1.3.0 release.
- Agent Platform supplies persistent repo cells, fixed agent sessions, GitOps,
  APIs, MCP, telemetry, and healthy target volumes, but security P0s, storage and
  Argo drift, invalid lifecycle records, provider-contract mismatch, and failed
  loops block fan-out.
- Gravity is a deployed, data-rich alpha with live retrieval and a substantial
  corpus, but its current North Star is unsigned, readiness is absent, citations
  are not hydrated, callable MCP is unproved, conversion is failed, and CI is
  broken.
- Orbit has useful mission, dispatch, ledger, and tick primitives on a Ready
  repo cell, but it is not a trusted Chief of Staff: its lifecycle points at
  retired infrastructure, loop recovery is unproved, CI/protection is absent,
  connector trust is unresolved, and Gravity integration is stale.

The overall maturity is therefore **architecture-approved, component-deployed,
integration-unproved**. Hands-off execution should remain limited to low-risk,
reversible work until the control floor and first four-project slice pass.

## What Is Working

1. GitHub and `.agent-workflow` already provide the right durable authority
   model; the system does not need a new private task database.
2. The root-planner, four-pilot, provider, context, and evidence responsibility
   split is already locked in Verdify iteration 25.
3. One-issue/lane/branch/worktree/session/PR isolation, fresh criticism, exact
   head checks, release provenance, and runtime verification are working in
   Verdify delivery.
4. Agent Platform runs 38/38 persistent repo cells and 136/136 agent containers
   Ready, with live API, MCP, GitOps, and loop primitives.
5. Gravity has a real deployed data plane and corpus rather than a design-only
   knowledge service.
6. Orbit has early durable mission and reporting primitives and its retired
   standalone OpenClaw deployment is gone.
7. The important gaps are already mostly represented by owning GitHub Issues.

## Blocking Gaps

| Priority | Gap | Owning work |
| --- | --- | --- |
| P0 | Four completed Verdify transactions still block global routing | Verdify #135 |
| P0 | Route and approval transitions can trust invalid or empty evidence | Verdify #71, #73 |
| P0 | Agent behavior and semantic correctness are not executable, merge-blocking evals | Verdify #75, #74 |
| P0 | Verdify requires a dispatch operation Agent Platform intentionally rejects | Verdify #12, Agents #2497/#655 |
| P0 | Agent Platform has unresolved request-desync and tracked-secret candidates | Agents #2884, #2887 |
| P0 | Root-loop health, replay, signals, and recovery substrate are unproved | Agents #2840, #2905 |
| P0 | Gravity does not yet return release-verified citations over HTTP/MCP | Gravity #184, #407 |
| P0 | Orbit context and fleet actuation share trust and stale lifecycle boundaries | Orbit #193-#198, Verdify #117 |
| P1 | Shared bounded-loop contract and risk fast path are incomplete | Verdify #43, #70 |
| P1 | One correlated portfolio trace and acceptance suite do not exist | Verdify #116 plus four owning projects |

## Execution Sequence

1. **Restore truthful routing:** execute one narrow issue #135 sprint and make
   terminalization automatic or merge-blocking.
2. **Build the trusted decision floor:** #71 -> #73 -> #75 -> #74.
3. **Codify bounded autonomy:** #43 and #70 define objective, permissions,
   budget, observation, repair, intervention, stop, provenance, and change class.
4. **Reconcile the provider:** close Agent Platform security/authority gates,
   decide #2905, and resolve #12/#116 through versioned capability negotiation.
5. **Make evidence and context trustworthy:** Gravity #184/#407 and Orbit
   #193-#198/#43, followed by Verdify #117/#98 thin facades.
6. **Prove one vertical slice:** cited Gravity evidence -> source-linked Orbit
   brief -> root-planner issue choice -> Agent Platform worker -> Verdify critic
   and CI -> deployed verification -> accepted outcome -> next-loop learning.
7. **Scale only after proof:** seven unattended days plus crash, missed-tick,
   auth-expiry, quota, stale-marker, duplicate-wake, push-conflict, and pod-restart
   drills, then canary fleet/customer rollout.

## Next Sprint Candidate

Issue #135 is ready as a single-issue transaction. It is evidence-complete,
narrow, and blocks deterministic lifecycle entry. Issues #71/#73 follow after
its route proof. The full one-SDLC slice remains correctly blocked on explicit
Agent Platform, Gravity, and Orbit prerequisites.

## Open Gates

- Agent Platform P0 security containment and four-pilot re-lock.
- Agent Platform durable-execution architecture decision and readiness approval.
- Gravity iteration-6 signoff, Gate B, citation parity, and canonical readiness.
- Orbit four-pilot reframe, stale sprint supersession, and trust-domain split.
- Integrated pilot acceptance from one correlated end-to-end trace and failure
  drill suite.

## Handoff

After this strategy is reviewed and merged, route to `sprint-planning` in
`lane-transaction` mode for issue #135. Detailed operating guidance is in
[`docs/northstar/autonomous-development-platform-plan-2026-07-10.md`](../../docs/northstar/autonomous-development-platform-plan-2026-07-10.md).
