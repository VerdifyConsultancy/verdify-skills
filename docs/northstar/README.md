# Skills North Star Evidence

This directory records planning evidence for the Verdify skills repository. It is
not the approved North Star by itself. Future `project-definition`,
`architecture-contracts`, and `state-of-union` passes should treat these records
as source inputs and reconcile them into canonical `.agent-workflow` artifacts,
ADRs, GitHub Issues, and implementation plans.

Evidence entries must preserve their status. Reported transcript evidence can
support proposed decisions and requirements. Ordinary planning questions should
restart the North Star evidence/research/design loop; final approval is required
only when locking the North Star for the next milestone.

## Machine-Readable Registry

New research should be registered through:

```bash
bin/verdify northstar ingest-research --repo <repo> --file <research-file> --title "<title>" --summary "<why it matters>"
```

The command writes:

- `.agent-workflow/northstar/evidence-registry.yaml`
- `.agent-workflow/northstar/collateral/<evidence-id>.yaml`
- `.agent-workflow/northstar/collateral/sources/<evidence-id>-<source-name>`

Registered evidence is referenced as `northstar://evidence/<evidence-id>` and
queried with `bin/verdify northstar evidence list`.

## Evidence Ledger

| Source ID | Pinned at | Source date | Status | Evidence | North Star impact |
| --- | --- | --- | --- | --- | --- |
| `SRC-NS-001` | 2026-06-23 | Not provided | Reported transcript extraction | [Walk transcript: Agent Platform, Gravity, and Skills](evidence/2026-06-23-walk-transcript-agent-platform-gravity-skills.md) | Establishes a reported Gravity readiness gate and expands the skills North Star around protected planning, transcript intake, repo hygiene, wave orchestration, deployed review, observability, and cross-repo platform readiness. |
| `SRC-NS-002` | 2026-06-25 | 2026-06-25 | Reported transcript extraction | `northstar://evidence/NSE-20260625-walk-transcript-delivery-loop-topology` | Defines the wave/loop/lane delivery topology, the North Star -> milestone -> wave -> user story -> issue traceability spine, and the per-wave human review cadence. |
| `SRC-NS-003` | 2026-06-25 | 2026-06-25 | Reported adversarial review | `northstar://evidence/NSE-20260625-recommended-event-driven-sdlc-control-plane` | Reconciles topology and operating contract: wave envelope on a deterministic control plane, reconciler controller, dynamic lanes, vendor-neutral worker adapter, rolling-wave planning, two-tier verification, and an M0-M8 build order. Source for ADR-0011 through ADR-0018. |

## Current Reconciliation Notes

- `SRC-NS-001` should be consumed by the next `project-definition` discovery pass
  through `.agent-workflow/northstar/northstar-plan.yaml`.
- `northstar-planning` now owns the loop that turns registered research,
  ideation, requirements, PRDs, user stories, milestones, waves, surfaces,
  architecture stories, architecture requirements, risks, conflicts, and gates
  into `NORTHSTAR_PRODUCT.md`, `NORTHSTAR_ARCHITECTURE.md`, and
  `northstar-artifacts.yaml` before project definition and architecture consume
  them.
- It should not be treated as `DESIGN_COMMITTED` evidence by itself.
- It introduced an explicit conflict with the prior default identity model (one
  issue equals one lane/branch/worktree/session/PR versus one branch per wave).
  **Resolved 2026-06-25** by ADR-0013 (a lane is a dynamic per-wave
  write-conflict partition; one active writer per worktree/branch, with ADR-0003
  isolation retained) and ADR-0011 (the wave is the versioned delivery envelope
  with a wave integration branch). Tracked as `NSQ-002` (resolved).
- It raises planning questions for branch identity, RBAC, secrets handling, wave
  taxonomy, rollback signals, and controller versus specialist infrastructure
  ownership. These questions feed the planning loop unless final North Star lock
  approval or unsafe access is required.
