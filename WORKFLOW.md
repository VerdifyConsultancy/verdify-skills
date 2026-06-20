# Step-by-Step Workflow

## Overview

The workflow is organized into four operating stages:

1. **Establish truth** — reconstruct the repository and deployed-system state, then combine it with the human sprint review.
2. **Plan and contract** — resolve decisions, define the sprint, decompose it into bounded lanes, and compile lane contracts.
3. **Execute and verdify lanes** — run isolated workers, supervise by exception, collect evidence, and perform independent review.
4. **Integrate, deploy, and close** — reconcile all changes, verdify the deployed result, update project truth, and close the sprint.

A fresh session is recommended for:

- initial controller;
- every lane worker;
- every independent critic;
- integration controller;
- deployment verifier when production risk is material.

The system passes state through artifacts rather than through conversational memory.

## GitHub backlog and delivery model

GitHub Issues are the backlog source of truth. Human reviews, audits, and architecture interviews may discover work, but that work must be reconciled into GitHub issues before it becomes executable sprint scope. Each approved issue is assigned to exactly one lane, and each lane worker works only on its assigned issue set.

All implementation flows through feature branches and pull requests. The integration controller merges approved lane PRs in dependency order, resolves conflicts according to lane ownership, and requires GitHub CI/CD evidence before deployment verification. Target repositories are expected to test and deploy through GitHub Actions or equivalent GitHub-hosted CI/CD checks.

## Gate artifacts

Any human, policy, or managing-agent interrupt must create a gate artifact before risky work stops or resumes:

```text
.verdify/sprints/<sprint-id>/gates/<gate-id>.yaml
```

Gate artifacts conform to `schemas/human-gate.schema.yaml` and include the trigger, question, resolver, required evidence, and resume conditions. A chat answer is not enough to resume work; the resolved gate must be written to durable state first.

---

## Stage A — Establish truth

### Step 0: Initialize the sprint workspace

**Actor:** Human or deterministic script  
**Prompt:** none  
**Human gate:** no

Create:

```text
.verdify/sprints/<sprint-id>/
├── state.yaml
├── baseline/
├── review/
├── decisions/
├── gates/
├── plan/
├── lanes/
├── integration/
├── deployment/
└── closure/
```

Capture:

- repository URL and local path;
- default branch;
- baseline commit SHA;
- Git status;
- open GitHub issue, milestone, PR, and GitHub Actions snapshots;
- target environment and currently deployed revision, when available;
- sprint ID and human owner.

**Exit gate:** workspace exists, baseline SHA is recorded, repository access works.

### Step 1: Start a fresh controller

**Actor:** Controller agent  
**Prompt:** `prompts/00-controller-bootstrap.md`  
**Human gate:** only if access is missing

The controller reads the common contract and establishes its role. It does not implement product code.

**Required output:** `baseline/controller-bootstrap.md`

**Exit gate:** controller confirms accessible sources and identifies missing access or material uncertainty.

### Step 2: Discover and adversarially audit the project

**Actor:** Controller plus optional read-only subagents  
**Prompt:** `prompts/01-discover-and-audit.md`  
**Human gate:** no, unless production access requires approval

Review:

- recently modified documentation;
- recent commits and merges;
- current issues, PRs, milestones, and planning records;
- architecture and design records;
- relevant code paths;
- tests and CI behavior;
- deployment manifests, containers, pods, services, logs, health checks, and actual deployed revision;
- drift between documentation, backlog, code, and runtime.

Use parallel subagents for independent review domains where supported, but reconcile their findings into one evidence-backed report.

**Required outputs:**

- `baseline/repository-map.md`
- `baseline/runtime-map.md`
- `baseline/adversarial-audit.md`
- `baseline/evidence.yaml`
- candidate issues or issue updates

**Exit gate:** the controller can explain the current architecture, current deployment, active work, known risks, and major inconsistencies.

### Step 3: Capture the human sprint review

**Actor:** Human  
**Prompt/template:** `templates/sprint-review-input.md`  
**Human gate:** yes—this is a deliberate human input window

The human records a walk-and-talk or live review covering:

- what appears correct or incorrect;
- behavior that differs from expectations;
- missing capabilities;
- usability or operational concerns;
- priorities and desired outcomes;
- hypotheses and uncertainties;
- architecture concerns;
- work that should or should not be included next.

Transcribe it and save it to `review/human-review-transcript.md` without cleaning away ambiguity.

