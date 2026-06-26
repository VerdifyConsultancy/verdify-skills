---
name: controller-loop
description: Specifies or operates the long-lived Verdify outer loop that persists lifecycle state, wave state, child sessions, gates, status events, and handoffs independently of model conversation history. Use when a project needs resumable orchestration across planning, research, hygiene, sprint execution, review, fixes, replanning, deployment, and human sign-off.
compatibility: Requires approved lifecycle prerequisites, repository artifacts, access to session/runtime records, and Agent Platform API or MCP details when child sessions are actually launched.
metadata:
  author: Verdify
  version: "1.0.0"
  lifecycle-order: "6a"
---

# Controller Loop

Own durable orchestration state. Do not implement lane code, review your own
work, or bypass human gates.

## Reconciler model

The controller is a **deterministic reconciler over a durable event log**, not a
model that holds state in conversation (ADR-0012). Lane workers are proposers:
they emit normalized events (`candidate_done`, `blocked`, `scope_change_requested`,
`human_decision_required`, `retry_recommended`); the controller validates each
event against current state and policy, applies an idempotent transition,
schedules newly-ready tasks, enforces retry/cost/risk/time budgets, and persists
the decision with evidence. A worker never moves authoritative state to `done`.

A **wave** is a versioned delivery envelope, not a loop: it advances through one
state machine (`Observe -> DraftWave -> Approve -> Execute -> Verify -> Integrate
-> DeployPreview -> Review -> Accept`, with `Replan` and `Escalate` as explicit
transitions; ADR-0011). Periodic polling exists only to detect lost workers
(expired leases, missing heartbeats, undelivered CI events, GitHub/controller
drift) — never to infer progress from terminal text.

Sources of truth: Git owns approved intent; GitHub owns backlog/delivery; the
runtime state store owns execution state (claims, leases, attempts, events,
costs); CI and policy are gate authority. The state-machine, event store, and
scheduler **runtime** are Agent Platform responsibilities (`jvallery/agents`
loop-runtime/loop-state); this skill owns the contracts and gate semantics
(ADR-0018).

Read `references/delivery-loop-model.md` for the full loop topology, decision
rights, and glossary.

## Canonical artifacts

- `.agent-workflow/controller/controller-state.yaml` - durable controller state
- `.agent-workflow/controller/session-ledger.yaml` - append-oriented session map
- `.agent-workflow/controller/waves/<wave-id>.yaml` - wave state when used

Validate controller state against `../../schemas/controller-state.schema.yaml`
and the session ledger against `../../schemas/session-ledger.schema.yaml`.
Normalized lane-worker events follow `../../schemas/worker-run-event.schema.yaml`.

## Procedure

1. Read the approved project definition, architecture, module contracts,
   state-of-union, sprint artifacts, gates, and current GitHub state.
2. Reconstruct the current lifecycle state and pending child sessions.
3. Validate the transition against `references/state-machine.md`.
4. For each child loop, record session ID, executor, repository, branch,
   worktree, issue, lane, wave, owner, start time, heartbeat expectations, and
   stop condition.
5. Launch child sessions only through the configured Agent Platform API, MCP
   tool, or documented manual handoff.
6. Monitor durable events: status, blockers, closeout, critic outcome, CI,
   deployment, review feedback, gate decisions, and session loss.
7. Pause at human gates and protected transitions.
8. Append session-ledger events for lifecycle-significant transitions and
   record explicit exceptions for missing coverage.
9. Write updated controller state and session ledger.

Read `references/session-ledger.md` before creating or reconciling
`.agent-workflow/controller/session-ledger.yaml`.

## Stop conditions

Stop when lifecycle state cannot be reconstructed, an open gate lacks an owner,
session identity is ambiguous, production access is requested directly by a
worker, or the controller would need to make a protected design decision.

## Load references only when needed

- Read `references/delivery-loop-model.md` for the wave state machine, nested
  loops, decision rights, and glossary.
- Read `references/state-machine.md` before defining transitions, waves, or
  failure recovery.
