# North Star Architecture

Status: `review_requested`
Iteration: `26`
Review: `requested`
Evidence registry: `.agent-workflow/northstar/evidence-registry.yaml`
Product pair: `.agent-workflow/northstar/NORTHSTAR_PRODUCT.md`
Loop record: `.agent-workflow/northstar/northstar-artifacts.yaml`

> **Iteration 26 (2026-07-27): local-delivery architecture audit revision.** Iteration 25 remains the protected architecture authority until Jason explicitly locks this revision. The proposed delta adds a capability-qualified supported Forgejo release and internal IdP, repository and portfolio-work authority, raw-body event admission and a durable delivery ledger, transport-neutral trusted statuses, repository-owned Argo Workflows, immutable package subjects and signed release envelopes in Zot, a GitOps-only stable-harness package consumer, internal immutable dependency mirrors, coordinated control-plane recovery, coexistence, failure injection, and attended cutover. This draft authorizes no implementation or protected mutation.

## Ten Iteration-25 Locked Architecture Constraints

| # | Architecture constraint |
| --- | --- |
| 1 | The complete July 9 review is the default architecture input; exceptions require new evidence and explicit authority. |
| 2 | Pre-lock overhead stays narrow, while package publication and installation form one exact-artifact, trusted-staging, integrity-checked, conflict-safe, atomic, recoverable transaction. |
| 3 | Verdify Skills remains proprietary and internal-first; possible future open-source publication does not add an external community or compatibility architecture now. The expanded public-rights, off-platform/package-use, and contributor-intake contract remains a proposed iteration-26 delta under `NSQ-017`, not an iteration-25 locked constraint. |
| 4 | There is no backwards-compatibility obligation; coordinated consumer cutover ends by deleting deprecated capability, aliases, duplicate schemas, routes, and shims. |
| 5 | Verdify Skills, Agent Platform, Orbit, and Gravity are co-equal active pilots connected by a common `PilotProject` contract and root-planner outer loop without losing project-local authority. |
| 6 | Policy separates Jason-only North Star lock, Jason-or-James release approval, James's npm-publisher role, and independent current-head PR review. |
| 7 | Current restarted Gravity source and runtime are authoritative; the prior instance is retired evidence, not an integration target. |
| 8 | Gravity's shared boundary is a versioned tenant-scoped read-only HTTP evidence API plus consumer MCP adapter with equivalent authorization, resolvable citations, typed denials, durability, health, identity, and audit. |
| 9 | Orbit spans authorized email, calendars, enterprise documents, transcripts, notes, conversations, meetings, and engineering context through governed connectors, with personal context separated from fleet actuation. |
| 10 | Delivery optimizes for the earliest safely complete four-project self-building slice, has no artificial calendar deadline, routes gaps to owning repositories, and reuses the proven contracts for customer consulting. |

## ARCH-001 Architecture Intent

- Architecture purpose: provide one human-governed outer planning loop and shared method across four co-equal pilot systems, with project-owned authority, versioned capabilities, deterministic transitions, least-privilege data and control planes, cited evidence, and independently verified delivery.
- Current state: Verdify Skills provides substantial declarative lifecycle machinery, Agent Platform provides shared runtime services, Orbit has a healthy repo pod but no authorized personal connectors, and Gravity has a live read-only search/MCP engine whose cross-pilot transport and citations are incomplete. Their authority, versions, readiness records, and dispatch contracts do not yet converge.
- Target state: the root planning agent consumes four `PilotProject` records and a dependency graph, then uses Verdify Skills to route work through supported Agent Platform capabilities, governed Orbit information sources, and a cited Gravity evidence boundary. Each pilot retains its own North Star, backlog, runtime, deployment, and outcome authority.
- Non-goals: do not preserve deprecated capability through compatibility shims, make Orbit or Agent Platform globally authoritative over the other projects, treat runtime adapters as product identities, rebuild retired Gravity, expose untrusted personal context directly to fleet actuation, or infer a future lock from ordinary review or release activity.
- Product links: `PRODUCT-001`, `PRODUCT-014`, `PRQ-001`, `PRQ-005`, `PRQ-030` through `PRQ-037`.
- Evidence: all registered evidence items, especially the July 9 adversarial review, Jason feedback, explicit iteration-25 lock approval, and fresh Agent Platform, Orbit, and Gravity audits (`northstar://evidence/NSE-20260709-*`), supported by the earlier security, delivery, GitOps, observability, session-ledger, control-request, backlog-sync, and learning-loop research.

## ARCH-002 Architecture Stories

| Story ID | Actor / system | Story | Acceptance signal | Product links | Evidence |
| --- | --- | --- | --- | --- | --- |
| AST-001 | Root planning agent | As the durable portfolio outer loop, I can reconcile all four pilot states and keep planning moving through evidence, research, questions, design, dependencies, and feedback until Jason final lock is requested. | Router and portfolio state name one next action without overriding project authority or inferring approval. | `PRQ-001`, `PRQ-002`, `PRQ-030`, `PRQ-032` | `NSE-20260709-jason-review-feedback`, `NSE-20260709-agents-current-state-audit` |
| AST-002 | Worktree agent | As an execution agent, I can trace my lane to product and architecture IDs instead of chat history. | Lane contracts cite North Star IDs and evidence references. | `PRQ-005`, `PST-003` | all registered evidence items |
| AST-003 | Platform operator | As an operator, I can enforce protected integration, trusted package/runtime versions, capability authorization, observability, and rollback before a cross-pilot dependency is trusted. | Platform and project readiness distinguish active development from release-verified integration. | `PRQ-003`, `PRQ-004`, `PRQ-034` | all 2026-07-09 evidence items |
| AST-004 | Human reviewer | As a reviewer, I can inspect review-ready changes with evidence, test steps, and rollback context. | Review inbox validates a packet with PR/MR identity, exact head SHA, checks, preview/review deployment, telemetry, security, rollback, recommendation, and feedback route. | `PST-004`, `SURF-004` | `NSE-20260623-cicd-sdlc-agent-orchestration-human-governed-delivery`, `NSE-20260623-review-inbox-product-examples`, `NSE-20260623-review-inbox-skill-implementation-best-p` |
| AST-005 | CLI operator | As an operator, I can run one dependency-light CLI to initialize, route, validate, ingest evidence, manage lanes, compile prompts, and reconcile authoritative forge plus mirror state. | `bin/verdify --help` exposes the canonical command set; provider-neutral CLI and current GitHub/capability-qualified Forgejo adapter tests pass. | `PRQ-008`, `SURF-006` | `README.md`, `lib/verdify/cli.rb` |
| AST-006 | Skills maintainer | As a maintainer, I can validate the exact packed artifact, installer transaction, managed host links, transitions, critic independence, executable evals, archive file set, provenance, and consumer behavior before release. | Source and exact-artifact gates pass, and no unmanaged target path is executed or deleted. | `PRQ-007`, `PRQ-009`, `PRQ-034`, `PST-006`, `PST-022` | `NSE-20260709-verdify-skills-adversarial-review` |
| AST-007 | Critic | As a critic, I can use a separate worktree and session to review without sharing worker state. | Critic lease/worktree and critic artifact are separate from worker lease/worktree. | `PRQ-011`, `PRQ-012`, `PST-007` | `ADR-0003`, `COMMON_OPERATING_CONTRACT.md` |
| AST-008 | Target repository | As an installed repository, I can carry only durable `.agent-workflow` state and host symlinks, not hidden chat memory. | Install/init writes starter artifacts and host discovery links. | `PRQ-013`, `SURF-007`, `SURF-008` | `README.md` |
| AST-009 | North Star interviewer | As a planning agent, I can turn review-ready drafts and new evidence into prioritized human questions without recording approval. | `NORTHSTAR_INTERVIEW.md` contains proposed defaults, options, tradeoffs, affected IDs, evidence references, and answer-capture rules. | `PRQ-016`, `PST-009`, `SURF-011` | `NSE-20260623-end-to-end-agent-based-sdlc`, `ADR-0008` |
| AST-010 | Orbit | As the personal-assistant and engineering-chief-of-staff information layer, I can retrieve authorized context and delegate supported workflows without sharing one broad trust principal with fleet actuation. | Connector records and policy separate personal reads, proposed actions, and authorized writes; runtime adapters remain replaceable. | `PRQ-022`, `PRQ-028`, `PRQ-035`, `PST-010`, `SURF-018` | `NSE-20260709-jason-review-feedback`, `NSE-20260709-orbit-current-state-audit` |
| AST-011 | Agent Platform pilot | As the shared runtime and control capability provider, I can advertise supported operation versions and accept semantic tasks through authorized adapters rather than requiring one worker topology. | Capability negotiation chooses supported fixed-worker or approved fallback strategies and records durable results. | `PRQ-017`, `PRQ-018`, `PRQ-033`, `PST-012` | `NSE-20260709-agents-current-state-audit`, `NSE-20260709-verdify-skills-adversarial-review` |
| AST-012 | Gravity pilot | As the active evidence product, I can expose versioned tenant-scoped read-only search and evidence resolution to authorized consumers while preserving my own project authority. | Current HTTP and MCP adapter contracts return cited results or typed denials and advertise accurate capability state. | `PRQ-019`, `PRQ-036`, `PST-011`, `SURF-013` | `NSE-20260709-gravity-current-state-audit` |
| AST-013 | Learning-capture loop | As a skills maintainer, I can mine sessions and research for recurring lessons, then stage evidence-backed proposals instead of letting agents rewrite skills silently. | Learning-capture packets route each lesson to content, context files, slash commands, skills, hooks, tools/CLI fixes, config, backlog, or no-op with evidence and approval requirement. | `PRQ-020`, `PST-013`, `SURF-014` | `NSE-20260623-long-horizon-agent-compounding-learning`, `NSE-20260623-long-horizon-learning-loop-source-verification` |
| AST-014 | Loop readiness checker | As a controller or operator, I can determine whether a candidate recurring loop has enough verifier, state, stop, budget, and objective done criteria to automate safely. | Loop automation requires a proven manual run and checklist before scheduling. | `PRQ-021`, `PST-014` | `NSE-20260623-long-horizon-agent-compounding-learning`, `NSE-20260623-long-horizon-learning-loop-source-verification` |
| AST-015 | Conversational workflow adapter | As an Orbit, OpenClaw, Hermes, Codex, or Claude user, I can expose ideation-to-production workflows while delegating execution to Verdify lifecycle skills and preserving configured-forge and `.agent-workflow` authority. | Each replaceable adapter maps intent to delegated skills, supported provider capabilities, durable artifacts, stop conditions, and proof requirements. | `PRQ-022`, `PST-015`, `SURF-015` | `NSE-20260709-jason-review-feedback`, `NSE-20260709-orbit-current-state-audit` |
| AST-016 | Repo controller bootstrap | As a newly assigned repo controller, I can discover my repo, authoritative forge and mirror state, runtime namespace, storage, credential references, observability, CI/CD, package needs, and planning gaps before proposing ownership changes. | A bootstrap packet records evidence, missing access, safe credential-validation results, AGENTS.md update proposal, issue recommendations, and PR proposal. | `PRQ-023`, `PRQ-024`, `PST-016`, `SURF-016` | `NSE-20260623-repo-controller-bootstrap-self-discovery` |
| AST-017 | Fleet controller runtime | As the Agent Platform runtime, I can expose repo controller sessions, worktrees, tmux/web/API views, durable state, and recovery status without relying on hidden chat context. | Session ledger, dashboard, and control request records reconstruct controller and child worktree state after restarts. | `PRQ-026`, `PST-017`, `SURF-017` | `NSE-20260623-repo-controller-bootstrap-self-discovery`, `NSE-20260623-session-ledger-implementation-best-pract` |
| AST-018 | Platform security boundary | As the security/platform layer, I can distinguish repo-local agents from infrastructure domain agents and gate broader access through owner, scope, audit, and approval records. | Platform readiness records domain-agent authority classes and blocks broad access without approval. | `PRQ-024`, `PRQ-025`, `PST-018` | `NSE-20260623-repo-controller-bootstrap-self-discovery`, `NSE-20260623-secrets-credential-injection-patterns` |
| AST-019 | Orbit context plane | As Jason's assistant, I can combine personal, enterprise, meeting, and engineering sources with source identity, ACL, tenant, freshness, provenance, retention, and read-audit controls. | Context cannot directly actuate the configured forge, Kubernetes, calendars, messages, or documents without a separate authorized policy decision. | `PRQ-028`, `PRQ-035`, `PST-019`, `PST-023`, `SURF-018` | `NSE-20260709-jason-review-feedback`, `NSE-20260709-orbit-current-state-audit` |
| AST-020 | Repo-agent scope contract | As a repo-associated controller, I can declare my scope, ownership, responsibilities, authority boundaries, runtime context, and escalation paths as a typed artifact before acting. | `repo-agent-scope.yaml` validates and links to discovery evidence, authoritative records, and handoff. | `PRQ-029`, `PST-020`, `SURF-019` | `NSE-20260623-repo-controller-bootstrap-self-discovery` |
| AST-021 | Four-project portfolio | As the root planner, I can compare four project-owned states through one `PilotProject` interface and route dependencies without hardcoding one repository as the global product authority. | Four current records expose revision, lifecycle, capabilities, gates, health, evidence, outcomes, tenancy, identity, idempotency, audit, and failure states. | `PRQ-030`, `PRQ-032`, `PST-021`, `SURF-020` | all 2026-07-09 evidence items |
| AST-022 | Package consumer | As a consumer repo, I can install or update Verdify atomically from one verified artifact and receive an explicit conflict or rollback instead of target-controlled execution or destructive replacement. | Trusted package transaction evidence links source, artifact, target inventory, managed ownership, switch, cleanup, and rollback. | `PRQ-013`, `PRQ-034`, `PST-022`, `SURF-021` | `NSE-20260709-verdify-skills-adversarial-review` |
| AST-023 | Gravity evidence consumer | As Orbit or another authorized pilot, I can request cited Gravity evidence through the versioned HTTP boundary and MCP adapter under one tenant/auth context. | API/MCP parity and negative tests cover missing, deleted, suppressed, mismatched, and cross-tenant references. | `PRQ-036`, `PST-024`, `SURF-013` | `NSE-20260709-gravity-current-state-audit` |
| AST-024 | Release approver | As Jason or James, I can approve a package release without that action being interpreted as North Star lock. | Release and North Star records use separate authority types, identities, and evidence. | `PRQ-037` | `NSE-20260709-jason-review-feedback` |
| AST-025 | Customer consulting project | As a customer project owner, I can adopt the same lifecycle, pilot contract, capability discovery, evidence, review, and deployment controls without inheriting another project's authority or private context. | Customer identity, tenant, data, backlog, runtime, evidence, approval, and outcome boundaries validate independently while remaining legible to the root planner. | `PRQ-038`, `PST-026` | `NSE-20260709-jason-review-feedback` |

## ARCH-003 Architecture Requirements

