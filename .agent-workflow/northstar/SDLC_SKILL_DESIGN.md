# SDLC Skill Design

Status: `proposed`
Date: `2026-06-23`
Repository: `verdify-skills`
Planning authority: current draft North Star, iteration `21`

This design answers the current planning question: based on the draft North
Star, what skills are needed to fully implement the Verdify SDLC loops and
expose them through an external OpenClaw planning agent?

Detailed OpenClaw workflow artifact:
`.agent-workflow/northstar/OPENCLAW_SDLC_WORKFLOW_SKILLS.md`.

The answer is not "create a large new skill for every noun in the plan." The
current 18-lifecycle-skill kernel, plus standalone `issue-triage`, is the right
base. OpenClaw should expose a smaller set of user-facing SDLC workflow skills
that delegate into that kernel. The missing
work is to add explicit skill coverage for review aggregation, wave release
planning, diagnostics, ledger behavior, Agent Platform control actions, and
learning capture, while keeping low-evidence ideas as modes until repeated use
proves they deserve a first-class skill.

## Design Position

Verdify Skills should keep the existing 18 canonical lifecycle skills as the
installable kernel, with `issue-triage` remaining standalone:

1. `project-router`
2. `transcript-replan`
3. `northstar-research-ingest`
4. `northstar-planning`
5. `northstar-interview`
6. `northstar-question-resolution`
7. `project-definition`
8. `architecture-contracts`
9. `state-of-union`
10. `repo-hygiene`
11. `sprint-planning`
12. `sprint-orchestrator`
13. `controller-loop`
14. `platform-readiness`
15. `gravity-readiness`
16. `lane-delivery`
17. `independent-critic`
18. `release-verification`

The full SDLC loop needs six promoted capabilities next. These should start as
explicit artifacts or modes where possible, then become top-level skills only
after they have stable input/output contracts and at least one reliable manual
run:

1. `review-inbox` - first packet/schema contract added under
   `release-verification`
2. `wave-release-planning` - first plan/schema contract added under
   `sprint-planning`
3. `observability-diagnostics` - first diagnostic packet/schema contract added
   under `release-verification`
4. `session-ledger` - first ledger/schema contract added under
   `controller-loop`
5. `agent-platform-control` - first request/schema contract added under
   `platform-readiness`
6. `learning-capture` - first proposal schema/reference/template contract added
   under `northstar-planning`

Three additional capabilities should stay mode-first for now:

1. `github-backlog-sync` - first sync/schema contract added under
   `state-of-union`
2. `environment-gitops` - first reconciliation/schema contract added under
   `platform-readiness`
3. `gravity-core-extraction` - first extraction-plan/schema contract added
   under `gravity-readiness`

## OpenClaw Workflow Exposure

OpenClaw should be the external conversational and planning layer for these
workflows. It should not be the deterministic controller, backlog authority, or
approval system. The OpenClaw-facing skills should be coarse workflow entry
points that call Verdify lifecycle skills, Agent Platform MCP/API tools, and
GitHub primitives.