**Exit gate:** raw transcript exists and is attributable to a date and reviewer.

### Step 4: Correlate the human review with repository evidence

**Actor:** Same controller session used for discovery, when possible  
**Prompt:** `prompts/02-ingest-human-review.md`  
**Human gate:** no

The controller separates the transcript into observations, preferences, decisions, hypotheses, contradictions, and unresolved questions. It tests claims against the baseline instead of treating the transcript as automatically correct.

**Required outputs:**

- `review/review-synthesis.md`
- `review/claim-correlation.yaml`
- `review/question-candidates.md`

**Exit gate:** every material statement is classified and linked to evidence, a decision, or a question.

### Step 5: Interview the human to close design gaps

**Actor:** Controller as architecture interviewer  
**Prompt:** `prompts/03-interview-human.md`  
**Human gate:** yes

Two supported modes:

- **Batch voice mode:** produce a prioritized question packet that the human answers in one recording.
- **Interactive grill mode:** ask one question at a time, challenge contradictions, and update decisions continuously.

The agent must not ask questions answerable from the repository, issues, specs, or runtime evidence. Each question explains why it matters and provides a recommended default where appropriate.

**Required outputs:**

- `review/question-pack.md`
- human response transcript

**Exit gate:** blocking product, architecture, scope, risk, and sequencing questions are answered or explicitly deferred.

### Step 6: Convert answers into durable decisions

**Actor:** Controller  
**Prompt:** `prompts/04-synthesize-decisions.md`  
**Human gate:** only for ambiguous or contradictory answers

Create a decision register and ADRs as appropriate. Do not silently choose among conflicting human statements.

**Required outputs:**

- `decisions/decision-register.yaml`
- `decisions/DEC-*.md` or ADR updates
- `decisions/unresolved.md`

**Exit gate:** all sprint-blocking decisions have status `ACCEPTED`; deferred items are explicit and cannot accidentally enter scope.

---

## Stage B — Plan and contract

### Step 7: Reconcile the backlog and propose the sprint

**Actor:** Controller  
**Prompt:** `prompts/05-plan-sprint.md`  
**Human gate:** no until proposal is complete

Create or update specifications/change proposals, GitHub issues, dependencies, milestones, acceptance criteria, and non-goals. Planning should be realistic for the desired operating cadence but must not force unrelated work into one sprint merely to achieve “one sprint per day.”

The sprint backlog is the approved set of GitHub issues. If an audit, review, or decision implies work that is not yet represented by a GitHub issue, draft or create the issue before including it in the sprint plan.

**Required outputs:**

- `plan/sprint-plan.yaml`
- `plan/sprint-plan.md`
- updated GitHub issues/milestone
- proposed spec/change records
- `plan/backlog-reconciliation.md`

**Exit gate:** every sprint item has a GitHub issue, acceptance criteria, dependency state, risk classification, and reason for inclusion.

### Step 8: Decompose the sprint into lanes

**Actor:** Controller  
**Prompt:** `prompts/06-decompose-lanes.md`  
**Human gate:** no until topology is proposed

Partition by GitHub issue assignment, bounded responsibility, interface ownership, runtime resource, and acceptance scenario. Directory ownership is a useful constraint but not the only one.

Each included GitHub issue must be assigned to exactly one lane. A lane may contain multiple issues only when they share one coherent objective, one PR boundary, and one validation path.

The controller must assess collision across:

- source paths;
- public APIs and internal contracts;
- database schemas and migrations;
- shared configuration;
- deployment resources;
- generated code;
- tests and fixtures;
- documentation and specifications.

Create a dependency DAG. Serialize work that cannot safely proceed in parallel.

**Required outputs:**

- `plan/lane-topology.yaml`
- `plan/lane-topology.md`
- `plan/conflict-matrix.md`

**Exit gate:** each lane has assigned GitHub issue IDs, one coherent objective, bounded ownership, explicit dependencies, and minimal hidden coupling.

### Step 9: Human approval of sprint and lanes

**Actor:** Human  
**Prompt:** controller presents an approval brief generated by Step 8  
**Human gate:** yes

Approve or revise:

- sprint objective and non-goals;
- issue inclusion/exclusion;
- issue-to-lane assignment;
- architecture decisions;
- lane count and boundaries;
- dependency ordering;
- risk and deployment policy;
- expected human intervention points.

