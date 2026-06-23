# North Star Plan

Status: `proposed`
Review state: `changes_requested`

This artifact is the planning loop output for the skills repository. It turns
the pinned walk transcript, routed intake evidence, registered research, the
latest Agent Platform / Sunshine Gravity / OpenClaw priority review, the
Brave-sourced research pass, local live-state audits, OpenClaw/Hermes workflow
evidence, the agent-loop / learning-capture evidence, and the repo-controller
bootstrap / fleet self-discovery walk into
goals, requirements, user stories, architecture principles, milestones, risks,
questions, conflicts, issues, research paths, and final approval state.

## Goals

- Turn research, ideation, transcript input, feedback, and requirements into
  durable planning artifacts before implementation planning.
- Keep product intent and architecture inputs separate but linked.
- Preserve the Gravity readiness gate until platform and human-review readiness
  are proven and approved.
- Preserve CI/CD based wave deployment as a core delivery planning requirement.
- Use a durable North Star interview packet to collect human priorities,
  decisions, and tradeoff answers before final lock approval.
- Reframe the owned-IP priority as a self-hosted software-and-knowledge
  operating plane spanning source control, CI/CD, pipelines, k3s management,
  agent orchestration, and evidence/knowledge workflows.
- Treat Agent Platform as API/MCP-first, with the web UI scoped to inspection,
  review, recovery, and operator-console workflows.
- Make Agent Platform MCP/API operations validate as request, authorization,
  policy, target, expected-effect, review, result, and handoff records before
  execution is trusted.
- Expose the end-to-end SDLC through curated OpenClaw-facing workflow skills
  that delegate to Verdify lifecycle skills and preserve GitHub plus
  `.agent-workflow` as authority.
- Make GitHub backlog sync a validated reconciliation artifact that records
  issue, PR, lane, dependency, project, check, deployment, action, and source
  freshness findings without replacing GitHub authority.
- Make review-ready status a validated evidence packet, not an unstructured
  claim spread across PR comments, CI pages, deployment dashboards, or chat.
- Make deployment-affecting waves validate a release plan before worker
  dispatch, so branch model, checks, environments, GitOps, rollback, and review
  handoff are explicit at the start of the wave.
- Make environment GitOps reconciliation a validated evidence record so desired
  state, observed controller state, namespace policy, runtime health, drift,
  rollback, and cleanup are explicit before review or release claims advance.
- Make runtime-sensitive review, release, readiness, incident, and feedback
  decisions use a validated diagnostic packet when telemetry materially affects
  the decision.
- Make session and wave history reconstructable from an append-oriented ledger
  so controller recovery and handoff do not rely on hidden chat context.
- Treat Sunshine Club as the reference implementation and code-mining source
  for reusable Gravity local-filesystem evidence ingestion.
- Make Gravity core extraction a validated readiness artifact before
  Sunshine-derived core reuse, pack extraction, or local filesystem ingestion
  implementation starts.
- Add proposal-only learning capture so repeated lessons from Codex, Claude,
  terminal, research, and delivery sessions become evidence-backed proposals
  instead of hidden chat memory or unreviewed skill drift.
- Require loop-readiness checks before recurring agent loops are scheduled or
  delegated: recurrence, verifier, state, stop condition, budget, objective
  done criteria, permissions, and one reliable manual run.
- Make repo-controller bootstrap and self-discovery a standard workflow before
  broad autonomous rollout across active repositories.
- Require every repo-associated controller or long-lived agent to declare scope,
  ownership, responsibilities, authority boundaries, runtime context, and
  escalation paths through a typed repo-agent scope contract tied to discovery.
- Standardize repo, namespace, environment, storage, route, credential, and
  base-image boundaries before fleet bootstrap runs beyond a pilot.
- Make controller loops observable and recoverable through dashboards,
  diagnostic packets, session ledgers, alerts, and outstanding-work rehydration.
- Add Orbit-style daily operating context as a read-only planning surface over
  authorized sources and authoritative records.

## Priority Sequence

1. Stabilize Agent Platform readiness for source control, CI/CD, k3s, repo-pod
   agents, MCP/API control, observability, review evidence, and the live
   Argo/GitHub/Kubernetes gaps found in the June 23 audit.
2. Keep Verdify Skills focused on lifecycle contracts, evidence, North Star
   planning, readiness, controller-loop, and review/release artifacts.
3. Use the OpenClaw SDLC workflow design as the external workflow facade for
   one non-Gravity pilot, while GitHub issues/branches/worktrees/PRs/checks and
   deployments remain the coordination primitives.
