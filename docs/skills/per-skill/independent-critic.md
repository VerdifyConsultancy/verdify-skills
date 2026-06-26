# independent-critic

**Lifecycle order:** 18 · **Modes:** `lane-review`, `evidence-review`, `risk-review` · **Owns schemas:** `critic-report`

> Fresh-context, evidence-based review of a completed lane against its issue, contracts, diff, tests, CI, and worker closeout.

## Purpose

The **adversarial reviewer**. From a fresh session with no hidden worker context, it
reconstructs the intended behavior independently and judges a finished lane against
its issue, requirements/design criteria, module and lane contracts, diff, evidence,
and CI. It must **never reuse the worker's session or worktree**: a separate detached
review worktree checked out at the current PR head SHA verifies the exact revision.
The critic reviews the lane; it does not become its implementer.

## When to use / when not

- **Use** after a `lane-delivery` worker closeout (`status: ready_for_critic`) and
  before review-inbox packet assembly or integration.
- **Not** to write lane code, edit or commit to the worker branch, re-run the
  worker's session, or make protected design decisions.

## Position in the loop

The gate of **VERIFY**. A fresh critic session runs after worker closeout and before
integration, reviewing the lane at its current PR head SHA, then routes the outcome
back to fixes or forward to release verification.

## Modes

| Mode | What it does |
|---|---|
| `lane-review` | Validate scope/ownership, contract and issue alignment, functional correctness per `references/critic-rubric.md`. |
| `evidence-review` | Assess evidence credibility, revision freshness, and false-positive risk per `references/evidence-review.md`; reject narrative-only proof. |
| `risk-review` | Surface architecture drift, integration/deployment/migration risk, and residual risks; classify findings by severity. |

## Inputs (consumed)

| Input | Schema / source | From |
|---|---|---|
| GitHub issue + dependencies | issue/links | GitHub control plane |
| Approved requirements / design criteria | `project-definition` | upstream lifecycle |
| Module + lane contracts | `module-contract`, `lane-contract` | `architecture-contracts`, `sprint-planning` |
| PR diff + commits, required checks + current head SHA | GitHub | `lane-delivery`, CI |
| Worker closeout + evidence; deployment/migration implications | `lane-closeout.schema.yaml` | `lane-delivery` |

## Outputs (produced)

| Output | Schema | Consumed by |
|---|---|---|
| `.agent-workflow/sprints/<sprint-id>/critic/<lane-id>.critic.yaml` | `critic-report.schema.yaml` | `sprint-orchestrator`, `release-verification`, session ledger |
| Optional GitHub review submission (approve / request-changes / comment) | GitHub | PR, integration |

## Sequence

```mermaid
sequenceDiagram
    participant LD as lane-delivery closeout
    participant IC as independent-critic
    participant WT as detached review worktree
    participant GH as GitHub PR + checks
    participant Art as .agent-workflow critic/
    LD-->>IC: contract, PR, head SHA, closeout, evidence
    IC->>WT: lane review (fresh session, checkout = PR head SHA)
    IC->>IC: confirm critic session != worker; no edits to worker branch
    IC->>GH: review diff, commits, required checks at head SHA
    IC->>IC: validate scope, behavior, evidence freshness, integration risk
    IC->>IC: classify each finding by severity with concrete citations
    IC->>Art: write <lane-id>.critic.yaml + set outcome
    IC->>GH: submit PR review (only when authorized)
```

## Gates & stop conditions

Work in a **separate detached review worktree**; the **critic session must differ
from the worker session**; review at the **current PR head SHA**; **do not edit or
commit to the worker branch**. Any new commit invalidates a prior approval. Outcomes:
`approve`, `approve_with_risks`, `request_fixes`, `block_integration`,
`needs_human_review`. Do not submit a GitHub review while any material scope,
security, migration, deployment, or human-only approval gate stays open.

## Tools used

- **CLI:** `bin/verdify lane review` (create/verify the detached review worktree and
  bind the critic session) — see [tools-and-mcp](../tools-and-mcp.md).
- **GitHub:** read issue/PR/check state; `gh pr review --approve | --request-changes
  | --comment --body-file <body>` when authorized.

## Handoffs

- **Upstream:** `lane-delivery` closeout (contract, PR, head SHA, closeout, evidence).
- **Downstream:** `sprint-orchestrator`, then `release-verification` review-inbox
  packet mode when dependencies are ready; or back to `lane-delivery` (via the
  orchestrator) for `request_fixes` / `block_integration`. A material contract problem
  routes to `sprint-planning` or `architecture-contracts`.

## References

- `skills/independent-critic/SKILL.md`, `references/critic-rubric.md`,
  `references/evidence-review.md`, `assets/critic-report.template.yaml`
- [lane-delivery](./lane-delivery.md), [controller-loop](./controller-loop.md),
  [schemas catalog](../schemas-catalog.md), [tools & MCP](../tools-and-mcp.md)
