# ADR-0014: State-of-union vs issue-triage GitHub issue actions

- Status: accepted
- Date: 2026-06-24
- Issue: #11

## Context

Verdify uses GitHub Issues as backlog truth and uses lifecycle artifacts for
approved strategy, sprint scope, lane execution, and review evidence.

Two skills meet at the GitHub issue boundary:

- `issue-triage` investigates user-reported problems, bugs, gaps, duplicates,
  and evidence, then creates or updates GitHub issue records.
- `state-of-union` reconciles approved project intent, backlog reality,
  architecture, drift, delivery state, gates, and runtime health into an
  execution strategy before sprint planning or after outcome closure.

Both skills can identify weak or missing GitHub issue fields. Without an
explicit action boundary, agents can either route tactical bug triage through a
strategic lifecycle review, or use tactical issue investigation as a parallel
strategy planner.

## Decision

Use `issue-triage` as the standalone tactical path for converting reported
problems into GitHub-native backlog records. It is appropriate for:

- user-reported product or code problems;
- bugs, product gaps, duplicate searches, and related-issue searches;
- evidence audits against code, docs, logs, tests, or issue history;
- direct issue-template creation or update when the user or repository policy
  grants that authority.

Use `state-of-union` as the lifecycle strategic path for reconciling approved
intent against delivery reality. It owns:

- approved product and architecture intent versus current GitHub backlog;
- backlog, architecture, sprint, gate, deployment, runtime, and review drift;
- issue classification for the next execution strategy;
- proposed issue, dependency, gate, diagnostic, or route actions needed before
  sprint planning, orchestration, integration, release verification, or the next
  lifecycle handoff.

`issue-triage` remains outside the lifecycle graph. It is not returned as the
next lifecycle handoff by `project-router`, `state-of-union`, or downstream
lifecycle skills. A user may invoke it directly for tactical issue work, and its
results may later become input evidence for a lifecycle strategy review.

## GitHub Issue Action Rule

For shared GitHub issue fields such as problem, outcome, acceptance intent,
dependencies, risk, and evidence:

- `issue-triage` creates or updates GitHub Issues directly when it is operating
  as the authorized tactical investigation path.
- `state-of-union` creates or updates GitHub Issues only when repository policy
  or the user grants direct write authority for that strategic review.
- When write authority is absent, or when the change depends on approved
  strategy, `state-of-union` records proposed GitHub issue actions in the
  strategy artifact instead of mutating issues directly.
- Neither skill stores an alternative private backlog. GitHub remains the
  backlog control plane, while strategy artifacts record strategic proposals and
  rationale until they are applied.

## Handoff Examples

A user provides a list of broken behaviors, possible duplicates, or product
gaps. Use `issue-triage` to search existing issues, inspect evidence, and create
or update one GitHub issue per confirmed problem. If the investigation discovers
broader sequencing or architecture drift, record that as related evidence or a
new proposed issue rather than turning the triage session into sprint planning.

A repository has a stale backlog after North Star, architecture, delivery, or
runtime evidence changes. Use `state-of-union` to classify issues, identify
missing or weak records, record proposed GitHub issue actions, and recommend the
next lifecycle handoff. If one proposed action needs detailed bug investigation,
that can become a standalone `issue-triage` invocation, but it is not a
lifecycle handoff.

## Consequences

- Tactical problem intake can update GitHub quickly without forcing a full
  lifecycle strategy review.
- Strategic backlog reconciliation remains tied to approved intent, drift, and
  readiness for sprint planning or later lifecycle phases.
- Duplicate issue edits are avoided by separating direct tactical authority from
  strategic proposed actions when authority or approved strategy is not present.
- The lifecycle graph stays stable: `state-of-union` may hand off to planning,
  orchestration, release verification, architecture, project definition, or a
  gate, but not to standalone `issue-triage`.