| OpenClaw workflow skill | Delegated Verdify skills / modes | GitHub primitives | Completion evidence |
| --- | --- | --- | --- |
| `sdlc-bootstrap-repo` | `project-router`, `repo-hygiene` | repository, labels, issue templates | route decision, validator result, hygiene findings |
| `sdlc-ideation-intake` | `transcript-replan`, `northstar-research-ingest` | issues, discussion, source links | routed intake, evidence items, questions |
| `sdlc-northstar-loop` | `northstar-planning`, `northstar-interview` | decision/review issues | product/architecture North Star, interview packet |
| `sdlc-definition-architecture` | `project-definition`, `architecture-contracts` | scope issues, ADR issues | project definition, contracts, ADRs |
| `sdlc-backlog-strategy` | `state-of-union`, `project-router`, `github-backlog-sync` | issues, sub-issues, dependencies, milestones/projects | strategy, `github-backlog-sync.yaml`, candidate wave |
| `sdlc-readiness-gates` | `repo-hygiene`, `platform-readiness`, `gravity-readiness`, `environment-gitops`, `gravity-core-extraction` | gate issues, environment checks | readiness artifacts, environment GitOps reconciliation, Gravity core extraction plan, and pass/block verdicts |
| `sdlc-wave-planning` | `sprint-planning`, `wave-release-planning` | milestone/project, lane issues, branch plan | sprint plan, lane contracts, CI/CD and rollback plan |
| `sdlc-lane-dispatch` | `sprint-orchestrator`, `controller-loop`, `lane-delivery`, `session-ledger` | assigned issues, branches, PR skeletons | leases, prompt manifests, ledger entries |
| `sdlc-review-inbox` | `independent-critic`, `review-inbox`, `observability-diagnostics` | PRs, checks, deployments, reviews | critic report, review packet, diagnostics |
| `sdlc-release-path` | `release-verification`, `environment-gitops`, `observability-diagnostics` | merge, tag, release, deployment, environment | deployment proof, environment GitOps reconciliation, rollback proof, outcome record |
| `sdlc-learning-capture` | `learning-capture`, `northstar-planning` | improvement issues | `NLP-*` proposal packet and follow-up route |

The detailed skill contracts, stakeholder map, milestones, and governance rules
live in `OPENCLAW_SDLC_WORKFLOW_SKILLS.md`.

## SDLC Loop Coverage

| Loop | Purpose | Current coverage | Missing or weak capability | Design decision |
| --- | --- | --- | --- | --- |
| Intake and evidence | Convert transcripts, research, and context into registered evidence. | `transcript-replan`, `northstar-research-ingest`, `northstar-planning` | Queryable evidence use is present but still early. | Keep current skills; add evidence query improvements to CLI, not a new skill. |
| North Star planning | Distill evidence, answer questions, propose research, update drafts, and request final lock approval only when ready. | `northstar-planning`, `northstar-interview` | Learning from sessions is staged but not yet a standalone loop. | Promote `learning-capture` after redaction/source policy and one manual proof. |
| Definition and architecture | Turn approved intent into project definition, architecture, and contracts. | `project-definition`, `architecture-contracts` | Responsibility split among Skills, Agent Platform, Hermes/OpenClaw, and Gravity remains open. | Continue through North Star artifact loop; no new skill yet. |
| Strategy and backlog | Reconcile North Star, GitHub, artifacts, and current delivery state. | `state-of-union`, `project-router` | First typed backlog sync artifact exists; CLI snapshot/reconcile remains a cache/report helper. | Keep `github-backlog-sync` as a state-of-union mode until repeated manual use proves it should be promoted. |
| Readiness | Prove repo, platform, and Gravity prerequisites before implementation. | `repo-hygiene`, `platform-readiness`, `gravity-readiness` | First environment GitOps reconciliation artifact exists; first Gravity core extraction plan artifact exists; production and Gravity feature mutation remain outside these artifacts. | Keep `environment-gitops` and `gravity-core-extraction` as readiness modes until repeated manual use proves either should be promoted. |
| Wave planning | Select bounded implementation work with contracts, ownership, traceability, tests, and delivery path. | `sprint-planning`, `architecture-contracts` | CI/CD wave deployment is required by `PRQ-006` but not yet a dedicated planning skill. | Add `wave-release-planning` as the first delivery-design promotion. |
| Orchestration | Coordinate child sessions, lifecycle state, gates, handoffs, and stop/resume behavior. | `controller-loop`, `sprint-orchestrator` | Session ledger schema and persistence need a sharper owner. | Promote `session-ledger` or make it a controller-loop subskill with its own schema. |
| Implementation | Execute one approved lane in one worktree/session/branch/PR by default. | `lane-delivery` | None at current design level. | Keep as-is; strengthen lease/traceability checks through CLI and schemas. |
| Independent review | Review worker output without self-certification. | `independent-critic` | Cross-lane integration risks need release context. | Keep critic lane-pure; route integration evidence to release/review skills. |
| Release and proof | Integrate, validate, deploy/verify, prove rollback and runtime state, and capture outcome acceptance. | `release-verification` | Review-ready packet and CI/CD wave release design are broader than verifier closeout. | Add `review-inbox`; add `wave-release-planning`; keep final runtime proof in `release-verification`. |
| Operations and diagnostics | Diagnose feedback through code, logs, metrics, traces, deployment markers, and correlation IDs. | `platform-readiness`, `release-verification` | No dedicated diagnostic loop skill exists. | Add `observability-diagnostics`. |
| Platform control | Drive Agent Platform source-control, CI/CD, k3s, session, review, and telemetry operations API/MCP-first. | `platform-readiness`, `controller-loop` | First request/policy artifact exists; actual executor waits for concrete Agent Platform operations and one reliable manual run. | Keep `agent-platform-control` as a platform-readiness contract now; promote to a skill only after API/MCP operations are concrete. |
| Learning and improvement | Mine validated lessons into proposal-only improvements with loop-readiness checks. | `northstar-planning` mode, learning proposal schema | Session source, retention, redaction, and scheduling readiness remain open. | Promote `learning-capture` only after `NSQ-009` is resolved and manual proof exists. |