| Requirement ID | Requirement | Quality / domain | Acceptance signal | Product links | Evidence |
| --- | --- | --- | --- | --- | --- |
| ARQ-001 | North Star product and architecture artifacts must be versioned, reviewable markdown with a machine-readable loop and signoff record. | governance | `northstar-artifacts.yaml` validates and records status, evidence, questions, research path, review feedback, and approvals. | `PRQ-001`, `PRQ-002` | all registered evidence items |
| ARQ-002 | Delivery control must remain Git-anchored, human-governed, and branch-enforced. | delivery | Protected `dev` accepts reviewed implementation; `main` accepts reviewed release promotion only; release approval by Jason or James remains distinct from Jason-only North Star lock. | `PRQ-004`, `PRQ-005`, `PRQ-037` | `NSE-20260709-jason-review-feedback`, `NSE-20260709-verdify-skills-adversarial-review` |
| ARQ-003 | Platform and information access must follow least privilege, separate principals, short-lived credentials, runtime injection, and purpose-bound policy. | security | Personal connector principals cannot actuate the fleet; fleet controllers cannot read raw personal sources except through audited scoped requests; no agent has broad production mutation or secret access by default. | `PRQ-003`, `PRQ-024`, `PRQ-035` | `NSE-20260709-orbit-current-state-audit`, `NSE-20260623-secrets-credential-injection-patterns` |
| ARQ-004 | Every repo/application must expose standard observability and diagnostic links. | operability | Metrics, logs, traces, endpoint health, storage health, deployment markers, signal assessments, and explicit missing-telemetry findings are recorded in review or diagnostic packets. | `PRQ-004`, `SURF-004` | all registered evidence items, especially `NSE-20260623-agent-platform-live-state-audit`, `NSE-20260623-review-inbox-product-examples`, `NSE-20260623-review-inbox-skill-implementation-best-p`, and `NSE-20260623-observability-diagnostics-implementation` |
| ARQ-005 | Session and wave history must survive model context loss. | auditability | `session-ledger.schema.yaml` validates append-oriented events, parent/child sessions, correlation IDs, issue/branch/PR/deployment links, decisions, outcomes, artifact/evidence/external refs, checksums, and explicit exceptions. | `PRQ-005` | all registered evidence items, especially `NSE-20260623-session-ledger-implementation-best-pract` |
| ARQ-006 | CI/CD based wave deployment must be modeled as a first-class architecture path. | delivery | Deployment-affecting waves validate `wave-release-plan.schema.yaml` with branch/merge model, CI events/checks, environments, GitOps desired state, deployment strategy, observability, rollback, release-health signals, and review handoff before dispatch; environment-sensitive waves validate `environment-gitops-reconciliation.schema.yaml` with desired state, controller status, namespace controls, health, drift, remediation, cleanup, and handoff. | `PRQ-006`, `PRQ-005` | `NSE-20260623-kubernetes-gitops-cicd-cardinality`, `NSE-20260623-cicd-sdlc-agent-orchestration-human-governed-delivery`, `NSE-20260623-wave-release-planning-implementation-bes`, `NSE-20260623-environment-gitops-implementation-best-p` |
| ARQ-007 | The package must keep the smallest coherent lifecycle and facade graph, with no deprecated aliases or duplicate execution paths after coordinated cutover. | maintainability | Every retained skill has an exercised contract or consumer; consolidation/removal passes executable evals and consumer conformance, and managed host links never overwrite unmanaged paths. | `PRQ-007`, `PRQ-031` | `NSE-20260709-jason-review-feedback`, `NSE-20260709-verdify-skills-adversarial-review` |
| ARQ-008 | The CLI must remain dependency-light and schema-driven for local and target repositories. | portability | Core commands run through Ruby standard-library code, validate artifacts by schema, and avoid hidden service dependencies. | `PRQ-008`, `PRQ-013` | `README.md`, `lib/verdify/cli.rb` |
| ARQ-009 | Durable artifacts must be the handoff layer between roles and sessions. | reliability | `.agent-workflow` records carry route decisions, project definitions, contracts, leases, evidence, readiness, release, and review state. | `PRQ-009`, `PRQ-015` | `COMMON_OPERATING_CONTRACT.md` |
| ARQ-010 | Source-control providers must reconcile with, not replace, durable artifact contracts. | governance | Until iteration-26 lock and attended cutover, `github-backlog-sync.schema.yaml` preserves GitHub authority. The target adds a provider-neutral reconciliation contract and Forgejo adapter, then classifies GitHub as a mirror without losing issue, PR, review, status, deployment, or action traceability. | `PRQ-010`, `PRQ-015`, `PRQ-039` | `ADR-0001`, `NSE-20260623-github-backlog-sync-implementation-best`, `NSE-20260727-verdify-skills-local-delivery-inventory` |
| ARQ-011 | Lane and worktree identity must be enforced before worker or critic execution. | isolation | Worker leases reject duplicate active leases; critic review uses a separate detached worktree/session. | `PRQ-011`, `PRQ-012` | `ADR-0003` |
| ARQ-012 | Validation must enforce package structure, document coherence, cross-artifact transitions, current-head identity, critic independence, nonempty evidence, executable evals, exact artifact contents, host-link ownership, and consumer conformance. | quality | A deliberately invalid transition, self-review, empty approval, stale head, corrupt archive, unmanaged collision, or broken behavior fixture fails before routing, merge, release, or consumer adoption. | `PRQ-007`, `PRQ-009`, `PRQ-012`, `PRQ-015`, `PRQ-034` | `NSE-20260709-verdify-skills-adversarial-review` |
| ARQ-013 | Readiness loops must remain inventory/checklist/planning roles, not feature-implementation lanes. | governance | Repo hygiene, platform readiness, and Gravity readiness produce artifacts and stop before unsafe implementation; platform readiness owns the first environment GitOps reconciliation artifact for desired/observed state and drift evidence. | `PRQ-003`, `PRQ-014` | `ADR-0004`, transcript evidence, `NSE-20260623-environment-gitops-implementation-best-p` |
| ARQ-014 | Package installation must be a trusted, exact-artifact, atomic, conflict-safe, and reversible transaction with a small explicit target footprint. | portability/security | Private staging verifies integrity/provenance before execution; managed ownership is explicit; unmanaged paths are refused; one version is switched atomically; cleanup occurs after success; rollback is tested. | `PRQ-013`, `PRQ-034` | `NSE-20260709-verdify-skills-adversarial-review` |
| ARQ-015 | North Star interview output must be durable, evidence-linked, and separate from final approval. | governance | `NORTHSTAR_INTERVIEW.md` records prioritized questions, proposed defaults, tradeoffs, affected IDs, evidence references, and answer capture; final approval remains in `northstar-artifacts.yaml` and gate records only. | `PRQ-016`, `PST-009`, `SURF-011` | `NSE-20260623-end-to-end-agent-based-sdlc`, `ADR-0008` |
| ARQ-016 | The architecture must model the owned-IP system as a self-hosted source-control, CI/CD, pipeline, k3s, agent, and evidence/knowledge operating plane. | product architecture | Platform readiness, controller-loop, and delivery plans cover these surfaces together rather than as unrelated repositories. | `PRQ-017`, `PST-012` | `NSE-20260623-agent-platform-sunshine-gravity-ip-priorities`, `NSE-20260623-agent-platform-live-state-audit`, `NSE-20260623-source-control-migration-local-forges` |
| ARQ-017 | Agent Platform control surfaces must advertise versioned capabilities and negotiate topology-neutral semantic tasks, with UI as inspection, review, recovery, and operator console. | interface | Capability and dispatch contracts identify supported/disabled/gated operations, transports, auth scopes, payload/result schemas, idempotency, worker topology, limits, selected adapter, result refs, heartbeats, and failures. | `PRQ-018`, `PRQ-033`, `PST-010`, `SURF-012` | `NSE-20260709-agents-current-state-audit`, `NSE-20260709-verdify-skills-adversarial-review` |
| ARQ-018 | Gravity must be modeled from its current active repository and runtime as the reusable evidence service, with historical Sunshine material treated only as optional reuse evidence. | modularity/interface | Current product/architecture/ADRs/readiness agree with the live versioned read-only HTTP API, consumer MCP adapter, tenant boundary, citations, health, durability, rollback, and capability state. | `PRQ-019`, `PRQ-036`, `PST-011`, `SURF-013` | `NSE-20260709-gravity-current-state-audit` |
| ARQ-019 | Learning capture must be proposal-only by default and evidence-backed. | governance | Each proposal records evidence line or artifact, redaction policy, observed issue/opportunity, verification performed, destination, risk class, approval requirement, routing decision, and affected artifacts. | `PRQ-020`, `PST-013`, `SURF-014` | `NSE-20260623-long-horizon-agent-compounding-learning`, `NSE-20260623-long-horizon-learning-loop-source-verification`, `NSE-20260623-learning-capture-implementation-best-pra` |
| ARQ-020 | Recurring agent loops must have explicit verifier, state, stop condition, budget, permissions, and objective done criteria before scheduling. | reliability | Loop specs fail readiness when they lack recurrence, automatic rejection path, end-to-end permissions, state record, stop/iteration cap, cost budget, one reliable manual run, or explicit scheduling verdict. | `PRQ-021`, `PST-014` | `NSE-20260623-long-horizon-agent-compounding-learning`, `NSE-20260623-long-horizon-learning-loop-source-verification`, `NSE-20260623-learning-capture-implementation-best-pra` |
| ARQ-021 | Optional conversational workflow adapters must remain thin facades over Verdify lifecycle contracts, configured-forge primitives, Agent Platform capabilities, and durable `.agent-workflow` records. | interface/governance | Each adapter names delegated skills, supported capabilities, authoritative records, mirror refs, stop conditions, human gates, and evidence; adapter state or availability cannot change project authority. | `PRQ-022`, `PST-015`, `SURF-015` | `NSE-20260709-jason-review-feedback`, `NSE-20260709-orbit-current-state-audit` |
| ARQ-022 | Repo-controller bootstrap must be a schema-backed workflow over existing lifecycle skills, not an ungoverned shell checklist. | governance/interface | Bootstrap records input sources, evidence status, missing access, inventory findings, safe credential-validation metadata, proposed issues, and PR output; changes route through the configured authoritative forge and `.agent-workflow`. | `PRQ-023`, `PRQ-024`, `SURF-016` | `NSE-20260623-repo-controller-bootstrap-self-discovery` |
| ARQ-023 | Repo-controller runtime must separate durable state, Git worktrees, authorized mounts, tmux sessions, web/API views, and controller recovery state. | reliability/operations | PVC/workspace layout, worktree paths, mount inventory, tmux/API connection profiles, VS Code workspace folders, and recovery status are visible and reconstructable without hidden chat memory. | `PRQ-023`, `PRQ-026`, `PST-016`, `PST-017` | `NSE-20260623-repo-controller-bootstrap-self-discovery`, `NSE-20260623-session-ledger-implementation-best-pract` |
| ARQ-024 | Namespace, storage, route, secret, and image changes must be mediated by platform contracts or PR-reviewed desired state. | security/platform | Owner/repo/environment namespace naming, NFS/PVC mounts, route/DNS propagation, base-image package changes, registry rollback, and domain-agent access have owners, gates, audit, and rollback paths. | `PRQ-024`, `PRQ-025`, `PST-018` | `NSE-20260623-repo-controller-bootstrap-self-discovery`, `NSE-20260623-environment-gitops-implementation-best-p`, `NSE-20260623-secrets-credential-injection-patterns` |
| ARQ-025 | Controller loops must emit enough telemetry for dashboards, alerts, recovery, and review. | observability/reliability | Prometheus/Grafana and diagnostic packets expose controller health, pod health, loop counts, stop reasons, ledger events, alert routing, recovery attempts, resource usage, and outstanding-work rehydration. | `PRQ-026`, `SURF-017` | `NSE-20260623-repo-controller-bootstrap-self-discovery`, `NSE-20260623-observability-diagnostics-implementation`, `NSE-20260623-session-ledger-implementation-best-pract` |
| ARQ-026 | Orbit must use a separate governed connector plane for authorized personal, enterprise, meeting, and engineering context. | interface/governance/security | Sources carry account, tenant, classification, approved purpose, minimum scopes, ACL, freshness cursor, provenance, raw/derived retention, correction/deletion, read audit, revocation, and proposed/write authority; cross-account and prompt-actuation tests fail closed. | `PRQ-028`, `PRQ-035`, `PST-019`, `PST-023`, `SURF-018` | `NSE-20260709-orbit-current-state-audit` |
| ARQ-027 | Repo-associated agents must have a typed scope and responsibility contract before they claim ownership. | governance/security | `repo-agent-scope.schema.yaml` validates repository identity, scope, ownership, responsibilities, authority boundaries, discovery inputs, runtime context, escalation paths, review, handoff, and approval. | `PRQ-029`, `PST-020`, `SURF-019` | `NSE-20260623-repo-controller-bootstrap-self-discovery` |
| ARQ-028 | North Star question resolution must scale open planning-question inventory into evidence-backed delegated answers and short human escalation packs. | planning/governance | `northstar-question-resolution` inventories, clusters, researches, resolves or escalates questions, and hands evidence-backed answers to `northstar-planning` without replacing final lock approval. | `PRQ-002`, `PRQ-016`, `PST-009` | `ADR-0009`, `NSE-20260624-question-resolution-workflow-brave-resea` |
| ARQ-029 | All four pilots must implement a common `PilotProject` status and capability interface without surrendering project-owned product authority. | integration/governance | Four records expose revision, lifecycle state, capabilities, gates, runtime/deployment health, evidence/outcomes, tenancy, identity, idempotency, audit, dependencies, and typed failure state. | `PRQ-030`, `PRQ-032`, `PST-021`, `SURF-020` | all 2026-07-09 evidence items |
| ARQ-030 | Package and consumer convergence may be breaking and must remove deprecated capability after an atomic cutover rather than retain compatibility layers. | maintainability/delivery | The wave records affected consumers, target version, migration action, verification, rollback, and deletion proof; no deprecated path remains after acceptance. | `PRQ-031` | `NSE-20260709-jason-review-feedback`, `NSE-20260709-verdify-skills-adversarial-review` |
| ARQ-031 | North Star lock authority and package release authority must be encoded as separate policy subjects. | governance | Lock records accept Jason only; release records accept Jason or James; review, npm publication, and release approval cannot satisfy lock validation. | `PRQ-037`, `PST-025` | `NSE-20260709-jason-review-feedback` |
| ARQ-032 | Gravity evidence references must be first-class contract outputs with API/MCP parity and tenant-aware denial semantics. | evidence/interface/security | Allowed results contain resolvable evidence references; missing, suppressed, deleted, mismatched, or cross-tenant refs fail closed under both HTTP and MCP. | `PRQ-036`, `PST-024`, `SURF-013` | `NSE-20260709-gravity-current-state-audit` |
| ARQ-033 | Capability state must distinguish implemented, deployed, exposed, integrated, and release-verified. | operability/integration | Root planner and consumers cannot infer callable or trusted capability from code existence, pod readiness, or a successful isolated probe alone. | `PRQ-030`, `PRQ-032`, `PRQ-036` | `NSE-20260709-agents-current-state-audit`, `NSE-20260709-gravity-current-state-audit` |
| ARQ-034 | Customer consulting projects must onboard through the same versioned lifecycle and `PilotProject` contracts with customer-scoped trust and ownership. | portability/tenancy/governance | Project bootstrap, North Star, backlog, agent scope, capabilities, credentials, data/evidence tenancy, CI/CD, review, deployment, and outcome acceptance remain customer-owned; Jason-private Orbit sources and internal pilot authority do not transfer by default. | `PRQ-038`, `PST-026` | `NSE-20260709-jason-review-feedback` |

## ARCH-004 High-Level Design

- System context: the root planning agent coordinates four project-owned pilots through registered evidence, authoritative-forge dependencies, mirror refs, `PilotProject` records, Verdify lifecycle artifacts, versioned capability adapters, and risk-based human gates. GitHub remains authority only until the approved attended cutover; target authority is provider-neutral with a Forgejo adapter.
- Major components: the smallest exercised Verdify lifecycle and facade set; `bin/verdify`; artifact, transition, and executable-eval validators; exact package transaction; four `PilotProject` records; root portfolio/dependency view; Agent Platform capability and semantic dispatch adapter; project-owned controllers and leases; Orbit connector broker and source/read-audit contracts; Gravity versioned HTTP evidence API plus MCP adapter; configured forge, CI/CD, GitOps, review, release, observability, mirror, and outcome evidence.
- Skill topology: router -> transcript/research intake -> North Star planning -> project definition -> architecture/contracts -> state-of-union -> repo hygiene -> sprint planning/orchestration -> controller/readiness/lane/critic/release loops.
- Artifact topology: schemas define every durable YAML contract; Markdown artifacts provide human review surfaces; route decisions name exactly one next skill/mode; evidence and traceability records preserve provenance.
- Runtime topology: Agent Platform owns repo pods, worker/session topology, Kubernetes/GitOps operations, CI integration, observability, and runtime identity enforcement. Orbit, OpenClaw, Hermes, Codex, and Claude are adapters or consumers within declared trust domains; they do not define the durable platform state. Gravity owns its service/runtime boundary and exposes read-only evidence through a versioned interface.
- Data flow: source/research/review feedback -> evidence registry -> four project North Stars and `PilotProject` records -> root dependency decision -> authoritative-forge issue/lane -> capability negotiation -> worker adapter -> PR/CI/preview -> critic/review -> deployment proof -> Gravity cited evidence -> Orbit source-linked report -> outcome acceptance -> learning proposal -> next outer-loop decision.
- Control flow: root planning chooses a project-owned next action; the project router chooses the earliest incomplete local lifecycle stage; capability negotiation chooses an authorized supported runtime adapter; deterministic transition validation prevents self-certification; Jason final lock gates protected North Star authority; Jason or James may approve package release.
- Failure modes: stale project record, conflicting project authority, unsupported dispatch operation, target-controlled installer content, unmanaged-path collision, partial release, invalid transition, self-review, empty evidence, stale head, version drift, connector trust-domain collapse, broad OAuth scope, raw personal data in source Git, missing ACL/provenance/freshness, prompt-driven actuation, Gravity citation omission, implemented-but-unexposed capability, misleading Ready health, and merge success without runtime proof.
- Product links: `PRODUCT-001`, `PRODUCT-007`, `PRODUCT-008`.
- Evidence: all registered evidence items.

## ARCH-005 Infrastructure And Environments

