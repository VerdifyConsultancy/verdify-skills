# independent-critic

**Lifecycle order:** 18 · **Modes:** `lane-review`, `evidence-review`, `risk-review` · **Owns schemas:** `critic-report`

> Fresh-context, evidence-based review of a completed lane against its issue, contracts, diff, tests, CI, and worker closeout.

## Purpose

The **adversarial reviewer**. From a fresh session with no hidden worker context, it
reconstructs the intended behavior independently and judges a finished lane against
its issue, requirements/design criteria, module and lane contracts, diff, evidence,
and CI. It must **never reuse the worker's agent, session, or worktree**: a
separate detached review worktree checked out at closeout-only evidence head E
verifies the exact revision. The critic reviews the lane, then commits only the
canonical report as final lane head S; it does not become its implementer or
approve its own report commit.

## When to use / when not

- **Use** after a `lane-delivery` worker closeout (`status: ready_for_critic`) and
  before review-inbox packet assembly or integration.
- **Not** to write lane code, alter implementation I or closeout E, reuse the
  worker agent/session/worktree, submit the advancing approval as the PR author,
  or make protected design decisions. Its only lane-branch write is the
  canonical critic report commit S.

## Position in the loop

The gate of **VERIFY**. A fresh critic starts at E, independently reconstructs
the worker's validated I and closeout-only suffix, then commits only its report as
S. A distinct repository admin or maintainer other than the PR author must submit
the latest effective `APPROVED` GitHub review on S before the lane can advance.

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
| Module + lane contracts and dispatch-only D | `module-contract`, `lane-contract`, Git | `architecture-contracts`, `sprint-planning`, `sprint-orchestrator` |
| PR diff + commits, implementation I, closeout-only E, and required checks | GitHub | `lane-delivery`, CI |
| Worker closeout + worker agent/session + evidence; deployment/migration implications | `lane-closeout.schema.yaml` | `lane-delivery` |

## Outputs (produced)

| Output | Schema | Consumed by |
|---|---|---|
| Critic-report-only final lane commit S containing `.agent-workflow/sprints/<sprint-id>/critic/<lane-id>.critic.yaml` | `critic-report.schema.yaml` | `sprint-orchestrator`, `release-verification`, session ledger |
| Separate commit-bound GitHub review by an authorized admin/maintainer who is not the PR author | GitHub | review packet, integration gate |

## Sequence

```mermaid
sequenceDiagram
    participant LD as lane-delivery closeout
    participant IC as independent-critic
    participant WT as detached review worktree
    participant GH as GitHub PR + checks
    participant Art as .agent-workflow critic/
    LD-->>IC: dispatch D, contract, PR, I, E, closeout, worker identity
    IC->>WT: fresh critic agent/session, detached checkout = E
    IC->>IC: verify D is dispatch-only; I..E changes only canonical closeout
    IC->>GH: review implementation I + checks and closeout E
    IC->>IC: validate scope, behavior, evidence freshness, integration risk
    IC->>IC: classify each finding by severity with concrete citations
    IC->>Art: write report with I/E + identity backlinks
    IC->>GH: commit only report as S and push
    GH-->>GH: distinct admin/maintainer submits APPROVED on S
```

## Gates & stop conditions

Work in a **separate detached review worktree**; both the **critic agent and
session must differ** from the worker identity recorded in the closeout. Review
starts at E; I..E may change only the closeout, and E..S may change only the
critic report. The external reviewer must have repository `admin` or `maintain`
permission and must not be the PR author. Any later commit or later effective
change-request invalidates approval. Outcomes:
`approve`, `approve_with_risks`, `request_fixes`, `block_integration`,
`needs_human_review`. Do not submit a GitHub review while any material scope,
security, migration, deployment, or human-only approval gate stays open.

## Tools used

- **CLI:** `bin/verdify lane review` (create/verify the detached review worktree and
  bind the critic session) — see [tools-and-mcp](../tools-and-mcp.md).
- **GitHub:** read issue/PR/check state; after S, an authorized external reviewer
  uses `gh pr review --approve | --request-changes --body-file <body>`.

## Handoffs

- **Upstream:** `lane-delivery` closeout (contract, PR, I, E, closeout, evidence,
  worker agent/session).
- **Downstream:** `sprint-orchestrator`, then `release-verification` review-inbox
  packet mode after S has a distinct admin/maintainer approval; or back to
  `lane-delivery` (via the
  orchestrator) for `request_fixes` / `block_integration`. A material contract problem
  routes to `sprint-planning` or `architecture-contracts`.

## References

- `skills/independent-critic/SKILL.md`, `references/critic-rubric.md`,
  `references/evidence-review.md`, `assets/critic-report.template.yaml`
- [lane-delivery](./lane-delivery.md), [controller-loop](./controller-loop.md),
  [schemas catalog](../schemas-catalog.md), [tools & MCP](../tools-and-mcp.md)
