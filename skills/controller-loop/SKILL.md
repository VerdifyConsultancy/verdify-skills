---
name: controller-loop
description: Specifies or operates the long-lived Verdify outer loop that persists lifecycle state, wave state, child sessions, gates, status events, and handoffs independently of model conversation history. Use when a project needs resumable orchestration across planning, research, hygiene, sprint execution, review, fixes, replanning, deployment, and human sign-off.
compatibility: Requires approved lifecycle prerequisites, repository artifacts, access to session/runtime records, and Agent Platform API or MCP details when child sessions are actually launched.
metadata:
  author: Verdify
  version: "1.0.0"
---

# Controller Loop

Own durable orchestration state. Do not implement lane code, review your own
work, or bypass human gates.

## Operating model

Controller-loop owns the long-running repo controller contract for outer loops,
inner loops, cron wakes, context-window resets, and recovery handoffs. A loop
must reconstruct from durable artifacts, write a checkpoint before context
reset or sleep, and resume from a prompt generated from trusted refs rather than
hidden chat history.

Read `references/recovery-contract.md` before defining controller loops,
resume prompts, loop KPIs, Agent Fleet metrics, alert handling, context reset
thresholds, or recoverable failure behavior.

## Canonical artifacts

- `.agent-workflow/controller/controller-state.yaml` - durable controller state,
  including current wave and wave-supervision state
- `.agent-workflow/controller/session-ledger.yaml` - append-oriented session map

Validate controller state against `../../schemas/controller-state.schema.yaml`
and the session ledger against `../../schemas/session-ledger.schema.yaml`.
Wave-supervision mode writes wave entries into controller state; do not create
standalone `.agent-workflow/controller/waves/<wave-id>.yaml` artifacts.

## Procedure

1. Read the approved project definition, architecture, module contracts,
   state-of-union, sprint artifacts, gates, and current GitHub state.
2. Reconstruct the current lifecycle state and pending child sessions.
3. Define or refresh the active loop record with status, owner, repository,
   issue refs, PR refs, checkpoint path, current objective, last action, last
   error, and next prompt.
4. Validate the transition against `references/state-machine.md`.
5. For each child loop, record session ID, executor, repository, branch,
   worktree, issue, lane, wave ID, owner, started_at, heartbeat_expectations,
   heartbeat_deadline_at, and stop_condition.
   In wave-supervision mode, record wave entries in controller-state `waves`,
   set `current_wave`, and link sessions to waves with `wave_id`.
6. Launch child sessions only through the configured Agent Platform API, MCP
   tool, or documented manual handoff.
7. Monitor durable events: status, blockers, closeout, critic outcome, CI,
   deployment, review feedback, gate decisions, and session loss.
8. Pause at human gates and protected transitions.
9. Append session-ledger events for lifecycle-significant transitions and
   record explicit exceptions for missing coverage.
10. Write updated controller state and session ledger.

Read `references/session-ledger.md` before creating or reconciling
`.agent-workflow/controller/session-ledger.yaml`.

## Stop conditions

Stop when lifecycle state cannot be reconstructed, an open gate lacks an owner,
session identity is ambiguous, production access is requested directly by a
worker, or the controller would need to make a protected design decision.

## Load references only when needed

- Read `references/state-machine.md` before defining transitions, waves, or
  failure recovery.
- Read `references/recovery-contract.md` before writing loop records, status
  events, resume prompts, context reset checkpoints, or Agent Fleet telemetry
  handoffs.