| Repository / application boundary | Environment / namespace model | Purpose | Owner | Quotas | Secrets model | Deployment path | Observability | Product links |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Verdify Skills repo | Local repo/worktree | Skill development, tests, draft artifacts | Skills maintainer | Host-local | Existing local credentials; do not print secrets | Git commits and PRs | CLI validation and test logs | `WAVE-000` |
| Agent Platform application | Dev namespace or namespace set, for example `<app>-dev` | Future agent execution and non-prod mutation | Platform owner | ResourceQuota and LimitRange required | Runtime-injected, least privilege | CI/CD wave deploys to dev through controlled automation | Prometheus/Grafana/logs/traces | `WAVE-001` |
| Any of the four pilot applications | Preview namespace per PR or wave, for example `pr-<id>` or `wave-<id>` | Reviewable temporary environment | Project and release/platform owner | Hard quota, TTL, default-deny NetworkPolicy | No production secrets; scoped preview secrets only | Issue/lane branch -> CI -> preview deployment | Endpoint health, pod health, logs, traces | `WAVE-002`, `PRQ-006`, `PRQ-030` |
| Application under review | Staging/review namespace or namespace set, for example `<app>-staging` | Human review of ready changes | Platform/release owner | Environment quota required | Protected environment secrets | Protected promotion after CI and review evidence | Review dashboards and smoke tests | `WAVE-002` |
| Production application | Production namespace or isolated cluster, for example `<app>-prod` | Protected live environment | Human release owner | Explicit quota and SLO capacity | No direct worker-agent credentials | Human-approved promotion only | SLOs, rollback signals, audit | `PRQ-003` |
| Target repository install | Private staging plus managed `.agent-skills`, `.agent-workflow`, `.agents/skills`, `.claude/skills`, and `AGENTS.md` footprint | Trusted local workflow installation | Repo owner | Host-local | Repo-local policy; installer never trusts target-controlled package content | Verify/provenance -> stage -> conflict check -> atomic switch -> post-check -> cleanup/rollback | Artifact, manifest, ownership, version, route, and rollback evidence | `PRQ-013`, `PRQ-034` |
| Repo controller pod | Owner/repo-aligned namespace or controller namespace plus authorized app namespaces | Durable repo controller, worktree sessions, bootstrap discovery, tmux/web/API access, and recovery | Repo controller owner and platform owner | PVC, ResourceQuota, LimitRange, and mount limits required | Runtime-injected references only; credential validation records safe metadata | Platform control request or GitOps desired state | Controller health, pod health, loop metrics, session ledger, alerts | `PRQ-023`, `PRQ-026`, `WAVE-008` |
| Root planning outer loop | Local Codex/root agent or future authorized controller runtime | Portfolio planning and cross-project dependency routing | Jason | Bounded by planning run and project scopes | Scoped configured-forge and mirror access; no raw secret retention | Read four `PilotProject` records and authoritative backlogs, propose one typed next action | Decision trace, evidence refs, issue/dependency updates, gate routing | `PRQ-030`, `PRQ-032`, `SURF-020` |
| Orbit connector plane | Separate principal or policy-enforcing broker adjacent to the Orbit repo pod | Authorized personal, enterprise, meeting, and project context | Jason / Orbit owner | Source- and tenant-specific quotas | Minimum-scope connector credentials isolated from fleet actuation | Read-only canary first; proposed/write actions require separate policy and human gate | Source freshness, ACL, provenance, read audit, revocation, retention, deletion/correction | `PRQ-028`, `PRQ-035`, `SURF-018` |
| Sunshine Club reference implementation | Existing Sunshine namespace and repo | Historical reuse evidence only where current Gravity code and contracts still benefit | Sunshine/Gravity owner | Existing app quotas/PVCs | Sunshine secrets and corpus access remain scoped to Sunshine | No required compatibility or automatic code migration | App and pipeline evidence when specifically cited | `PRQ-019`, `WAVE-005` |
| Active Gravity pilot | Current Gravity repo/app at its authoritative revision | Evidence ingestion, processing state, tenant-scoped search, citations, read-only API, and MCP adapter | Gravity owner | Declared by Gravity readiness | Runtime-injected, tenant-scoped service identity | Current CI/GitOps/runtime path; Gate B and readiness govern trusted cross-pilot consumption | Evidence spine, citations, API/MCP parity, health, durability, denial, rollback | `PRQ-019`, `PRQ-036`, `MS-005`, `MS-006` |

## ARCH-006 Interfaces And Integration Contracts

| Interface ID | Provider | Consumer | Contract | Versioning rule | Product links | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| IFACE-001 | Evidence registry | North Star planning | `northstar://evidence/<id>` plus YAML item and copied source | Append/update through ingest command | `PRQ-001` | all registered evidence items |
| IFACE-002 | North Star artifacts | Downstream lifecycle skills | `NORTHSTAR_PRODUCT.md`, `NORTHSTAR_ARCHITECTURE.md`, `northstar-artifacts.yaml` | Protected after approval | `PRQ-001`, `PRQ-005` | `NSE-20260623-walk-transcript-agent-platform-gravity-skills` |
| IFACE-003 | Router | Operator/controller | RouteDecision YAML with next skill/mode and evidence | Schema-versioned | `SURF-003` | `NSE-20260623-walk-transcript-agent-platform-gravity-skills` |
| IFACE-004 | Review inbox | Human reviewer | PR/MR identity, exact reviewed head SHA, issue/lane/sprint/North Star IDs, checks, preview/review deployment, reviewer guidance, telemetry, security, rollback, risks, questions | `ReviewInboxPacket` validated by `schemas/review-inbox-packet.schema.yaml` and owned initially by `release-verification` review-inbox mode | `SURF-004`, `PRQ-004` | `NSE-20260623-cicd-sdlc-agent-orchestration-human-governed-delivery`, `NSE-20260623-review-inbox-product-examples`, `NSE-20260623-review-inbox-skill-implementation-best-p` |
| IFACE-005 | `bin/verdify` CLI | Operators, skills, controllers | Standard commands for init, doctor, route, artifact validation, northstar evidence, sprint, lane, prompt, and provider-neutral source/backlog workflows | CLI help, provider contract, GitHub adapter, and Forgejo adapter are versioned with the package | `PRQ-008`, `SURF-006` | `README.md`, `lib/verdify/cli.rb` |
| IFACE-006 | Schemas | CLI and lifecycle skills | YAML/JSON schema files under `schemas/` referenced by `schema_ref` | Schema filename and `schema_version` define compatibility | `PRQ-009`, `SURF-007` | `schemas/` |
| IFACE-007 | Lane lease records | Lane workers, critics, orchestrator | Lease binds lane, issue, branch, baseline SHA, role, agent, session, and worktree path | Lease schema governs durable identity; paths are runtime details | `PRQ-011`, `SURF-009` | `ADR-0003` |
| IFACE-008 | Source/backlog provider primitives | Router, planner, orchestrator, release verifier | Issues, PRs, checks, reviews, releases, deployments, environments, dependencies, projects, snapshots, CLI reconciliation reports, provider IDs, and mirror refs | GitHub remains operational authority until migration ADR and attended cutover; the provider-neutral contract plus GitHub and Forgejo adapters records cache freshness, authority, split-brain, limitations, findings, and actions | `PRQ-010`, `SURF-010`, `PRQ-039` | `ADR-0001`, `NSE-20260623-source-control-migration-local-forges`, `NSE-20260623-github-backlog-sync-implementation-best` |
| IFACE-009 | Managed host discovery links | Codex and Claude sessions | Ownership-marked `.agents/skills/<skill>` and `.claude/skills/<skill>` links into one verified installed version | Installer owns only marked paths; unmanaged collisions fail by default; no deprecated links after atomic cutover | `PRQ-007`, `PRQ-013`, `PRQ-031`, `SURF-008` | `NSE-20260709-verdify-skills-adversarial-review` |
| IFACE-010 | Prompt compiler | Worker and critic agents | Compiled prompt plus input hash manifest from lane contract and role | Manifest schema records hashes and source paths | `PRQ-011`, `PRQ-012` | `lib/verdify/cli.rb` |
| IFACE-011 | North Star interview packet | Jason, James, North Star planning | Markdown packet with review findings, decisions, priorities, questions, proposed defaults, options, tradeoffs, affected IDs, evidence, and answer-capture rules | Regenerated when evidence or review feedback materially changes | `PRQ-016`, `SURF-011` | `ADR-0008`, `NSE-20260623-end-to-end-agent-based-sdlc` |
| IFACE-012 | Agent Platform capability and semantic dispatch contract | Root planner, Orbit, controller-loop, platform-readiness | `AgentPlatformCapabilities` plus `LaneDispatchRequest` and durable result records describing supported operations, versions, transport, auth scopes, topology, limits, idempotency, selected strategy, worker/session refs, heartbeats, evidence, and failures | Product/API and operation schema versioned; unsupported/disabled operations fail closed; current fixed-worker/task-worker and approved fallback adapters are conformance-tested | `PRQ-018`, `PRQ-033`, `SURF-012` | `NSE-20260709-agents-current-state-audit`, `NSE-20260709-verdify-skills-adversarial-review` |
| IFACE-013 | Current Gravity product and pack boundary | Gravity project, organization packs, readiness and consumers | Current Gravity product/architecture plus source, ingestion, content identity, processing, search, evidence, tenant, and pack contracts; Sunshine records are optional evidence rather than authority | Current Gravity repository and accepted contracts are authoritative; no backwards compatibility with retired implementations is required | `PRQ-019`, `PRQ-031`, `SURF-013` | `NSE-20260709-gravity-current-state-audit` |
| IFACE-014 | Learning-capture proposal packet | North Star planning, controller-loop, skills maintainer, root planner, optional adapters | `northstar-learning-proposals.schema.yaml` packet under `.agent-workflow/northstar/learning-capture/` with source refs, redaction policy, observed pattern, verification, destination, proposed change, risk class, approval requirement, routing decision, affected artifacts, loop-readiness answers, review, and handoff | Schema-versioned before automation; operator reference and template live under `skills/northstar-planning`; proposal scans may be scheduled only after loop-readiness approval; applying changes requires the configured approval path | `PRQ-020`, `PRQ-021`, `SURF-014` | `NSE-20260623-long-horizon-agent-compounding-learning`, `NSE-20260623-long-horizon-learning-loop-source-verification`, `NSE-20260623-learning-capture-implementation-best-pra` |
| IFACE-015 | Optional conversational workflow adapter | Orbit, OpenClaw, Hermes, Codex, Claude, Verdify lifecycle skills, Agent Platform, configured forge | Adapter request naming repository, intent, current route, source context, provider authority and mirror state, supported capabilities, delegated lifecycle action, gates, and durable outputs | Adapter may be replaced or unavailable without changing authority; no duplicate lifecycle or private state is permitted | `PRQ-022`, `SURF-015`, `PST-015` | `NSE-20260709-jason-review-feedback`, `NSE-20260709-orbit-current-state-audit` |
| IFACE-016 | Repo-bootstrap self-discovery packet | Repo controller, repo owner, platform-readiness, state-of-union | Inventory of repo/source/authoritative-forge/mirror/runtime/namespace/logs/metrics/routes/storage/credential references/CI/CD/package needs/gaps plus AGENTS.md proposal, issue recommendations, and PR proposal | First implementation should be a repo-hygiene/platform-readiness workflow artifact before becoming a standalone schema or skill | `PRQ-023`, `SURF-016`, `PST-016` | `NSE-20260623-repo-controller-bootstrap-self-discovery` |
| IFACE-017 | Fleet controller dashboard and alert routing | Controller-loop, platform readiness, SRE/operator | Prometheus/Grafana dashboards, Alertmanager routes, diagnostic packets, session-ledger refs, pod/controller/loop/resource/recovery signals | Dashboard and alert definitions are generated from platform readiness and controller-loop records, not hand-maintained private notes | `PRQ-026`, `SURF-017`, `PST-017` | `NSE-20260623-repo-controller-bootstrap-self-discovery`, `NSE-20260623-observability-diagnostics-implementation` |
| IFACE-018 | Orbit source and context contract | Orbit connector plane, Jason, root planner, project owners | Normalized source/account/tenant/classification/purpose/scope/ACL/freshness/provenance/retention/correction/deletion/read-audit records plus cited derived context and proposed action | Read-only minimum scope first; personal-context principal separated from fleet actuation; writes require policy and human authorization; raw bodies and secrets never enter logs or Git | `PRQ-028`, `PRQ-035`, `SURF-018`, `PST-019`, `PST-023` | `NSE-20260709-orbit-current-state-audit` |
| IFACE-019 | Repo-agent scope and responsibility contract | Repo-hygiene discovery, repo controller, platform-readiness, controller-loop, state-of-union | `RepoAgentScope` artifact with agent identity, repository identity, purpose, in/out scope, owned/protected paths, stakeholders, ownership, `RAS-*` responsibilities, authority boundaries, discovery inputs, runtime context, escalation paths, review, handoff, and approval | First contract validates with `schemas/repo-agent-scope.schema.yaml` and starts from `skills/repo-hygiene/assets/repo-agent-scope.template.yaml`; approved scope may be copied into controller state with source reference | `PRQ-029`, `SURF-019`, `PST-020` | `NSE-20260623-repo-controller-bootstrap-self-discovery` |
| IFACE-020 | Four pilot project controllers and authoritative backlogs | Root planning outer loop | `PilotProject` record with provider/authority identity, project revision, lifecycle/North Star state, authoritative backlog and mirror refs, capability versions, operations, gates, dependencies, runtime/deployment health, evidence/outcome refs, tenancy, identity, idempotency, audit, and typed failure state | Schema and provider/project adapters are versioned by Verdify; each project owns its record; stale or split-brain records cannot authorize execution | `PRQ-030`, `PRQ-032`, `SURF-020`, `PST-021` | all 2026-07-09 evidence items |
| IFACE-021 | Verdify package/release workflow | Consumer repository and release approver | Source revision, exact tarball/archive, manifest, integrity, provenance, managed-path inventory, staging, conflict verdict, atomic switch, cleanup, publication state, consumer verification, and rollback record | Breaking consumer convergence is allowed; one new version becomes authoritative only after canary proof; deprecated managed paths are deleted after success | `PRQ-013`, `PRQ-031`, `PRQ-034`, `SURF-021` | `NSE-20260709-verdify-skills-adversarial-review` |
| IFACE-022 | Active Gravity pilot | Orbit, root planner, and authorized pilot consumers | Versioned tenant-scoped HTTP search/evidence/status contract plus consumer-side MCP mapping for `gravity.search`, `gravity.get_evidence`, and `gravity.get_processing_status` | API version and MCP mapping are conformance-tested; results include resolvable citations or typed denials; state advertises implemented/deployed/exposed/integrated/release-verified separately | `PRQ-036`, `SURF-013`, `PST-024` | `NSE-20260709-gravity-current-state-audit` |

## ARCH-007 Security, RBAC, And Secrets

- Identity model: agents get scoped identities for the repo, lane, wave, and environment they are authorized to inspect or mutate.
- RBAC boundaries: direct writes are limited to dev/preview; staging and production change only through protected promotion.
- Secret injection: runtime secret references and short-lived credentials are preferred; raw secrets must not enter prompts, transcripts, logs, or source control.
- Bootstrap credential checks: self-discovery records credential locations, auth modes, scopes, owners, validation status, and failure mode only. It must not copy raw tokens, passwords, refresh tokens, API keys, client secrets, or private keys into prompts, artifacts, logs, or commits.
- Domain-agent authority: networking, storage, backup, and platform agents may require broader scoped access to owned systems, but that access must have an owner, scope, audit path, allowed operations, prohibited operations, rollback path, and approval gate.
- Repo-agent boundary: repo-local agents remain constrained to their assigned namespace, approved mounts, routes, secrets, and environment promotion path unless a platform/security gate grants more.
- Repo-agent scope contract: each repo-associated controller or long-lived agent declares scope, ownership, responsibilities, allowed and prohibited operations, credential rules, runtime context, and escalation paths in `repo-agent-scope.yaml` before claiming ownership.
- Worktree isolation: worker and critic sessions must have separate leases/worktrees; one active worker lease per lane is permitted.
- Delivery authority: backlog and delivery changes flow through the configured authoritative forge's issues, PRs, checks, reviews, deployments, and releases rather than private state; GitHub is current authority before cutover and a mirror afterward.
- Prohibited access: no broad production mutation, no broad Kubernetes secret list/watch for worker agents, no default production browser terminal, no raw secret values in prompts or committed artifacts.
- Audit evidence: session ledger, lease records, prompt manifests, PR reviews, deployment approvals, and telemetry links must record privileged or lifecycle-significant actions.
- MCP/API authorization: the root planner and optional runtime adapters may request actions, but Agent Platform and Verdify policies remain responsible for authorization, policy checks, traceability, and human routing.
- Orbit trust split: personal-source connectors and fleet actuation use separate principals or a policy-enforcing broker. A connector read can produce cited context or a proposed action, but it cannot directly invoke configured-forge, Kubernetes, calendar, document, or outbound-message writes.
- Orbit source governance: every source records human principal, runtime actor, account, tenant, classification, purpose, minimum scopes, ACL/sensitivity, cursor/freshness, provenance, raw/derived retention, correction/deletion propagation, read audit, and revocation state. Cross-account, stale-source, prompt-injection, and unauthorized-write tests fail closed.
- Personal data storage: raw personal, biometric, health, location, email, meeting, contact, and session material belongs in approved encrypted private storage, not source Git or general-purpose logs. Source repositories retain only schemas, sanitized fixtures, pointers, and approved derived metadata.
- Gravity evidence authorization: consumers use the accepted vault/tenant-scoped query boundary and cannot fabricate trusted identity headers. Evidence references are resolved under the same context and fail closed when missing, cross-tenant, deleted, suppressed, or mismatched.
- Package trust: installer code and package contents are verified before execution; target-controlled version directories are never trusted; unmanaged host paths are never deleted by default; breaking cutovers remove only managed deprecated paths after successful consumer verification.
- Learning capture: session mining must redact secrets and personal data, stage proposals without mutation, and require explicit approval before changing skills, hooks, commands, tools, config, or source.
- Product links: `PRQ-003`, `PRQ-010`, `PRQ-011`, `PRQ-012`, `PRQ-024`, `PRQ-025`, `PRQ-029`, `PRQ-034`, `PRQ-035`, `PRQ-036`, `SURF-005`, `SURF-009`, `SURF-016`, `SURF-018`, `SURF-019`, `SURF-021`.
- Evidence: prior security evidence plus `NSE-20260709-verdify-skills-adversarial-review`, `NSE-20260709-orbit-current-state-audit`, and `NSE-20260709-gravity-current-state-audit`.

