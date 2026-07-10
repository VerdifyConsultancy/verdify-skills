# SDLC Skill Design

Status: `approved`
Iteration: `25`
Updated: `2026-07-09`

This locked iteration-25 artifact supersedes the iteration 21 fixed-kernel and
OpenClaw-specific design. Current product and architecture authority lives in
`NORTHSTAR_PRODUCT.md`, `NORTHSTAR_ARCHITECTURE.md`, and
`northstar-artifacts.yaml`.

## Ten Defaults This Design Must Preserve

1. Every July 9 review recommendation is the planning default unless new
   evidence and explicit authority approve an exception.
2. Pre-lock safety work stays narrow, while publication and installation use
   the exact tested artifact, trusted staging, integrity/conflict checks,
   atomic promotion, and recoverable rollback.
3. Verdify Skills remains proprietary and internal-first; a possible future
   open-source reference does not create a current community-growth goal.
4. No backwards compatibility is promised; atomic consumer convergence ends
   by removing deprecated capabilities, aliases, schemas, routes, and shims.
5. Verdify Skills, Agent Platform, Orbit, and Gravity are co-equal active
   pilots connected by the root planning outer loop and shared contracts while
   retaining their own backlogs, runtimes, deployments, and outcomes.
6. Jason records North Star lock; Jason or James may approve a Verdify Skills
   release; James publishes npm; independent PR review remains separate.
7. The restarted current Gravity repository and runtime are source truth; the
   prior instance is retired history.
8. Gravity exposes a versioned tenant-scoped read-only HTTP evidence API plus a
   consumer MCP adapter with equivalent authorization, resolvable citations,
   typed denials, durability, health, identity, and audit.
9. Orbit serves as both personal assistant and engineering chief of staff
   across authorized email, calendars, enterprise documents, transcripts,
   notes, conversations, meetings, and engineering context through governed
   connectors separated from fleet actuation.
10. Delivery moves as soon as safely possible with no artificial deadline,
    targets the first complete four-project self-building slice, files gaps in
    owning repositories, and then reuses the platform for customer consulting.

## Design Position

Verdify Skills should ship the smallest coherent, exercised graph that carries
the shared lifecycle across the four active pilots. There is no promised
17-skill kernel, no backward-compatibility window, and no rule that every
useful noun becomes a first-class skill. Retain a skill only when it has a
stable input/output contract, distinct ownership, deterministic routing,
executable evidence, and at least one real consumer. Otherwise merge it into a
clear owner, keep it as a mode or reference, or delete it after atomic consumer
convergence.

## Three Product Layers

| Layer | Purpose | Design rule |
| --- | --- | --- |
| Lifecycle method | Evidence intake, North Star, definition, architecture, hygiene/readiness, strategy, sprint, execution, criticism, integration, release, and outcome proof. | One canonical transition graph, durable artifacts, GitHub authority, fresh criticism, and deterministic validation. |
| Provider adapters | Negotiate Agent Platform runtime/control capabilities and Gravity evidence capabilities. | Versioned discovery, semantic requests, typed unsupported/degraded states, authorization, idempotency, audit, and evidence. No hard-coded retired worker operation. |
| Experience facades | Orbit personal-assistant/chief-of-staff workflows and optional OpenClaw, Hermes, Codex, or Claude conversational entry points. | Thin delegation only. No duplicate lifecycle, private source of truth, product identity, or implicit approval. |

## Required Consolidation Rules

1. Inventory every shipped skill, schema, route, transition, host link, example,
   and consumer before proposing a merge or deletion.
2. Prefer one owner for repeated artifact or transition logic. A facade may
   compose owners but must not reimplement their planning, gate, or evidence
   rules.
3. Delete deprecated modes, aliases, links, docs, schemas, fixtures, and routes
   in the same coordinated cutover. Compatibility is retained only by a new
   explicit product decision.
4. Validate graph membership, legal transitions, nonempty evidence, current
   head identity, independent critic state, transport-neutral handoffs,
   executable evals, exact package contents, managed-path ownership, and
   consumer conformance.
5. Add a first-class skill only after repeated use proves stable ownership and
   contracts. Until then, prefer a mode, reference, template, CLI operation, or
   backlog issue.

## Current Recommended Actions

| Action | Current owner | Tracking |
| --- | --- | --- |
| Negotiate supported Agent Platform capabilities and dispatch strategies. | `sprint-orchestrator` plus platform provider contract | Verdify Skills #12; Agents #2497 and #2890 |
| Enforce legal lifecycle transitions and route agreement. | CLI/router/controller validation | Verdify Skills #71 |
| Enforce fresh critic independence against the exact lane head. | Lane/critic contracts and validator | Completed by Verdify Skills #72 / PR #123 |
| Reject vacuous approval and evidence collections. | Schemas and semantic validator | Verdify Skills #73 |
| Make semantic validation and executable evals merge-blocking. | Package CI and eval runner | Verdify Skills #74 and #75 |
| Keep Orbit experiences thin over governed connector and lifecycle contracts. | Orbit facades plus existing lifecycle owners | Verdify Skills #98; Orbit #193-#198 |
| Separate North Star lock from release approval. | North Star and release policy contracts | Verdify Skills #117 and #121 |
| Publish and install the exact tested package through an atomic transaction. | Package/release/installer tooling | Verdify Skills #120 and private advisory |
| Define the common four-pilot status and capability record. | North Star, architecture contracts, controller loop | Verdify Skills #119; Agents #2890; Gravity #406 |
| Reconcile legacy sprint transactions before fail-closed dispatch. | Project controllers and owning backlogs | Agents #2889; Orbit #198 |
| Reconcile current Gravity readiness and lifecycle evidence. | Gravity owner and readiness controller | Gravity #406; cited API/MCP parity remains #407 |

## Runtime Adapter Position

The earlier OpenClaw-specific workflow design is retained as historical
evidence in `OPENCLAW_SDLC_WORKFLOW_SKILLS.md`. Its reusable pattern is a small
facade that delegates to the canonical lifecycle and authoritative records.
OpenClaw and Hermes may be useful Orbit runtime adapters, just as Codex and
Claude may be useful task workers, but none is a mandatory product layer or a
separate authority.

## Completion Criteria For The Next Skill-Graph Decision

- Current consumers and routes are inventoried across all four pilots.
- Every retained capability has a named owner, contract, evidence, and real
  consumer.
- Proposed merges and removals include atomic cutover, verification, rollback,
  and deletion proof.
- The exact packed artifact passes source, archive, install, upgrade,
  collision, rollback, and consumer-conformance checks.
- A fresh critic confirms the new graph is smaller without losing required
  lifecycle or cross-pilot behavior.
- Iteration 25 records Jason's North Star lock; Jason or James may separately
  approve a release under the applicable independent-review policy.
