# Lifecycle and handoffs

Verdify exposes nine skills but preserves the detailed lifecycle as explicit modes. A skill may advance through its own modes without reactivation, provided each mode's artifacts and gates are satisfied.

## 1. Project router

Inspects Git, GitHub state or snapshot, and `.agent-workflow` artifacts. It writes a route decision and names exactly one next skill/mode. It does not manufacture missing project facts.

## 2. Project definition

Four ordered modes share one canonical `project-definition.yaml`:

1. **Discovery** inventories supplied sources, known decisions, assumptions, contradictions, and evidence-based questions.
2. **Requirements** defines functional and non-functional requirements, constraints, acceptance criteria, and traceability.
3. **Product** defines users, jobs, scope, non-goals, workflows, value, success metrics, and product risks.
4. **Design surface** defines UI, CLI, API, tool, agent, and human-approval surfaces, states, and error behavior.

Material ambiguity opens a decision gate rather than becoming an invented requirement.

## 3. Architecture and contracts

The architecture mode defines system boundaries, topology, data flow, storage, integrations, security, deployment, observability, and ADRs. The module-contract mode converts that architecture into black boxes with stable inputs, outputs, public interfaces, owned paths, invariants, dependencies, tests, and completion evidence.

## 4. State of union

Reviews approved project definition, lifecycle readiness, architecture, module contracts, GitHub Issues, pull requests, gates, sprint history, and deployment state. It reconciles the backlog against the north-star goal, records stale/missing/blocked work, proposes issue and gate actions, recommends execution sequencing, and names one next lifecycle handoff. It does not create lane contracts or replace GitHub Issues with a private task list.

## 5. Sprint planning transaction

Planning begins from GitHub Issues, not a private task list. It selects a bounded outcome, records exclusions and risk, then atomically creates the lane topology and lane contracts. The default mapping is one issue to one lane. Human or policy approval applies to the complete transaction; worktrees are not created before approval.

## 6. Sprint orchestration

The orchestrator checks prerequisites, snapshots/reconciles GitHub, dispatches dependency-ready lanes, monitors events, resolves gates, and routes results. It does not implement lane code or review its own output.

## 7. Lane delivery

A worker acquires one worktree lease, implements only the contract, runs validation, pushes a branch, opens or updates the linked PR, and performs closeout in the same bounded session. Discoveries become issues. Material contract problems stop the lane.

## 8. Independent criticism

A fresh critic uses a separate detached worktree or clean clone. It compares requirements, issue, module contract, lane contract, diff, tests, CI, and evidence. It approves, approves with risks, requests fixes, blocks, or escalates. It does not silently repair the worker branch.

## 9. Release verification

A fresh integration role combines approved lanes in dependency order, runs whole-system validation, and uses required checks or a merge queue. A separately authorized deployment role proves the expected commit/image/configuration in the target environment. Outcome review records human acceptance, remaining risk, follow-up issues, and lessons learned.

The cycle returns to `project-router`.

## Gates

A gate is durable, typed, and includes owner, evidence required, allowed decisions, and resume state. Chat approval alone is insufficient for production, security, destructive operations, or policy exceptions.