## ARCH-008 Observability And Diagnostics

- Metrics: pod health, CPU, memory, network, endpoint health, storage health, deployment status, wave/session throughput, controller availability, loop counts, stop reasons, recovery attempts, and token/cost signals where material.
- Logs: searchable by repo, environment, namespace, issue, wave, session, pod, and deployment.
- Traces: operations emit correlation IDs connecting user feedback, agent actions, code paths, CI/CD, and runtime behavior.
- Correlation IDs: `wave_id`, `session_id`, `plan_id`, `pr_id`, `deployment_id`, and `policy_decision_id`.
- Diagnostic packet: `schemas/observability-diagnostic-packet.schema.yaml`
  validates diagnostic scope, correlation, hypotheses, telemetry links, signal
  assessments, runtime checks, deployment markers, findings, missing
  instrumentation, recommendation, and feedback route.
- Dashboards: namespace/application dashboards, controller fleet dashboards, review and release health panels, and per-agent loop/activity summaries.
- Alerts: release health, endpoint failure, resource pressure, tunnel failure, storage issues, controller unreachability, loop stall, failed bootstrap, failed credential probe, and missing session-ledger event.
- Rollback signals: defined health criteria and stabilization windows, not arbitrary alerts.
- Package validation signals: repository validator, schema validator, CLI lifecycle tests, PR policy tests, npm install tests, archive manifest verification.
- Portfolio signals: each `PilotProject` record age, source revision, lifecycle route, capability state, gates, dependency blockers, runtime/deployment health, and last accepted outcome.
- Capability signals: implemented, deployed, exposed, integrated, and release-verified are separate states; unsupported, disabled, degraded, quota-blocked, auth-blocked, and stale are explicit.
- Orbit connector signals: account/tenant authorization, minimum scopes, cursor/freshness, source ACL, read audit, revocation, retention/deletion propagation, policy denials, and prompt-injection test results without logging raw content.
- Gravity evidence signals: search outcome, tenant context, citation count, resolvability, API/MCP parity, index generation, processing state, durability, denial reason, and Gate B evidence.
- Learning loop signals: loop readiness, verifier pass/fail, iteration count, stop reason, proposal acceptance rate, cost per accepted change, and repeated-friction categories.
- Alert-to-agent routing: Alertmanager or equivalent should route a failure to the responsible controller when possible; if the controller is unavailable, recovery should restart or replace the controller and seed it with outstanding work from durable state.
- Product links: `PRQ-004`, `PRQ-009`, `PRQ-015`, `PRQ-026`, `SURF-004`, `SURF-017`.
- Evidence: all registered evidence items, especially `NSE-20260623-agent-platform-live-state-audit`, `NSE-20260623-review-inbox-product-examples`, `NSE-20260623-review-inbox-skill-implementation-best-p`, `NSE-20260623-observability-diagnostics-implementation`, and `NSE-20260623-repo-controller-bootstrap-self-discovery`.

## ARCH-009 Delivery, Release, And Rollback

- CI substrate: GitHub Actions remains authoritative until iteration-26 final lock and attended cutover. The proposed target is raw-body Forgejo event admission -> durable delivery ledger -> Argo Events/persistent EventBus -> repository-owned Argo Workflows -> protected-base policy -> minimally scoped trusted status reporter; GitHub Actions dual-runs during coexistence and then becomes non-load-bearing.
- CI/CD based wave deployment: each implementation wave produces a validated wave release plan with CI evidence, branch/merge model, preview or review deployment when applicable, GitOps desired state, review bundle metadata, promotion intent, rollback evidence, security disposition, telemetry links or explicit gaps, release-health signals, and traceability before dispatch and review-ready status.
- GitOps / deployment controller: Argo CD is the proposed sole desired-state owner for the Verdify package-consumer acceptance environment; `environment-gitops-reconciliation.schema.yaml` records desired state, observed sync/health, namespace controls, deployment evidence, runtime health, drift, remediation, rollback, cleanup, review, and handoff.
- Preview environment model: per PR or wave preview namespaces with quota, TTL, default-deny policies, and admin-controlled dynamic generator configuration.
- Promotion gates: dev -> staging -> production requires checks, review, environment protection, and human approval for protected targets.
- Rollback criteria: release health signals, stabilization windows, and rollback instructions recorded before review-ready status.
- Branch model: implementation PRs target protected `dev`; `main` accepts generated reviewed `dev -> main` release promotion only. Current-head critic evidence and required checks are merge-blocking.
- Package release: an unprivileged builder creates one exact tarball/archive set and runs fresh/reinstall/upgrade/collision/corruption/rollback/consumer tests on those bytes; a separate publisher writes the immutable Zot package subject; an isolated signer signs one complete pre-promotion envelope enumerating the subject, checksums, source/protected-policy, exact tests, provenance, SBOM, attestations, and criticism. Approval, GitOps, consumer, rollback, release, and mirror effects are durable ledger receipts against that fixed digest.
- Package installation: private staging verifies the package before any code runs, managed ownership is explicit, unmanaged collisions fail, one version switches atomically, old managed versions are removed after success, and rollback restores the prior managed state.
- Publication recovery: the durable effect ledger and signed release-envelope state machine make subject publication, evidence completion, approval, GitOps proposal, installation, rollback, and mirroring resumable without duplicate effects. npm and GitHub Releases are best-effort output mirrors derived from the approved envelope, and a partial mirror failure does not invalidate local promotion.
- Release authority: Jason or James may approve package release; Jason-only North Star lock remains a different policy decision.
- Breaking convergence: no backwards-compatibility promise is required. A wave may atomically move all four consumers and delete deprecated surfaces after verification and rollback proof.
- Operating-plane release scope: source-control workflows, CI/CD, pipelines, k3s app state, repo-pod agents, and MCP/API control operations are part of one platform readiness and release architecture, not separate unmanaged admin tasks.
- Loop scheduling rule: prove one manual run, extract or update the skill/command, add verifier/state/stop/budget criteria, then schedule only if the loop-readiness checklist passes.
- Product links: `PRQ-004`, `PRQ-005`, `PRQ-006`, `PRQ-012`, `PRQ-015`, `PRQ-031`, `PRQ-034`, `PRQ-037`, `PRQ-039` through `PRQ-049`, `WAVE-002`, `WAVE-004`, `WAVE-011` through `WAVE-014`.
- Evidence: prior delivery evidence plus `NSE-20260709-jason-review-feedback`, `NSE-20260709-verdify-skills-adversarial-review`, `NSE-20260727-verdify-skills-local-delivery-inventory`, `NSE-20260727-local-delivery-control-plane-primary-sources`, and `NSE-20260727-local-delivery-adversarial-audit`.

## ARCH-010 ADR And Decision Index

| Decision ID | Decision / topic | Status | ADR path | Product links | Evidence |
| --- | --- | --- | --- | --- | --- |
| ADR-0001 | Use GitHub as typed control plane | accepted | `docs/decisions/ADR-0001-github-control-plane.md` | `PRQ-010` | `README.md`, `COMMON_OPERATING_CONTRACT.md` |
| ADR-0002 | Expose cohesive lifecycle skills | accepted, extended | `docs/decisions/ADR-0002-cohesive-skills.md` | `PRQ-007` | `README.md` |
| ADR-0003 | Use one coding session per leased worktree | accepted | `docs/decisions/ADR-0003-worktree-leases.md` | `PRQ-011`, `PRQ-012` | `COMMON_OPERATING_CONTRACT.md` |
| ADR-0004 | Add readiness-loop skills | accepted | `docs/decisions/ADR-0004-readiness-loop-skills.md` | `PRQ-003`, `PRQ-014` | `NSE-20260623-walk-transcript-agent-platform-gravity-skills` |
| ADR-0005 | Add North Star planning loop | accepted | `docs/decisions/ADR-0005-northstar-planning-loop.md` | `PRQ-001` | `NSE-20260623-walk-transcript-agent-platform-gravity-skills` |
| ADR-0006 | Add North Star evidence registry | accepted | `docs/decisions/ADR-0006-northstar-evidence-registry.md` | `PRQ-001` | all registered evidence items |
| ADR-0007 | Split North Star into product and architecture artifacts | accepted | `docs/decisions/ADR-0007-product-architecture-northstar-artifacts.md` | `PRQ-001`, `PRQ-002` | all registered evidence items |
| ADR-0008 | Add North Star interview skill | accepted | `docs/decisions/ADR-0008-northstar-interview-skill.md` | `PRQ-016`, `PST-009` | `NSE-20260623-end-to-end-agent-based-sdlc` |
| ADR-0009 | Add North Star question resolution skill | accepted | `docs/decisions/ADR-0009-northstar-question-resolution-skill.md` | `PRQ-002`, `PRQ-007`, `PRQ-016` | `NSE-20260624-question-resolution-workflow-brave-resea` |
| ADR-0010 | Make planning and review comprehensive | accepted | `docs/decisions/ADR-0010-comprehensive-planning-review-loop.md` | `PRQ-006`, `PRQ-010`, `PRQ-012`, `PRQ-015`, `PRQ-027` | `NSE-20260624-comprehensive-planning-and-review-loop-b` |
| ADR-0013 | Move delivery authority to Forgejo, Argo, Zot, and GitOps while retaining GitHub/npm as coexistence mirrors | proposed; requires iteration-26 final lock and implementation evidence | `docs/decisions/ADR-0013-local-delivery-authority.md` | `PRQ-039` through `PRQ-047` | `NSE-20260623-source-control-migration-local-forges`, `NSE-20260727-verdify-skills-local-delivery-inventory`, `NSE-20260727-local-delivery-control-plane-primary-sources` |

## ARCH-013 Operating Plane And Control Surface

- Boundary: the root planner owns cross-project planning and dependency routing; Verdify Skills owns shared lifecycle contracts, validators, evidence/review/release shapes, and platform adapters; Agent Platform owns shared runtime/control capabilities and operational integration; Orbit owns governed personal and engineering information experiences; Gravity owns evidence/search semantics. Each remains a co-equal project with its own authority.
- Primary interface shape: `PilotProject` status plus versioned capabilities and semantic tasks. Direct UI remains useful for inspection, review, recovery, observability, and emergency override, but automated execution requires capability negotiation and typed results.
- Dispatch adapters: `fixed_worker_task` is the preferred near-term Agent Platform strategy; approved detached worker and local leased worktree are explicit fallbacks; dynamic worktree is optional and currently disabled. No generator assumes one topology.
- Owned-IP focus: root-planning method, lifecycle/evidence contracts, deterministic transitions, trusted package distribution, capability adapters, Orbit connector/context contracts, Gravity evidence interfaces, and review/outcome proof.
- Commodity dependencies to compose: Forgejo/Git with GitHub mirroring, Kubernetes/k3s, GitOps, an internal IdP such as Authentik, Postgres or another approved durable transaction store, object storage, vector search, observability tools, and CI workers.
- Product links: `PRQ-017`, `PRQ-018`, `PRQ-030`, `PRQ-032`, `PRQ-033`, `PST-010`, `PST-012`, `PST-021`, `SURF-012`, `SURF-020`.
- Evidence: `NSE-20260709-jason-review-feedback`, `NSE-20260709-agents-current-state-audit`, `NSE-20260709-verdify-skills-adversarial-review`.

## ARCH-014 Active Gravity Evidence Service Architecture

- Authority: current Gravity repository `main`, its approved artifacts, accepted ADRs, and live revision are the implementation source of truth. The retired instance and Sunshine code are not compatibility authorities.
- Product boundary: Gravity owns source ingestion, content identity, managed objects, processing state, enrichment, tenant/vault-scoped retrieval, citations, read-only evidence tools, and organization-pack semantics.
- First consumer interface: a versioned tenant-scoped read-only HTTP API. A consumer-side MCP adapter maps `gravity.search`, `gravity.get_evidence`, and `gravity.get_processing_status` until a trusted network MCP transport is separately accepted.
- Citation invariant: every allowed result must contain resolvable evidence references or declare a typed limitation. Resolution occurs under the same tenant, generation, visibility, deletion, and suppression context; cross-tenant or mismatched refs fail closed.
- Capability-state invariant: implementation, deployment, exposure, integration, and release verification are distinct. Current stdio MCP existence does not imply Orbit integration; pod readiness does not imply Gate B.
- Readiness role: reconcile platform/runtime identity and transport, Gravity contracts and Gate B, API/MCP parity, citations, authorization, durability, health, rollback, and current lifecycle artifacts before other pilots treat the service as trusted.
- Sunshine role: historical reuse evidence only where current Gravity code and contracts still identify useful material. No direct copy or deprecated compatibility is required.
- Product links: `PRQ-003`, `PRQ-019`, `PRQ-031`, `PRQ-036`, `PST-011`, `PST-024`, `SURF-013`, `WAVE-003`, `WAVE-005`.
- Evidence: `NSE-20260709-jason-review-feedback`, `NSE-20260709-gravity-current-state-audit`.

## ARCH-015 Learning Capture And Loop Readiness

- Boundary: Learning capture is a planning and maintenance loop, not an autonomous permission to rewrite the system. It reads evidence, stages proposals, and routes accepted changes through the appropriate skill, command, hook, CLI, config, backlog, or documentation path.
- Proposal format: each candidate improvement validates as `northstar-learning-proposals.schema.yaml` and records source evidence, redaction policy, observed issue/opportunity, verification performed, proposed destination, expected benefit, risk class, approval requirement, affected artifacts, routing decision, review, and no-op rationale when rejected.
- Operator reference: `skills/northstar-planning/references/learning-capture.md`
  defines source eligibility, redaction, verifier, stop, budget, permissions,
  recurring-scan readiness, and stop conditions.
- Template and example:
  `skills/northstar-planning/assets/northstar-learning-proposals.template.yaml`
  and
  `examples/minimal-project/.agent-workflow/northstar/learning-capture/learning-proposals.yaml`.
- Current packets: `.agent-workflow/northstar/learning-capture/2026-06-23-alignment-loop.yaml` and `.agent-workflow/northstar/learning-capture/2026-07-09-adversarial-review-feedback.yaml` record manual alignment lessons and keep recurring session mining unscheduled.
- Routing taxonomy: content idea, context file (`AGENTS.md`/`CLAUDE.md`), slash command, skill update, hook, tool/CLI fix, config change, backlog issue, artifact schema, product shape, architecture, or no-op.
- Loop-readiness checklist: recurring task, objective verifier, durable state, stop condition, budget, permissions, one reliable manual run, and handoff summary.
- Automation boundary: scheduling a scan is acceptable after redaction and read-only proof; applying changes requires human or configured governance approval.
- Metrics: proposal acceptance rate, cost per accepted change, repeated-friction categories, verifier failure rate, stop reasons, and safety/redaction findings.
- Product links: `PRQ-020`, `PRQ-021`, `PST-013`, `PST-014`, `SURF-014`, `WAVE-006`.
- Evidence: `NSE-20260623-long-horizon-agent-compounding-learning`, `NSE-20260623-long-horizon-learning-loop-source-verification`, `NSE-20260623-learning-capture-implementation-best-pra`.

## ARCH-016 Optional Conversational Workflow Adapter Architecture

- Boundary: Orbit, OpenClaw, Hermes, Codex, and Claude are interchangeable or task-specific adapters and experiences over Verdify lifecycle contracts, configured-forge authority, Agent Platform capabilities, and project-owned state. None is a second SDLC or durable authority.
- Thin-facade rule: chief-of-staff transcript/North Star, report-out, agenda/deck, and calendar/accountability experiences delegate to existing lifecycle and connector contracts rather than becoming five new core lifecycle nodes.
- Runtime-independence rule: losing or replacing an adapter cannot change project state, approvals, gates, or evidence. Private adapter memory is never the only record of work.
- Authorization rule: `*_LIVE` or prompt wording is not a security boundary. Adapter actions use typed capability, policy, source, identity, and human-gate records.
- Production rule: adapters cannot infer completion from merge, pod readiness, or successful tool initialization. Release verification proves deployment, runtime health, rollback, citations, and outcome acceptance.
- Product links: `PRQ-022`, `PRQ-028`, `PRQ-035`, `PST-010`, `SURF-015`, `WAVE-007`, `WAVE-010`.
- Evidence: `NSE-20260709-jason-review-feedback`, `NSE-20260709-orbit-current-state-audit`, `NSE-20260709-verdify-skills-adversarial-review`.

## ARCH-017 Repo Controller Bootstrap And Fleet Runtime

