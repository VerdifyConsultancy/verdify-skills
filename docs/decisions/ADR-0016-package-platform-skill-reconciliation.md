# ADR-0016: Reconcile package and platform skill contracts

- Status: accepted
- Date: 2026-06-24
- Resolves: GitHub issue #36, NSQ-007

## Context

`verdify-skills` defines the portable lifecycle method for project routing,
North Star planning, sprint planning, lane delivery, criticism, review,
release verification, and readiness gates. It also defines promoted artifact
contracts such as:

- `session-ledger.yaml`, owned by `controller-loop`, for lifecycle session and
  event traceability;
- `review-inbox-packet.yaml`, owned by `release-verification`, for review-ready
  evidence bundles;
- `agent-platform-control-request.yaml`, owned by `platform-readiness`, for
  proposed Agent Platform operations, authorization, policy, and result refs.

The `jvallery/agents` Agent Platform Skills Fleet is the runtime system that
hosts controller cells, repo pods, dashboard/API control, and MCP worktree
tools. Its approved Skills Fleet program identifies platform-native contracts
for:

- `loop-runtime` and `loop-state` for durable controller runtime continuity;
- `consensus-review` and `consensus-report`, plus PR-native review, for
  platform review consensus;
- the dashboard/API/MCP worktree control path, including the real
  `add_worktree_agent` operation, for dispatching worktree agents.

Without an explicit boundary, a worker can follow the package skills and
produce package artifacts that the platform does not consume, while the
platform can evolve native skill contracts that the package does not reference.

## Decision

Use a layered ownership model:

| Surface | Authoritative system | Verdify Skills responsibility | Agent Platform responsibility |
| --- | --- | --- | --- |
| Durable controller state: `session-ledger` vs `loop-state` | Agent Platform is authoritative for runtime controller continuity through `loop-runtime` and `loop-state`. | Own portable lifecycle audit evidence in `session-ledger.yaml`: sessions, events, refs, checks, handoffs, and exceptions. When running on Agent Platform, cite or mirror platform `loop-state` refs instead of treating `session-ledger` as the live runtime state. | Own the live controller recovery record, context-reset continuity, bring-up outstanding-work state, and controller-cell loop telemetry in `loop-state`. |
| Review: `review-inbox-packet` vs `consensus-review`/PR-native review | Agent Platform is authoritative for platform-native consensus through `consensus-review`, `consensus-report`, and PR reviews. | Own the review-ready evidence packet in `review-inbox-packet.yaml`: exact SHA, checks, deployments, telemetry, risks, rollback, human test steps, and links to critic or consensus evidence. Consume/link platform `consensus-report` when present. | Own multi-party consensus, vote records, cross-model/lane-owner signoff, and PR-native review state for platform work. |
| Control dispatch: `agent-platform-control-request` vs MCP/API `add_worktree_agent` | Agent Platform is authoritative for actual dispatch through dashboard/API/MCP operations, including `add_worktree_agent`. | Own the pre-execution request envelope in `agent-platform-control-request.yaml`: requested operation, target, authorization, policy verdict, expected effects, review gate, rollback/recovery, and observed result refs. Do not execute or simulate dispatch by writing package artifacts alone. | Own the callable, idempotent, repo-scoped worktree/session operation and resulting runtime state through the dashboard/API/MCP control path. |

The package artifacts remain valid and useful, but they are planning,
governance, evidence, or request records. They do not replace platform runtime
contracts when the work is executed inside `jvallery/agents`.

When this package drives the Agent Platform:

1. `controller-loop` records lifecycle-significant events in the
   `session-ledger`, then links or mirrors the Agent Platform `loop-state`
   record that controls runtime continuation.
2. `release-verification` assembles a `review-inbox-packet` for human review,
   but platform-native consensus evidence is a linked `consensus-report` and
   PR review state, not a competing verdict.
3. `sprint-orchestrator` and `platform-readiness` create or consume
   `agent-platform-control-request` records before protected operations, then
   dispatch only through the platform MCP/API operation such as
   `add_worktree_agent` after authorization and policy evidence are present.

NSQ-007 is resolved for this package boundary as follows:

- Verdify Skills owns lifecycle contracts, portable `.agent-workflow`
  artifacts, planning/review/readiness schemas, and the method for moving work
  from issue to lane to critic to release evidence.
- Agent Platform owns runtime/control APIs, controller cells, k3s/source
  control/CI/CD operational integration, loop runtime state, platform-native
  consensus review, and actual MCP/API dispatch.
- Hermes/OpenClaw owns higher-level conversation and planning orchestration,
  constrained to call the package and platform through their approved artifact,
  API, and MCP surfaces.
- Gravity owns reusable file-to-knowledge and evidence ingestion, plus
  customer packs, and remains gated by platform and Gravity readiness before
  implementation work.

## Consequences

- This ADR is documentation-only. It does not edit skills, schemas, or platform
  code, and it does not implement the mappings above.
- Follow-up code or documentation lanes may update affected skills to cite the
  platform contracts and implement explicit mapping from `session-ledger` to
  `loop-state`, from `review-inbox-packet` to `consensus-report`/PR review
  refs, and from `agent-platform-control-request` to MCP/API dispatch refs.
- A vendored copy of `verdify-skills` inside `jvallery/agents` is a consumer of
  this package. Platform-native extensions are not automatically upstream
  package authority until accepted through this repository's issue, ADR, schema,
  and PR process.
- If the Agent Platform API/MCP operation is unavailable, a controller or
  orchestrator must route to platform readiness or an explicit gate instead of
  silently spawning an ad hoc local worker.
