# OpenClaw SDLC Workflow Skills Design

Status: `proposed`
Date: `2026-06-23`
Repository: `verdify-skills`
Planning authority: current draft North Star, iteration `21`

## Purpose

This design turns the current North Star, registered research, and agentic SDLC
evidence into an OpenClaw-managed set of workflows that can drive a project
repository from ideation through production deployment.

OpenClaw is the external planning and conversation layer. It may expose these
workflows as user-facing skills, but it does not become the source of truth.
GitHub remains the backlog and delivery control plane, `.agent-workflow`
remains the durable lifecycle record, and Verdify lifecycle skills remain the
bounded executable contracts.

Evidence:

- `NSE-20260623-end-to-end-agent-based-sdlc`
- `NSE-20260623-cicd-sdlc-agent-orchestration-human-governed-delivery`
- `NSE-20260623-openclaw-hermes-local-evidence`
- `NSE-20260623-openclaw-hermes-reuse-interface-security-audit`
- `NSE-20260623-agent-platform-live-state-audit`
- `NSE-20260623-review-inbox-product-examples`
- `NSE-20260623-review-inbox-skill-implementation-best-p`
- `NSE-20260623-wave-release-planning-implementation-bes`
- `NSE-20260623-observability-diagnostics-implementation`
- `NSE-20260623-session-ledger-implementation-best-pract`
- `NSE-20260623-agent-platform-control-implementation-be`
- `NSE-20260623-github-backlog-sync-implementation-best`
- `NSE-20260623-environment-gitops-implementation-best-p`
- `NSE-20260623-gravity-core-extraction-implementation-b`
- `NSE-20260623-learning-capture-implementation-best-pra`
- `NSE-20260623-long-horizon-learning-loop-source-verification`

## Operating Model

OpenClaw should expose a small set of high-level workflow skills. Each workflow
skill delegates to one or more Verdify lifecycle skills, records durable
artifacts, and reconciles GitHub primitives before it claims progress.

| Layer | Responsibility | Must not do |
| --- | --- | --- |
| OpenClaw workflow agent | Gather intent, choose a workflow, call Verdify skills and Agent Platform MCP/API tools, present review packets, route decisions. | Store private source of truth, self-approve protected gates, mutate production directly, bypass GitHub or `.agent-workflow`. |
| Verdify lifecycle skills | Define the lifecycle contracts, artifacts, checks, gates, lane scope, review, and release proof. | Act as an unbounded chat controller or silently expand lane scope. |
| GitHub | Own Issues, PRs, branches, checks, reviews, deployments, environments, releases, and backlog hierarchy. | Be replaced by local snapshots or OpenClaw conversation state. |
| Agent Platform | Execute authorized repo/session/worktree/CI/CD/k3s/review/telemetry operations through MCP/API surfaces backed by validated `AgentPlatformControlRequest` records. | Grant broad production mutation or secret access to planning or worker agents. |
| Human reviewers | Approve final North Star locks, protected readiness gates, review-ready changes, and production promotion. | Reconstruct hidden context from chats or accept claims without evidence. |

## Stakeholders And Personas