- Boundary: Repo bootstrap is a workflow facade over existing lifecycle skills, not a new source of authority. It may coordinate `repo-hygiene`, `platform-readiness`, `controller-loop`, `state-of-union`, and `northstar-planning`, but the configured authoritative forge and `.agent-workflow` remain authoritative.
- Bootstrap inventory: repository structure, docs, Git history, authoritative forge issues/PRs/statuses/reviews, mirror state, deployed Kubernetes resources, pods, utilization, logs, metrics, routes, secret references, credential validation status, storage mounts, CI/CD shape, package/runtime needs, missing access, and planning gaps.
- Required outputs: bootstrap packet, `repo-agent-scope.yaml`, `AGENTS.md` update proposal, namespace/environment map, storage/credential inventory, package/base-image recommendations, gap issues, PR proposal, dashboard links, and handoff.
- Runtime shape: repo controllers run with durable workspace/PVC state, clear worktree/session layout, tmux/web/API visibility, Agent Platform MCP/control operations, and local recovery context.
- Recovery: controller or pod restart must reconstruct outstanding work from session ledger and artifacts; startup prompt should include unresolved alerts, active leases, pending PR/review actions, and blocked gates.
- Product links: `PRQ-023`, `PRQ-026`, `PST-016`, `PST-017`, `SURF-016`, `SURF-017`, `WAVE-008`.
- Evidence: `NSE-20260623-repo-controller-bootstrap-self-discovery`, `NSE-20260623-agent-platform-live-state-audit`, `NSE-20260623-session-ledger-implementation-best-pract`.

## ARCH-018 Namespace, Storage, Credential, And Image Topology

- Namespace rule: repository/application remains the durable product boundary; fleet rollout needs a collision-safe owner/repo naming convention plus explicit dev, preview, staging, and production namespace-set rules.
- Repo-local access: repo agents default to their assigned namespace, approved mounts, declared routes, runtime-injected credential references, and dev/preview mutation only unless gated otherwise.
- Domain-agent access: networking, storage, backup, and platform agents may have broader scoped authority to owned systems, but only with explicit owner, scope, audit, rollback, approval, and prohibited-operation records.
- Storage and workspace: NFS/PVC mounts, durable controller state, Git worktrees, repo source, and useful workspace folders should be visible inside the pod and VS Code or equivalent remote workspace. Repo agents request new mounts through platform/storage control paths, not ad hoc shell mutation.
- Routes and DNS: route/DNS propagation should be declared through platform/network desired state so repo delivery can remain low-friction without granting repo agents broad network authority.
- Image policy: repo bootstrap may recommend base-image packages. Fleet image changes should be consolidated, versioned, rebuilt regularly, regression-tested, cached in a registry, and rollback-ready.
- Secret rule: artifacts record credential references, auth modes, scopes, owners, validation result, and failure mode only; raw secret values are never written.
- Product links: `PRQ-024`, `PRQ-025`, `PST-018`, `SURF-016`, `WAVE-008`.
- Evidence: `NSE-20260623-repo-controller-bootstrap-self-discovery`, `NSE-20260623-secrets-credential-injection-patterns`, `NSE-20260623-environment-gitops-implementation-best-p`.

## ARCH-019 Orbit Personal Assistant And Engineering Chief-Of-Staff Surface

- Boundary: Orbit owns Jason-facing information experiences across authorized personal, enterprise, meeting, and engineering sources. It may prepare context, proposals, accountability, and delegated workflows; the root planner remains the portfolio outer loop and project control remains in the configured authoritative forge and durable artifacts.
- Inputs: email, calendars, enterprise documents, transcripts, notes, conversations, meetings, configured forge and mirror state, repo/controller state, issues, PRs, deployments, alerts, agent activity, and evidence references.
- Connector plane: separate principal or policy-enforcing broker with minimum source scopes, tenant/account identity, classification, ACL/sensitivity, approved purpose, freshness cursor, provenance, raw/derived retention, correction/deletion propagation, read audit, revocation, and explicit read/propose/write capabilities.
- Trust boundary: untrusted source instructions are data. They cannot trigger configured-forge, Kubernetes, calendar, document, or outbound-message actions without an independent authorized policy decision and required human gate.
- Storage boundary: raw personal and enterprise content stays in approved encrypted, ACL-preserving storage. Repositories hold schemas, sanitized fixtures, pointers, and approved derived metadata only.
- First safe milestone: one read-only minimally scoped connector with citations, read audit, revocation, deletion/correction behavior, negative cross-account tests, and no fleet-actuation authority.
- Product links: `PRQ-028`, `PRQ-035`, `PST-010`, `PST-019`, `PST-023`, `SURF-018`, `WAVE-009`, `WAVE-010`.
- Evidence: `NSE-20260709-jason-review-feedback`, `NSE-20260709-orbit-current-state-audit`.

## ARCH-020 Repo-Agent Scope, Ownership, And Responsibilities

- Boundary: `repo-agent-scope.yaml` is the typed charter for a repo-associated controller or long-lived repo agent. It does not replace configured-forge authority, `AGENTS.md`, platform-readiness artifacts, or controller state; it binds them together for exploration, discovery, and handoff.
- Discovery tie-in: repo hygiene or repo-bootstrap discovery creates the first scope artifact from repository identity, authoritative forge and mirror state, `AGENTS.md`, `.agent-workflow`, runtime/namespace/storage/route/credential-reference evidence, observability links, and planning gaps.
- Required shape: `schemas/repo-agent-scope.schema.yaml` validates agent identity, repository identity, purpose, in-scope work, out-of-scope work, owned paths, protected paths, stakeholders, ownership, `RAS-*` responsibilities, authority boundaries, discovery inputs, runtime context, escalation paths, review, handoff, and approval.
- Template: `skills/repo-hygiene/assets/repo-agent-scope.template.yaml` provides the starter artifact for target repositories.
- Authority: repo agents default to least privilege. Broader storage, networking, credential, image, route, protected-environment, or production actions must route to the named platform/security/domain owner and control plane.
- Handoff: state-of-union, platform-readiness, controller-loop, sprint-planning, and release-verification may consume the scope contract to determine whether the agent is operating inside its declared authority.
- Product links: `PRQ-029`, `PST-020`, `SURF-019`, `WAVE-008`.
- Evidence: `NSE-20260623-repo-controller-bootstrap-self-discovery`, `NSE-20260623-secrets-credential-injection-patterns`, `NSE-20260623-environment-gitops-implementation-best-p`.

## ARCH-021 Four-Project Integration And Root Planning Outer Loop

- Portfolio invariant: Verdify Skills, Agent Platform, Orbit, and Gravity are co-equal pilots. Each owns its product North Star, authoritative backlog and mirror policy, runtime/deployment, and outcome acceptance. Shared capabilities do not transfer product authority.
- Root-planner responsibility: read current evidence and `PilotProject` records, reconcile cross-project dependencies and gates, rank the next bounded action, create or update the owning authoritative-forge issue, mirror when configured, invoke the correct lifecycle skill, and preserve a reconstructable handoff.
- `PilotProject` contract: project/repository identity, current source and deployed revision, lifecycle/North Star state, issue/PR/dependency state, capabilities and operation versions, gates, readiness, runtime/deployment health, evidence/outcome refs, tenancy, identity, idempotency, audit, last refresh, and typed degradation/failure.
- Capability provider rule: Agent Platform may supply runtime, CI, GitOps, observability, identity, and session capabilities; Gravity supplies evidence/search capabilities; Orbit supplies governed context/assistant experiences; Verdify supplies the method and adapters. Consumers discover and invoke capabilities through versioned contracts.
- Dispatch rule: the root planner requests semantic work. Verdify and Agent Platform negotiate an authorized adapter and worker topology; unsupported or stale capability fails closed. Work still uses one issue/lane/branch/worktree/session/PR by default.
- Information rule: Orbit context may inform planning, but every claim retains source/freshness and every action becomes an authoritative-forge issue, platform request, review packet, or human gate. Personal-source content never becomes executable instruction.
- Evidence rule: Gravity results include resolvable citations or typed denials. Root planning cannot treat uncited or unresolvable evidence as verified project truth.
- Convergence rule: no backwards-compatibility promise is required. Breaking package, contract, or skill simplification is allowed through an explicit four-consumer migration, canary, rollback, and deletion wave.
- Completion rule: the integrated pilot succeeds when one platform improvement traverses all four projects, passes fresh critic and deployment verification, produces cited evidence and source-linked reporting, records outcome acceptance, and feeds a proposed lesson back into the next outer-loop decision.
- Expansion rule: after the internal four-project slice is proven, customer consulting repositories enter through the same project-owned North Star, `PilotProject`, bootstrap, agent-scope, capability, evidence, readiness, delivery, review, deployment, and outcome contracts. They do not inherit Jason-private Orbit context or create a second lifecycle.
- Product links: `PRODUCT-014`, `PRQ-030` through `PRQ-038`, `PST-021` through `PST-026`, `SURF-020`, `WAVE-001` through `WAVE-005`.
- Evidence: all `NSE-20260709-*` items.

## ARCH-011 Planning Questions And Research Queue