**Required output:** approval record in `plan/approval.md`.

**Exit gate:** explicit approval or recorded edits; no lane dispatch before approval.

### Step 10: Compile lane contracts and short worker prompts

**Actor:** Controller  
**Prompt:** `prompts/07-compile-lane-contracts.md`  
**Human gate:** no

For every approved lane, create:

- authoritative `lane.yaml` contract;
- human-readable `lane.md`;
- worker prompt of at most 4,000 characters;
- assigned issue set;
- branch/worktree name;
- dependency and interface package;
- validation and evidence requirements.

The short prompt is a compiled convenience artifact. The lane contract remains authoritative.

**Exit gate:** all lane contracts validate against the schema; no ownership overlap lacks an explicit coordination rule.

### Step 11: Create worktrees and dispatch workers

**Actor:** Script/controller  
**Prompt:** `prompts/08-lane-worker-start.md`  
**Human gate:** no

Create one worktree and fresh agent session per ready lane. Do not start a lane whose hard dependencies are incomplete.

Each lane worker owns its assigned GitHub issues, feature branch, and pull request. The worker keeps issue status and PR description synchronized with implementation evidence.

**Exit gate:** workers acknowledge their contracts, assigned GitHub issues, branch/PR policy, and report no unresolved scope ambiguity before entering `IMPLEMENTING` or `DECISION_REQUIRED`.

---

## Stage C — Execute and verdify lanes

### Step 12: Lane worker executes autonomously

**Actor:** Lane worker  
**Prompt:** initial worker prompt plus lane contract  
**Human gate:** only on explicit escalation conditions

Worker sequence:

1. inspect relevant code, docs, tests, and interfaces;
2. validate the proposed approach against the contract;
3. make the smallest coherent implementation;
4. test incrementally;
5. update issue/PR state;
6. record discoveries outside scope;
7. maintain a status artifact;
8. stop only for a genuine decision, blocker, or approved completion.

**Exit gate:** worker believes all acceptance criteria are met and enters `READY_FOR_CRITIC`.

### Step 13: Supervise by exception

**Actor:** Controller  
**Prompt:** `prompts/09-lane-status-and-guidance.md`  
**Human gate:** only if the controller cannot resolve the escalation from approved artifacts

Do not continuously poll narrative output. Use event-driven statuses:

- `DECISION_REQUIRED`
- `BLOCKED`
- `SCOPE_CHANGE_REQUESTED`
- `READY_FOR_CRITIC`
- timeout or heartbeat failure

Controller responses are limited to:

- `CONTINUE`
- `REDIRECT`
- `PAUSE`
- `APPROVE_SCOPE_CHANGE`
- `REJECT_SCOPE_CHANGE`
- `ESCALATE_TO_HUMAN`
- `CANCEL`

**Exit gate:** every active lane has a current machine-readable status and no unanswered blocker.

### Step 14: Lane closeout and adversarial self-audit

**Actor:** Lane worker  
**Prompt:** `prompts/10-lane-closeout.md`  
**Human gate:** no

The worker:

- runs all validation commands;
- checks acceptance criteria one by one;
- reviews the full diff adversarially;
- confirms scope compliance;
- updates docs/specs/issues assigned to the lane;
- creates new issues for follow-up discoveries;
- commits and pushes all intended work;
- confirms a clean worktree;
- prepares an evidence manifest and closure report.

**Exit gate:** lane branch is pushed, worktree is clean, PR exists, evidence is complete, and state is `READY_FOR_CRITIC`.

### Step 15: Independent critic review

**Actor:** Fresh critic agent  
**Prompt:** `prompts/11-independent-critic.md`  
**Human gate:** only for disputed requirements or risk exceptions

The critic begins from the lane contract, not from the worker's narrative. It checks the diff, tests, issue/spec alignment, interface compatibility, security, operational behavior, and evidence completeness.

Possible outcomes:

- `PASS`
- `PASS_WITH_FOLLOWUPS`
- `CHANGES_REQUESTED`
- `ESCALATE`

A worker may address requested changes, then the critic re-runs the relevant review.

**Exit gate:** all lanes are `READY_FOR_INTEGRATION`, cancelled, or explicitly deferred.

---

## Stage D — Integrate, deploy, and close

### Step 16: Start a fresh integration controller

**Actor:** Fresh controller/integrator session  
**Prompt:** `prompts/12-integration-controller.md`  
**Human gate:** only if artifacts are incomplete or branches conflict semantically