| Persona | Primary job | Key decisions | Evidence they need |
| --- | --- | --- | --- |
| Product owner | Turn ideas into product intent and acceptance criteria. | Scope, priority, final North Star approval. | North Star, requirements, open questions, tradeoffs. |
| Project owner | Own repository policy, backlog, and delivery acceptance. | Issue scope, milestone fit, implementation readiness. | GitHub issues, project definition, state-of-union. |
| Architect | Preserve boundaries, invariants, interfaces, and migration safety. | Architecture decisions, module contracts, public interfaces. | Architecture contracts, ADRs, impact map. |
| Platform operator | Prove repo, cluster, namespace, RBAC, secrets, CI/CD, and observability readiness. | Readiness exceptions, environment availability, promotion path. | Platform-readiness, GitOps state, telemetry. |
| Security reviewer | Guard credential, data, RBAC, browser terminal, and production boundaries. | Secret injection model, privileged access, exception approval. | Security findings, audit trail, policy verdicts. |
| Worktree agent | Implement one bounded issue/lane in one branch/worktree/session. | Local implementation choices inside the lane contract. | Lane contract, prompt manifest, tests. |
| Critic/verifier | Review worker output without shared worker state. | Approve, request changes, block, or escalate. | Diff, tests, contract, risk, runtime evidence. |
| Release verifier | Prove integration, deployment, rollback, and runtime outcome. | Release readiness, rollback, outcome acceptance. | PRs, checks, deployments, logs, smoke tests. |
| OpenClaw planner | Orchestrate the workflow through MCP/API and skills. | Next workflow action, routing, review packet assembly. | Route decision, ledger, GitHub state, policy verdicts. |
| End user/customer | Receive a working, supportable outcome. | Outcome acceptance or feedback. | Release notes, test steps, production proof. |

## GitHub Primitive Model

GitHub primitives scale the agent work. OpenClaw may view and drive them, but
the primitive remains authoritative.

| Primitive | SDLC use | Scaling rule |
| --- | --- | --- |
| Issue | Backlog problem, desired outcome, acceptance intent, dependencies. | Default one implementation issue per lane. Discovered work becomes an issue or issue recommendation. |
| Sub-issue/dependency | Initiative and dependency graph. | Use native GitHub hierarchy instead of a competing local graph. |
| Label | Lifecycle state, gate, risk, skill, component, environment. | Labels are searchable coordination aids, not approval records. |
| Milestone/project | Sprint or wave grouping. | Sprint plan snapshots the approved set; GitHub remains live authority. |
| Branch | Proposed code for a lane. | Default one issue/lane/branch/worktree/session/PR. |
| Worktree lease | Local worker or critic ownership. | One active worker lease per lane; critic gets a separate worktree. |
| Pull request | Reviewable code and discussion. | PR links to issue, lane, tests, preview, critic report, and release evidence. |
| Check | Deterministic validation evidence. | Required before review-ready or release-ready claims. |
| Deployment/environment | Preview, staging, production, and protection state. | Protected promotion uses environment approvals and deployment evidence. |
| Release/tag | Accepted release identity. | Release verifier links tag/release to deployment and outcome evidence. |

## End-To-End Workflow Map