## Promoted Skill Specifications

### `review-inbox`

Purpose: Build the human review packet for a change or wave.

Current contract status:

- First executable packet shape:
  `schemas/review-inbox-packet.schema.yaml`.
- Owning lifecycle mode for the first manual runs:
  `release-verification` / review inbox packet.
- Operator reference:
  `skills/release-verification/references/review-inbox.md`.
- Template:
  `skills/release-verification/assets/review-inbox-packet.template.yaml`.
- Example:
  `examples/minimal-project/.agent-workflow/sprints/2026-06-22-a/review/review-inbox-packet.yaml`.
- Evidence:
  `northstar://evidence/NSE-20260623-review-inbox-skill-implementation-best-p`.

Inputs:

- North Star IDs, issue IDs, PRs, commits, artifact digests, critic findings,
  CI results, preview or review URLs, test plan, telemetry links, risks,
  migration notes, rollback plan, and open human questions.

Outputs:

- A review-ready packet with recommendation: `approve`, `request_changes`,
  `reject`, or `escalate`.
- Evidence completeness verdict.
- Feedback routing instructions for fix, replan, or signoff.
- Validated `ReviewInboxPacket` artifact with PR/MR identity, exact reviewed
  head SHA, required checks, preview/review deployment, telemetry, security,
  rollback, risks, reviewer guidance, open questions, and feedback route.

Why promote:

- `PRQ-004`, `SURF-004`, and `IFACE-004` make the review inbox a product
  surface, not only a release-verification paragraph.

Start condition:

- Use after `independent-critic` and before `release-verification` outcome
  acceptance, or when a PR/wave claims review-ready status.

Stop condition:

- Packet is complete, or missing evidence is listed as blocking.

### `wave-release-planning`

Purpose: Design the CI/CD path for each wave before implementation starts.

Current contract status:

- First executable plan shape:
  `schemas/wave-release-plan.schema.yaml`.
- Owning lifecycle mode for the first manual runs:
  `sprint-planning` / wave release planning.
- Operator reference:
  `skills/sprint-planning/references/wave-release-planning.md`.
- Template:
  `skills/sprint-planning/assets/wave-release-plan.template.yaml`.
- Example:
  `examples/minimal-project/.agent-workflow/sprints/2026-06-22-a/release/wave-release-plan.yaml`.
- Evidence:
  `northstar://evidence/NSE-20260623-wave-release-planning-implementation-bes`.

Inputs:

- Wave scope, lane contracts, issue/branch/worktree model, target environment,
  GitHub checks, preview namespace policy, promotion path, rollback criteria,
  observability requirements, and release-health signals.

Outputs:

