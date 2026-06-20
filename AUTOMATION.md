# Automation Blueprint

This document shows how to evolve the manual prompt pack into an increasingly automated system without prematurely hiding the workflow inside one model session.

## Principle: automate transitions, not judgment

Automate:

- context collection;
- artifact creation and schema validation;
- branch/worktree lifecycle;
- issue/PR synchronization;
- test and CI execution;
- status events and notifications;
- evidence capture;
- state persistence;
- safe retries and timeouts.

Keep explicit human or policy gates for:

- unresolved product intent;
- architecture changes with material consequences;
- public API and database migration decisions;
- security boundary changes;
- destructive or production actions;
- exceptions to failed quality gates;
- final acceptance where required.

## Phase 1: shell/CLI automation

Add scripts such as:

```text
scripts/
├── initialize_sprint.py
├── collect_repo_baseline.py
├── collect_github_state.py
├── collect_runtime_state.py
├── validate_artifact.py
├── create_lane_worktree.sh
├── compile_worker_prompt.py
├── report_lane_status.py
├── verdify_git_clean.py
├── gather_evidence.py
├── reconcile_issues.py
└── cleanup_worktrees.sh
```

Suggested commands:

```bash
verdify sprint init --id 2026-06-20-a
verdify audit collect --sprint 2026-06-20-a
verdify review ingest transcript.md
verdify plan validate
verdify lanes create-worktrees
verdify lane status runtime-health
verdify integration preflight
verdify deploy verdify --env staging
verdify sprint close
```

Every command should be idempotent where practical and should write structured output under `.verdify/sprints/<id>/`.

## Phase 2: GitHub-native events

Suggested labels:

- `verdify:sprint`
- `verdify:lane`
- `verdify:blocker`
- `verdify:decision-required`
- `verdify:ready-for-critic`
- `verdify:ready-for-integration`
- `verdify:deployment-ready`
- `risk:high`
- `risk:critical`

Suggested issue fields:

- sprint ID;
- lane ID;
- desired outcome;
- acceptance criteria;
- dependencies;
- risk;
- evidence links;
- current workflow state.

Suggested events:

- PR opened → attach lane contract and run lane gates;
- CI failed → notify the owning lane worker;
- critic requested changes → return lane to `CHANGES_REQUESTED`;
- all required checks pass → set `READY_FOR_INTEGRATION`;
- deployment completed → start runtime verification;
- runtime verification passes → allow spec archive and issue closure.

## Phase 3: Agent Skill packaging

Use the Agent Skills folder pattern:

```text
verdify-agentic-sprint/
├── SKILL.md
├── references/
│   ├── common-operating-contract.md
│   ├── workflow.md
│   └── prompts/
├── scripts/
├── schemas/
└── assets/
    └── templates/
```

The top-level `SKILL.md` should remain a router and policy summary. It should load the detailed phase reference only when the current task matches that phase.

Skill activation cues should include:

- start or replan a sprint;
- audit an existing repository and deployment;
- ingest a spoken sprint review;
- interview for architecture or product decisions;
- decompose work into agent lanes/worktrees;
- compile lane prompts;
- close a lane;
- reconcile multi-agent work;
- verdify deployment;
- close a sprint.

Do not load every prompt at once. Progressive disclosure keeps context focused and reduces cross-phase instruction confusion.

## Phase 4: Durable workflow engine

Represent the state machine in Temporal, LangGraph, or an equivalent runtime.

Recommended mapping:

- sprint = parent workflow;
- lane = child workflow;
- controller/worker/critic calls = activities or agent nodes;
- human decisions = durable interrupts/signals;
- GitHub/CI/deployment webhooks = workflow events;
- artifacts = external durable state, referenced by ID;
- timeouts = heartbeat and escalation policies;
- retry only idempotent or explicitly compensatable operations.

The workflow engine owns transition state. GitHub owns work discussion/status. Git owns code. Specifications own intended behavior. Evidence owns proof. Avoid duplicating all content into the workflow database.

## Phase 5: Prompt compiler

A compiler should render a concise worker prompt from the authoritative lane contract.

Inputs:

- common operating contract version;
- lane YAML;
- relevant decision excerpts;
- relevant spec/change excerpts;
- dependency outputs;
- repository-specific instructions.

Outputs:

- `worker-prompt.md` under the character limit;
- context manifest showing what was included and omitted;
- hash of the authoritative inputs;
- validation report proving required constraints were preserved.

Never manually edit the compiled prompt without updating the lane contract or recording an override.

## Phase 6: Human interaction surface

The dashboard should not stream every terminal. It should show:

- sprint outcome and state;
- lane state and last heartbeat;
- pending human decisions;
- blockers;
- risk changes;
- critic outcome;
- deployment readiness;
- verified outcome and evidence.

Primary human notifications:

- `DECISION_REQUIRED`
- `BLOCKED`
- `SCOPE_CHANGE_REQUESTED`
- `DEPLOY_READY`
- `DEPLOYMENT_FAILED`
- `SPRINT_COMPLETE`

Voice review flow:

1. record review;
2. transcribe locally or through an approved service;
3. store raw transcript;
4. run the review-ingestion prompt;
5. generate a question packet;
6. record answers;
7. synthesize the decision register;
8. request approval only after the proposed sprint and lanes are visible.

## Evaluation before increased autonomy

Track at least:

- percent of questions answerable from repo that agents incorrectly asked humans;
- lane-contract changes after dispatch;
- merge conflict rate;
- cross-lane interface breakages;
- critic escape rate;
- acceptance criteria without evidence;
- issue/spec drift at closure;
- deployment mismatch incidents;
- human interruptions per sprint;
- cycle time from review to verified deployment;
- rolled-back or reopened sprints;
- cost by phase and lane.

Use these metrics to improve prompts and boundaries. Do not evaluate the system only by lines of code, number of agents, or apparent autonomy.