4. Define and pilot repo-controller bootstrap on one safe non-production
   repository, including a validated repo-agent scope/responsibility charter,
   before running it across the full fleet.
5. Run a non-Gravity pilot through the governed loop before Gravity
   implementation.
6. Inventory Sunshine Club and define the reusable Gravity core versus
   organization-pack boundary, using `verdify_gravity` as the generic core
   target and Sunshine as a client pack/reference implementation; validate a
   `gravity-core-extraction-plan.yaml` before implementation lanes open.
7. Define the typed learning-capture proposal packet, redaction rules, routing
   taxonomy, schema validation, and loop-readiness checklist.
8. Use Gravity's first pilot story for local filesystem evidence ingestion
   after readiness approval.

## OpenClaw SDLC Workflow Design

- Current design artifact:
  `.agent-workflow/northstar/OPENCLAW_SDLC_WORKFLOW_SKILLS.md`.
- OpenClaw is the external planning and conversation layer. It exposes
  workflow skills and calls Verdify lifecycle skills, Agent Platform MCP/API
  operations, and GitHub primitives; it does not replace GitHub, final human
  approvals, or `.agent-workflow` records.
- Curated OpenClaw workflow skills:
  `sdlc-bootstrap-repo`, `sdlc-ideation-intake`, `sdlc-northstar-loop`,
  `sdlc-definition-architecture`, `sdlc-backlog-strategy`,
  `sdlc-readiness-gates`, `sdlc-wave-planning`, `sdlc-lane-dispatch`,
  `sdlc-review-inbox`, `sdlc-release-path`, and `sdlc-learning-capture`.
- GitHub scaling primitives: issues, sub-issues/dependencies, labels,
  milestones/projects, branches, worktree leases, PRs, checks, deployments,
  environment approvals, releases, and tags.
- Production rule: deployment proof is separate from merge success; the
  release path must prove runtime health, rollback readiness, and outcome
  acceptance.

## Research Loop Update

- The June 23 research queue has no remaining pending topics from this pass.
- The Brave Search key is referenced safely from
  `.agent-workflow/northstar/credential-references.yaml`; the raw secret stays
  in Jason's local secret store.
- New registered evidence covers live Agent Platform state, Gravity remote and
  Onyx status, Sunshine-to-Gravity extraction, OpenClaw/Hermes interface
  security, browser terminal security, runtime secret injection,
  GitHub/GitLab/Gitea/Forgejo migration patterns, OpenGitOps session leads,
  long-horizon harness patterns, review inbox examples, the first
  `review-inbox-packet.schema.yaml` implementation contract, and the first
  `wave-release-plan.schema.yaml` implementation contract, the first
  `observability-diagnostic-packet.schema.yaml` implementation contract, the
  first `session-ledger.schema.yaml` implementation contract, and the first
  `agent-platform-control-request.schema.yaml` implementation contract, and
  the first `github-backlog-sync.schema.yaml` implementation contract, and the
  first `environment-gitops-reconciliation.schema.yaml` implementation
  contract, and the first `gravity-core-extraction-plan.schema.yaml`
  implementation contract, plus the reported repo-controller bootstrap and
  fleet self-discovery walk evidence.
- Deeper follow-up is now gate-driven: watch/timestamp individual GitOpsCon
  sessions only if a release architecture claim depends on them; exercise live
  browser terminal/runtime endpoints/secret-controller config only during
  platform readiness with the right safety boundary.

## Repo Controller Bootstrap Update

- New evidence:
  `northstar://evidence/NSE-20260623-repo-controller-bootstrap-self-discovery`.
- Cross-project routing matrix:
  `.agent-workflow/northstar/walk-routing-2026-06-23.md`.
- The walk was normalized semantically, not preserved as a literal transcript.
- The proposed default is to keep repo bootstrap as a workflow facade over
  existing lifecycle skills instead of adding a new top-level skill immediately.
- Bootstrap should inventory repo/source/GitHub/runtime/namespace/logs/metrics/
  routes/storage/credential references/CI/CD/package needs/gaps, then produce a
  standard packet, `AGENTS.md` proposal, issue recommendations, namespace map,
  dashboard links, and PR proposal.
- Each assigned repo controller or long-lived repo agent should also produce a
  validated `.agent-workflow/hygiene/repo-agent-scope.yaml` that records
  purpose, in/out scope, owned/protected paths, responsibilities, authority
  boundaries, runtime context, escalation paths, review, handoff, and approval.