- Wave release plan.
- CI/CD evidence requirements.
- Preview/review deployment contract.
- Promotion and rollback checklist.
- Branch/session/worktree identity recommendation.
- Validated `WaveReleasePlan` artifact with branch/merge model, GitHub checks,
  CI workflows, environments, GitOps desired state, deployment strategy,
  observability, rollback, release-health signals, review handoff, risks, and
  approval.

Why promote:

- `PRQ-006` and `ARQ-006` require CI/CD based wave deployment as a core
  architecture path. It is broader than selecting sprint lanes and earlier than
  deployment verification.

Start condition:

- Use after `sprint-planning` has candidate lane scope and before
  `sprint-orchestrator` dispatches worker sessions.

Stop condition:

- Wave cannot be marked executable until CI, preview/review, promotion,
  rollback, and traceability expectations are explicit.

### `observability-diagnostics`

Purpose: Define and use the telemetry contract for review, release health, and
feedback-driven diagnostics.

Current contract status:

- First executable diagnostic packet shape:
  `schemas/observability-diagnostic-packet.schema.yaml`.
- Owning lifecycle mode for the first manual runs:
  `release-verification` / observability diagnostics.
- Operator reference:
  `skills/release-verification/references/observability-diagnostics.md`.
- Template:
  `skills/release-verification/assets/observability-diagnostic-packet.template.yaml`.
- Example:
  `examples/minimal-project/.agent-workflow/sprints/2026-06-22-a/release/observability-diagnostic-packet.yaml`.
- Evidence:
  `northstar://evidence/NSE-20260623-observability-diagnostics-implementation`.

Inputs:

- Repository/environment profile, deployment markers, logs, metrics, traces,
  dashboards, correlation IDs, user feedback, issue/PR/wave/session IDs, and
  authorized runtime access.

Outputs:

- Standard telemetry checklist.
- Diagnostic hypothesis packet with evidence links.
- Missing-instrumentation findings.
- Release-health and rollback signal assessment.
- Validated `ObservabilityDiagnosticPacket` artifact with scope, correlation
  IDs, hypotheses, telemetry links, signal assessments, runtime checks,
  deployment markers, findings, missing instrumentation, recommendation, and
  feedback route.

Why promote:

- `ARQ-004`, `ARCH-008`, and the review-ready requirement need a repeatable
  diagnostic loop, not ad hoc release prose.

Start condition:

- Use during platform readiness, before review-ready status, after user
  feedback, or when release health is uncertain.

Stop condition:

- Hypotheses are evidence-backed and ranked, or missing telemetry is recorded
  as a blocker.

### `session-ledger`

Purpose: Specify and maintain durable session and wave history independent of
model conversation context.

Current contract status:

- First executable ledger shape:
  `schemas/session-ledger.schema.yaml`.
- Owning lifecycle mode for the first manual runs:
  `controller-loop` / session ledger.
- Operator reference:
  `skills/controller-loop/references/session-ledger.md`.
- Template:
  `skills/controller-loop/assets/session-ledger.template.yaml`.
- Example:
  `examples/minimal-project/.agent-workflow/controller/session-ledger.yaml`.
- Evidence:
  `northstar://evidence/NSE-20260623-session-ledger-implementation-best-pract`.

Inputs:

- Controller session, child sessions, lane leases, prompts/manifests, tool
  actions, commits, PRs, CI, deployment IDs, review decisions, handoffs, and
  outcome status.

Outputs:

- Append-oriented session ledger records.
- Parent/child session graph.
- Traceability links to issues, branches, worktrees, PRs, tests, deployments,
  reviews, and decisions.
- Validated `SessionLedger` artifact with event envelope fields, correlation
  IDs, artifact/evidence/external refs, result, previous event ID, checksum,
  redaction policy, and explicit exceptions.

Why promote:

- `ARQ-005` makes session and wave history an auditability requirement. The
  controller can own runtime orchestration, but the ledger contract should be
  independently testable.

Start condition:

- Use with `controller-loop`, `sprint-orchestrator`, lane dispatch, critic,
  release verification, and learning capture.