| Question ID | Question | Owner | Blocking only for final lock? | Proposed resolution or research path | Evidence |
| --- | --- | --- | --- | --- | --- |
| NSQ-001 | What exact approval rule applies to protected North Star product and architecture artifacts? | Jason | false | Resolved and recorded: Jason alone records final North Star lock and explicitly approved iteration 25. James is a reviewer and release approver; neither release nor review feedback creates a future lock. | `NSE-20260709-jason-review-feedback`, `NSE-20260709-jason-iteration-25-final-lock-approval` |
| NSQ-002 | Should execution identity remain one issue/lane/branch/worktree/session/PR or introduce wave-level branches? | Release owner | false | Resolved: retain one issue/lane/branch/worktree/session/PR by default; the wave is integrated deployment/review/outcome metadata, not a long-lived implementation branch. | `NSE-20260709-jason-review-feedback` |
| NSQ-005 | What is the exact repo/application/environment/namespace cardinality for the Agent Platform pilot? | Platform/security owner | false | Resolved by primary-source research: repository/application is the durable product boundary; dev, staging, production, and preview use environment-scoped namespaces or namespace sets with quota, RBAC, NetworkPolicy, secret references, endpoints, and observability. | `NSE-20260623-kubernetes-gitops-cicd-cardinality` |
| NSQ-003 | Does Gravity still depend on Onyx? | Jason and Gravity readiness owner | false | Resolved for this loop: current evidence says Gravity does not depend on Onyx ingestion for the MVP; Onyx remains a separate planned/gated vault or search front door and post-MVP/control-plane concern. | `NSE-20260623-gravity-local-repo-evidence`, `NSE-20260623-gravity-remote-onyx-confirmation` |
| NSQ-006 | Which P0 North Star interview decisions should be accepted, modified, or rejected before final lock? | Jason | false | Resolved and locked: all July 9 recommendations are accepted planning defaults, the recorded answers supersede older proposed defaults, and the separate iteration-25 lock is recorded. | `NSE-20260709-jason-review-feedback`, `NSE-20260709-verdify-skills-adversarial-review`, `NSE-20260709-jason-iteration-25-final-lock-approval` |
| NSQ-007 | What exact responsibility split should hold among the root planner, Verdify Skills, Agent Platform, Orbit, and Gravity? | Jason and architecture owner | false | Resolved by `ARCH-021`: root planner coordinates; Skills owns method/adapters; Agent Platform owns shared runtime capabilities; Orbit owns governed assistant/context experiences; Gravity owns evidence/search semantics; all four projects retain product authority. | all 2026-07-09 evidence items |
| NSQ-008 | What is the authoritative Gravity implementation and reuse path? | Gravity readiness owner | false | Resolved: current Gravity repository/runtime is source truth; Sunshine is optional historical reuse evidence; versioned read-only HTTP plus consumer MCP adapter is the first trusted consumer boundary. | `NSE-20260709-jason-review-feedback`, `NSE-20260709-gravity-current-state-audit` |
| NSQ-009 | Which session sources, retention windows, and redaction rules should the learning-capture loop use? | Skills maintainer and security owner | false | Deferred, nonblocking default: start with explicit research artifacts and local Codex/Claude/terminal session summaries that can be redacted; stage proposals only; require source scope, retention, verifier, durable state, stop condition, budget, permissions, and one manual proof before scheduling. | `NSE-20260623-long-horizon-agent-compounding-learning`, `NSE-20260623-long-horizon-learning-loop-source-verification` |
| NSQ-010 | What exact namespace naming convention should bind GitHub owner, organization, repository, dev, preview, staging, and production namespace identity for fleet bootstrap? | Platform and security owner | false | Deferred, nonblocking default: repo/application remains the durable product boundary; namespace names include a collision-safe owner/repo identity plus environment suffixes where needed. Validate against Kubernetes naming and existing Agent Platform conventions before rollout. | `NSE-20260623-repo-controller-bootstrap-self-discovery`, `NSE-20260623-environment-gitops-implementation-best-p` |
| NSQ-011 | Should repo-controller orchestration use Codex, Claude, or a controller abstraction that selects the model/tooling per task and failure mode? | Platform architecture owner | false | Deferred, nonblocking default: model-neutral controller contract with Codex/Claude as interchangeable or task-specific workers; validate with a manual bootstrap pilot before scheduling. | `NSE-20260623-repo-controller-bootstrap-self-discovery`, `NSE-20260623-openclaw-hermes-local-evidence` |
| NSQ-012 | Which infrastructure domain agents are allowed broader scoped access, and what owner, audit, approval, and rollback rules apply? | Jason, platform owner, and security owner | false | Deferred, nonblocking default: networking, storage, backup, and platform domain agents may receive explicit scoped authority; repo-local agents remain namespace-scoped unless a gate grants more. | `NSE-20260623-repo-controller-bootstrap-self-discovery`, `NSE-20260623-secrets-credential-injection-patterns` |
| NSQ-013 | What is the approved request path for repo agents to add NFS/PVC mounts, route/DNS changes, or base-image packages? | Platform, storage, and networking owners | false | Deferred, nonblocking default: repo agents submit platform control requests or PR-reviewed desired-state changes; storage/network/image owners approve before mutation. | `NSE-20260623-repo-controller-bootstrap-self-discovery`, `NSE-20260623-environment-gitops-implementation-best-p` |
| NSQ-014 | What sources, privacy boundaries, connector permissions, and source-freshness rules should Orbit use? | Jason and Orbit/platform owner | false | Product scope resolved: authorized email, calendars, enterprise documents, transcripts, notes, conversations, meetings, and engineering sources are in scope. `ARQ-003`, `ARQ-026`, and Orbit #193-#197 define the required principal separation, source/tenant/ACL policy, freshness, provenance, retention, audit, human-gated writes, and protected North Star reframe. | `NSE-20260709-jason-review-feedback`, `NSE-20260709-orbit-current-state-audit` |
| NSQ-015 | Approve a capability-qualified supported Forgejo release (v16 is the current candidate) as internal repository authority and GitHub as an output mirror? | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-006`, `OWN-009`; Jason decides | true | Proposed: require every applicable question/owner row, then approve only after exact-version capability, IdP, repository and governance-history import, review/status/protection/audit, portfolio-work, upgrade, coordinated-restore, and GitHub-unavailable contract tests. | `NSE-20260623-source-control-migration-local-forges`, `NSE-20260727-verdify-skills-local-delivery-inventory`, `NSE-20260727-local-delivery-control-plane-primary-sources`, `NSE-20260727-local-delivery-adversarial-audit`, `NSE-20260727-shared-local-delivery-authority-live-state`, `NSE-20260727-local-delivery-native-dependency-reconciliation` |
| NSQ-016 | Approve a Zot package subject plus signed immutable complete pre-promotion release envelope, later-effect ledger receipts, and stable-harness/fresh-volume Argo CD consumer as the authoritative release and non-production acceptance model? | `OWN-001`, `OWN-002`, `OWN-004`, `OWN-005`, `OWN-006`, `OWN-008`, `OWN-009`; Jason decides | true | Proposed: require every applicable question/owner row; the consumer is an acceptance fixture, and promotion identity is the signed envelope digest fixing the complete pre-promotion package/evidence graph while later effects remain ledger receipts. | `NSE-20260709-verdify-skills-adversarial-review`, `NSE-20260727-verdify-skills-local-delivery-inventory`, `NSE-20260727-local-delivery-control-plane-primary-sources`, `NSE-20260727-local-delivery-adversarial-audit` |
| NSQ-017 | Keep GitHub source, npm, and GitHub Releases as best-effort proprietary/source-available mirrors that preserve GitHub's in-Service public-repository rights, make no additional project grant beyond GitHub's Terms and applicable law for off-platform/package use, accept issue/security reports but no external code until approved CLA/assignment terms exist, and separately govern freshness, outage, verification, support, licensing, intake, and retirement? | `OWN-001`, `OWN-009`, `OWN-010`; Jason decides | true | Proposed: require every applicable question/owner row, including legal/IP confirmation of the exact rights statement, so public input remains non-authoritative and internal recovery, additional licensing/contributor rights, distribution, and destructive retirement remain separate decisions. | `NSE-20260727-verdify-skills-local-delivery-inventory`, `NSE-20260727-local-delivery-adversarial-audit`, `NSE-20260727-verdify-skills-public-visibility-license`, `NSE-20260727-github-public-repository-license-terms` |
| NSQ-018 | Approve migration of repository and portfolio-work authority through provider-neutral IDs, imported-history markers, portfolio metadata, and cross-system links while keeping `jvallery/agents#3044` as the GitHub-side migration record until reconciliation? | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-009`; Jason decides | true | Proposed: require every applicable question/owner row; Git mirroring alone cannot move governance authority, and the native `#3044 blocked_by #3047` relationship is the reconciled ownership boundary. | `NSE-20260727-local-delivery-adversarial-audit`, `NSE-20260727-shared-local-delivery-authority-live-state`, `NSE-20260727-local-delivery-native-dependency-reconciliation` |
| NSQ-019 | Approve the complete proposed two-repository pilot envelope represented by stable thresholds `OE-001` through `OE-034` in `NORTHSTAR_INTERVIEW.md`? | `OWN-001`–`OWN-009` per threshold; Jason decides | true | Proposed: accept only through the complete identity-bound owner/threshold disposition ledger. Missing assignments or rows, rejections, and conflicting revisions remain blocking; no generic approval can satisfy the architecture envelope. | `NSE-20260727-local-delivery-adversarial-audit`; `NORTHSTAR_INTERVIEW.md` owner and threshold matrices |
| NSQ-020 | Approve IdP-backed immutable identities, raw-body admission plus a durable effect ledger, minimally scoped trusted status reporting, and separate candidate, trusted validator, critic, integrator, publisher, signer, mirror, GitOps, verifier, approver, and recovery principals as mandatory architecture? | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-006`, `OWN-008`, `OWN-009`; Jason decides | true | Proposed: require every applicable question/owner row and reject any provider or design that cannot prove the boundary. | `NSE-20260727-local-delivery-adversarial-audit` |

## ARCH-012 Traceability Index

| From | To | Relationship |
| --- | --- | --- |
| `PRQ-001` | `ARQ-001` | requires durable product/architecture artifact architecture |
| `PRQ-002` | `ARQ-001` | requires loop state, questions, review state, and final signoff record |
| `PRQ-003` | `ARQ-003` | requires least-privilege platform access |
| `PRQ-004` | `ARQ-002` | requires Git-anchored human-governed delivery controls |
| `PRQ-004` | `ARQ-004` | requires observability and diagnostics |
| `ARQ-004` | `schemas/observability-diagnostic-packet.schema.yaml` | validates the first concrete observability diagnostic packet contract |
| `PRQ-005` | `ARQ-005` | requires session and wave ledger |
| `ARQ-005` | `schemas/session-ledger.schema.yaml` | validates the first concrete session ledger contract |
| `PRQ-006` | `ARQ-006` | requires CI/CD wave deployment architecture |
| `ARQ-006` | `schemas/wave-release-plan.schema.yaml` | validates the first concrete wave release planning contract |
| `ARQ-006` | `schemas/environment-gitops-reconciliation.schema.yaml` | validates the first concrete environment GitOps reconciliation contract |
| `PRQ-007` | `ARQ-007` | requires the smallest exercised skill/facade graph and removal of deprecated surfaces |
| `PRQ-007` | `skills/controller-loop/SKILL.md` | traces the shipped controller-loop lifecycle skill to the validated package count |
| `PRQ-007` | `skills/northstar-question-resolution/SKILL.md` | traces the shipped North Star question-resolution lifecycle skill to the validated package count |
| `PRQ-008` | `ARQ-008` | requires dependency-light CLI architecture |
| `PRQ-009` | `ARQ-009` | requires durable schema-governed artifacts |
| `PRQ-010` | `ARQ-010` | requires GitHub reconciliation architecture |
| `ARQ-010` | `schemas/github-backlog-sync.schema.yaml` | validates the first concrete GitHub backlog sync mode contract |
| `PRQ-011` | `ARQ-011` | requires lease and worktree identity enforcement |
| `PRQ-012` | `ARQ-011` | requires independent critic/release verification isolation |
| `PRQ-013` | `ARQ-014` | requires explicit target-repo install footprint |
| `PRQ-014` | `ARQ-013` | requires readiness loops before feature execution |
| `ARQ-013` | `schemas/environment-gitops-reconciliation.schema.yaml` | validates environment readiness, desired/observed state, namespace policy, drift, remediation, rollback, and cleanup evidence |
| `PRQ-015` | `ARQ-012` | requires deterministic validation evidence |
| `PRQ-016` | `ARQ-015` | requires durable interview packet architecture |
| `PRQ-002` | `ARQ-028` | requires scalable North Star question inventory and delegated resolution before synthesis |
| `ARQ-028` | `skills/northstar-question-resolution/SKILL.md` | implements question inventory, clustering, research, delegated answer, escalation, and planning handoff |
| `PRQ-017` | `ARQ-016` | requires self-hosted operating-plane architecture |
| `PRQ-018` | `ARQ-017` | requires API/MCP-first Agent Platform control surface |
| `ARQ-017` | `schemas/agent-platform-control-request.schema.yaml` | validates the first concrete Agent Platform control request contract |
| `PRQ-019` | `ARQ-018` | requires current Gravity source/runtime authority and evidence-service architecture |
| `ARQ-018` | `schemas/gravity-core-extraction-plan.schema.yaml` | validates the first concrete Gravity core extraction planning contract |
| `PRQ-020` | `ARQ-019` | requires proposal-only evidence-backed learning capture |
| `PRQ-020` | `IFACE-014` | requires typed learning proposal packet contract |
| `PRQ-021` | `ARQ-020` | requires loop-readiness criteria before scheduling recurring automation |
| `PRQ-022` | `ARQ-021` | requires optional conversational adapters to delegate to lifecycle contracts and preserve the configured provider authority, with GitHub authority retained only before cutover |
| `PRQ-023` | `ARQ-022` | requires schema-backed repo-controller bootstrap workflow |
| `PRQ-023` | `ARQ-023` | requires durable controller workspace and runtime visibility |
| `PRQ-024` | `ARQ-024` | requires safe credential-reference, namespace, storage, route, and image topology |
| `PRQ-025` | `ARQ-024` | requires platform contracts before namespace/storage/route/image mutation |
| `PRQ-026` | `ARQ-025` | requires controller loop telemetry, dashboards, alerts, and recovery |
| `PRQ-027` | `ARQ-022` | requires bootstrap and planning artifacts to record adversarial review and dispositions |
| `PRQ-028` | `ARQ-026` | requires a governed Orbit connector plane and source-linked assistant outputs |
| `PRQ-029` | `ARQ-027` | requires a typed repo-agent scope and responsibility contract |
| `PRQ-029` | `ARCH-020` | requires repo-agent scope, ownership, responsibility, authority, and escalation architecture |
| `ARQ-027` | `schemas/repo-agent-scope.schema.yaml` | validates the first concrete repo-agent scope contract |
| `SURF-004` | `IFACE-004` | defines review inbox interface |
| `IFACE-004` | `schemas/review-inbox-packet.schema.yaml` | validates the first concrete review inbox packet contract |
| `SURF-006` | `IFACE-005` | defines CLI interface |
| `SURF-007` | `IFACE-006` | defines artifact/schema interface |
| `SURF-008` | `IFACE-009` | defines host discovery interface |
| `SURF-009` | `IFACE-007` | defines lane lease interface |
| `SURF-010` | `IFACE-008` | defines GitHub operating interface |
| `IFACE-008` | `schemas/github-backlog-sync.schema.yaml` | defines source freshness, issue, PR, lane, delivery, action, and handoff findings for GitHub backlog sync |
| `SURF-011` | `IFACE-011` | defines North Star interview packet interface |
| `SURF-012` | `IFACE-012` | defines Agent Platform MCP/control API |
| `IFACE-012` | `schemas/agent-platform-control-request.schema.yaml` | defines the durable request, authorization, policy, target, result, review, and handoff artifact |
| `SURF-013` | `IFACE-013` | links the evidence service to the current Gravity product and pack boundary |
| `IFACE-013` | `schemas/gravity-core-extraction-plan.schema.yaml` | validates source-object inventory, reuse matrix, pack assumptions, contracts, migration risks, pilot criteria, readiness updates, handoff, and approval |
| `SURF-014` | `IFACE-014` | defines learning-capture proposal packet interface |
| `SURF-015` | `IFACE-015` | defines the optional conversational workflow facade |
| `SURF-016` | `IFACE-016` | defines the repo-bootstrap self-discovery packet interface |
| `SURF-017` | `IFACE-017` | defines fleet controller dashboard and alert routing interface |
| `SURF-018` | `IFACE-018` | defines the governed Orbit personal and engineering context interface |
| `SURF-019` | `IFACE-019` | defines the repo-agent scope and responsibility contract interface |
| `IFACE-014` | `schemas/northstar-learning-proposals.schema.yaml` | validates proposal-only learning-capture packets |
| `IFACE-014` | `skills/northstar-planning/references/learning-capture.md` | defines learning-capture source eligibility, redaction, verifier, stop, budget, permissions, and scheduling boundaries |
| `IFACE-014` | `skills/northstar-planning/assets/northstar-learning-proposals.template.yaml` | provides a reusable proposal packet template |
| `NSE-20260623-learning-capture-implementation-best-pra` | `ARQ-019` | supports proposal-only learning capture with eval, persistence, redaction, privacy, and LLM risk controls |
| `NSE-20260623-learning-capture-implementation-best-pra` | `ARQ-020` | supports recurring-scan loop readiness and scheduling boundaries |
| `NSE-20260623-agent-platform-live-state-audit` | `ARQ-016` | proves live repo-pod, GitHub, Kubernetes, and Argo CD operating-plane surfaces plus readiness gaps |
| `NSE-20260623-openclaw-hermes-reuse-interface-security-audit` | `ARQ-017` | supports MCP/API-first planning-agent control with constrained tool surfaces |
| `NSE-20260623-agent-platform-control-implementation-be` | `ARQ-017` | supports durable Agent Platform control requests with operation identity, authorization, policy verdict, mutation level, target, evidence, result, review gate, and handoff |
| `NSE-20260623-sunshine-gravity-extraction-architecture-audit` | `ARQ-018` | sharpens the generic Gravity core versus Sunshine client-pack extraction path |
| `NSE-20260623-gravity-core-extraction-implementation-b` | `ARQ-018` | supports source-object provenance, checksum strategy, reusable core boundaries, pack assumptions, migration risks, and local-filesystem pilot criteria |
| `NSE-20260623-gravity-remote-onyx-confirmation` | `ARQ-018` | resolves the Gravity/Onyx dependency question for MVP planning |
| `NSE-20260623-secrets-credential-injection-patterns` | `ARQ-003` | supports runtime secret injection and least-privilege credential boundaries |
| `NSE-20260623-browser-terminal-security-patterns` | `ARCH-007` | supports browser-terminal RBAC, session, audit, and production restrictions |
| `NSE-20260623-source-control-migration-local-forges` | `ARQ-010` | supports keeping GitHub authority until an explicit migration ADR changes source-control ownership |
| `NSE-20260623-github-backlog-sync-implementation-best` | `ARQ-010` | supports typed GitHub issue, PR, dependency, sub-issue, project, check, workflow, deployment, and environment reconciliation |
| `NSE-20260623-review-inbox-product-examples` | `IFACE-004` | supports review inbox bundle and deployment-review examples |
| `NSE-20260623-review-inbox-skill-implementation-best-p` | `IFACE-004` | supports required packet groups, completeness verdicts, recommendation states, and feedback routing |
| `NSE-20260623-wave-release-planning-implementation-bes` | `ARQ-006` | supports branch/merge model, CI checks/events, environments, GitOps desired state, deployment strategy, release-health signals, and rollback criteria |
| `NSE-20260623-environment-gitops-implementation-best-p` | `ARQ-006` | supports environment GitOps desired-state refs, observed controller sync/health, namespace controls, runtime health, drift, remediation, rollback, and cleanup evidence |
| `NSE-20260623-observability-diagnostics-implementation` | `ARQ-004` | supports diagnostic correlation, telemetry links, signal assessments, runtime checks, deployment markers, missing instrumentation, and feedback routing |
| `NSE-20260623-session-ledger-implementation-best-pract` | `ARQ-005` | supports append-oriented event envelopes, parent/child session graph, correlation IDs, refs, checksums, and reconstruction after context loss |
| `ARQ-005` | `skills/controller-loop/SKILL.md` | implements durable controller loop state, child-session tracking, and session-ledger handoff |
| `NSE-20260623-long-horizon-learning-loop-source-verification` | `ARQ-020` | strengthens loop-readiness criteria with primary-source long-horizon harness evidence |
| `NSE-20260623-openclaw-hermes-local-evidence` | `ARQ-021` | supplies reusable session, queue, approval, MCP, and JSONL log patterns for optional adapters |
| `NSE-20260623-openclaw-hermes-reuse-interface-security-audit` | `IFACE-015` | constrains optional workflow adapters to governed MCP/API planning surfaces |
| `NSE-20260623-end-to-end-agent-based-sdlc` | `ARCH-016` | supports the external workflow map from ideation through production proof |
| `NSE-20260623-repo-controller-bootstrap-self-discovery` | `ARQ-022` | supports repo-bootstrap workflow shape and output requirements |
| `NSE-20260623-repo-controller-bootstrap-self-discovery` | `ARQ-023` | supports durable controller workspace, tmux/web/API visibility, and recovery state |
| `NSE-20260623-repo-controller-bootstrap-self-discovery` | `ARQ-024` | supports namespace, storage, credential, route, domain-agent, and base-image topology planning |
| `NSE-20260623-repo-controller-bootstrap-self-discovery` | `ARQ-025` | supports controller observability and alert-to-agent recovery |
| `NSE-20260623-repo-controller-bootstrap-self-discovery` | `ARQ-026` | provides the earlier operating-context seed now broadened into Orbit connector and source governance |
| `NSE-20260623-repo-controller-bootstrap-self-discovery` | `ARQ-027` | supports repo-agent scope, ownership, responsibility, and escalation contracts |
| `NSE-20260624-question-resolution-workflow-brave-resea` | `ARQ-028` | supports large-question inventory, clustering, evidence-backed delegated answers, and human escalation packs |
| `WAVE-002` | `ARCH-009` | requires preview, promotion, and rollback architecture |
| `WAVE-007` | `ARCH-016` | proves an optional Orbit/OpenClaw/Hermes adapter delegates to the one lifecycle |
| `WAVE-008` | `ARCH-017` | requires a repo-controller bootstrap pilot before broad fleet rollout |
| `WAVE-008` | `ARCH-020` | requires repo-agent scope charter before controller ownership |
| `WAVE-005` | `ARCH-014` | requires convergence on the current Gravity API, MCP adapter, citations, and Gate B |
| `WAVE-006` | `ARCH-015` | requires learning-capture proposal-only loop and loop-readiness planning |
| `NSE-20260709-jason-review-feedback` | `ARQ-029` | establishes the co-equal four-pilot and root-planner model |
| `NSE-20260709-verdify-skills-adversarial-review` | `ARQ-012` | grounds transition, critic, eval, artifact, archive, and consumer validation gaps |
| `NSE-20260709-verdify-skills-adversarial-review` | `ARQ-014` | grounds trusted atomic installer and managed-path requirements |
| `NSE-20260709-agents-current-state-audit` | `ARQ-017` | proves the capability and dispatch mismatch with current Agent Platform |
| `NSE-20260709-orbit-current-state-audit` | `ARQ-003` | grounds separation of personal-context and fleet-actuation principals |
| `NSE-20260709-orbit-current-state-audit` | `ARQ-026` | grounds the connector source, privacy, ACL, retention, and read-audit contract |
| `NSE-20260709-gravity-current-state-audit` | `ARQ-018` | establishes current Gravity source/runtime authority and consumer boundary |
| `NSE-20260709-gravity-current-state-audit` | `ARQ-032` | proves citation hydration and API/MCP parity requirements |
| `PRQ-030` | `ARQ-029` | requires one integration contract across four project-owned pilots |
| `PRQ-031` | `ARQ-030` | permits breaking atomic convergence and deletion of deprecated capability |
| `PRQ-032` | `IFACE-020` | requires the common `PilotProject` status and capability interface |
| `PRQ-033` | `IFACE-012` | requires capability-negotiated semantic lane dispatch |
| `PRQ-034` | `IFACE-021` | requires trusted exact-artifact publication and installation transaction |
| `PRQ-035` | `IFACE-018` | requires the governed Orbit source and context contract |
| `PRQ-036` | `IFACE-022` | requires the versioned Gravity read-only HTTP and MCP adapter interface |
| `PRQ-037` | `ARQ-031` | separates Jason-only North Star lock from Jason-or-James release approval |
| `PST-025` | `ARQ-031` | provides the release-approver product story for the separate authority policy |
| `PRQ-038` | `ARQ-034` | requires customer consulting onboarding through the same governed platform contracts |
| `PST-026` | `ARCH-021` | makes customer consulting reuse an explicit expansion rule for the root-planner platform |
| `SURF-020` | `IFACE-020` | defines the root-planner portfolio and capability view |
| `SURF-021` | `IFACE-021` | defines the trusted package transaction |
| `WAVE-002` | `ARCH-021` | proves one integrated four-project self-building vertical slice |
| `WAVE-009` | `ARCH-019` | requires connector governance and read-only Orbit context before writes |
| `NSE-20260727-local-delivery-adversarial-audit` | `ARQ-035` through `ARQ-046` | grounds authority scope, identity, admission/ledger, status trust, release envelope, consumer topology, offline boundary, recovery, public support, operating envelope, and sequencing |
| `NSE-20260727-shared-local-delivery-authority-live-state` | `ARCH-022`, `ARQ-035`, `ARQ-039`, `NSQ-015`, `NSQ-018` | verifies that shared platform issue #3047 remains open and no Verdify Skills-specific internal authority, Workflow, or package acceptance path is bound |
| `NSE-20260727-local-delivery-native-dependency-reconciliation` | `ARCH-022`, `ARQ-035`, `ARQ-046`, `NSQ-015`, `NSQ-018` | verifies the native shared-platform dependency and prevents repository delivery planning from duplicating #3047 |
| `NSE-20260727-verdify-skills-public-visibility-license` | `ARQ-044`, `IFACE-028`, `NSQ-017` | proves the current PUBLIC repository plus `UNLICENSED` package state that constrains public-mirror use and contributor-rights semantics |
| `NSE-20260727-github-public-repository-license-terms` | `ARQ-044`, `IFACE-028`, `NSQ-017` | proves GitHub's in-Service public-repository rights and constrains the separate project-license statement |
| `PRQ-039` | `ARQ-035` | requires capability-qualified Forgejo, internal IdP, repository and portfolio-work authority |
| `PRQ-040` | `ARQ-036`, `ARQ-041`, `IFACE-030` | requires raw-body admission and durable effect authority before Argo transport and protected effects |
| `PRQ-041` | `ARQ-037`, `IFACE-025` | requires the package subject plus signed immutable complete pre-promotion release envelope and later-effect ledger receipts |
| `PRQ-042` | `ARQ-038`, `IFACE-026` | requires the stable harness, fresh-volume verification/install path, and sole GitOps ownership |
| `PRQ-043` | `ARQ-039` | requires empty-node/CRI-cache full-boundary internal-only reproducibility |
| `PRQ-044` | `ARQ-040`, `IFACE-029` | requires immutable subjects, principal separation, and candidate credential denial |
| `PRQ-045` | `ARQ-042`, `IFACE-028` | requires isolated rehearsal, coordinated internal recovery, attended switch, and separate transfer/retirement gates |
| `PRQ-046` | `ARQ-043`, `IFACE-027` | blocks cutover on any load-bearing exception |
| `PRQ-047` | `ARQ-044`, `IFACE-028` | requires governed public output-mirror, contribution, support, and retirement semantics |
| `PRQ-048` | `ARQ-045`, `IFACE-031` | requires measurable capacity, cost, latency, recovery, outage, and observation objectives |
| `PRQ-049` | `ARQ-046` | requires closed #120/#121 to be mapped as completed absorbed predecessors and never redispatched |

## ARCH-022 Local CI, Package, Forge, And GitOps Authority

This section is a proposed architecture delta. It becomes authority only after
Jason records iteration-26 final lock. Its implementation must then proceed
through approved project definition, architecture contracts, issue-backed
lanes, protected-base validation, fresh criticism, human gates, and separately
verified runtime deployment.

Shared Agent Platform issue `jvallery/agents#3047` owns the reusable internal
forge/event/status and offline-supply substrate; repository issue `#3044` owns
the Verdify Skills adapter, parity, package, consumer, and cutover evidence.
Both are currently proposed inputs, not approved architecture or executable
lane contracts.

