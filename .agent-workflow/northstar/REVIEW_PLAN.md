# North Star Review And Signoff Plan

Status: `approved`
Iteration: `25`
Prepared: `2026-07-09`
Lock recorded: `2026-07-09T23:20:09Z`
Final lock authority: Jason
PR and release approver: James (`jrvallery`) or another authorized independent repository admin/maintainer under the applicable policy

## Decision

Jason approved every July 9 recommendation and ten-answer resolution as the
planning default, then separately directed the controller to fix #72 and lock
iteration 25. The final-lock decision is registered as
`northstar://evidence/NSE-20260709-jason-iteration-25-final-lock-approval`.
It does not overwrite the earlier feedback item, which correctly records that
the ten answers alone were not yet the final lock.

Iteration 25 is the approved product and architecture North Star for one
self-building system composed of four co-equal active pilot projects:

1. Verdify Skills — internal-first shared agent method, lifecycle contracts,
   validators, planning outer loop, and capability adapters.
2. Agent Platform — shared runtime/control, worker/session, Kubernetes/GitOps,
   CI, observability, and identity capabilities.
3. Orbit — Jason's personal assistant and engineering chief of staff across
   governed personal, enterprise, meeting, conversation, and project context.
4. Gravity — active evidence ingestion, retrieval, citation, processing, and
   versioned read-only HTTP/API plus consumer MCP capability.

Each project retains product, backlog, runtime, deployment, and outcome
authority. The root planner reconciles portfolio vision, dependencies, gates,
and next actions without replacing those project authorities.

## Evidence In Scope

- `northstar://evidence/NSE-20260709-jason-iteration-25-final-lock-approval`
- `northstar://evidence/NSE-20260709-jason-review-feedback`
- `northstar://evidence/NSE-20260709-verdify-skills-adversarial-review`
- `northstar://evidence/NSE-20260709-agents-current-state-audit`
- `northstar://evidence/NSE-20260709-orbit-current-state-audit`
- `northstar://evidence/NSE-20260709-gravity-current-state-audit`
- Prior registered North Star evidence and accepted ADRs where they do not
  conflict with the July 9 decisions.

## Content Signoff Checks

- [x] Every July 9 recommendation is represented as a planning default.
- [x] The exact ten human answers are represented, including the separate
  adoption decision and the later final-lock decision.
- [x] The old single non-Gravity pilot and Orbit-as-global-outer-loop model is
  replaced by the four-project `PilotProject` model and root planner.
- [x] Internal-first distribution and no-backwards-compatibility policy are
  explicit; deprecated capability ends in atomic convergence and removal.
- [x] Trusted installation, exact packed-artifact publication, validated
  transitions, executable evals, consumer conformance, protected `dev`, and
  release-only `main` remain critical-path safety prerequisites.
- [x] Agent Platform dispatch negotiates supported versioned capabilities.
- [x] Current Gravity is active source truth; the trusted consumer contract is
  versioned tenant-scoped read-only HTTP plus a consumer MCP adapter with cited
  results or typed denials.
- [x] Orbit broad information scope is core intent and remains separated from
  fleet actuation through source, tenant, ACL, provenance, freshness,
  classification, retention, audit, revocation, and human-write controls.
- [x] Jason-only North Star lock is distinct from package/PR approval under the
  repository's independent-review policy.
- [x] The next outcome is one integrated four-project vertical slice that
  improves the platform itself and can later onboard customer consulting work
  without creating a second lifecycle.
- [x] Learning proposals remain staged; no proposal is silently implemented.
- [x] There are no P0 or other blocking human questions for this lock.

## Issue And Security Reconciliation

- Verdify Skills: #12, #71-#76, #98, #116, #117, #119-#121; #72 is closed by
  merged PR #123 and supplies the v2 exact-head evidence substrate.
- Private installer vulnerability: draft advisory `GHSA-4452-3c6p-3q26`;
  public planning retains safe acceptance criteria only.
- Agent Platform: #2889 owns legacy sprint-transaction reconciliation; #2890
  retains the co-equal pilot/root-planner authority change; other capability,
  runtime, health, CI, security, and version issues remain project-owned.
- Orbit: #198 owns W27B transaction reconciliation; #193-#197 retain distinct
  connector, trust, private-material, data-contract, and North Star work.
- Gravity: #406 owns current authority/readiness reconciliation; #407 retains
  cited API/MCP parity; #184 and other CI/GitOps/conversion issues remain
  project-owned.

## Deferred, Nonblocking Owner Work

NSQ-009 through NSQ-013 retain proposed defaults and named Skills, platform,
security, storage, and networking owners. They must be resolved before their
affected recurring loop, fleet bootstrap, broad infrastructure authority, or
platform mutation path is activated. They do not block this North Star lock or
project-definition discovery.

## Delivery Proof Still Required For PR #122

The human North Star decision is recorded, while repository integration still
requires the independent delivery chain:

1. immutable dispatch `D` from the post-#123 `dev` baseline;
2. one substantive implementation head `I` containing the complete lock;
3. closeout-only `E` under LaneCloseout v2;
4. fresh critic-report-only `S` under CriticReport v2;
5. current checks and an independent admin/maintainer GitHub approval on `S`;
6. integration into `dev` and a fresh downstream route probe.

No runtime deployment or package publication belongs to this planning lane.

## Handoff

After the PR delivery proof integrates, route exactly to
`project-definition / discovery`. Material future feedback starts a new North
Star evidence iteration; it does not reopen or silently mutate iteration 25.