Stop condition:

- Every lifecycle-significant action has a ledger event or explicit exception.

### `agent-platform-control`

Purpose: Specify and later exercise authorized Agent Platform API/MCP actions.

Current contract status:

- First validated request shape:
  `schemas/agent-platform-control-request.schema.yaml`.
- Owning lifecycle mode for the first manual runs:
  `platform-readiness` / Agent Platform control request.
- Operator reference:
  `skills/platform-readiness/references/agent-platform-control.md`.
- Template:
  `skills/platform-readiness/assets/agent-platform-control-request.template.yaml`.
- Example:
  `examples/minimal-project/.agent-workflow/platform/agent-platform-control-request.yaml`.
- Evidence:
  `northstar://evidence/NSE-20260623-agent-platform-control-implementation-be`.

Inputs:

- Route decision, planning intent, repo/session/worktree commands, GitHub
  reconcile requests, CI/CD operations, k3s app state requests, review packet
  operations, telemetry queries, authz context, and policy verdicts.

Outputs:

- Validated `AgentPlatformControlRequest` artifact.
- API/MCP operation contract reference.
- Authorized action request with target identity.
- Policy verdict.
- Execution result refs and telemetry/review evidence when execution is
  separately authorized.

Why promote:

- `PRQ-018`, `SURF-012`, and `IFACE-012` make the Agent Platform API/MCP
  boundary central to composition with Hermes/OpenClaw and the control plane.

Start condition:

- Promote only when the Agent Platform exposes a concrete API/MCP surface or
  when `platform-readiness` needs an executable control-plane contract.

Stop condition:

- Unsafe, unauthorized, missing-evidence, stale-state, or protected-production
  operations are blocked and routed back to planning or human review.

### `learning-capture`

Purpose: Convert session, research, tool-friction, failed-loop, and review
feedback evidence into proposal-only improvements.

Inputs:

- Local Codex/Claude/terminal summaries, research artifacts, review feedback,
  failed-loop records, command friction, validation failures, and accepted
  manual corrections.

Outputs:

- `NLP-*` packets under `.agent-workflow/northstar/learning-capture/`.
- Proposed destinations: content, context file, slash command, skill, hook,
  tool/CLI, config, backlog, artifact schema, product shape, architecture, or
  no-op.
- Loop-readiness verdict for any recurring automation proposal.
- Validated `NorthStarLearningProposals` artifact using the operator reference,
  template, and minimal-project example.

Current contract status:

- First proposal packet shape:
  `schemas/northstar-learning-proposals.schema.yaml`.
- Owning lifecycle mode for the first manual runs:
  `northstar-planning` / learning capture.
- Operator reference:
  `skills/northstar-planning/references/learning-capture.md`.
- Template:
  `skills/northstar-planning/assets/northstar-learning-proposals.template.yaml`.
- Example:
  `examples/minimal-project/.agent-workflow/northstar/learning-capture/learning-proposals.yaml`.
- Evidence:
  `northstar://evidence/NSE-20260623-learning-capture-implementation-best-pra`.

Why promote:

- `PRQ-020`, `PRQ-021`, `SURF-014`, and `IFACE-014` already define this as a
  product surface. It should become standalone once `NSQ-009` is resolved.

Start condition:

- Use after manual sessions, review feedback, repeated tool friction, failed
  loops, or research that changes the operating model.

Stop condition:

- Proposals are staged with evidence, verification, risk class, approval path,
  and affected artifacts. Applying changes remains separate.

## Mode-First Capabilities

### `github-backlog-sync`

Keep this as router/state-of-union/CLI behavior until it becomes repetitive
enough to deserve a skill. It should reconcile Issues, PRs, checks, reviews,
deployments, snapshots, labels, duplicate assignments, branches without PRs,
and local artifacts. It maps primarily to `PRQ-010`, `SURF-010`, and
`IFACE-008`.

Current contract status:

- First sync artifact shape:
  `schemas/github-backlog-sync.schema.yaml`.
- Owning lifecycle mode for the first manual runs:
  `state-of-union` / GitHub backlog sync.
- Operator reference:
  `skills/state-of-union/references/github-backlog-sync.md`.
- Template:
  `skills/state-of-union/assets/github-backlog-sync.template.yaml`.
- Example:
  `examples/minimal-project/.agent-workflow/strategy/github-backlog-sync.yaml`.
- Evidence:
  `northstar://evidence/NSE-20260623-github-backlog-sync-implementation-best`.

### `environment-gitops`

Keep this under `platform-readiness` and `release-verification` until a non-
Gravity pilot proves the environment contract. It should cover namespaces,
ResourceQuota, NetworkPolicy, Argo CD or Flux app state, preview TTL, secrets,
promotion, rollback, dashboards, and endpoint health. It maps to `PRQ-006`,
`PRQ-014`, `PRQ-017`, `ARCH-005`, `ARCH-007`, `ARCH-008`, and `ARCH-009`.

Current contract status:

- First reconciliation artifact shape:
  `schemas/environment-gitops-reconciliation.schema.yaml`.
- Owning lifecycle mode for the first manual runs:
  `platform-readiness` / environment GitOps reconciliation.
- Operator reference:
  `skills/platform-readiness/references/environment-gitops.md`.
- Template:
  `skills/platform-readiness/assets/environment-gitops-reconciliation.template.yaml`.
- Example:
  `examples/minimal-project/.agent-workflow/platform/environment-gitops-reconciliation.yaml`.
- Evidence:
  `northstar://evidence/NSE-20260623-environment-gitops-implementation-best-p`.

### `gravity-core-extraction`

Keep this under `gravity-readiness` until the Sunshine inventory is complete.
It should produce a reuse matrix, generic-core/organization-pack boundary,
source-object contract, migration risk list, local-filesystem ingestion pilot
story, and updated Gravity readiness checklist. It maps to `PRQ-019`,
`SURF-013`, `IFACE-013`, and `ARCH-014`.

Current contract status:

- First extraction plan artifact shape:
  `schemas/gravity-core-extraction-plan.schema.yaml`.
- Owning lifecycle mode for the first manual runs:
  `gravity-readiness` / Gravity core extraction.
- Operator reference:
  `skills/gravity-readiness/references/gravity-core-extraction.md`.
- Template:
  `skills/gravity-readiness/assets/gravity-core-extraction-plan.template.yaml`.
- Example:
  `examples/minimal-project/.agent-workflow/gravity/gravity-core-extraction-plan.yaml`.
- Evidence:
  `northstar://evidence/NSE-20260623-gravity-core-extraction-implementation-b`.

## Implementation Order

1. Add `review-inbox` packet shape and schema. Initial contract completed with
   `schemas/review-inbox-packet.schema.yaml`; promotion to a top-level
   canonical skill remains pending one reliable manual run and stable
   ownership.
2. Add `wave-release-planning` artifact shape, likely as a mode under
   `sprint-planning` first. Initial contract completed with
   `schemas/wave-release-plan.schema.yaml`; promotion to a top-level canonical
   skill remains pending one reliable manual run and stable ownership.
3. Add `observability-diagnostics` checklist and diagnostic packet shape.
   Initial contract completed with
   `schemas/observability-diagnostic-packet.schema.yaml`; promotion to a
   top-level canonical skill remains pending one reliable manual run and stable
   ownership.
4. Split `session-ledger` from `controller-loop` only if the ledger schema
   becomes independently validated and reused by other skills. Initial contract
   completed with `schemas/session-ledger.schema.yaml`; promotion to a top-level
   canonical skill remains pending one reliable manual run and stable reuse.
5. Add the first `agent-platform-control` request/policy shape under
   `platform-readiness`. Initial contract completed with
   `schemas/agent-platform-control-request.schema.yaml`; promotion to a
   top-level canonical skill remains pending concrete Agent Platform operations
   and one reliable manual run.
