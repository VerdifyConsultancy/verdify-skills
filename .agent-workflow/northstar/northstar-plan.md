# North Star Plan

Status: `approved`
Iteration: `25`
Updated: `2026-07-09`
Lock evidence: `northstar://evidence/NSE-20260709-jason-iteration-25-final-lock-approval`

This is the human-readable summary of the locked planning loop. The canonical
structured record is `northstar-plan.yaml`; product, architecture, review, and
signoff state live in `NORTHSTAR_PRODUCT.md`, `NORTHSTAR_ARCHITECTURE.md`,
`REVIEW_PLAN.md`, and `northstar-artifacts.yaml`.

## Outcome

Verdify Skills is the internal-first shared agent and method layer that binds
four co-equal active pilots—Verdify Skills, Agent Platform, Orbit, and
Gravity—into one self-building platform. The root planning agent owns the
portfolio outer loop for shared vision, priority, dependencies, gates,
evidence, and handoffs. Each pilot retains its own product intent, GitHub
backlog, runtime, deployment, and outcome acceptance. Once the internal
four-project loop is proven, customer consulting repositories enter through
the same governed lifecycle and `PilotProject` contracts without inheriting
internal authority or Jason-private Orbit context.

Iteration 25 is approved. It incorporates the July 9 adversarial review,
Jason's ten answers, current Agent Platform/Orbit/Gravity evidence, and the
separate instruction to fix #72 and lock. PR #123 integrated the exact-head
review substrate before this lock transaction began.

## Ten Approved Planning Defaults

1. **Adopt the complete review.** Every July 9 recommendation is the planning
   default used to move forward; exceptions require new evidence and explicit
   authority.
2. **Keep safety narrow but real.** Minimize pre-lock overhead, while package
   publication and installation require protected-base validation, the exact
   tested artifact, trusted private staging, integrity/conflict checks, atomic
   promotion, and recoverable rollback.
3. **Remain internal-first.** Verdify Skills is primarily proprietary/internal.
   Public source or reference use may occur later, but building an open
   community is not a current product objective.
4. **Carry no compatibility obligation.** Remove deprecated or redundant
   capability after atomic consumer convergence; do not retain indefinite
   aliases, facades, dual schemas, or retired paths.
5. **Treat all four projects as the pilot.** Verdify Skills, Agent Platform,
   Orbit, and Gravity are active co-equal projects that must operate as one
   system. Verdify Skills supplies the shared planning/method layer and root
   outer-loop contracts while project-local authority remains intact.
6. **Separate human authority classes.** Jason records North Star locks. Jason
   or James may approve Verdify Skills releases, James publishes npm, and PR
   delivery still requires the applicable independent current-head review.
7. **Use current Gravity truth.** The restarted current Gravity repository is
   authoritative; the prior instance is retired history. Readiness gates
   trusted cross-project consumption and promotion, not whether Gravity is an
   active project.
8. **Use versioned API plus MCP.** Gravity's first shared consumer boundary is
   a versioned tenant-scoped read-only HTTP evidence API with a consumer-side
   MCP adapter, resolvable citations, typed denials, equivalent authorization,
   durability, health, identity, and audit.
9. **Make Orbit both assistant and chief of staff.** Orbit governs authorized
   email, calendars, enterprise documents, transcripts, notes, conversations,
   meetings, and engineering context. GOG, OpenClaw, Hermes, or successors are
   connector/runtime choices beneath separate trust domains, minimum scopes,
   ACL/provenance/freshness, classification, retention, audit, revocation, and
   human-gated write controls.
10. **Move as soon as safely possible.** There is no artificial deadline. The
    critical path is the first complete four-project vertical slice that lets
    the platform build its next increment, then supports customer consulting
    through the same governed method. Verified gaps belong in their owning
    repositories.

## Operating Foundations

- GitHub Issues are backlog truth and GitHub is the delivery control plane.
- `.agent-workflow` holds durable approved definitions, contracts, evidence,
  gates, and handoffs; chat is not authority.
- One issue, lane, branch, worktree, worker session, and PR is the default
  implementation unit. A wave coordinates integration, deployment, review,
  and outcome rather than creating a shared coding branch.
- Agent Platform operations use versioned capability discovery and supported
  adapters; model or runtime brands are not product identity or authority.
- Fresh criticism, current-head checks, external review, runtime proof when
  applicable, and rollback evidence remain separate gates.

## Delivery Sequence

1. **Trust foundation.** Complete installer/release trust, lifecycle and critic
   enforcement, executable evals, provider capabilities, and consumer
   convergence. #72/PR #123 completed the exact-head substrate.
2. **Four-pilot contract.** Define `PilotProject`, capability, dependency,
   lifecycle, evidence, readiness, and outcome contracts across the four
   project-owned North Stars and backlogs.
3. **Safe integration boundaries.** Establish supported Agent Platform
   dispatch, Orbit connector governance, and Gravity cited HTTP/MCP parity.
4. **Integrated vertical slice.** Deliver one small platform improvement
   through root planning, Verdify lifecycle, Agent Platform execution, fresh
   criticism, CI/CD/runtime proof, Gravity evidence, Orbit reporting, and
   project-owner outcome acceptance.
5. **Compounding loop.** Capture verified lessons as proposals and apply only
   those accepted through their configured authority.
6. **Customer consulting reuse.** Onboard customer repositories through the
   proven bootstrap, `PilotProject`, capability, evidence, delivery, review,
   deployment, and outcome contracts with customer-scoped trust.

## GitHub Reconciliation

- Verdify Skills: #12, #71, #73-#76, #98, #116, #117, #119-#121; #72 is
  closed by merged PR #123.
- Agent Platform: #2889 owns sprint-transaction reconciliation; #2890 owns the
  co-equal pilot/root-planner authority change; other provider issues remain
  project-owned.
- Orbit: #198 owns W27B transaction reconciliation; #193-#197 retain distinct
  connector, trust, data-contract, and North Star work.
- Gravity: #406 owns current authority/readiness reconciliation; #407 owns
  cited API/MCP parity; #184 and other delivery work remain project-owned.
- Sensitive installer detail remains in private advisory
  `GHSA-4452-3c6p-3q26`; public artifacts contain safe acceptance intent only.

## Questions And Learning

There are no P0 or other blocking human questions for iteration 25. NSQ-009
through NSQ-013 are deferred, nonblocking owner work under the defaults above.
The July 9 learning packet remains `staged`; its NLP proposals are not applied
by this lock.

## Handoff

Next route: `project-definition / discovery`.

Project definition should turn the locked product and architecture intent into
end-to-end users, requirements, lifecycle coverage, interfaces, operations,
relationships, and human approval points. Platform, connector, publication,
and readiness gates continue to block only their affected implementation or
promotion action.