| Stage | OpenClaw workflow skill | Delegates to Verdify skills | GitHub primitives | Durable artifacts | Exit condition |
| --- | --- | --- | --- | --- | --- |
| 0. Bootstrap | `sdlc-bootstrap-repo` | `project-router`, `repo-hygiene` | repo, labels, issue templates | `.agent-workflow`, host links, route decision | Repo can route and validate. |
| 1. Ideation intake | `sdlc-ideation-intake` | `transcript-replan`, `northstar-research-ingest` | issue ideas, discussion, evidence links | intake records, evidence items | Intent is routed or registered as evidence. |
| 2. Research and North Star | `sdlc-northstar-loop` | `northstar-planning`, `northstar-interview` | decision issues, review issue | product/architecture North Star, questions | Draft is coherent or final lock is requested. |
| 3. Project definition | `sdlc-project-definition` | `project-definition` | scope issue, milestone | project definition | Users, scope, workflows, constraints are explicit. |
| 4. Architecture contracts | `sdlc-architecture-contracts` | `architecture-contracts` | ADR issue, contract issue | architecture, ADRs, module contracts | Interfaces and invariants are reviewable. |
| 5. Strategy and backlog | `sdlc-backlog-strategy` | `state-of-union`, `project-router`, `github-backlog-sync` mode | issues, sub-issues, dependencies, milestone/project, PRs, checks, deployments | strategy, `github-backlog-sync.yaml` | Candidate sprint/wave is evidence-backed. |
| 6. Readiness gates | `sdlc-readiness-gates` | `repo-hygiene`, `platform-readiness`, `gravity-readiness`, `environment-gitops`, `agent-platform-control` request mode, `gravity-core-extraction` mode | gate issues, environment checks, policy decisions | readiness artifacts, `environment-gitops-reconciliation.yaml`, `agent-platform-control-request.yaml` when API/MCP operations are proposed, `gravity-core-extraction-plan.yaml` when Gravity reuse is in scope | Gates pass or block with owner and reason. |
| 7. Wave planning | `sdlc-wave-planning` | `sprint-planning`, `wave-release-planning` | sprint/wave milestone, lane issues | sprint plan, lane contracts, `wave-release-plan.yaml` | Each lane has issue, branch plan, checks, preview, rollback. |
| 8. Lane dispatch | `sdlc-lane-dispatch` | `sprint-orchestrator`, `controller-loop` | assigned issues, branches, PR skeletons | leases, prompts, `session-ledger.yaml` | Workers and critics have isolated worktrees. |
| 9. Implementation | `sdlc-lane-implementation` | `lane-delivery` | branch, commits, PR | worker closeout, tests | Lane PR is ready for fresh review. |
| 10. Independent review | `sdlc-independent-review` | `independent-critic` | PR review, checks | critic report | Approved, changes requested, blocked, or escalated. |
| 11. Review inbox | `sdlc-review-inbox` | `review-inbox`, `observability-diagnostics` | PR, checks, deployments, review comments | `review-inbox-packet.yaml`, `observability-diagnostic-packet.yaml` | Human reviewer has complete evidence. |
| 12. Integration and release | `sdlc-release-path` | `release-verification`, `environment-gitops`, `observability-diagnostics` | merge, tag, release, deployment | release evidence, environment GitOps reconciliation, diagnostic packet, rollback plan | Deployment is verified separately from merge. |
| 13. Production outcome | `sdlc-outcome-acceptance` | `release-verification`, `state-of-union` | production deployment, release, outcome issue | outcome acceptance, residual risks | Outcome accepted or follow-up issues opened. |
| 14. Learning loop | `sdlc-learning-capture` | `learning-capture`, `northstar-planning` | improvement issues | learning proposal packet | Reusable lessons are staged, not silently applied. |

## Curated Skill Set

The externally visible OpenClaw skill set should stay smaller than the internal
Verdify lifecycle kernel. It should expose user-intent workflows, not every
internal role.

### `sdlc-bootstrap-repo`

Purpose: install or verify Verdify in a target repo and produce the first route.

Delegates: `project-router`, `repo-hygiene`.

Inputs: repository URL/path, desired project owner, GitHub repository, existing
policy files, optional install mode.

Outputs: route decision, repo-hygiene findings, missing setup actions, host
links, validation result.

Stop conditions: ambiguous repo identity, missing GitHub access when required,
invalid repo artifacts, unsafe credentials in repo.

### `sdlc-ideation-intake`

Purpose: turn rough product ideas, walk transcripts, links, and decisions into
routed evidence and backlog candidates.

Delegates: `transcript-replan`, `northstar-research-ingest`,
`northstar-planning` in `intake` mode.

Inputs: transcript, meeting notes, pasted requirements, external links, existing
issues, stakeholder notes.

Outputs: transcript-replan artifact, evidence items, proposed issues,
questions, conflicts.

Stop conditions: raw secrets, regulated data, unclear provenance, or a
protected decision that needs explicit approval.

### `sdlc-northstar-loop`

Purpose: maintain product and architecture North Star drafts until final lock
approval is intentionally requested.

Delegates: `northstar-planning`, `northstar-interview`,
`northstar-research-ingest`.

Inputs: evidence registry, review feedback, research queue, product questions,
architecture questions.

Outputs: `NORTHSTAR_PRODUCT.md`, `NORTHSTAR_ARCHITECTURE.md`,
`northstar-artifacts.yaml`, `northstar-plan.yaml`, interview packet.

Stop conditions: final lock approval required, unsafe access, raw secrets, or
blocked source material.