6. Add the first `gravity-core-extraction` plan shape under
   `gravity-readiness`. Initial contract completed with
   `schemas/gravity-core-extraction-plan.schema.yaml`; feature implementation
   remains blocked until Gravity readiness and platform readiness approve the
   pilot.
7. Promote `learning-capture` after `NSQ-009` resolves session source,
   retention, and redaction rules. Initial contract completed with
   `schemas/northstar-learning-proposals.schema.yaml`,
   `skills/northstar-planning/references/learning-capture.md`, a template, and
   a validating minimal-project example; scheduled scanning remains blocked
   until source scope, verifier, stop/budget, permissions, and one manual run
   are approved.

This order keeps the next milestone practical: improve human review and wave
deployment proof first, then harden diagnostics and auditability, then expose
runtime platform actions.

## Traceability

| Design item | North Star IDs |
| --- | --- |
| 18-lifecycle-skill kernel plus standalone `issue-triage` | `PRQ-007`, `ARQ-007` |
| Final-lock-only North Star gate | `PRQ-002`, `ARQ-001`, `NSQ-001` |
| Review inbox | `PRQ-004`, `SURF-004`, `IFACE-004`, `ARCH-008`, `ARCH-009` |
| Wave release planning | `PRQ-006`, `ARQ-006`, `ARCH-009`, `NSQ-002` |
| Observability diagnostics | `ARQ-004`, `ARCH-008`, `PRQ-004` |
| Session ledger | `PRQ-005`, `ARQ-005`, `ARCH-008` |
| Agent Platform control | `PRQ-018`, `SURF-012`, `IFACE-012`, `ARCH-013` |
| Learning capture | `PRQ-020`, `PRQ-021`, `SURF-014`, `IFACE-014`, `ARCH-015`, `NSQ-009` |
| GitHub sync | `PRQ-010`, `SURF-010`, `IFACE-008`, `ADR-0001` |
| Environment GitOps | `PRQ-006`, `PRQ-014`, `PRQ-017`, `ARCH-005`, `ARCH-009` |
| Gravity extraction | `PRQ-019`, `SURF-013`, `IFACE-013`, `ARCH-014` |

## Acceptance Signals

- The current 18 lifecycle skills plus standalone `issue-triage` validate as the package's 19 skills.
- `review-inbox` has a validated packet schema, template, operator reference,
  and example artifact before it is promoted into the canonical skill kernel.
- `wave-release-planning` has a validated plan schema, template, operator
  reference, and example artifact before it is promoted into the canonical skill
  kernel.
- `observability-diagnostics` has a validated diagnostic packet schema,
  template, operator reference, and example artifact before it is promoted into
  the canonical skill kernel.
- `session-ledger` has a validated ledger schema, template, operator reference,
  and example artifact before it is promoted into the canonical skill kernel.
- `agent-platform-control` has a validated request schema, template, operator
  reference, and example artifact before it is promoted into the canonical
  skill kernel or used for mutation.
- `github-backlog-sync` has a validated sync schema, template, operator
  reference, and example artifact before it is promoted out of state-of-union
  mode.
- `environment-gitops` has a validated reconciliation schema, template,
  operator reference, and example artifact before it is promoted out of
  platform-readiness mode or used for mutation.
- `gravity-core-extraction` has a validated plan schema, template, operator
  reference, and example artifact before Gravity implementation lanes are
  opened.
- `learning-capture` has a validated proposal schema, template, operator
  reference, and example artifact before recurring scans are scheduled.
- New capabilities have named inputs, outputs, start conditions, stop
  conditions, and traceability before implementation.
- Review-ready work cannot bypass CI, preview/review deployment evidence,
  rollback context, and human test steps.
- Recurring loops cannot be scheduled without loop-readiness proof.
- Agent Platform operations remain API/MCP-first but are not invented before
  the platform exposes concrete contracts.
- Gravity implementation remains gated; Gravity extraction stays readiness and
  inventory work until approval.