Read:

- baseline and sprint plan;
- decision register;
- lane topology and contracts;
- every assigned GitHub issue, PR, and diff;
- lane closure reports;
- critic reports;
- current default branch and GitHub CI/CD state.

Build a safe merge order from lane dependencies and issue relationships. Ensure all lane branches are pushed, PRs are current, assigned issues are linked, and worktrees are clean. Rebase or update according to repository policy, then merge one lane at a time with whole-system validation and GitHub CI/CD evidence after each merge.

**Exit gate:** integration branch/default branch contains all approved issue work, GitHub CI/CD passes, linked issues/PRs reflect reality, and no unresolved semantic conflict remains.

### Step 17: Whole-system reconciliation

**Actor:** Integrator  
**Prompt:** continuation of `prompts/12-integration-controller.md`  
**Human gate:** for architecture changes or policy exceptions

Verdify:

- cross-lane interfaces;
- integration and end-to-end tests;
- schema and migration order;
- configuration compatibility;
- generated artifacts;
- docs/spec coherence;
- issue and PR relationships;
- GitHub Actions check and deployment status;
- absence of dirty or orphaned worktrees/branches.

**Required outputs:**

- `integration/integration-plan.md`
- `integration/integration-report.md`
- `integration/evidence.yaml`

**Exit gate:** state is `READY_FOR_DEPLOYMENT`.

### Step 18: Deploy and verdify the actual runtime

**Actor:** Deployment job plus verifier agent  
**Prompt:** `prompts/13-deploy-and-verdify.md`  
**Human gate:** according to environment/risk policy

Capture pre-deploy state, target revision, GitHub CI/CD run, rollout events, deployed image digests, pod/container health, logs, migrations, health endpoints, synthetic checks, and rollback readiness.

Do not equate “pipeline succeeded” with “correct code is running.” Confirm the deployed revision or image digest matches the intended release.

**Required outputs:**

- `deployment/deployment-record.yaml`
- `deployment/evidence.yaml`
- `deployment/verification-report.md`

**Exit gate:** deployed revision matches target and all required runtime acceptance checks pass, or rollback is completed and documented.

### Step 19: Reconcile project records and close the sprint

**Actor:** Controller/integrator  
**Prompt:** `prompts/14-close-sprint.md`  
**Human gate:** final acceptance where policy requires it

Update:

- issues and milestones;
- PR states;
- specifications and architecture records;
- decision status;
- follow-up issues;
- deployment records;
- sprint state;
- branch/worktree cleanup.

Archive proposed spec changes into current truth only after deployed verification succeeds.

**Required outputs:**

- `closure/sprint-closure-report.md`
- `closure/carryover.yaml`
- `closure/final-evidence.yaml`

**Exit gate:** repository and project records accurately reflect what was delivered, what was not delivered, and what remains.

### Step 20: Human outcome review and next-cycle input

**Actor:** Human plus controller  
**Prompt:** `prompts/15-human-outcome-review.md`  
**Human gate:** yes

Present a plain-language review of:

- intended versus delivered outcomes;
- user-visible and operational changes;
- deviations from plan;
- evidence and residual risk;
- follow-up work;
- decisions needed for the next sprint.

The human may inspect the deployed system and record the next walk-and-talk review, beginning the cycle again.

---

## Human interaction rhythm

The workflow is designed to minimize terminal watching. A typical rhythm is:

1. **Review window:** inspect the product/runtime and record observations.
2. **Decision window:** answer the controller's prioritized questions and approve the sprint/lane topology.
3. **Autonomous work window:** lane agents execute; the human is interrupted only for material decisions or blockers.
4. **Release window:** approve high-risk deployment actions, review delivery evidence, and inspect the result.

Multiple projects may run concurrently, but each project should expose only a small event queue: `DECISION_REQUIRED`, `BLOCKED`, `DEPLOY_READY`, and `SPRINT_COMPLETE`.

## Minimum viable implementation

The first implementation needs only:

- Git and Git worktrees;
- GitHub issues/PRs and `gh` CLI;
- the prompt files in this package;
- YAML files under `.verdify/sprints/`;
- scripts that validate clean Git state and run known test commands;
- humans to start the next prompt when a phase completes.

Do not introduce a workflow engine until the manual sequence is stable enough that its states, transitions, and failure policies are understood.