### `sdlc-definition-architecture`

Purpose: convert approved or accepted North Star direction into project
definition, architecture, contracts, ADRs, and module ownership.

Delegates: `project-definition`, `architecture-contracts`.

Inputs: North Star IDs, GitHub backlog, repository docs, existing code,
constraints, personas, environments.

Outputs: project definition, architecture contract set, ADRs, module contracts,
decision gates.

Stop conditions: missing product intent, contradictory architecture authority,
unapproved public interface or data model change.

### `sdlc-backlog-strategy`

Purpose: reconcile GitHub backlog and durable artifacts into an executable
delivery strategy.

Delegates: `state-of-union`, `project-router`, `github-backlog-sync`.

Inputs: GitHub issues, PRs, milestones/projects, North Star artifacts,
readiness state, prior sprint outcomes.

Outputs: state-of-union strategy, `github-backlog-sync.yaml`, issue
recommendations, gate recommendations, candidate sprint/wave scope.

Stop conditions: stale GitHub state, duplicate lane assignment, missing
approved artifact, conflicting backlog authority.

Initial Verdify contract:

- `schemas/github-backlog-sync.schema.yaml`
- `skills/state-of-union/references/github-backlog-sync.md`
- `skills/state-of-union/assets/github-backlog-sync.template.yaml`
- `examples/minimal-project/.agent-workflow/strategy/github-backlog-sync.yaml`

### `sdlc-readiness-gates`

Purpose: prove repository, platform, environment, secrets, observability, and
domain-specific readiness before feature execution.

Delegates: `repo-hygiene`, `platform-readiness`, `gravity-readiness`,
`environment-gitops`, `agent-platform-control` request mode,
`gravity-core-extraction` mode.

Inputs: repo state, GitHub state, Kubernetes/GitOps state, secret references,
CI/CD, observability, pilot criteria.

Outputs: readiness artifacts, pass/fail verdict, exceptions, issue/gate
recommendations, validated `environment-gitops-reconciliation.yaml` records,
validated `agent-platform-control-request.yaml` records for proposed API/MCP
operations, and validated `gravity-core-extraction-plan.yaml` records when
Gravity reuse or Sunshine extraction is in scope.

Stop conditions: broad production mutation needed, unresolved secret/RBAC
boundary, missing observability for required runtime proof.

Initial Verdify contract:

- `schemas/environment-gitops-reconciliation.schema.yaml`
- `skills/platform-readiness/references/environment-gitops.md`
- `skills/platform-readiness/assets/environment-gitops-reconciliation.template.yaml`
- `examples/minimal-project/.agent-workflow/platform/environment-gitops-reconciliation.yaml`
- `schemas/agent-platform-control-request.schema.yaml`
- `skills/platform-readiness/references/agent-platform-control.md`
- `skills/platform-readiness/assets/agent-platform-control-request.template.yaml`
- `examples/minimal-project/.agent-workflow/platform/agent-platform-control-request.yaml`
- `schemas/gravity-core-extraction-plan.schema.yaml`
- `skills/gravity-readiness/references/gravity-core-extraction.md`
- `skills/gravity-readiness/assets/gravity-core-extraction-plan.template.yaml`
- `examples/minimal-project/.agent-workflow/gravity/gravity-core-extraction-plan.yaml`

### `sdlc-wave-planning`

Purpose: transform selected issues into a bounded wave with lane contracts,
branch/worktree identity, CI/CD evidence, preview/review environment, and
rollback path.

Delegates: `sprint-planning`, `wave-release-planning`,
`architecture-contracts`.

Inputs: strategy, candidate issues, dependencies, target environment,
architecture contracts, readiness gates.

Outputs: sprint plan, lane contracts, wave release plan, GitHub milestone or
project update, branch naming plan.

Stop conditions: unresolved wave branch decision, missing acceptance criteria,
unsafe environment plan, lane too broad for one issue/branch/worktree/PR.

Initial Verdify contract:

- `schemas/wave-release-plan.schema.yaml`
- `skills/sprint-planning/references/wave-release-planning.md`
- `skills/sprint-planning/assets/wave-release-plan.template.yaml`
- `examples/minimal-project/.agent-workflow/sprints/2026-06-22-a/release/wave-release-plan.yaml`

### `sdlc-lane-dispatch`

Purpose: launch and monitor bounded worker and critic sessions through leases
and GitHub-linked work.

Delegates: `sprint-orchestrator`, `controller-loop`, `lane-delivery`,
`session-ledger`.

Inputs: approved lane contracts, GitHub issues, baseline SHA, worktree root,
worker/critic identity.

Outputs: worker leases, critic leases, prompt manifests, session ledger
entries, PR links, status events.

Stop conditions: duplicate active lease, dirty shared worktree, missing issue,
missing branch baseline, contract hash mismatch.

Initial Verdify contract:

- `schemas/session-ledger.schema.yaml`
- `skills/controller-loop/references/session-ledger.md`
- `skills/controller-loop/assets/session-ledger.template.yaml`
- `examples/minimal-project/.agent-workflow/controller/session-ledger.yaml`

### `sdlc-review-inbox`

Purpose: assemble human review packets for lanes or waves.

Delegates: `independent-critic`, `review-inbox`,
`observability-diagnostics`.

Inputs: PR, critic report, CI checks, preview URL, telemetry, test plan,
rollback, risks, open questions.

Outputs: review packet, evidence completeness verdict, reviewer recommendation,
feedback route.

Stop conditions: missing CI, no preview/review deployment when required,
missing rollback, unresolved critical security finding.

Initial Verdify contract:

- `schemas/review-inbox-packet.schema.yaml`
- `skills/release-verification/references/review-inbox.md`
- `skills/release-verification/assets/review-inbox-packet.template.yaml`
- `examples/minimal-project/.agent-workflow/sprints/2026-06-22-a/review/review-inbox-packet.yaml`
- `schemas/observability-diagnostic-packet.schema.yaml` when runtime telemetry
  is material to the review decision

### `sdlc-release-path`

Purpose: integrate approved work and verify deployment separately from merge.

Delegates: `release-verification`, `environment-gitops`,
`observability-diagnostics`.

Inputs: approved PRs, release identity, deployment target, GitOps state,
promotion approval, rollback plan.

Outputs: merge/release record, deployment evidence, runtime verification,
rollback proof, outcome acceptance request.

Stop conditions: protected environment approval missing, degraded runtime,
unverified rollback, GitHub/deployment state disagreement.

### `sdlc-learning-capture`

Purpose: mine research, sessions, failed loops, review feedback, and tool
friction into proposed improvements.

Delegates: `learning-capture`, `northstar-planning`.

Inputs: session summaries, command history, review comments, validation
failures, research artifacts, accepted corrections.

Outputs: validated `NLP-*` learning proposals, backlog issues,
artifact/schema proposals, skill update proposals, no-op findings, and
loop-readiness verdicts.

Stop conditions: raw secret exposure, weak evidence, missing redaction policy,
recurring loop lacks verifier/state/stop/budget/manual proof.

Initial Verdify contract:

- `schemas/northstar-learning-proposals.schema.yaml`
- `skills/northstar-planning/references/learning-capture.md`
- `skills/northstar-planning/assets/northstar-learning-proposals.template.yaml`
- `examples/minimal-project/.agent-workflow/northstar/learning-capture/learning-proposals.yaml`

## Milestones

