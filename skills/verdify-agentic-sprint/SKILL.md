---
name: verdify-agentic-sprint
version: 0.1.0
description: "Run a structured agentic software-development sprint for an existing repository: reconstruct current truth, audit code and runtime, ingest a human sprint review, interview for unresolved decisions, plan and decompose work into isolated lanes/worktrees, supervise execution, independently verdify lanes, integrate, deploy, and reconcile project records."
license: Apache-2.0
metadata:
  verdify.version: "0.1.0"
---

# Verdify Agentic Sprint

Use this skill when the user wants to start, replan, execute, reconcile, deploy, or close a multi-agent coding sprint on an existing GitHub-hosted codebase.

## Required operating principle

The workflow state and decisions must live in durable artifacts, issues, pull requests, specifications, Git, and evidence. Do not attempt to run the whole sprint from one enormous prompt or from unrecorded chat memory.

## GitHub operating model

GitHub Issues are the source of truth for the backlog. Sprint planning starts from GitHub issues and milestones; transcripts, audits, and decisions may propose changes, but sprint work is not executable until it is represented by a GitHub issue or an approved issue update.

Lanes are narrow execution tracks derived from assigned GitHub issues. Every included GitHub issue must be assigned to exactly one lane, and the lane worker instantiated for that lane works only on its assigned issues unless a scope-change gate expands the contract.

Each lane uses a feature branch and pull request. Integration brings approved lane PRs back together through an explicit merge order, conflict reconciliation, repository-wide validation, and GitHub CI/CD. All target repositories are expected to test and deploy through GitHub Actions or equivalent GitHub-hosted CI/CD checks.

## Before activation

1. Identify the repository, default branch, target environment, and sprint ID.
2. Read `references/common-operating-contract.md`.
3. Determine the current workflow state from `.verdify/sprints/<sprint-id>/state.yaml`.
4. Load only the reference for the current phase.
5. If a human, policy, or managing-agent gate is active, read `references/human-gates.md`.

## Phase router

- No sprint workspace or controller baseline → `references/prompts/00-controller-bootstrap.md`
- Baseline exists but no audit → `references/prompts/01-discover-and-audit.md`
- Human review transcript received → `references/prompts/02-ingest-human-review.md`
- Unresolved decisions remain → `references/prompts/03-interview-human.md`
- Interview answers received → `references/prompts/04-synthesize-decisions.md`
- Decisions permit planning → `references/prompts/05-plan-sprint.md`
- Sprint candidate exists but lanes do not → `references/prompts/06-decompose-lanes.md`
- Plan and lanes approved → `references/prompts/07-compile-lane-contracts.md`
- Lane dispatched → `references/prompts/08-lane-worker-start.md`
- Lane reports blocker/decision/status → `references/prompts/09-lane-status-and-guidance.md`
- Lane implementation complete → `references/prompts/10-lane-closeout.md`
- Lane ready for independent review → `references/prompts/11-independent-critic.md`
- All lanes terminal or ready → `references/prompts/12-integration-controller.md`
- Integration ready and deployment authorized → `references/prompts/13-deploy-and-verdify.md`
- Deployment outcome known → `references/prompts/14-close-sprint.md`
- Sprint records reconciled → `references/prompts/15-human-outcome-review.md`

## Mandatory human interrupts

Pause for a human and write a gate artifact when:

- product intent or architecture remains materially ambiguous;
- the proposed sprint/lane topology needs approval;
- a lane requests a public API, database, security, destructive, or production-risk change not already approved;
- policy requires deployment approval;
- a failed mandatory gate would need an exception;
- final outcome acceptance is required.

Gate artifacts live at `.verdify/sprints/<sprint-id>/gates/<gate-id>.yaml` and conform to `schemas/human-gate.schema.yaml`. A managing agent may resolve a gate only when the gate policy explicitly allows that actor and all required evidence is present.

## Gate enforcement model

This skill treats gates as contracts first. In a plain agent session, gates are procedural: the agent must stop, write the gate artifact, and ask for the required decision. In an orchestrated runtime, the same gate artifact is the mechanical interrupt signal used by a workflow engine, CI job, or managing agent.

Do not substitute narrative confidence for deterministic checks. Tests, schema validation, clean Git state, CI, policy checks, and deployment evidence decide whether a gate can close.

## Agent session boundaries

Use fresh sessions for lane workers, independent critics, and the integration controller. Pass context through authoritative artifacts and references.

## Completion

A sprint is complete only when code, GitHub issues, PRs, specifications, decisions, workflow state, GitHub CI/CD evidence, and deployment evidence agree on what was delivered and what remains.