### Architecture stories

| Story ID | Actor | Architecture story | Acceptance signal | Product links |
| --- | --- | --- | --- | --- |
| AST-026 | Maintainer | Deliver a protected change without GitHub availability. | Capability-qualified Forgejo source and portfolio-work records, pull request, exact-head trusted checks, critic, review, merge, audit, and coordinated recovery state complete through local systems. | `PST-027`, `PRQ-039`, `PRQ-040` |
| AST-027 | Release approver | Approve one immutable package and complete pre-promotion evidence graph, then observe later effects without changing its identity. | A signed immutable envelope enumerates the exact package/source/policy/test/provenance/SBOM/signing/attestation/critic digests; the durable ledger binds approval, GitOps, consumer, rollback, release, and mirror receipts to that fixed digest. | `PST-028`, `PRQ-041` |
| AST-028 | Platform operator | Operate an event-driven delivery transaction through duplicates, partial effects, loss, replay, and restart. | Admission, ledger, EventBus, Workflow, trusted status, artifact, desired state, Argo health, probe, rollback, and authorized replay remain correlated and idempotent. | `PST-029`, `PRQ-040`, `PRQ-042`, `PRQ-045` |
| AST-029 | Security reviewer | Prove the path is local, immutable, least-privilege, and auditable. | Empty-node/CRI-cache denial, registry audit, dependency inventory, credential isolation, immutable identities, scoped issuers, signatures, negative tests, logs, and exceptions agree. | `PST-030`, `PRQ-043`, `PRQ-044`, `PRQ-046` |
| AST-030 | Change-gate operator | Switch authority without conflating internal recovery, emergency transfer, mirror operation, and retirement. | Coordinated snapshot/restore, human APPLY, dead-man, recovery deadline, four-hour outage proof, delayed probe, fourteen-day observation, and later exact-target retirement are separate records. | `PRQ-045`, `PRQ-047`, `WAVE-014` |
| AST-031 | Agent Platform service owner | Operate the delivery control plane within accepted capacity, cost, support, and recovery objectives. | Dashboards and runbooks prove repository/event scale and age, queue, validation, health, rollback, concurrency, compute, storage, spend, operator-hours, availability, support/on-call, RPO/RTO, backup age, retention, upgrade, escalation, and ownership thresholds. | `PST-031`, `PRQ-048` |
| AST-032 | Public visitor, authorized consumer, or prospective contributor | Verify public mirror bytes and distinguish GitHub's in-Service rights from any additional project/off-platform/package license, issue, vulnerability, contributor-rights, and support paths without mistaking mirror input for internal authority. | Public metadata binds mirror bytes to the signed release envelope, preserves GitHub Terms rights, states that `UNLICENSED` makes no additional project grant beyond those Terms and applicable law, identifies separate-user terms, rejects external code until approved CLA/assignment intake exists, and declares freshness, outage, support, import, and retirement behavior. | `PST-032`, `PRQ-047` |
| AST-033 | Identity and audit reviewer | Reconstruct every protected action through immutable human/machine subjects and the durable effect ledger. | MFA, deprovisioning, break-glass, imported-history, issuer-scope, retention, replay, and recovery tests reconcile to exact change and release identities. | `PST-033`, `PRQ-039`, `PRQ-040`, `PRQ-044` |

### Architecture requirements

| Requirement ID | Requirement | Layer | Verification | Product links |
| --- | --- | --- | --- | --- |
| ARQ-035 | A capability-qualified supported Forgejo release and internal IdP become repository, issue, pull-request, review, protected-status, branch-protection, audit, and portfolio-work authority only after attended cutover. | authority | Exact-version capability suite; immutable subject/MFA/deprovisioning/break-glass tests; provider-neutral IDs; governance-history import markers; portfolio reconciliation; GitHub-unavailable transaction; upgrade and coordinated restore rehearsal. | `PRQ-039` |
| ARQ-036 | A dedicated admission service authenticates the raw Forgejo webhook body and writes a canonical PostgreSQL transaction before Argo Events may transport it through a file-backed replicated JetStream EventBus or a Sensor may submit a repository-owned WorkflowTemplate. | event/control | HMAC, secret key version and rotation overlap, trusted receipt time, provider/repository/event/ref allowlist, payload size, delivery ID/payload-hash uniqueness, authoritative state re-fetch, malformed body, duplicate, reorder, stale head, retry, dead letter, EventBus loss/partition, restart, archive, and authorized replay fixtures. The target EventBus uses at least three replicas across eligible failure domains, or a separately approved topology proving equivalent loss/partition durability. | `PRQ-040` |
| ARQ-037 | The promotion identity is an immutable package subject plus one signed immutable envelope enumerating every required pre-promotion subject/referrer and authority digest; subsequent lifecycle effects are ledger receipts, not envelope mutations. | artifact/supply chain | Exact-byte and two-clean-build (or explicitly approved equivalent) tests; subject/envelope verification; ORAS pull; source/policy/test/provenance/SBOM/signing/attestation/critic completeness; fixed version-to-digest binding; separated publisher/signer; ledger approval/consumer/rollback/release/mirror receipts and mirror comparison. | `PRQ-034`, `PRQ-041` |
| ARQ-038 | Argo CD is the sole desired-state mutator for a stable digest-pinned harness Deployment whose init container verifies the package and envelope into a fresh volume before the main container installs and probes it. | deployment | Internal desired-state repo, AppProject/namespace/kind allowlists, field-owner inspection, fresh-volume proof, real install, readiness, Synced/Healthy state, drift, functional probes, rollback, orphan cleanup, delayed durability. | `PRQ-042` |
| ARQ-039 | All executable inputs resolve from approved internal systems with immutable identities, and offline acceptance covers the full node/controller boundary. | reproducibility | Controlled node with empty CRI/task caches; node, gateway, candidate, workflow-controller, and Argo CD repo-server egress denial; internal DNS/registry/package audit; isolated mirror refresh; offline bootstrap/recovery bundle; no mutable tags or external fetches. | `PRQ-043` |
| ARQ-040 | Identity, review, authorization, status, secret, provenance, and audit controls are transport-neutral; candidate execution has no privileged service-account token or delivery credential and is admission-confined by a restricted Pod Security policy or proven equivalent. | security/governance | Exact-head/stale-review fixtures; immutable identity subjects; imported approvals remain historical; separate candidate/validator/critic/status/publisher/signer/mirror/GitOps principals; token-automount denial; non-root execution; RuntimeDefault seccomp; all capabilities dropped; no privilege escalation, host namespaces, hostPath, devices, or privileged containers; read-only root filesystem where compatible; ResourceQuota/LimitRange, isolated ephemeral workspace and TTL cleanup; admission-rejection, credential-reference, redaction, and negative-policy tests. | `PRQ-044` |
| ARQ-041 | A PostgreSQL-backed durable transaction/effect ledger with tamper-evident archived events, not Argo controller memory, owns canonical state and idempotency for event, policy, status, publication, signing, promotion, rollback, replay, and recovery. | reliability/observability | Atomic unique transaction key and payload hash; monotonic attempts; compare-and-set transitions; transactional outbox; immutable external-effect receipts; synchronized time; access/deletion audit; retention/archive/backup/restore; partial-effect, concurrent-attempt, restart, replay, clock-skew, and stale-currentness tests produce no duplicate effects. An alternative store requires explicit architecture approval and identical contracts. | `PRQ-040`, `PRQ-045` |
| ARQ-042 | Isolated rehearsal and coexistence precede an attended authority switch; coordinated internal restoration is the rollback path, public mirrors are not failback, and destructive retirement or emergency authority transfer are separate gates. | migration/recovery | Parity packet, whole-control-plane snapshot/restore, recovery deadline, dead-man, attended APPLY, four-hour outage proof, fourteen-day observation, delayed probe, and exact separately authorized targets. | `PRQ-045`, `PRQ-047` |
| ARQ-043 | Every unresolved external dependency is explicit, owned, expiring, detectable, and recoverable, and no load-bearing exception may be waived at cutover. | governance/supply chain | Versioned exception ledger and discovery check fail on omission, expiry, mutable identity, missing fallback, or any load-bearing entry at cutover. | `PRQ-046` |
| ARQ-044 | Public GitHub, Releases, and npm are output mirrors governed by a versioned authority, proprietary/source-available GitHub-versus-project license posture, separate-user, contributor-IP, freshness, outage, issue, vulnerability, support, verification, deprecation, and retirement contract. | product boundary/integration | Public docs preserve GitHub's in-Service public-repository rights and state that `UNLICENSED` makes no additional project grant beyond GitHub's Terms and applicable law for off-platform use, modification, redistribution, derivatives, or package use; legal/IP confirms the exact statement. Docs identify separate written terms where applicable, accept issue/security reports, reject external code until approved CLA/copyright-assignment intake exists, bind mirrored bytes to the signed envelope, expose lag, and prove mirror failure or public input does not satisfy or block internal policy. | `PRQ-047` |
| ARQ-045 | The control plane has named service ownership and measurable capacity, cost, latency, reliability, recovery, retention, support, and observation objectives. | operability/cost | Before lock, the owners accept or explicitly revise: one rehearsal plus one live repository; 500 admitted events/day and 20/minute burst; ten-minute maximum event age except authorized replay; two workflows and one release/day; 16 vCPU, 32 GiB, 200 GiB, USD 250/month, at most four attended operator-hours per rolling seven days including incident response with any exceedance requiring an explicit threshold revision or extension record, and at most 30 consecutive dual-run days before an explicit extension decision; 99.5% monthly availability excluding approved maintenance; 24x7 automated alerting with attended release/cutover windows; at least twenty consecutive distinct successful end-to-end change transactions and at least three consecutive distinct successful release-and-rollback transaction pairs; p95 queue/validation/health/rollback; RPO/RTO and mirror freshness; 24-hour snapshot and 30-day restore-rehearsal age; raw admitted events and transaction/effect/status/audit/acceptance evidence retained at least 365 days; supported package subjects, signed release envelopes, and immutable graphs retained through the later of support end or retirement plus at least 365 days; outage proof; 30-minute delayed re-probe; and fourteen healthy days. `NORTHSTAR_INTERVIEW.md` is the canonical disposition surface with stable `OWN-001` through `OWN-009`, exact `OE-001` through `OE-034`, immutable identity/authority assignment, one record per applicable pair, and blocking conflict semantics. | `PRQ-048` |
| ARQ-046 | The delivery graph treats closed issues #120 and #121 as completed absorbed predecessor contracts before broader migration lanes are dispatched. | sequencing/governance | Issue dependency graph and lane contracts cite and preserve #120 exact-package/atomic-install and #121 protected-development/release-only-main outcomes without redispatch, while assigning each new provider-neutral policy, ledger, release-envelope, consumer, rehearsal, and cutover delta once without contradiction. | `PRQ-049` |

### High-level design

```text
Internal IdP immutable subjects
  -> capability-qualified Forgejo repository / portfolio work / pull request / review
  -> raw signed webhook body
  -> forgejo-event-admission
       -> verify HMAC + timestamp + replay window
       -> normalize canonical repository/work/change/head/base/actor IDs
       -> durable delivery-transaction ledger + immutable event archive
  -> Argo Events EventSource -> file-backed replicated JetStream EventBus -> Sensor
  -> candidate Workflow
       -> immutable source checkout; no service-account token or privileged credentials
       -> unprivileged build/test output
  -> trusted validator / policy Workflow
       -> protected-base validator + policy/template digests
       -> exact-head currentness and independent critic/reviewer evidence
       -> ledger compare-and-set result + trusted status reporter
  -> separated release transaction
       -> publisher writes exact package subject to Zot staging
       -> provenance/SBOM/attestation generation
       -> isolated signer signs complete immutable pre-promotion envelope
       -> approver advances ledger state for the fixed envelope digest
       -> GitOps proposer changes accepted envelope digest in internal desired-state repo
  -> Argo CD sole-owner reconciliation
       -> stable harness Deployment
       -> init ORAS pull + envelope verification into fresh volume
       -> main real install + representative probes -> readiness
  -> ledger effects, Argo health, rollback, durability, mirror, and exception evidence

Output-only coexistence mirrors:
  internal Forgejo -> GitHub Git mirror + governed issue/security bridge
  accepted signed envelope -> npm and GitHub Release mirrors
  local protected results <-> GitHub Actions parity comparison before cutover
```

Admission must persist the canonical transaction before transport. Candidate
execution produces untrusted outputs only; trusted policy, status, publication,
signing, and GitOps effects each require a scoped principal and ledger
compare-and-set transition. The workflow path may produce evidence and propose
Git changes but may not directly mutate the acceptance workload. Argo CD alone
reconciles the committed signed-envelope digest. Tags, semantic versions,
Workflow names, GitHub Releases, and npm versions are searchable metadata, not
authority or deployment identity.

### Ownership split

