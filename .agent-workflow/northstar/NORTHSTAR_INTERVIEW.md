# North Star Interview

Status: `final_lock_recorded`
Generated at: `2026-07-09T23:28:41Z`
Routed mode: `northstar-planning / signoff`
Evidence registry: `.agent-workflow/northstar/evidence-registry.yaml`
Product pair: `.agent-workflow/northstar/NORTHSTAR_PRODUCT.md`
Architecture pair: `.agent-workflow/northstar/NORTHSTAR_ARCHITECTURE.md`
Loop record: `.agent-workflow/northstar/northstar-artifacts.yaml`

## Review Summary

Jason answered every material July 9 interview question, adopted every
adversarial-review recommendation as the planning default, and then explicitly
directed the controller to fix #72 and lock iteration 25. The earlier answer
packet remains registered as
`northstar://evidence/NSE-20260709-jason-review-feedback`; it is historically
correct that those ten answers alone were not the lock. The later, separate
signoff is registered as
`northstar://evidence/NSE-20260709-jason-iteration-25-final-lock-approval`.

PR #123 integrated the exact-head review substrate into `dev` before this lock
transaction began. There are zero P0 or otherwise blocking human questions for
iteration 25.

## Resolved Decisions

| Decision ID | Resolution | Planning effect | Evidence |
| --- | --- | --- | --- |
| NQI-D001 | Adopt every July 9 recommendation as the planning default. | Iteration 25 is the authority baseline rather than an optional proposal set. | `NSE-20260709-jason-review-feedback` |
| NQI-D002 | Keep pre-lock safety work narrow, while requiring trusted installation and atomic publication. | Publication uses protected-base validation, exact packed bytes, atomic promotion, and rollback; unrelated features do not hide inside the safety lane. | July 9 feedback and adversarial review |
| NQI-D003 | Verdify Skills is internal-first; public reference use is possible, but community growth is not a current objective. | Preserve the internal/proprietary posture for this milestone without creating a public compatibility promise. | `NSE-20260709-jason-review-feedback` |
| NQI-D004 | No backwards compatibility is required; remove deprecated capability. | Consumer convergence ends in deletion, not indefinite aliases, facades, or dual schemas. | `NSE-20260709-jason-review-feedback` |
| NQI-D005 | Verdify Skills, Agent Platform, Orbit, and Gravity are one integrated set of active pilots. | The root planner coordinates a four-project `PilotProject` portfolio while every project retains its own authority. | all `NSE-20260709-*` project evidence |
| NQI-D006 | Jason or James may approve Verdify Skills releases; James publishes npm. | Release authority remains distinct from Jason-only North Star lock authority and from PR critic evidence. | `NSE-20260709-jason-review-feedback` |
| NQI-D007 | The restarted current Gravity repository is active source truth. | Readiness gates trusted consumption and promotion; the prior instance is retired history. | Jason feedback and Gravity audit |
| NQI-D008 | Gravity exposes a versioned tenant-scoped read-only HTTP API with a consumer-side MCP adapter. | Cited API/MCP parity, identity, typed denials, durability, health, and audit form the evidence boundary. | Jason feedback and Gravity audit |
| NQI-D009 | Orbit is both personal assistant and engineering chief of staff across authorized personal, enterprise, meeting, conversation, and project context. | Broad information scope is core intent, bounded by separate trust domains, minimum connector scopes, ACL/provenance/freshness, retention, read audit, and human-gated writes. | Jason feedback and Orbit audit |
| NQI-D010 | Move as soon as safely possible, prove self-building progress, and reuse the platform for customer consulting. | Optimize for the first complete four-project vertical slice; record every verified gap in its owning repository. | `NSE-20260709-jason-review-feedback` |
| NQI-D011 | Fix #72, then lock iteration 25 and update the interview packet. | #72/PR #123 is integrated; iteration 25 is now approved and hands off to project definition. | `NSE-20260709-jason-iteration-25-final-lock-approval` |

## Accepted Foundations

- Deterministic durable controller state remains authoritative over chat.
- One issue, lane, branch, worktree, worker session, and PR remains the default
  execution unit; a wave is the integration, deployment, review, and outcome
  unit.
- Risk-based human review continues for protected product/architecture,
  security, privacy, identity, production, destructive, public-interface,
  material-cost, and exception decisions.
- Review-ready requires immutable identity, current-head checks, CI/test proof,
  deployment evidence when applicable, telemetry, risks, rollback, and a fresh
  critic.
- Agent Platform dispatch negotiates versioned capabilities and supported
  worker strategies; runtime adapters are not product identities or authority.
- Chief-of-staff experiences remain thin facades over governed lifecycle and
  connector contracts.

## Remaining Nonblocking Owner Work

These are not questions Jason must answer before lock. Each retains a proposed
default and named owner for project-definition, architecture, security, or
platform readiness.

| Item | Owner / route | Locked default |
| --- | --- | --- |
| NSQ-009 learning sources, retention, and redaction | Skills maintainer and security owner | Use explicit research/validation/review evidence plus redacted session summaries; proposal-only output; no scheduled loop without readiness proof. |
| NSQ-010 namespace naming | Platform and security owner | Use collision-safe owner/repository identity with environment suffixes and validate against Kubernetes and Agent Platform conventions. |
| NSQ-011 controller model selection | Platform architecture owner | Keep the controller model-neutral and select Codex, Claude, or successors per supported capability and failure mode. |
| NSQ-012 broader infrastructure-domain authority | Jason, platform owner, and security owner | Grant only named domain agents explicit scoped authority with audit, approval, and rollback; repo agents stay namespace-scoped by default. |
| NSQ-013 mounts, DNS/routes, and base-image requests | Platform, storage, and networking owners | Use typed platform control requests or PR-reviewed desired state; owning operators approve before mutation. |
| Orbit sprint-transaction reconciliation | Orbit #198 | Reconcile or terminalize W27B before exact-head dispatch; retain #193-#197 for distinct connector, trust, and North Star work. |
| Agent Platform legacy sprint reconciliation | Agents #2889 | Designate one active transaction and archive or validate legacy plans before fail-closed routing. |
| Gravity lifecycle/readiness reconciliation | Gravity #406 | Reconcile current active source, readiness, and exact transaction evidence while #407 retains cited API/MCP parity scope. |

## Remaining Questions For Jason

None for iteration-25 lock.

Future material changes start a new evidence iteration. The five deferred
questions above may be answered by their named owners under the locked defaults
without reopening this North Star unless their answer changes product intent,
architecture safety, or human authority.

## Answer Capture Rules

- The final lock lives in `northstar-artifacts.yaml`, `northstar-plan.yaml`, and
  `.agent-workflow/gates/northstar.yaml`, backed by the separate final-lock
  evidence item.
- Canonical product and architecture resolutions live in the approved paired
  markdown artifacts; implementation remains in GitHub Issues and one-lane PRs.
- Learning proposals remain staged until their configured approval path applies
  them.
- A future contradiction or material decision routes through evidence intake
  and `northstar-planning / review-feedback` as a new iteration; it does not
  silently mutate iteration 25.
