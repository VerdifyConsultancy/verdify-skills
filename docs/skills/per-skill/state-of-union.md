# state-of-union

**Lifecycle order:** 10 · **Modes:** `strategy-review`, `comprehensive-replan`, `strategy-refresh`, `health-triage`, `gate-resolution` · **Owns schemas:** `state-of-union`, `github-backlog-sync`

> Reconcile the GitHub backlog and delivery reality against the north-star goal and produce an actionable execution strategy.

## Purpose

Owns the **strategy reconciliation contract**. It reconstructs approved intent, source
freshness, planning reality, and delivery/runtime reality, classifies every open issue
against the goal, surfaces drift as durable actions, and emits a typed strategy record
with a recommended sequence and a next-sprint candidate set. It plans; it never carves
lanes or writes code.

## When to use / when not

- **Use** after foundations are approved and before `sprint-planning`, after a sprint or
  outcome closes, for full triage/replanning, or when docs, architecture, issues, gates,
  runtime health, and delivery may be drifting apart.
- **Not** for sprint plans, lane maps/contracts, branches, worktrees, or PRs, nor editing
  architecture/definition directly — those belong to `sprint-planning`, `lane-delivery`,
  `architecture-contracts`, and `project-definition`.

## Position in the loop

The strategy hinge of **PLAN**: it consumes approved foundations and live GitHub state,
then names exactly one downstream handoff the router consumes once the strategy is
approved and current — the only skill that reconciles backlog intent against runtime
health before a sprint is selected.

## Modes

| Mode | What it does |
|---|---|
| `strategy-review` | Default reconciliation: rebuild intent, sources, planning, delivery; classify issues; emit `recommended_sequence` and `next_sprint_candidates`. |
| `comprehensive-replan` | Full triage per `references/comprehensive-operating-replan.md` — in/deferred/owned/reviewable, plus health review and replanning. |
| `strategy-refresh` | Re-validate a prior strategy against current source freshness and delivery state without a full rebuild. |
| `health-triage` | Gather deployment/log/telemetry health evidence separately and convert discovered health work into tracked GitHub issues. |
| `gate-resolution` | Open or resolve a `strategy` gate when priority, acceptance authority, ownership, dependency, or risk is unresolved. |

## Inputs (consumed)

| Input | Schema / source | From |
|---|---|---|
| Approved product intent | `NORTHSTAR_PRODUCT.md`, project definition | `project-definition`, North Star |
| Architecture + module contracts | `NORTHSTAR_ARCHITECTURE.md`, `module-contract` | `architecture-contracts` |
| GitHub backlog | Issues / PRs / checks / gates | GitHub (or `.agent-workflow/github/snapshot.json` cache) |
| Sprint + outcome history | `sprint-plan`, review packets, outcome records | prior lifecycle |
| Deployment / log health | diagnostic packet, runtime evidence | `release-verification` |

## Outputs (produced)

| Output | Schema | Consumed by |
|---|---|---|
| `.agent-workflow/strategy/state-of-union.yaml` (with `next_sprint_candidates`) | `state-of-union.schema.yaml` | `sprint-planning`, router |
| `.agent-workflow/strategy/github-backlog-sync.yaml` (optional) | `github-backlog-sync.schema.yaml` | `sprint-orchestrator`, `release-verification` |

## Sequence

```mermaid
sequenceDiagram
    participant Art as ".agent-workflow + North Star"
    participant SoU as state-of-union
    participant GH as "GitHub control plane"
    participant RV as release-verification
    Art->>SoU: reconstruct intent, planning, delivery reality
    SoU->>GH: read live issues / PRs / checks / deployments
    GH-->>SoU: backlog + delivery state (or cached snapshot)
    SoU->>RV: request observability diagnostics (health-triage)
    RV-->>SoU: runtime / log health findings
    SoU->>SoU: classify issues, identify drift, draft actions
    SoU->>Art: write state-of-union.yaml + optional github-backlog-sync.yaml
    SoU->>SoU: validate against schemas; name one handoff
```

## Gates & stop conditions

An approved state-of-union must have **no open blocking gaps**; while gaps or unresolved
approval requirements remain, open a `strategy` gate instead of approving. A
`sprint-planning` handoff requires a populated `next_sprint_candidates` set with
prerequisites ready. Stop and route when live GitHub and a snapshot disagree on material
state, a lane references a missing/duplicate issue, or write authority is required but
not granted.

## Tools used

- **CLI:** `bin/verdify github snapshot` / `github reconcile` (refresh and reconcile the
  cached backlog); `bin/verdify artifact validate --file PATH [--schema PATH]` validates
  the strategy and backlog-sync artifacts — see [tools-and-mcp](../tools-and-mcp.md).
- **GitHub:** read issues, PRs, checks, deployments, Projects/milestones, dependencies.

## Handoffs

- **Upstream:** `project-definition`, `architecture-contracts` (approved foundations);
  `release-verification` (diagnostic packets, outcome records).
- **Downstream:** [`sprint-planning`](./sprint-planning.md) when candidates are ready;
  [`repo-hygiene`](./repo-hygiene.md) and readiness skills
  ([`platform-readiness`](./platform-readiness.md), [`gravity-readiness`](./gravity-readiness.md))
  when the standard must be met first; [`release-verification`](./release-verification.md)
  for integration/deployment/outcome blockers; [`issue-triage`](./issue-triage.md) for
  `missing` work needing GitHub issue creation.

## References

- `skills/state-of-union/SKILL.md`, `references/comprehensive-operating-replan.md`,
  `references/issue-reconciliation.md`, `references/github-backlog-sync.md`,
  `references/handoff-rules.md`
- [schemas catalog](../schemas-catalog.md) · [tools and MCP](../tools-and-mcp.md)