| Owner | Owns | Must not own |
| --- | --- | --- |
| Verdify Skills repository | Validation commands and fixtures; protected check semantics; package/envelope media types and state machine; stable-harness conformance; transport-neutral work/review/status/release schemas; exception declarations; lane evidence. | Cluster-wide controllers, shared forge/IdP/ledger operation, registry service, signing-key custody, public-mirror credentials, or direct environment mutation. |
| Agent Platform repository and named service owners | Supported Forgejo and IdP operation; event-admission service; durable ledger/archive; replicated EventBus, EventSource/Sensor, and reusable WorkflowTemplates; Zot, signer, and mirror infrastructure; isolated principals; internal desired-state repository and Argo CD Applications; observability; coordinated backup/restore; service objectives; change gates. | Repository-specific acceptance-policy content, candidate self-certification, or unilateral Verdify authority changes. |
| Internal IdP | Immutable human/service subjects, group membership, MFA, deprovisioning, break glass, and authentication audit. | Code review, required status, release approval, or package/deployment decisions. |
| Forgejo | Authoritative repositories, portfolio work, issues, pull requests, reviews, protected statuses/branches, audit, and output-mirror configuration after cutover. | Package bytes, delivery effect idempotency, GitOps desired state, runtime health, or North Star approval. |
| Event admission and delivery ledger | Raw-body authentication, normalized canonical IDs, transaction state, exact-head currentness, effect receipts, replay authorization, archive, and recovery correlation. | Candidate policy results, source review, release approval, or direct deployment. |
| Argo Events and Workflows | Transport admitted events and execute ephemeral candidate, validation, packaging, evidence, and recovery tasks from approved templates. | Canonical transaction authority, long-lived desired state, protected success without trusted reporter, or direct environment deployment. |
| Zot and signing service | Immutable package subjects, release envelopes, referrers, mirror artifacts, signatures, retention, garbage-collection safety, and verification metadata. | Source/review authority, release approval, or deployment decisions. |
| Argo CD / internal GitOps repository | Sole allowed environment desired-state ownership and observed sync/health within AppProject, namespace, kind, and field-manager allowlists. | Building artifacts, approving releases, accepting candidate policy, or fetching public dependencies. |
| GitHub/npm public surfaces | Proprietary/source-available output mirrors, GitHub-Terms in-Service rights, public discovery, issue/security intake, and distribution under declared separate project/package terms. | Protected internal authority, implicit failback, satisfaction of internal approvals/statuses, an unreviewed claim that GitHub users have no rights, or external-code acceptance before approved CLA/assignment terms. |
| Humans and fresh critics | North Star lock, protected review, release approval, change-gate APPLY, emergency authority transfer, exception acceptance, operating-envelope changes, cutover, and retirement decisions. | Hidden, imported-as-current, inferred, or self-authored approvals. |

### Interfaces

| Interface ID | Interface | Required fields and behavior |
| --- | --- | --- |
| IFACE-023 | Source/work/review/status provider | Provider instance and version/capabilities; canonical and provider repository/work/change/review/status IDs; portfolio relationships; immutable head/base; author/reviewer identity subjects; imported-history flag; CODEOWNERS-equivalent decision; conversations; required check name, trusted issuer, protected validator/policy/template digests, attempt, currentness, evidence, result; protection snapshot; audit and mirror refs; timestamps; stale/error state. Adapters: current GitHub and capability-qualified Forgejo. |
| IFACE-024 | Admitted repository delivery event | Raw-body hash and HMAC verdict; secret key version and rotation window; trusted receipt time; provider/repository/event/ref/size allowlist verdicts; CloudEvents-style ID/type/time/source/subject; provider delivery ID; canonical transaction key; repository/work/change; immutable head/base plus authoritative re-fetch result; actor subject; admission policy version; archive ref; JetStream/Sensor/Workflow refs; retry/dead-letter/authorized-replay state. Unadmitted events cannot submit workflows. |
| IFACE-025 | Verdify OCI release graph | Immutable package subject digest and media types; source head; protected policy/template digests; version and immutable binding; tarball/zip; checksum ledger; exact file manifest; build/test/critic refs; provenance predicate/builder/materials; SBOM; signing bundle and trust-root version; attestations; retention/GC/backup policy; signer identity; signed immutable pre-promotion envelope digest. `IFACE-030` records approval, GitOps, consumer, rollback, release, mirror, and retirement states/effect receipts against the fixed envelope. |
| IFACE-026 | GitOps consumer acceptance | Environment; Application/AppProject; internal desired-state provider/revision/path; package subject and release-envelope digests; stable harness digest; init pull/verify and fresh-volume evidence; real install/probes; namespace/kind/field-manager allowlists; sync/health/readiness; telemetry; drift; previous/candidate/rollback envelope; orphan cleanup; UTC verify and delayed re-probe. |
| IFACE-027 | External dependency exception | Dependency class; original origin; internal mirror; immutable identity; discovery source; owner; reason; scope; load-bearing verdict; risk; created/expiry; detection probe; fallback; remediation issue; closure evidence. Cutover requires zero load-bearing entries. |
| IFACE-028 | Parity, public mirror, cutover, and retirement packet | Candidate heads/envelopes; both-path result matrix; transaction counts and service objectives; logs/metrics/failures; public authority, GitHub-Terms in-Service rights, absence or presence of an additional project/off-platform/package grant, separate-user terms, legal/IP disposition, contributor-IP/non-acceptance rule, issue/vulnerability route, freshness/outage/support contract, and mirror digests; coordinated snapshot set; authorized exact mutations; internal recovery deadline; dead-man; emergency-transfer option; observation window; human decisions; post-verify; delayed probes; exact retirement targets. |
| IFACE-029 | Identity and principal contract | IdP issuer; immutable subject; display identity; human/service class; groups/roles; MFA; lifecycle/deprovision state; credential reference; allowed provider/status/registry/signing/mirror/GitOps actions; prohibited actions; break-glass owner/expiry; imported-history treatment; audit refs. |
| IFACE-030 | Delivery transaction and effect ledger | Canonical transaction key; raw payload hash/archive; repository/work/change/head/base; admission verdict; protected policy digests; compare-and-set state/version; attempt; currentness; requested and completed effects; idempotency keys; issuer/principal; external receipts; outbox/retry/dead-letter/replay authorization; created/updated/retention timestamps; recovery correlation. |
| IFACE-031 | Delivery service objectives and operating envelope | Named service/on-call/finance/security/backup owners and owner approvals; target rehearsal/live repositories; admitted events/day and burst; maximum ordinary event age and authorized-replay rule; concurrent-workflow and release-rate limits; CPU, memory, storage, currency-spend, attended operator-hours including incidents, exceedance disposition, and dual-run bounds; monthly availability and maintenance exclusions; automated-alert and attended-window coverage; p50/p95 queue/validation/health/rollback; parity and false-accept counts; change/release transaction counts; RPO/RTO; mirror freshness; maximum snapshot and restore-rehearsal age; raw-event/transaction/effect/status/audit/acceptance and package-subject/signed-envelope/immutable-graph retention; outage-test hours; delayed re-probe interval; healthy observation days; measurement queries; breaches; approved exceptions and expiry. |

### Required WorkflowTemplates

The repository proposes behavior; the platform supplies reusable mechanics.
Names are illustrative until architecture contracts approve them.

| Template | Behavior | Critical controls |
| --- | --- | --- |
| `repo-candidate` | Check out the immutable candidate and run admission-confined build/test steps whose outputs remain untrusted until protected validation. | No service-account token, Kubernetes API, forge/status/Zot/signer/mirror/GitOps credentials, or public egress. Restricted Pod Security or an approved equivalent enforces non-root, RuntimeDefault seccomp, all capabilities dropped, no privilege escalation, no host namespaces/hostPath/devices/privileged containers, and a read-only root filesystem where compatible. Read-only source, ResourceQuota/LimitRange bounds, isolated ephemeral workspaces, TTL cleanup, and negative admission fixtures are required. |
| `repo-validate` | From a protected-base template and validator digest, run `make test`, repository validation, previously unwired tests, behavior fixtures, and check-specific commands against candidate outputs. | Immutable head/base, policy/template digest, no candidate-supplied validator, no public egress, per-check evidence written to ledger. |
| `repo-policy` | Evaluate exact-head pull-request policy, critic evidence, reviewer identity, imported-history exclusion, CODEOWNERS-equivalent rules, status currentness, and promotion eligibility. | Separate policy principal, compare-and-set ledger state, stale-head/approval invalidation, no candidate-only authority. |
| `repo-status` | Publish a protected check result only after validating a terminal ledger transition and exact-head currentness. | Minimally scoped trusted issuer or signed merge-guard fallback, fixed check namespace, no candidate credentials, effect receipt and audit ref. |
| `repo-package` | Build the exact package archives and run fresh/reinstall/upgrade/collision/corruption/rollback/consumer tests on those bytes; emit unprivileged build outputs. | One source head, deterministic manifest/checksums, no accepted-Zot or signing access, evidence bound to transaction. |
| `repo-publish` | Publish the verified immutable package subject to a staging namespace and generate provenance/SBOM/attestations. | Publisher principal is not candidate or signer; create-only digest semantics; minimal Zot scope; ledger effect receipt; retention and GC guards. |
| `repo-sign-envelope` | Assemble and sign the complete immutable release envelope after every required digest exists. | Isolated signer principal and key reference; no candidate/publisher key access; envelope completeness and signature verification; compare-and-set state. |
| `repo-promote` | Create or update the internal GitOps desired-state change for an approved release-envelope digest. | No direct Kubernetes mutation, required human release approval, exact previous/candidate envelope, allowed repo/path, rollback metadata. |
| `repo-mirror` | After the ledger records `consumer_verified` and authorized `released` state, derive GitHub, npm, or other public outputs from the fixed signed release envelope. | Consumer-verified/released compare-and-set precondition, mirror-only principal and authority, public service contract, idempotency, partial-failure visibility, checksum/envelope comparison. |
| `repo-recover` | Replay an explicitly authorized idempotent effect, resume incomplete envelope state, restore prior desired state, or orchestrate coordinated control-plane recovery evidence. | Human/owner recovery reason, immutable transaction and snapshot-set identity, no stale promotion or implicit GitHub failback, effect CAS, audit refs. |
| `mirror-refresh` | Populate internal image, chart, language-package, binary, and release-download mirrors outside candidate execution. | Source allowlist, checksum/digest verification, quarantine, approval, freshness, rollback and expiry. |

### Immutable dependency and cold-node model

The dependency inventory covers Git remotes, container base/tool images, Argo
and Forgejo charts, Ruby/Node/system packages, ORAS and signing binaries,
Kaniko/build tools, release downloads, generated assets, and any fixture that
currently reaches npm or GitHub. Each record supplies origin, internal location,
digest/checksum, mirror-refresh transaction, owner, freshness, consumer, and
exception status.

A cold-node acceptance worker is scheduled onto a controlled node after its
relevant CRI image and task caches are emptied and the absence is recorded.
Public DNS/egress is denied at node or gateway enforcement and independently for
candidate pods, workflow controllers/executors, and the Argo CD repository
server; an in-pod NetworkPolicy alone is insufficient. Success requires registry,
Git, package, chart, DNS, gateway, and download audit logs to resolve only
approved internal endpoints. Mirror refresh runs in a separate allowlisted trust
domain and cannot overlap candidate validation. A versioned offline
bootstrap/recovery bundle must be restorable when mirrors or controllers are
empty. Warm-cache success is diagnostic evidence, never acceptance.

### Security and authority

- The exact supported Forgejo release integrates with the internal IdP.
  Immutable subjects, groups, MFA, deprovisioning, break glass, and audit map to
  human and machine roles without silently merging authors, reviewers, critics,
  release approvers, or bots. Imported approvals remain historical.
- The webhook verifier receives only its HMAC reference; candidate checkout,
  trusted validation, protected status reporting, Zot staging, signing, public
  mirroring, GitOps proposal, Argo CD reconciliation, and recovery each have
  distinct runtime-injected identities and credential references.
- Candidate pods set service-account token automount off, cannot reach the
  Kubernetes API or privileged endpoints, and receive no forge write, protected
  status, Zot write, signing, mirror, or GitOps credential.
- Sensors may submit only named digest-qualified WorkflowTemplates. Workflow
  service accounts receive no blanket namespace, registry, status, signing, or
  GitOps write authority.
- Candidate code cannot certify its own policy. Protected-base code or a trusted
  digest-pinned Verdify package evaluates the candidate.
- If Forgejo cannot constrain protected status reporting to a minimally scoped
  issuer, a separately signed merge guard must verify ledger receipts at merge;
  otherwise the provider fails capability qualification.
- Zot repository paths and ACLs separate package staging, accepted subjects,
  signed envelopes, and public mirrors. The unprivileged builder does not write
  Zot; the publisher does not hold the signing key; the signer cannot overwrite
  package subjects; only an approved ledger transition can propose desired
  state.
- Garbage collection, retention, replication, backup, and restore preserve every
  subject and envelope referenced by an active, rollback, audit-retention, or
  public-mirror record.
- NetworkPolicy, resource limits, TTL, workspace isolation, log redaction,
  artifact retention, audit correlation, and backup encryption are acceptance
  requirements, not later hardening.

### Observability and recovery

Metrics and logs must expose admission acceptance/rejection, raw-body signature
verdict, transaction and payload identity, duplicate/reorder/replay/partial-
effect count, ledger compare-and-set failure, outbox lag, EventBus persistence,
Sensor trigger, Workflow queue/start/end/duration/retry, per-check outcome and
trusted issuer, protected-base/policy/template revision, package and envelope
digests/state, Zot latency/error/GC guard, GitOps desired/observed revision,
field managers, sync/health/drift, init verification, install/probe outcome,
rollback duration, delayed probe, mirror lag, exception age, RPO/RTO, backup age,
restore result, public-egress denial, registry pulls, operating-envelope breach,
and cutover state. Alerts route to the named service owner and owning repository
controller with the immutable transaction ID and recovery runbook.

Failure injection covers invalid signatures and timestamps, malformed bodies,
duplicate/reordered/replayed events, concurrent attempts, partial effects,
EventBus and ledger restart, unauthorized replay, stale heads, imported/changed
approvals, forged status, failing validation, candidate credential probes,
poisoned or missing mirror content, registry interruption, signer/publisher
separation, incomplete envelope, garbage-collection pressure, GitOps sync or
unexpected field-manager failure, unhealthy init/install/probe, controller
restart, coordinated backup/restore, rollback, public mirror failure, and
service-objective breach. No test may use production credentials or mutate
production.

### Cutover and retirement

1. Keep GitHub Actions, current branch protections, public releases, and current
   portfolio-work authority required while iteration 26 is unlocked.
2. Reconcile closed #120/#121 as completed absorbed predecessors in the
   dependency graph without redispatch. In an isolated rehearsal,
   qualify the exact Forgejo release and prove IdP, provider-neutral work IDs,
   governance-history migration, admission/ledger/status, immutable mirrors,
   signing, GitOps, public-support, and coordinated restore contracts without
   changing authority.
3. Dual-run both paths and block on any false accept or discrepancy. Complete
   at least twenty consecutive distinct successful end-to-end change
   transactions and at least three consecutive distinct successful
   release-and-rollback transaction pairs within the accepted queue,
   validation, health, rollback, storage, and operator-cost envelope.
4. Prove the stable-harness fresh-volume consumer, empty-node/CRI-cache
   internal-only supply chain, controller/node/gateway egress denial, isolated
   mirror refresh, failure injection, unhealthy rollback, coordinated recovery,
   and delayed durability.
5. Snapshot and transactionally identify Forgejo Git and metadata, IdP,
   protections/webhooks, ledger/archive, Zot subjects/referrers, signing trust,
   internal GitOps desired state, evidence, public outputs, deployments, and the
   exception ledger.
6. At an attended change gate, a human applies the exact repository,
   portfolio-work, review, protected-status, merge, and promotion authority
   switch. A dead-man timer triggers internal restoration on missing
   post-verification; it does not silently make GitHub authoritative.
7. Complete four hours of GitHub-unavailable delivery, reconcile output-mirror
   lag, meet Forgejo RPO at most five minutes/RTO at most two hours, and run the
   delayed durability probe.
8. Observe fourteen healthy days. Retire only separately authorized exact
   targets. GitHub, npm, and GitHub Releases otherwise remain output mirrors;
   emergency authority transfer is a separate explicit gate.

### Decision and evidence boundary

`CON-011` through `CON-016` remain blocking until every applicable
identity-bound `NSQ-*`/`OWN-*` decision row and `OWN-*`/`OE-*`
operating-envelope row is complete as mapped in `NORTHSTAR_INTERVIEW.md`.
Missing assignments or rows, any rejection, unresolved conflicting revisions,
or generic approvals keep the affected question and gate open; only after none
remain may Jason resolve `NSQ-015` through `NSQ-020`. Live Forgejo does not yet
exist; live Argo objects and Zot contents were unreadable to this repository
service account; organization-level GitHub controls remain unknown; no
cold-node, GitHub-unavailable, or rollback acceptance has run. Those statements
are limitations and implementation gates, not reasons to infer approval or
readiness.

Evidence:
`northstar://evidence/NSE-20260727-verdify-skills-local-delivery-inventory`,
`northstar://evidence/NSE-20260727-local-delivery-control-plane-primary-sources`,
`northstar://evidence/NSE-20260727-local-delivery-adversarial-audit`,
`northstar://evidence/NSE-20260727-shared-local-delivery-authority-live-state`,
`northstar://evidence/NSE-20260727-local-delivery-native-dependency-reconciliation`,
`northstar://evidence/NSE-20260623-source-control-migration-local-forges`,
`northstar://evidence/NSE-20260623-kubernetes-gitops-cicd-cardinality`,
`northstar://evidence/NSE-20260623-environment-gitops-implementation-best-p`,
`northstar://evidence/NSE-20260623-session-ledger-implementation-best-pract`,
and `northstar://evidence/NSE-20260709-verdify-skills-adversarial-review`.

Product links: `PRODUCT-015`, `PRQ-039` through `PRQ-049`, `PST-027` through
`PST-033`, `MS-012` through `MS-015`, `WAVE-011` through `WAVE-014`, and
`SURF-022` through `SURF-027`.