| Milestone | Outcome | Entry criteria | Exit evidence |
| --- | --- | --- | --- |
| M0 Repository routable | OpenClaw can route the repo into exactly one lifecycle action. | Repo exists and GitHub identity is known. | Route decision, validator result, repo-hygiene initial findings. |
| M1 Intent captured | Ideation has become evidence, questions, and candidate backlog. | Transcript, notes, or issue input exists. | Evidence registry entries and routed intake artifacts. |
| M2 North Star coherent | Product and architecture drafts are cross-linked and reviewable. | Enough evidence exists to draft intent and architecture. | North Star artifacts, interview packet, review script. |
| M3 Definition and architecture ready | Project definition and contracts are sufficient for backlog strategy. | North Star direction is accepted for planning input. | Project definition, architecture contracts, ADRs. |
| M4 Backlog executable | Candidate issues and dependencies are reconciled. | GitHub state is fresh. | State-of-union, issue recommendations, milestone/project update. |
| M5 Readiness approved | Repo/platform/domain gates pass or block explicitly. | Candidate pilot or wave exists. | Readiness artifacts, gate decisions, exceptions. |
| M6 Wave executable | Lanes, branches, worktrees, CI, preview, and rollback are explicit. | Approved issue set and readiness evidence. | Sprint plan, lane contracts, wave release plan. |
| M7 Review-ready | Worker output has independent review and complete packet evidence. | Lane PRs exist and checks run. | Critic reports, review inbox packet, diagnostics. |
| M8 Production verified | Deployment and runtime outcome are verified after merge. | Human approval for protected promotion. | Deployment record, smoke tests, telemetry, rollback evidence. |
| M9 Learning captured | Reusable lessons are staged for future improvement. | Delivery outcome or review feedback exists. | Learning proposal packet and follow-up issues. |

## Governance Rules

- OpenClaw may request, summarize, and route work, but GitHub and durable
  artifacts remain authoritative.
- One issue, lane, branch, worktree, worker session, and PR is the default
  implementation unit.
- Critic review and release verification are separate roles. Worker closeout is
  never sufficient for integration or production outcome acceptance.
- Production access, secret reads, broad Kubernetes mutation, browser terminal
  access, and protected North Star lock approval require explicit gates.
- Runtime deployment proof is separate from merge success.
- Recurring OpenClaw loops require verifier, durable state, stop condition,
  budget, permissions, objective done criteria, and one reliable manual run.

## Skill Promotion Order

1. `review-inbox`: needed to make human review packets concrete. Initial
   packet/schema contract exists under `release-verification`; top-level skill
   promotion remains pending one reliable manual run.
2. `wave-release-planning`: needed before worker dispatch for CI/CD and preview
   expectations. Initial plan/schema contract exists under `sprint-planning`;
   top-level skill promotion remains pending one reliable manual run.
3. `session-ledger`: needed once OpenClaw supervises multiple worker/critic
   sessions concurrently. Initial ledger/schema contract exists under
   `controller-loop`; top-level skill promotion remains pending one reliable
   manual run.
4. `observability-diagnostics`: needed for review-ready and production proof.
   Initial diagnostic packet/schema contract exists under
   `release-verification`; top-level skill promotion remains pending one
   reliable manual run.
5. `agent-platform-control`: initial request/schema contract exists under
   `platform-readiness`; top-level skill promotion remains pending concrete
   Agent Platform MCP/API operations and one reliable manual run.
6. `learning-capture`: initial proposal schema/reference/template contract
   exists under `northstar-planning`; top-level promotion and recurring scans
   remain pending redaction, retention, verifier, and manual-run proof.

## Initial Implementation Slice

The first practical slice is not production autonomy. It is a non-Gravity pilot
that exercises:

1. `sdlc-bootstrap-repo`
2. `sdlc-ideation-intake`
3. `sdlc-northstar-loop`
4. `sdlc-backlog-strategy`
5. `sdlc-readiness-gates`
6. `sdlc-wave-planning`
7. `sdlc-lane-dispatch`
8. `sdlc-review-inbox`
9. `sdlc-release-path` against a protected non-production environment
10. `sdlc-learning-capture`

Exit proof for the slice: one issue moves through branch, worktree, PR, checks,
critic review, review packet, preview or review deployment, protected promotion
rehearsal, release verification, outcome record, and learning proposal without
using hidden chat state as authority.
