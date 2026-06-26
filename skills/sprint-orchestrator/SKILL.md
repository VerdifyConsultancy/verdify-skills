---
name: sprint-orchestrator
description: Coordinates an approved Verdify sprint or wave by reconciling GitHub, preparing an Agent Platform MCP execution runbook, dispatching dependency-ready lane worktrees and worker sessions, supervising lane agents through platform session and terminal interfaces, handling gates and coordination requests, monitoring CI/CD and deployment readiness, and routing completed lanes to criticism, review inbox, and release verification. Use only after sprint and lane contracts are approved, including when a user asks for a controller loop that owns lane agents, polling, MCP dispatch, tmux/browser terminal visibility, CI/CD, and review deployment coordination.
compatibility: Requires Git, the Verdify CLI, approved sprint artifacts, GitHub CLI for live reconciliation, and Agent Platform API/MCP details when platform sessions are launched. It coordinates but does not implement lane code or review its own work.
metadata:
  author: Verdify
  version: "1.0.0"
  lifecycle-order: "6"
---

# Sprint Orchestrator

Act as controller, not worker, critic, or deployment verifier. Coordinate lane
agents, CI/CD, review deployment readiness, and handoffs from durable evidence.

## Canonical artifacts

- `.agent-workflow/sprints/<sprint-id>/execution/sprint-execution-runbook.yaml`
  - sprint execution controller runbook for Agent Platform MCP dispatch,
  terminal visibility, polling cadence, lane session identities, CI/CD,
  deployment, review, and ledger requirements.
- `.agent-workflow/sprints/<sprint-id>/status.yaml` - sprint execution status.
- `.agent-workflow/controller/controller-state.yaml` and
  `.agent-workflow/controller/session-ledger.yaml` - durable loop and session
  history owned with `controller-loop`.
- Agent Platform control request artifacts when MCP/API operations need policy,
  authorization, target, result, and review records.

Validate the runbook against
`../../schemas/sprint-execution-runbook.schema.yaml`.

## Start

1. Read the approved sprint plan, wave release plan when present, plan gate,
   lane contracts, module contracts, execution runbook when present, and
   dependency order.
2. Refresh GitHub state:

   ```bash
   ../../bin/verdify github snapshot --repo OWNER/REPO --target <repository>
   ../../bin/verdify github reconcile --repo-path <repository> --sprint <sprint-id>
   ```

3. Confirm the baseline, issue state, branch naming, required checks, Agent
   Platform readiness, MCP operation identity, terminal access mode, and
   authorized agents.
4. Create or update the execution runbook before dispatch:

   ```bash
   scripts/build_execution_runbook.rb \
     --repo <repository> \
     --sprint <sprint-id> \
     --controller-session-id <controller-session-id>
   ```

5. Create or update per-lane Agent Platform control request stubs when session
   creation is not already authorized:

   ```bash
   scripts/build_platform_control_requests.rb \
     --repo <repository> \
     --runbook <repository>/.agent-workflow/sprints/<sprint-id>/execution/sprint-execution-runbook.yaml
   ```

6. Mark only dependency-ready lanes as dispatchable.

Read `references/platform-execution.md` before creating platform sessions or
running the controller poll loop.

## Dispatch

Derive lanes for this wave from the task DAG and the expected write-set /
file-conflict graph (ADR-0013); a lane is a temporary partition, not a fixed
silo. For each ready lane, create exactly one worker worktree/session through the
adapter the runbook authorizes for this host — an Agent Platform MCP/API
operation or a host-local Claude/Codex run, recorded as a control request when
platform mediation applies (ADR-0016). Use `bin/verdify lane create` for the
local lease/worktree identity. Record the substrate, lease ID, and session;
never run an unrecorded substrate.

```bash
../../bin/verdify lane create \
  --repo <repository> \
  --sprint <sprint-id> \
  --lane-id <lane-id> \
  --issue <issue-number> \
  --session-id <unique-session-id> \
  --agent <agent-name>
```

Compile the worker prompt from the contract. Record lease ID, Agent Platform
session ID, terminal/tmux/browser refs, branch, PR, issue, and agent session in
the execution runbook, sprint status, and session ledger. Never dispatch two
workers into the same lane/worktree.

## Monitor events

Orchestration is **event-driven** through a vendor-neutral worker adapter
(ADR-0016): consume normalized `../../schemas/worker-run-event.schema.yaml`
events from the adapter (`start`/`events`/`send`/`cancel`/`collect`), validate
each `proposal` against state and policy, and record the authorized transition.
Both substrates implement the adapter — Claude (Agent SDK / in-session fan-out)
and Codex (`exec --json` / SDK threads) — and the controller selects per host.
A periodic poll exists only to detect lost workers (expired leases, missing
heartbeats, undelivered CI events, GitHub/controller drift), not to scrape
terminal text for progress. Read `references/worker-adapter-contract.md`.

Handle durable events rather than trusting free-form chat narratives:

- heartbeat/status update;
- blocker;
- decision required;
- scope-change request;
- coordination request across lanes;
- worker closeout;
- critic changes requested or approval;
- CI failure;
- review deployment readiness;
- terminal/session loss;
- dependency completion;
- lease expiry or abandoned worktree.

Coordinate with `controller-loop` so dispatch, lease, closeout, critic,
review, deployment, gate, and handoff transitions have session-ledger events or
explicit exceptions.

Read `references/state-machine.md`, `references/platform-execution.md`, and
`references/gate-management.md`.

## Reconcile

At every material transition, compare issue, PR, checks, contract, lease, and artifact state. GitHub is authoritative for backlog and delivery; the lane contract is authoritative for scope; the lease is authoritative only for local worktree ownership.

Read `references/github-reconciliation.md`.

## Role boundaries

- Do not modify lane implementation files.
- Do not use the worker's session or worktree as the critic.
- Do not approve your own material plan exception.
- Do not bypass required checks, reviews, or deployment approvals.
- Do not close a sprint before release verification and outcome review.
- Do not launch a worker on a substrate the runbook does not authorize for the
  host; record the chosen Claude/Codex/platform adapter and its session.
- Do not copy raw session logs, secrets, or private terminal payloads into
  durable artifacts.

## Handoffs

- Ready worker -> `lane-delivery`
- Worker closeout -> fresh `independent-critic`
- Critic changes requested -> original or newly leased `lane-delivery` session per policy
- All required lanes approved -> `release-verification` review-inbox packet mode
- CI/CD or deployment readiness gap -> `release-verification`,
  `platform-readiness`, or a gate owner according to the runbook
- Material replan -> `sprint-planning`
