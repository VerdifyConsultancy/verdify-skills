---
name: project-router
description: Determines the next Verdify lifecycle skill and mode by inspecting repository state, GitHub backlog and delivery state, and approved .verdify artifacts. Use when starting or resuming a project, after a handoff, after sprint closure, or whenever lifecycle position and missing prerequisites are unclear.
compatibility: Requires repository read access. Git is required; GitHub CLI is recommended when live GitHub state is relevant.
metadata:
  author: Verdify
  version: "1.0.0"
  lifecycle-order: "1"
---

# Project Router

Decide exactly one next lifecycle action without doing that action's substantive work.

## Before routing

1. Read `../../COMMON_OPERATING_CONTRACT.md`.
2. Read `../../config/authority-matrix.yaml` when records disagree.
3. Use live GitHub state when available. A local snapshot is only a cache.
4. Never infer that a missing artifact was approved.

## Procedure

1. Locate the repository root and identify the default branch, current branch, clean/dirty state, recent commits, open pull requests, active issues, and `.verdify` tree.
2. Run:

   ```bash
   ../../bin/verdify route --repo <repository> --write
   ```

3. Review the deterministic recommendation against material context that the CLI cannot judge, such as an explicit human request, a production incident, or an open decision gate.
4. Classify missing information as `missing`, `stale`, `contradictory`, or `approval_required`.
5. Write or update:
   - `.verdify/router/route-decision.yaml`
   - `.verdify/router/route-decision.md`
6. Name one next skill and one mode. Explain prerequisites, why earlier stages are complete, and what must stop the next role.
7. Hand off. Do not continue into implementation from the router role.

## Routing order

Use the first unmet condition:

1. Incomplete project understanding or design surface -> `project-definition` in the earliest incomplete mode.
2. Missing or stale system architecture/module contracts -> `architecture-contracts`.
3. No approved bounded sprint/lane transaction -> `sprint-planning`.
4. Approved sprint with lanes requiring dispatch, monitoring, or gate resolution -> `sprint-orchestrator`.
5. A worker lane explicitly assigned to this session -> `lane-delivery`.
6. Worker closeout awaiting fresh review -> `independent-critic`.
7. Approved lanes awaiting integration, deployment proof, or outcome acceptance -> `release-verification`.
8. Completed cycle -> route to `project-router` for the next outcome.

An urgent incident may route directly to `release-verification` only when the repository's incident policy authorizes it and the decision is recorded.

## Required output fields

The YAML decision must include current state, next skill, next mode, evidence, missing artifacts, open gates, and reason. Validate it against `../../schemas/route-decision.schema.yaml`.

## Stop conditions

Stop and report rather than guessing when:

- repository identity or default branch is ambiguous;
- GitHub cannot be reached and the cached snapshot is materially stale;
- approved artifacts conflict with live code or GitHub state;
- a material gate has no authorized resolver;
- the user requests a later phase but prerequisites are absent.

## Load references only when needed

- Read `references/routing-rules.md` for precedence and exceptional routing.
- Read `references/artifact-readiness.md` when deciding whether a phase is actually complete.
