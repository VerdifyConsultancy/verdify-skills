# lane-delivery

**Lifecycle order:** 17 · **Modes:** `implementation`, `closeout`, `fix-forward` · **Owns schemas:** `lane-closeout`

> Implement and close out one approved lane contract inside one leased Git worktree and one coding-agent session.

## Purpose

The **bounded worker**. Given one approved lane (issue, contract, branch, worktree,
lease), it implements only that lane, runs required validation, updates the linked PR,
and writes a worker closeout for fresh criticism — in the same session. Its output is
a candidate for review, never a self-certified completion.

## When to use / when not

- **Use** only when assigned a specific lane, issue, contract, branch, worktree, and
  lease; also for contract-scoped fixes requested by an `independent-critic`.
- **Not** to expand scope, pick up "while I'm here" work, review its own work, or run
  without an active lease that belongs to this session.

## Position in the loop

The hands of **EXECUTE**. Dispatched by `sprint-orchestrator`; hands closeout to
`independent-critic` and ledger events to `controller-loop`.

## Modes

| Mode | What it does |
|---|---|
| `implementation` | Work only inside the leased worktree and owned paths; incremental validation; one PR. |
| `closeout` | Final worker action: capture validation results, map evidence to acceptance criteria, write closeout `ready_for_critic`. |
| `fix-forward` | After critic findings, take a new sequential lease for the same worktree and address only cited findings. |

## Inputs (consumed)

| Input | Schema / source | From |
|---|---|---|
| Lane contract (scope, owned/prohibited paths, AC, validation) | `lane-contract` | `sprint-planning` |
| Module contracts | `module-contract` | `architecture-contracts` |
| Active lease + worktree | `lane-lease` (`bin/verdify lane inspect`) | `sprint-orchestrator` |
| Operating contract + worker procedure | `COMMON_OPERATING_CONTRACT.md`, `references/worker-procedure.md` | repo |

## Outputs (produced)

| Output | Schema | Consumed by |
|---|---|---|
| Commits on the lane branch + one linked PR | GitHub | `independent-critic`, integration |
| `…/lanes/closeout/<lane-id>.closeout.yaml` (`status: ready_for_critic`) | `lane-closeout.schema.yaml` | `independent-critic`, `project-router` |
| Proposed GitHub issue for discovered work | issue template | backlog |

## Sequence

```mermaid
sequenceDiagram
    participant SO as sprint-orchestrator
    participant LD as lane-delivery
    participant WT as leased worktree
    participant GH as GitHub PR
    participant IC as independent-critic
    SO-->>LD: lane assignment + lease-id
    LD->>WT: lane inspect (confirm ownership) + reconstruct code/tests
    LD->>WT: implement owned paths only, validate incrementally
    LD->>GH: create/update PR linked to issue + contract
    LD->>LD: closeout — map evidence to each acceptance criterion
    LD->>GH: push; write closeout (status ready_for_critic)
    LD-->>IC: hand off contract, PR, head SHA, closeout, evidence
```

## Gates & stop conditions

Stop and open a gate for missing upstream contracts, public API/schema changes,
migrations, security-boundary changes, destructive operations, new privileged
dependencies, ownership conflicts, or acceptance criteria that cannot be met as
written. Stop if the lease is not owned by this session or the contract is
stale/unapproved. Worker lanes never inherit or request production credentials.

## Tools used

- **CLI:** `bin/verdify lane inspect`; `bin/verdify lane release --keep-worktree`
  (fix-forward hand-back).
- **Git/GitHub:** lane branch commits, one linked PR.
- **Build tools:** the contract's required validation commands, run in the lease's
  isolated namespace (db/container/cache/port).

## Handoffs

- **Upstream:** `sprint-orchestrator` (assignment + lease).
- **Downstream:** `independent-critic` (fresh review) + `controller-loop`
  (session-ledger events). Fix-forward returns to fresh criticism.

## References

- `skills/lane-delivery/SKILL.md`, `references/worker-procedure.md`,
  `references/scope-change.md`, `references/closeout-procedure.md`
- [ADR-0003](../../decisions/ADR-0003-worktree-leases.md)