- Credential validation must record safe metadata only: references, auth modes,
  scopes, owners, pass/fail/needs-reauth status, and failure mode. Raw secrets
  stay out of prompts, artifacts, logs, and commits.
- Broad infrastructure-domain access and self-service storage/route/image
  changes are gated behind platform/security ownership and should not be
  implemented from this planning pass.
- Orbit daily briefs are a future read-only planning surface over authorized
  connectors and authoritative records, not an approval or delivery control
  plane.
- Concrete backlog now exists:
  `VerdifyConsultancy/verdify-skills#1`, `#2`, `#3`;
  `jvallery/agents#1808`, `#1809`, `#1810`, `#1811`, `#1812`, `#1813`;
  `VerdifyConsultancy/gravity#2`; and `jvallery/vast-cloud-tco#217`.
- The VAST TCO calculator/object-storage comparison is routed to
  `jvallery/vast-cloud-tco#217` and local VAST North Star/backlog addenda.

## Planning Questions

- Final-lock rule is resolved for this loop: approval to lock the North Star
  and proceed to the next milestone is the only North Star planning gate.
- Should wave automation keep the current one issue/lane/branch/worktree/session/PR
  model or introduce a wave branch? Current direction: wave is the CI/CD
  deployment and review unit.
- Gravity/Onyx is resolved for this loop: current repo and GitHub evidence says
  Gravity does not depend on Onyx ingestion for the MVP; Onyx remains a
  separate planned/gated vault or search front door and post-MVP/control-plane
  concern.
- Which P0 North Star interview decisions should be accepted, modified, or
  rejected before final lock?
- What exact responsibility split should hold among Verdify Skills, Agent
  Platform, Hermes/OpenClaw, and Gravity? Current default: Skills owns lifecycle
  contracts/artifacts; Agent Platform owns runtime/control integration;
  Hermes/OpenClaw exposes user-facing workflow skills and plans through
  constrained MCP/API surfaces; Gravity owns the reusable evidence engine plus
  packs.
- What is the safest extraction path from Sunshine Club into reusable Gravity
  core? Current default: validate a Gravity core extraction plan first, then
  port scanner, SHA-256/object staging, Postgres pipeline, readiness, read-only
  MCP, and validation contracts before Sunshine-specific client-pack behavior.
- Which session sources, retention windows, and redaction rules should the
  learning-capture loop use? Current default: explicit research artifacts plus
  redacted local Codex/Claude/terminal summaries, with proposal-only output and
  loop-readiness proof before scheduling.
- What exact namespace naming convention should bind GitHub owner,
  organization, repository, dev, preview, staging, and production namespace
  identity for fleet bootstrap?
- Should repo-controller orchestration use Codex, Claude, or a model-neutral
  controller abstraction that selects tools per task and failure mode?
- Which infrastructure domain agents may hold broader scoped access, and what
  owner, audit, approval, and rollback rules apply?
- What is the approved request path for repo agents to add NFS/PVC mounts,
  route/DNS changes, or base-image packages?
- What sources, privacy boundaries, connector permissions, and source-freshness
  rules should the Orbit daily operating brief use?

## Learning Capture

- Incorporate the three social posts as reported evidence, not final authority.
- Capture lessons as staged `NLP-*` proposals in
  `.agent-workflow/northstar/learning-capture/*.yaml`, validated by
  `schemas/northstar-learning-proposals.schema.yaml`.
- Record evidence, verification, destination, proposed change, risk class,
  approval requirement, routing decision, affected artifacts, and loop-readiness
  answers.
- Route lessons to content, context files, slash commands, skills, hooks,
  tool/CLI fixes, config, backlog, artifact schemas, product shape,
  architecture, or no-op.
- Schedule scans only after redaction and read-only proof; applying changes
  stays human-approved or governed by an explicit policy.
- Treat cost per accepted change and proposal acceptance rate as the useful
  metrics for recurring loops.

Ordinary planning questions feed `artifact-loop` or `research-loop`; they are
not human gates until the North Star is ready for final lock approval.
Interview answers feed `review-feedback` or `artifact-loop`; they do not record
final approval unless Jason/James explicitly provide it.

## SDLC Skill Design

- Current design artifact:
  `.agent-workflow/northstar/SDLC_SKILL_DESIGN.md`.
- OpenClaw workflow artifact:
  `.agent-workflow/northstar/OPENCLAW_SDLC_WORKFLOW_SKILLS.md`.
