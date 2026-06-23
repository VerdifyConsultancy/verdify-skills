---
name: state-of-union
description: Reviews approved Verdify project definition, lifecycle readiness, north-star architecture, module contracts, GitHub Issues, pull requests, gates, sprint history, and deployment state to reconcile the backlog against the north-star goal and produce an actionable execution strategy. Use after foundations are approved and before sprint planning, after a sprint or outcome closes, when backlog direction is unclear, or when docs, architecture, issues, gates, and delivery reality may be drifting apart.
compatibility: Requires repository read access and GitHub issue access or a current snapshot. Writing GitHub updates or gates requires explicit authority from repository policy or the user.
metadata:
  author: Verdify
  version: "1.0.0"
  lifecycle-order: "4"
---

# State Of Union

Reconcile durable intent with delivery reality before committing to the next execution slice. This skill creates a strategic plan; it does not create sprint lane contracts or implement code.

## Canonical artifacts

- `.agent-workflow/strategy/state-of-union.yaml` — authoritative strategy record
- `.agent-workflow/strategy/state-of-union.md` — generated human view
- `.agent-workflow/strategy/github-backlog-sync.yaml` — optional detailed
  GitHub backlog and delivery reconciliation artifact
- `.agent-workflow/strategy/gates/*.yaml` — optional human or policy gates

The YAML is canonical. Markdown summarizes it and must not introduce new decisions.

## Procedure

1. Reconstruct approved intent: `NORTHSTAR_PRODUCT.md`,
   `NORTHSTAR_ARCHITECTURE.md`, `northstar-artifacts.yaml`, project definition,
   lifecycle readiness, north-star architecture, ADRs, module contracts, and
   previous outcome reviews.
2. Reconstruct delivery reality: Git state, active branches, open pull requests, open gates, active/completed sprints, release verification, and deployment evidence.
3. Reconstruct backlog reality from live GitHub when available, otherwise from `.agent-workflow/github/snapshot.json`. GitHub Issues remain the backlog source of truth. Use `github-backlog-sync.yaml` when issue/PR/lane/delivery reconciliation materially affects the strategy.
4. Compare open issues against the north-star goal and current architecture. Classify issues as ready candidates, underspecified, stale, duplicate, blocked, missing, deferred, in progress, or done.
5. Identify drift: stale docs, stale architecture, missing module contracts, missing issues, unresolved decisions, dependency conflicts, sequencing risks, and delivery/operations gaps.
6. Produce a recommended execution sequence and a next sprint candidate set only when prerequisites are ready.
7. Record proposed actions with where they must be applied: GitHub issue, GitHub dependency, durable gate, project definition, architecture contracts, sprint planning, orchestrator, or release verification.
8. Validate `state-of-union.yaml` against `../../schemas/state-of-union.schema.yaml`. Validate any `github-backlog-sync.yaml` artifact against `../../schemas/github-backlog-sync.schema.yaml`.

Read `references/issue-reconciliation.md` before classifying issues. Read `references/github-backlog-sync.md` before writing or evaluating a GitHub backlog sync artifact. Read `references/handoff-rules.md` before naming the next skill.

## Action rules

Use existing control planes rather than private chat state:

- Missing work -> create or propose GitHub Issues.
- Weak issues -> update or propose updates to issue problem, outcome, acceptance intent, dependencies, risk, and evidence.
- Duplicates -> propose closure or dependency changes in GitHub.
- Missing decisions -> open durable gates with owner, evidence required, allowed decisions, and resume state.
- Stale product definition -> hand off to `project-definition`.
- Stale architecture or module boundaries -> hand off to `architecture-contracts`.
- Ready next slice -> hand candidate issues to `sprint-planning`; do not write lane contracts here.
- Active sprint blockers -> hand off to `sprint-orchestrator`.
- Integration, deployment, or outcome drift -> hand off to `release-verification`.

When write authority is absent, record proposed actions in the strategy artifact rather than mutating GitHub or gates.

## Boundaries

Do not:

- invent requirements not traceable to sources, decisions, or issues;
- replace GitHub Issues with a private task list;
- create sprint plans, lane maps, lane contracts, branches, worktrees, or PRs;
- modify architecture or project definition directly unless routed into those skills;
- claim readiness while blocking gaps or unresolved approval requirements remain.

## Handoff

The strategy must name exactly one recommended next skill and mode in `handoff`. The router consumes that handoff when the strategy is approved and current. Typical handoffs are:

- `project-definition` when product or lifecycle intent is stale;
- `architecture-contracts` when architecture or module contracts no longer support the goal;
- `sprint-planning` when candidate issues are ready for an executable sprint transaction;
- `sprint-orchestrator` when an active sprint requires coordination;
- `release-verification` when integration, deployment, or outcome evidence is the next blocker.

Open a strategy gate instead of approving the artifact when priority, acceptance authority, issue ownership, dependency sequencing, or execution risk is materially unresolved.