- Keep the existing 17 lifecycle skills as the installable kernel.
- `review-inbox` now has its first executable packet/schema contract under
  `release-verification`: `schemas/review-inbox-packet.schema.yaml`,
  `skills/release-verification/references/review-inbox.md`, a template, and a
  validating minimal-project example. Top-level skill promotion remains pending
  one reliable manual run and stable ownership.
- `wave-release-planning` now has its first executable plan/schema contract
  under `sprint-planning`: `schemas/wave-release-plan.schema.yaml`,
  `skills/sprint-planning/references/wave-release-planning.md`, a template, and
  a validating minimal-project example. Top-level skill promotion remains
  pending one reliable manual run and stable ownership.
- `observability-diagnostics` now has its first executable diagnostic
  packet/schema contract under `release-verification`:
  `schemas/observability-diagnostic-packet.schema.yaml`,
  `skills/release-verification/references/observability-diagnostics.md`, a
  template, and a validating minimal-project example. Top-level skill promotion
  remains pending one reliable manual run and stable ownership.
- `session-ledger` now has its first executable ledger/schema contract under
  `controller-loop`: `schemas/session-ledger.schema.yaml`,
  `skills/controller-loop/references/session-ledger.md`, a template, and a
  validating minimal-project example. Top-level skill promotion remains pending
  one reliable manual run and stable reuse across roles.
- `agent-platform-control` now has its first validated request/schema contract
  under `platform-readiness`:
  `schemas/agent-platform-control-request.schema.yaml`,
  `skills/platform-readiness/references/agent-platform-control.md`, a template,
  and a validating minimal-project example. Top-level skill promotion and
  execution remain pending concrete Agent Platform operations and one reliable
  manual run.
- `github-backlog-sync` now has its first sync/schema contract under
  `state-of-union`: `schemas/github-backlog-sync.schema.yaml`,
  `skills/state-of-union/references/github-backlog-sync.md`, a template, and a
  validating minimal-project example. It remains a mode-first capability until
  repeated use proves a standalone skill is justified.
- `environment-gitops` now has its first reconciliation/schema contract under
  `platform-readiness`:
  `schemas/environment-gitops-reconciliation.schema.yaml`,
  `skills/platform-readiness/references/environment-gitops.md`, a template, and
  a validating minimal-project example. It remains a mode-first capability and
  does not authorize environment mutation.
- `gravity-core-extraction` now has its first extraction-plan/schema contract
  under `gravity-readiness`:
  `schemas/gravity-core-extraction-plan.schema.yaml`,
  `skills/gravity-readiness/references/gravity-core-extraction.md`, a template,
  and a validating minimal-project example. It remains a mode-first readiness
  capability and does not authorize Gravity feature implementation.
- `repo-bootstrap` / `sdlc-bootstrap-repo` is now a proposed workflow facade
  over `repo-hygiene`, `platform-readiness`, `controller-loop`,
  `state-of-union`, and `northstar-planning`. It should not become a new
  top-level skill until a manual pilot proves the inventory shape, security
  boundaries, controller observability, issue/PR output, and handoff.
- `repo-agent-scope` now has its first schema/template/reference contract under
  `repo-hygiene`: `schemas/repo-agent-scope.schema.yaml`,
  `skills/repo-hygiene/assets/repo-agent-scope.template.yaml`, and
  `skills/repo-hygiene/references/repo-agent-scope.md`. It is a discovery
  artifact, not a standalone top-level skill.
- Promote these capabilities next when their contracts are stable:
  `review-inbox`, `wave-release-planning`, `observability-diagnostics`,
  `session-ledger`, `agent-platform-control`, and `learning-capture`.
- Keep `github-backlog-sync`, `environment-gitops`, and
  `gravity-core-extraction` as mode-first capabilities until repeated manual
  use proves they should become standalone skills.
- Prioritize review packet shape, CI/CD wave deployment planning, diagnostics,
  durable session evidence, and one OpenClaw-facing non-Gravity pilot before
  broadening autonomous platform actions.

## Handoff

Next skill: `northstar-planning`

Next mode: `artifact-loop`

Reason: The OpenClaw SDLC workflow skill design, first review-inbox packet
contract, first wave release plan contract, first observability diagnostic
packet contract, first session ledger contract, first Agent Platform control
request contract, first GitHub backlog sync contract, first environment
GitOps reconciliation contract, first Gravity core extraction plan contract, and
first repo-agent scope contract plus the repo-controller bootstrap walk evidence
have been synthesized into product, architecture, SDLC design, schemas,
examples, and structured plan artifacts. Continue the North Star artifact loop
before any final lock approval request.
