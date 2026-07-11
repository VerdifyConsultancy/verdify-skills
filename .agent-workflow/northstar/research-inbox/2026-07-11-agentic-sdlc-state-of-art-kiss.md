# Agentic Software Delivery State of the Art and KISS Direction

Date: 2026-07-11  
Research cutoff: 2026-07-11 UTC  
Verdify baseline: <code>origin/dev@4fe6ff65338bb129cbfbeb2451cb5a5fa696533d</code>  
Published baseline checked: <code>origin/main@416caf3ff005cdb78b58b7c991351edd627fd00b</code>, npm and GitHub release <code>1.3.0</code>  
Status: research evidence and architecture proposals; this report does not change the approved North Star  
Method: Brave Search discovery, primary-source verification, repository inspection, executable local validation, comparable-repository inspection, and an independent adversarial audit

## 1. Executive verdict

Verdify Skills should become a **portable lifecycle and assurance profile for
agentic software delivery**. It should not become another coding agent, general
workflow engine, multi-agent framework, memory database, source-control system,
telemetry backend, software catalog, CI/CD product, or GitOps controller.

The market is converging on a much smaller hot path:

1. A ready issue or bounded request supplies intent.
2. One disposable, isolated environment is leased to one task.
3. One replaceable coding agent gets a small context and tool envelope.
4. Deterministic checks run before model judgment.
5. A pull request carries exact source and check identity.
6. Independent or human review examines the exact head.
7. Merge, deployment, runtime health, durability, and outcome are treated as
   different states.
8. Git and GitHub remain the durable work and delivery record.

Verdify is directionally strong where the market is weakest: North Star
governance, explicit authority, traceable lane contracts, separate worker and
critic contexts, exact-head evidence, release provenance, and the distinction
between merge, deployment, and accepted outcome. Its present risk is that 28
skills, 101 lifecycle modes, 22 states, 49 schemas, and many overlapping
artifacts have arrived before one narrow delivery transaction has been shown to
survive restarts, duplicate dispatch, stale evidence, failed deployment, and a
later durability re-probe.

The KISS recommendation is therefore:

- preserve the 28 skill directories as a library for now, but freeze surface
  expansion;
- make a small deterministic Verdify policy kernel the operational product;
- use existing coding agents through Agent Client Protocol where practical and
  thin adapters otherwise;
- keep GitHub as backlog and delivery authority;
- use Agent Platform and Kubernetes for isolated compute, credentials,
  supervision, and reconciliation;
- use MCP for tools, OpenTelemetry for diagnostics, and GitOps for deployment;
- prove one single-repository lane, then one runtime-changing lane, then one
  narrow cross-project dependency, and only then the four-project slice;
- simplify only from measured trigger confusion, duplicate fields, operator
  steps, artifact touches, latency, cost, and failures—not from arbitrary target
  counts.

## 2. What this report means by “proven”

The word “proven” is easy to misuse in agent research. This report applies the
following evidence ladder.

| Level | Label | What it establishes | What it does not establish |
| --- | --- | --- | --- |
| 1 | Design precedent | A documented architecture, specification, or provider practice exists. | Adoption, correctness, or suitability for Verdify. |
| 2 | Popularity signal | Stars, forks, installs, downloads, or community attention exist. | Successful tasks, security, reliability, or return on investment. |
| 3 | Empirical but non-transferable | A benchmark, survey, controlled study, or vendor deployment reports measured results. | That Verdify will obtain the same result in its repositories and environment. |
| 4 | Locally implemented | Code or an artifact exists at an exact revision. | That it works, fails closed, or survives real operation. |
| 5 | Locally verified | A deterministic fixture, integration test, or exact-artifact check passed. | Repeated live recovery, production durability, or business value. |
| 6 | Operationally proven | A live end-to-end run, failure recovery, rollback, and later re-probe passed. | Sustainable value across a representative workload. |
| 7 | Value proven | Repeated accepted outcomes beat a declared human or no-skill baseline on cycle time, intervention, cost, or defect rate without an unacceptable regression. | Universal performance on unrelated tasks. |

Provider claims, repository stars, SWE-bench scores, schema validity, and green
unit tests are never silently promoted to levels 6 or 7.

## 3. Research questions and scope

This work asked:

1. What user and infrastructure stories is Verdify trying to solve?
2. Which of those stories are already solved by mature systems?
3. What do production coding-agent programs actually keep in their hot path?
4. Which existing skill ecosystems, agents, protocols, workflow engines, and
   platform primitives should Verdify reuse?
5. What is implemented, locally verified, operationally proven, and
   value-proven in Verdify today?
6. Where do the current Skills, Agent Platform, Orbit, and Gravity boundaries
   leak or remain incomplete?
7. What is the smallest sequence that can prove the target without expanding
   scope?

The product boundaries are kept explicit:

| Product | Proper authority |
| --- | --- |
| Verdify Skills | Bounded playbooks, deterministic lifecycle policy, assurance contracts, routing, and adapters. |
| Agent Platform | Isolated compute, credentials, networking, worker/session supervision, Kubernetes/GitOps integration, and runtime status. |
| GitHub | Backlog and delivery authority through issues, branches, pull requests, checks, reviews, deployments, and releases. |
| Orbit | Governed personal and engineering context experience; it may propose or delegate but is not lifecycle authority. |
| Gravity | Tenant-scoped evidence ingestion, retrieval, citations, and typed read-only results; it is not the workflow controller. |

GitHub should not become a high-frequency telemetry database, personal-data
store, or distributed execution log. Skills should not own retries,
idempotency, leases, or durable state transitions. Agent Platform should not
own product requirements or accept its own work.

## 4. Method and limitations

### 4.1 Discovery and verification

- Brave Search API was used for broad discovery across official provider
  documentation, specifications, repositories, engineering reports, standards,
  benchmarks, and independent research.
- Claims used for decisions were checked against primary sources. Secondary
  comparison pages and search snippets were not treated as authority.
- Current repositories were inspected for release state, maintenance cadence,
  archive status, documentation, tests, and boundaries.
- Two close skill repositories were cloned at exact revisions:
  [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) and
  [obra/superpowers](https://github.com/obra/superpowers).
- The comparable addyosmani suite was executed locally: 124 checks passed with
  zero warnings or errors, and 65 of 76 routing cases ranked the expected skill
  first (86%). This is useful routing evidence, not production outcome proof.
- Verdify was independently reviewed through product, engineering, security,
  infrastructure, business, and evidence-quality lenses.

### 4.2 Local verification

At the stated dev revision:

- <code>ruby scripts/validate-repo.rb</code> passed for 28 skills and 49
  schemas.
- <code>make test</code> passed, including the 458-entry manifest, schema,
  lifecycle, lane-review, sprint-terminal, pull-request policy, delivery
  controls, release-preflight, npm install, and exact packed-artifact tests.
- The produced package was <code>verdify-cli-cli-1.3.0.tgz</code>.
- npm reports version 1.3.0 with
  <code>gitHead=416caf3ff005cdb78b58b7c991351edd627fd00b</code>.
- GitHub reports a non-draft v1.3.0 release published 2026-07-10 with the
  tarball, archive, checksums, binding, provenance, and release-transaction
  assets.

These are levels 4–5. The completed package transaction also supplies an
observed live publication and recovery episode, but it is not level 6 under
this report's rubric: no executed rollback and later durability re-probe are
cited. It does not prove safe installation into every consumer topology or
autonomous lane recovery.

### 4.3 Limitations

- GitHub GraphQL quota was exhausted during the first final board query, then
  recovered. A fresh 2026-07-11 query found 14 open Verdify Skills issues, 133
  Agent Platform issues, 62 Orbit issues, and 21 Gravity issues and confirmed
  that every issue mapped in Section 22 remains open. This is still a
  point-in-time snapshot and must be refreshed before implementation.
- Vendor production reports are primary sources but interested evidence.
- Repository stars and downloads are a dated popularity snapshot only.
- The external field moves rapidly; every adopted protocol or dependency must
  be pinned and rechecked.
- No private data, secret value, destructive mutation, production deployment,
  issue edit, or pull-request mutation was used for this research.

## 5. Exact Verdify baseline

The current dev tree contains:

| Surface | Count or state | Interpretation |
| --- | ---: | --- |
| Skill directories | 28 | 25 ordered lifecycle skills, one configured standalone issue-triage skill, plus crm-email and timeline-historian domain skills. |
| Lifecycle modes | 101 | A large machine-facing routing vocabulary; not evidence of harmful complexity by itself. |
| Standard states | 22 | A meaningful state model, but only some transitions are deterministically enforced. |
| YAML schemas | 49 | Broad artifact structure coverage; schema presence does not prove semantic enforcement or runtime use. |
| Reference files | 70 | Progressive disclosure is structurally sound; cross-skill duplication needs usage evidence. |
| Skill scripts | 8 across 4 skills | Most skills are procedural playbooks; deterministic behavior is concentrated in the shared CLI and validators. |
| Evaluation files | 28 with 77 cases | Cases are prose fixtures; no general executable behavior runner currently grades them. |
| Published package | 1.3.0 | Exact npm/GitHub/source binding and release assets are live. |
| North Star current-state prose | says 26 skills/1.2.1 | Stale relative to the exact audited baseline; retain as approved intent, not current inventory. |

### 5.1 The 28 skills

1. Entry and evidence: project-router, repo-bootstrap, transcript-replan,
   northstar-research-ingest.
2. Product and architecture: northstar-planning, northstar-interview,
   northstar-question-resolution, project-definition,
   architecture-contracts.
3. Strategy and repository readiness: state-of-union, repo-hygiene,
   platform-readiness, gravity-readiness.
4. Sprint and delivery: sprint-planning, sprint-replan, sprint-orchestrator,
   controller-loop, subagent-worktree, lane-delivery.
5. Assurance and integration: independent-critic, controller-merge,
   release-verification, sprint-handoff, adversarial-audit,
   consensus-audit-workflow.
6. Standalone/domain work: issue-triage, crm-email, timeline-historian.

All individual SKILL.md files are below the Agent Skills recommendation of
roughly 500 lines and 5,000 tokens. The main complexity concern is therefore
not oversized individual instructions; it is the number of triggers, modes,
states, artifacts, repeated fields, and handoffs a routine story may touch.

### 5.2 What is working and genuinely strong

- GitHub Issues and pull requests are explicitly authoritative.
- The default implementation identity is one issue, lane, branch, worktree,
  worker session, and pull request.
- Lane leases and separate worker/critic worktrees are implemented and tested.
- Product, architecture, evidence, gates, and lane work use durable repository
  artifacts rather than private chat state.
- Route authority and terminal receipt behavior have substantial deterministic
  test coverage.
- Pull requests bind implementation, evidence, reviewed, and current head
  identities.
- A fresh critic and a non-author, commit-bound maintainer review are required
  before protected integration.
- Merge, release, deployment, outcome, and terminal status are modeled
  separately.
- Package 1.3.0 has unusually strong exact-artifact, integrity, provenance,
  recovery, npm, tag, release, and consumer-install evidence.
- Research ingestion produces normalized, hashed, queryable North Star
  evidence.

### 5.3 Demonstrated local gaps

1. **Installer collision safety is not fully closed.** The npm init path invokes
   the legacy host-link script. That script removes any existing path at a
   selected skill name before creating a symlink. A consumer-owned directory at
   that path can therefore be deleted. The transactional package copy does not
   by itself protect those host paths. A minimal reproducer and issue are
   needed before claiming safe installation.
2. **Critic approval can be vacuous.** The critic schema allows an empty
   <code>acceptance_assessment</code>; the semantic validator only iterates
   entries that exist. An approving critic can therefore cover zero criteria.
   Existing issue #73 owns exhaustive critic evidence.
3. **Scope is described but not enforced against the diff.** Lane validation
   rejects a literal overlap between owned and prohibited declarations, but it
   does not compare changed files to the contract's allowed and prohibited
   paths.
4. **Evaluation is not executable end to end.** There are 77 prompt/assertion
   cases but no common runner that invokes the skill in a clean context,
   compares with/without-skill behavior, and grades objective outcomes. Issue
   #75 owns the runner; #74 owns consumer enforcement.
5. **YAML identity can be lost while structure passes.** Unquoted issue-like
   values in YAML can be parsed as comments or nulls while related validation
   remains green. This has affected draft pull-request evidence and is tracked
   by #74.
6. **Terminal handoff has a weaker contract.** Canonical SprintHandoff YAML
   lacks the schema-reference and semantic validation discipline applied to
   stronger lifecycle artifacts.
7. **Recovery instructions exceed executable capability.** The controller
   documentation requires a baked <code>resume-check</code>, but no such helper
   is present.
8. **Dispatch is provider-specific despite a topology-neutral North Star.**
   Sprint orchestration hardcodes <code>add_worktree_agent</code>; the live
   platform operation was observed as unavailable/permanently unimplemented in
   this environment. A local leased-worktree fallback exists as a separate
   skill, but capability negotiation is not the normal path.
9. **No adversarial durability proof exists.** There is no recorded matrix that
   kills the controller at every transition, duplicates dispatch, drops
   callbacks, expires a lease, changes the reviewed head, fails a deploy after
   merge, then proves recovery and a later re-probe.
10. **No value baseline exists.** Verdify has not yet compared accepted
    outcomes, review effort, cost, intervention, or escaped defects against a
    human-only or no-skill path.

## 6. The intended user stories, current evidence, and gaps

The approved 26 product stories are grouped below without dropping their
traceability.

| Story family and IDs | User outcome | Working today | Proven today | Remaining gap / next proof |
| --- | --- | --- | --- | --- |
| Evidence-to-North-Star planning (PST-001, PST-009) | Natural-language transcripts, research, questions, and feedback become cited planning artifacts and focused human decisions. | Transcript routing, research ingestion/query, North Star planning, interview packets, and question resolution exist. | Local artifacts and validators; repeated registered evidence entries at levels 4–5. | Measure answer quality, missed conflicts, operator effort, and with/without-skill benefit; current inventory prose is stale. |
| Distinct human authorities (PST-002, PST-025) | Review, release approval, and final North Star lock cannot be confused. | Authority matrix, artifacts, release workflow, and exact identities distinguish the roles. | The v1.3.0 release transaction exercised release authority; schema/route tests exercise policy. | Prove malformed/stale authority records fail closed across every route; keep the human identity policy externally configurable. |
| Repository install and deterministic route (PST-005) | A repo owner installs Verdify and gets one next action from durable state. | Init, doctor, route, validation, packs, and host discovery exist. | Source and packed-artifact tests pass. | Fix host-path deletion risk; prove clean install, upgrade, collision, corruption, rollback, and consumer-owned-path preservation from the published package. |
| Package maintenance and trusted distribution (PST-006, PST-022) | Maintainers can validate and publish one exact, provenance-bound artifact. | Manifest, schema, CLI, policy, npm, archive, release transaction, and provenance controls are extensive. | Strongest Verdify proof: v1.3.0 is bound across source, npm, tag, GitHub release, and release assets. | Add consumer semantic conformance and safe unmanaged-collision proof; avoid equating package release success with runtime platform readiness. |
| Traceable bounded implementation (PST-003) | A worker receives one issue-backed contract with requirements, evidence, gates, scope, and stop conditions. | Lane contracts, leases, prompt manifests, worktrees, branches, closeouts, and PR templates exist. | Deterministic fixture coverage at level 5. | Enforce actual diff paths; prove duplicate dispatch and crash recovery; measure context size and operator steps. |
| Review-ready evidence and independent criticism (PST-004, PST-007) | A reviewer sees exact tests, head identity, risks, rollback, and an independent assessment. | Separate critic lease/worktree, critic schema, exact-head PR metadata, and review packet structures exist. | Local lane-review and PR-policy tests pass. | Reject empty criterion coverage, quantify critic defect yield/false positives/cost, and prove stale-head rejection against live PR changes. |
| Release, deploy, and outcome proof (PST-008) | Merge, deployment, rollback readiness, runtime health, durability, and accepted outcome are distinct. | Release plans, verification, outcome, terminal receipts, GitOps reconciliation, and diagnostic schemas exist. | Published v1.3.0 is level-5 exact-artifact evidence plus an observed live publication; general application deployment is only fixture/document evidence. | Run one runtime-changing issue through gated deploy-failure simulation, rollback, successful probe, delayed re-probe, and user acceptance. |
| Coherent platform operation (PST-012) | Operators manage source, CI, k3s, GitOps, sessions, observability, and rollback as one plane. | Platform-readiness inventory and contracts exist; the real fleet and Argo/Kubernetes services exist. | July 9 live audit found 38/38 repo StatefulSets ready, but only 42/56 Argo apps Synced and 48/56 Healthy. | Close Agent Platform security P0s, reconcile checkout/runtime drift, prove supported dispatch, and show restart recovery. |
| Safe learning and loop readiness (PST-013, PST-014) | Recurring lessons become reviewed proposals; automation begins only after a manual proof and explicit stops. | Proposal schema, routing guidance, loop-readiness criteria, and stop types exist. | Structural level 4–5 only. | Prove redaction, source scope, deduplication, marginal value, bounded cost, and one scheduled resume cycle before automating. |
| Thin conversational facade (PST-015) | Orbit, Codex, Claude, Hermes, or OpenClaw can invoke the same lifecycle without becoming authority. | Adapter principles and interfaces are documented. | Design precedent only. | Implement one capability-negotiated facade; prove removing or swapping the provider does not alter authoritative state. |
| Repo bootstrap, scope, and fleet health (PST-016, PST-017, PST-020) | A controller discovers a repo, declares authority, and is observable/recoverable. | Bootstrap, repo scope, hygiene, platform inventory, diagnostic packet, and session-ledger structures exist. | Local schema/fixture validation and point-in-time audits. | Prove one new repo end to end, reconcile generated issues with GitHub, restart the controller, and restore outstanding work from durable state. |
| Scoped infrastructure authority (PST-018) | Domain agents can operate only owned infrastructure while repo agents stay namespace-scoped. | Authority and readiness contracts describe owners, allowed/prohibited actions, secrets, audit, rollback, and gates. | Configuration/document evidence; own-namespace RBAC is observable in this pod. | Close live request-desync, archive-secret, and probe-destination security stops; test denial and escalation paths. |
| Orbit governed context (PST-010, PST-019, PST-023) | Authorized personal and engineering context yields cited briefs and proposals without direct untrusted actuation. | Orbit has a ready repo pod and multiple runtime adapters. | July 9 audit is counterevidence: zero working Google accounts, no verified enterprise/meeting connectors, shared personal/fleet trust domain, and failed headless iterations. | Separate principals, move private data out of Git, establish read-only connector contracts, source ACL/freshness/read audit, then prove one cited digest. |
| Gravity cited evidence (PST-011, PST-024) | Authorized consumers receive tenant-scoped cited results or typed denials through versioned HTTP/MCP interfaces. | Live HTTP search and stdio MCP tools exist; core deployments were ready and Argo reported Synced/Healthy on July 9. | Search returned five allowed hits from about 74,609 chunks, proving a live read path. | Hits had zero resolved evidence spans; no network MCP integration; readiness artifacts absent; prove citations, API/MCP parity, denial, durability, and rollback. |
| Portfolio outer loop and consulting reuse (PST-021, PST-026) | Four co-equal projects expose current status/capabilities and later onboard a customer without a parallel lifecycle. | Locked target, PilotProject design, common artifacts, and root-planner responsibilities exist. | Design and local artifact evidence only. | Do not begin with the full four-project slice. Prove a single repo, a runtime lane, one narrow dependency, then correlated four-project recovery; only then test a customer repo. |

## 7. Infrastructure stories, current evidence, and gaps

| Infrastructure story | Reuse/build boundary | Working today | Proven today | Gap |
| --- | --- | --- | --- | --- |
| Backlog and delivery authority | Reuse GitHub Issues, PRs, checks, reviews, deployments, releases. Build only reconciliation and Verdify policy. | Repo rules and CLI encode GitHub authority. | PR/release policy tests and v1.3.0 publication. | Backlog hygiene and fresh cross-repo reconciliation are incomplete; GitHub must not be overloaded with telemetry. |
| Portable skill packaging | Reuse the Agent Skills SKILL.md format and progressive disclosure. | All 28 skills follow the structure and stay under recommended size. | Repository validator and host-link tests. | Cross-host trigger/output/denial equivalence and safe install are unproved; allowed-tools is not a permission boundary. |
| Deterministic policy kernel | Build route, validate, lease, exact-head checks, risk class, transition legality, and compact receipts. | A dependency-light Ruby CLI and schemas exist. | Broad local deterministic test suite. | Several semantic gaps remain; too much policy still lives only in prose. |
| Worker interoperability | Reuse existing agents; prefer ACP sessions and MCP tools. | Multiple agents are available in the platform; local subagent worktree fallback exists. | Individual runtimes work interactively. | Normal dispatch is hardcoded to an unavailable platform operation; no cross-agent conformance run. |
| Isolation and workspace lifecycle | Reuse Git worktrees plus disposable Kubernetes Jobs/containers or VMs. | Worktree leases and worker/critic separation exist. | Local lane fixtures. | No full per-lane credential/egress sandbox and no kill/recovery proof. |
| Durable execution | Start with GitHub plus compact controller projection and Kubernetes reconciliation. Adopt DBOS/Temporal only after measured failure. | Controller state, ledgers, receipts, heartbeats, and status artifacts exist. | Structural/local fixture proof. | No executable resume-check, replay drill, idempotent effect ledger, or seven-day durability proof. |
| Identity, secrets, and egress | Reuse Kubernetes RBAC, short-lived GitHub/OIDC identity, secret references, network policy, and safe-output brokers. | Own-namespace service accounts, credential-reference rules, and secret scanning exist. | Some denial/configuration evidence; package OIDC publication. | Agent Platform P0 security stops remain; personal and fleet principals are mixed in Orbit; worker egress containment is inconsistent. |
| Deterministic verification | Reuse tests, builds, formatters, security scanners, CI, and environment probes. Build contract-to-diff checks. | Extensive source/package tests. | Level-5 local suite and exact package artifact. | Skill behavior evals, prohibited-path enforcement, consumer conformance, visual/runtime checks, and flaky-test policy are incomplete. |
| Independent review | Build one exact-head fresh critic policy; reuse branch protection and GitHub reviews. | Separate critic artifacts and required non-author review. | Local PR policy and lane-review tests. | Empty coverage can approve; quality lift and cost are unmeasured; consensus should not be the default. |
| Supply-chain provenance | Reuse GitHub artifact attestations, Sigstore/SLSA concepts, immutable action pins, npm provenance. | Release candidate binding, integrity, provenance, and exact-source publication exist. | v1.3.0 is live and bound. | Skill provenance/allowlisting for third-party marketplace intake and consumer path preservation need proof. |
| Deployment and rollback | Reuse CI, Kaniko, registry, Argo CD, Kubernetes, and environment protection. Build only Verdify evidence adapters. | Wave and GitOps artifacts exist; fleet applications run. | Point-in-time runtime audits; not a general Verdify transaction proof. | Merge-to-deploy correlation, failure rollback, delayed re-probe, orphan cleanup with prune disabled, and accepted outcome remain incomplete. |
| Observability | Reuse OpenTelemetry, Prometheus, Grafana, Alertmanager, and provider logs. | Diagnostic schemas and desired correlations exist. | Design/fixture evidence. | No verified end-to-end correlation from issue to session to PR to deploy to outcome; GenAI conventions are still evolving. |
| Evidence and memory | Keep Git/repo artifacts authoritative; use Gravity for cited read-only evidence and optional caches for convenience. | Evidence registry works; Gravity has a live retrieval path. | Registered evidence query and live uncited search. | Citation hydration, ACL parity, deletion/correction, network integration, and memory quality remain open. Do not build a vector-memory authority. |
| Repository catalog and golden paths | Reuse Backstage if a broader catalog/template product is needed. | Repo bootstrap and AGENTS proposals exist. | Local artifacts. | Avoid duplicating a software catalog; prove one bootstrap and identify only Verdify-specific deltas. |
| Fleet supervision | Reuse Kubernetes controllers/Jobs for process reconciliation; build a small run-state projection. | Repo pods, tmux sessions, and readiness audits exist. | Pod readiness snapshots. | Ready pods have coexisted with stale checkouts, failed loops, and unhealthy Argo apps; process health is not outcome health. |
| Cross-project interfaces | Use narrow versioned HTTP/MCP/ACP/A2A-shaped task vocabulary only where needed. | Proposed capability, PilotProject, Orbit, and Gravity contracts exist. | Design/schema evidence. | No correlated, idempotent, version-negotiated transaction across the four projects. |

## 8. What community and industry are doing in July 2026

### 8.1 The convergent production pattern

The strongest production delivery reports default to one accountable lane
owner and a deterministic controller around replaceable agents; they do not
require an open-ended multi-agent organization:

- [Stripe Minions](https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents-part-2)
  reports more than 1,300 fully agent-written, human-reviewed pull requests
  merged per week. It uses isolated pre-warmed devboxes, deterministic and
  agentic blueprint nodes, a tiny task-specific subset of a much larger MCP
  catalog, no production access, restricted egress, one local repair loop, at
  most one CI repair attempt, and human review for every pull request. This is
  vendor evidence, but it is the closest high-volume analogue.
- [Spotify Honk part 1](https://engineering.atspotify.com/2025/11/spotifys-background-coding-agent-part-1),
  [context engineering](https://engineering.atspotify.com/2025/11/context-engineering-background-coding-agents-part-2),
  and [verification loops](https://engineering.atspotify.com/2025/12/feedback-loops-background-coding-agents-part-3)
  report more than 1,500 merged agent-generated pull requests. Spotify retained
  existing repo/PR/review/merge infrastructure, built a thin agent-swappable
  CLI, exposed few tools, expressed desired states as tests where possible,
  ran deterministic verifiers before opening a PR, and used an LLM judge only
  after those checks. Spotify explicitly says its judge still lacks proper
  evaluations.
- [OpenAI Harness Engineering](https://openai.com/index/harness-engineering/)
  reports roughly 1,500 merged pull requests and about one million lines in
  five months in an internal repo. The important practice is repository
  investment: a short AGENTS map, source-controlled knowledge, runnable apps
  per worktree, logs/metrics/browser validation, and mechanical architecture
  rules. OpenAI warns that the result depends on that harness and is not a
  universal autonomy claim.
- [Anthropic Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents)
  recommends the simplest composable pattern that fits the task and separates
  deterministic workflows from model-directed agents.
- [Anthropic long-running harnesses](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
  use one feature at a time, Git history, a small durable progress record,
  clean checkpoints, stable environments, and deterministic grading.
- [Anthropic's multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)
  is positive provider evidence for a lead agent delegating separable,
  breadth-first research to parallel subagents. It also describes substantial
  coordination and token costs and is not a delivery-lane proof.
- [Why Do Multi-Agent LLM Systems Fail?](https://arxiv.org/abs/2503.13657)
  provides independent empirical counterevidence by classifying coordination,
  specification, and verification failures in multi-agent systems.

The direct Verdify inference is not “copy a vendor.” It is: keep agentic
judgment inside bounded implementation and semantic review; make lease,
authorization, checks, retry count, exact heads, merge, deployment, and
completion deterministic. Parallel agents can improve separable research,
inventory, or independent review, while one accountable owner remains the
default for a delivery lane.

### 8.2 Hosted and platform systems

| System | Useful precedent | Evidence maturity | Verdify boundary |
| --- | --- | --- | --- |
| [GitHub Copilot coding agent](https://docs.github.com/en/copilot/concepts/coding-agent/coding-agent) | Issue-to-ephemeral Actions environment-to-branch/PR, repository instructions, logs, review loop, GitHub-native authority. | Production product; provider evidence. | Reuse GitHub primitives and security controls; do not duplicate its worker. |
| [GitHub Agentic Workflows](https://github.github.com/gh-aw/) | Markdown-compiled Actions, read-only agent job, buffered artifact, threat scan, separately scoped safe-output job, network/tool allowlists, budgets, audit. | Technical/public preview. | Strong safe-output design precedent; not yet a critical dependency. |
| [OpenAI Symphony](https://github.com/openai/symphony) and [Draft v1 spec](https://github.com/openai/symphony/blob/main/SPEC.md) | Issue tracker to isolated workspace and agent; tiny authoritative scheduler; tracker/filesystem recovery; explicitly avoids rich UI, multitenancy, and general workflow scope. | Low-key engineering preview, experimental implementation, no stable releases. | Useful KISS precedent, not proof or a dependency decision. |
| [GitLab Duo Agent Platform](https://docs.gitlab.com/user/duo_agent_platform/) | Issue-to-draft-MR, planning, review, CI repair, security flows, logs, repository instructions, and MCP inside one SCM. | Mixed generally available and beta features. | Confirms SCM-native delivery; avoid naming/product coupling and reimplementation. |
| [Claude Code GitHub Actions](https://code.claude.com/docs/en/github-actions) | Issue/PR mentions and CI events can analyze code, implement work, review, and create pull requests on GitHub runners. | Production product documentation; no transferable outcome proof. | Another replaceable worker/CI adapter; scope GitHub App permissions and secrets. |
| [Cursor Background Agents](https://docs.cursor.com/background-agent) | Asynchronous isolated Ubuntu VMs, branch handoff, follow-ups, custom environments, and a beta API. | Product/design evidence; internet access and read-write GitHub permissions create explicit exfiltration risk. | Candidate worker only; Verdify supplies policy, egress constraints, exact-head review, and outcome evidence. |
| [Google Jules](https://jules.google/docs/) | Experimental asynchronous issue-to-code agent with repository integration and a CLI. | Official product documentation labels it experimental. | Worker candidate, not lifecycle or assurance authority. |
| [OpenHands](https://docs.openhands.dev/overview/introduction) / [Open SWE](https://github.com/langchain-ai/open-swe) | Persistent isolated task sandboxes, pluggable agents, issue/Slack/Linear triggers, automatic draft PRs, middleware. | Active OSS products; limited public production outcome evidence. | Candidate worker/platform adapters, not Verdify lifecycle authority. |

### 8.3 Open-source coding agents

GitHub metrics below are a 2026-07-11 UTC snapshot and prove attention only.

| Repository | Approx. stars | What it is good at | Why Verdify should not absorb it |
| --- | ---: | --- | --- |
| [OpenCode](https://github.com/anomalyco/opencode) | 184,760 | Highly active terminal/desktop/editor worker, skills, MCP, ACP, SDK/server, GitHub action. | It lacks Verdify leases, exact-head assurance, deploy and outcome policy; use as a worker. |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | 105,911 | Broad sandbox options, skills, subagents, rewind, reviewed auto-memory proposals. | Provider worker and memory UX, not delivery authority. |
| [Codex CLI](https://github.com/openai/codex) | 97,172 | OS sandboxing, approvals, worktrees, AGENTS, skills, MCP, subagents, noninteractive runs. | Use as a worker; the hosted control plane is not the OSS repo. |
| [OpenHands](https://github.com/OpenHands/OpenHands) | 80,458 | Pluggable sandbox backends, issue-to-PR, persistence, secrets, confirmations, ACP agents. | Broad mixed-license platform surface; do not fork or treat model-based security analysis as a boundary. |
| [Cline](https://github.com/cline/cline) | 64,551 | Editor/CLI/SDK, checkpoints, rules, skills, MCP, headless GitHub workflows. | Its model-classified approvals are UX, not a hard security boundary. |
| [Goose](https://github.com/aaif-goose/goose) | 51,072 | Open governance, recipes, MCP, plans, hooks, subagents. | Autonomous defaults, optional isolation, and large feature surface argue for an adapter only. |
| [Aider](https://github.com/Aider-AI/aider) | 47,289 | Git-native pair programming, repo map, lint/test loop, undo. | No isolated unattended controller; automatic commits may bypass hooks. |
| [Continue](https://github.com/continuedev/continue) | 34,817 | Clear tool permissions, repo rules, headless review. | Review comments are not commit-bound delivery evidence. |
| [Roo Code](https://github.com/RooCodeInc/Roo-Code) | 24,320 | Historically popular Cline fork. | Archived in May 2026; proves the need for replaceable provider adapters. |
| [SWE-agent](https://github.com/SWE-agent/SWE-agent) | 19,772 | Research/evaluation scaffold for issue-to-patch trajectories. | Not a production SDLC platform. |
| [Open SWE](https://github.com/langchain-ai/open-swe) | 10,257 | Isolated persistent task sandboxes, draft PR, pluggable providers, deterministic middleware. | Default validation remains prompt-driven unless operators add checks. |

[mini-SWE-agent](https://github.com/SWE-agent/mini-swe-agent) is the strongest
direct KISS counterweight: a small Bash-centered worker can be competitive on
[SWE-bench](https://www.swebench.com/). That demonstrates benchmark capability,
not production review, security, deployment, or economics.

The key architecture boundary is:

- A provider-neutral Verdify adapter connects to replaceable worker sessions;
  ACP is one candidate transport pending conformance evidence.
- MCP exposes external tools and data.
- Agent Platform supplies isolated compute, credentials, networking, and
  process supervision.
- Verdify supplies semantic work identity, policy, evidence, review, release,
  deployment, and outcome assurance.
- GitHub supplies backlog and delivery authority.

## 9. Existing skill ecosystems and what Verdify should learn

### 9.1 The portable Agent Skills layer

[Agent Skills](https://agentskills.io/home) now supplies the smallest useful
interchange format: a directory with a required SKILL.md and optional scripts,
references, and assets. Its progressive disclosure model loads metadata first,
the full skill only when selected, and supporting resources only when needed.
The [specification](https://agentskills.io/specification) recommends keeping the
main instructions concise; its allowed-tools field is experimental and is not
a security or authorization boundary.

The [official evaluation guide](https://agentskills.io/skill-creation/evaluating-skills)
is especially relevant:

- start with two or three realistic cases derived from actual use;
- run the same case with the skill and without it or with the old version;
- use clean contexts;
- capture time and token use;
- grade objective assertions mechanically where possible;
- use human judgment for subjective quality;
- remove instructions that do not create marginal value.

This argues for improving Verdify's 77 existing cases before creating a large
new benchmark or more skills.

### 9.2 Repository and marketplace comparison

| Ecosystem or repository | July 2026 signal | Useful design | Caution |
| --- | --- | --- | --- |
| [agentskills/agentskills](https://github.com/agentskills/agentskills) | About 22,900 stars | Portable format, progressive disclosure, validation, evaluation guidance. | Format compatibility does not imply behavioral equivalence or security. |
| [anthropics/skills](https://github.com/anthropics/skills) | About 160,000 stars | High-quality examples, procedures, references, and reusable resources. | Popularity and provider curation are not Verdify outcome evidence. |
| [openai/skills](https://github.com/openai/skills) | About 23,500 stars | Codex-oriented curated skills and reference patterns. | Host-specific behavior still needs conformance tests. |
| [github/awesome-copilot](https://github.com/github/awesome-copilot) | About 36,400 stars | Large instructions/prompts/skills catalog integrated with GitHub workflows. | Catalog breadth can increase trigger ambiguity and supply-chain review burden. |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | About 77,100 stars; 24 skills, six stages, eight commands | Structural tests, deterministic TF-IDF trigger/routing tests, and token/behavior checks. | The local 86% rank-one result is routing evidence only; it leaves 11 of 76 cases not ranked first. |
| [obra/superpowers](https://github.com/obra/superpowers) | About 252,000 stars; 14 skills | A clear design-to-worktree-to-plan-to-subagent/TDD-to-review-to-finish path; plugin tests and external behavioral drills. | Its behavior drill is not ordinary CI and the workflow is narrower than Verdify governance. |
| [skills.sh](https://skills.sh/) | Self-reported 820,513 all-time installs | Discovery plus security-audit aggregation from multiple scanners. | Marketplace installation is a new software-supply-chain surface; installs do not prove correctness. |

The close repositories reinforce four practices:

1. A small, legible user journey matters more than a large ontology.
2. Trigger and negative-control tests are first-class.
3. Repeated mechanical work belongs in scripts or a CLI.
4. Skills should contain failure-derived expertise, defaults, procedures, and
   validation—not reimplement a runtime.

### 9.3 Verdify's skill-level decision

Do **not** delete or merge skills merely to reach a fashionable count. The
current description-overlap scan did not find a single obviously identical
pair; the largest overlaps are expected boundaries such as platform versus
Gravity readiness, adversarial versus consensus review, and sprint planning
versus replanning.

Instead:

- freeze new skills, modes, and schemas until a measured failure requires one;
- expose a small human-facing set of intentions—discover, define, plan,
  execute, review, release, and status—while retaining internal routing;
- instrument co-invocation, wrong-trigger rate, artifacts touched per story,
  duplicate fields, operator steps, token cost, runtime, and abandoned paths;
- consolidate only when those measurements show a redundant boundary;
- preserve required locked-pilot interfaces until consumers are mapped and an
  atomic migration is ready.

## 10. Protocol and interface boundaries

| Protocol | Mature capability | Missing capability | Verdify decision |
| --- | --- | --- | --- |
| [Agent Client Protocol v1](https://agentclientprotocol.com/get-started/agents) | Capability/auth negotiation; session create, load, resume, close, cancel; workspace roots; plans; tool calls; file and terminal operations; MCP connections across many coding agents. | It does not define Verdify issues, leases, risk, exact-head review, release, deploy, or outcome policy. | Optional candidate pending a two-worker conformance, security, maintenance, and fallback spike. Keep the internal adapter provider-neutral. |
| [MCP 2025-11-25](https://modelcontextprotocol.io/specification/2025-11-25) | Stable JSON-RPC tools, resources, prompts, capability negotiation, progress, cancellation, logging, and optional OAuth authorization. | It is not a workflow authority, scheduler, task ledger, or permission enforcement system by itself. The Tasks feature remains draft. | Use for tools/data only; enforce identity, scope, and effects server-side. |
| [A2A v1.0](https://a2a-protocol.org/v1.0.0/specification/) | Stable task IDs, context, artifacts, history, submitted/working/input-required/auth-required/completed/failed states, streaming, and push. | Push delivery is effectively at-least-once; receivers must authenticate, deduplicate, and reconcile. Ecosystem maturity is younger. | Borrow task vocabulary only if a true cross-service agent task appears; do not add it to the single-repo hot path. |
| [OpenTelemetry GenAI conventions](https://github.com/open-telemetry/semantic-conventions-genai) | Shared vocabulary for agents, model calls, tools, events, metrics, and MCP. | The separate repository remains evolving and has unresolved version/schema details. Telemetry is not authority. | Pin an explicit version and use it only for diagnostics/correlation. |

Verdify's semantic idempotency key should be based on repository, issue, lane,
operation, and exact artifact/head identity. Every effect handler must perform
check-before-act and record a compact result. Protocol delivery success is not
business completion.

## 11. Durable execution: build-versus-adopt

The current Verdify design needs durable behavior, but that does not imply it
needs a general workflow engine now.

| System | What is mature or useful | Cost / mismatch | Decision trigger |
| --- | --- | --- | --- |
| GitHub plus [Kubernetes controllers](https://kubernetes.io/docs/concepts/architecture/controller/) and [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/) | GitHub is already authoritative; controllers reconcile desired/actual state; Jobs retry Pods, expose status, backoff, deadlines, and failure policies. | Kubernetes does not replay business-step history or make external effects exactly once. | Default starting point with a compact Verdify projection and idempotent handlers. |
| [Temporal event history](https://docs.temporal.io/encyclopedia/event-history/event-history-java), [activities](https://docs.temporal.io/activity-definition), and [self-hosting](https://docs.temporal.io/self-hosted-guide/deployment) | Most mature durable history/replay, timers, signals, visibility, and long waits. Activities are at-least-once, so effects still need idempotency. | A new operational subsystem, persistence, worker model, replay constraints, and migration burden. | Consider only if measured multi-day workflow/replay failures exceed what reconciliation can safely handle. |
| [DBOS workflows](https://docs.dbos.dev/python/tutorials/workflow-tutorial) | KISS-friendly library plus Postgres; workflow-ID idempotency, durable sleep, notifications, and queues. | Emerging project; external steps remain at-least-once; introduces a database execution authority. | First spike if the compact current loop cannot resume reliably and a library is sufficient. |
| [Restate durable agents](https://docs.restate.dev/ai/patterns/durable-agents) | Journals LLM calls, tools, routing, and events; simple single-node start. | Younger; high availability adds operator/storage/distributed-log complexity; arbitrary effects still need idempotency. | Revisit only after a concrete journal/replay need. |
| [Dapr workflow](https://docs.dapr.io/developing-applications/building-blocks/workflow/workflow-features-concepts/) and [agents](https://docs.dapr.io/developing-ai/dapr-agents/dapr-agents-core-concepts/) | CNCF-graduated core, workflow/state/telemetry/MCP building blocks. | Dapr Agents is newer; sidecars, operators, placement, scheduler, sentry, and platform footprint are broad. | Adopt only if Agent Platform standardizes on Dapr for reasons beyond Verdify. |
| [LangGraph persistence](https://docs.langchain.com/oss/python/langgraph/persistence) and [interrupts](https://docs.langchain.com/oss/python/langgraph/interrupts) | Useful inner-agent graphs, checkpoints, interrupts, and stores. | Resuming restarts an interrupted node; prior effects must be idempotent. It is not an obvious portfolio controller. | Use inside a chosen worker, not as Verdify authority. |
| [OpenAI Agents SDK sessions](https://openai.github.io/openai-agents-python/sessions/) / [HITL](https://openai.github.io/openai-agents-python/human_in_the_loop/) | Serializable agent conversation/run state and approval flows. | Not a distributed workflow scheduler. | Worker implementation choice only. |
| [Google ADK resume](https://adk.dev/runtime/resume/) | Event-based resume and framework sessions. | Tools may execute more than once; custom agents need explicit state handling. | Worker implementation choice only. |

Immediate decision: do not adopt Temporal, Restate, DBOS, Dapr, or a graph
framework as a prerequisite. First implement and test the missing deterministic
resume/idempotency contract. If that proof fails because application-level
history/replay is genuinely required, spike DBOS and Temporal against the same
failure matrix and choose from evidence.

The required drill matrix is:

- terminate before and after every state transition;
- deliver the same dispatch twice;
- lose, delay, and replay callbacks;
- wait 24 hours for an approval;
- expire and reacquire a lease;
- change the pull-request head after evidence;
- merge successfully and fail deployment;
- roll back and resume;
- re-probe after the stabilization interval;
- prove no duplicate PR, comment, release, deploy, or external message was
  created.

## 12. Evaluation and productivity evidence

### 12.1 What external evidence says

- The [Agent Skills evaluation guide](https://agentskills.io/skill-creation/evaluating-skills)
  recommends beginning with two or three realistic with/without-skill cases,
  then iterating from failures.
- OpenAI's [skill evaluation guidance](https://developers.openai.com/blog/eval-skills)
  suggests a small 10–20 prompt routing set covering explicit, implicit,
  contextual, and negative triggers. This is appropriate for cheap routing
  regression, not a substitute for behavior evaluation.
- [Anthropic agent evaluations](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents)
  combine outcome grading, trajectory inspection, deterministic and model
  graders, human calibration, production monitoring, and user feedback.
- [SWE-bench Verified](https://www.swebench.com/) is useful for bounded
  repository issue resolution. It does not test onboarding, product judgment,
  authority, deployment, recovery, or economics.
- [SWE-Lancer](https://arxiv.org/abs/2502.12115) broadens evaluation to more
  than 1,400 freelance software tasks worth about one million dollars, but it
  still does not prove a particular organization's delivery controls.
- [METR time horizons](https://metr.org/time-horizons/) are useful capability
  indicators; METR warns that estimates above roughly 16 hours remain
  unreliable as of May 2026.
- An observational study of
  [7,156 public agent-authored pull requests](https://arxiv.org/abs/2602.08915)
  found acceptance varied by agent and task. Acceptance is not correctness and
  public-repository selection limits transfer.
- A 2026 [Python redundancy study](https://arxiv.org/abs/2601.21276) is
  counterevidence to equating more agent code with more value.

Productivity evidence is mixed:

- [DORA 2025](https://dora.dev/research/2025/dora-report/) surveyed about 5,000
  practitioners and characterizes AI as an amplifier: throughput and product
  effects can improve while delivery stability worsens when foundations are
  weak.
- METR's [early-2025 randomized study](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/)
  found experienced maintainers were 19% slower on the sampled tasks despite
  believing they were faster.
- METR's [February 2026 update](https://metr.org/blog/2026-02-24-uplift-update/)
  found raw late-2025 estimates suggesting roughly 18% speedup for returning
  developers and 4% for new participants, but confidence intervals crossed
  zero and selection bias made the result unreliable.

The appropriate conclusion is not “agents are fast” or “agents are slow.” It is
that Verdify must measure its own accepted outcomes against its own baseline.

### 12.2 Minimal Verdify evaluation program

1. Preserve the existing 77 cases as hypotheses.
2. For each high-risk or changed skill, begin with two or three real failure
   cases and run clean-context with/without-skill trials.
3. Add a small routing/negative-control set for trigger regression.
4. Mechanically grade artifact validity, changed paths, checks, exact heads,
   side effects, and final repository/runtime state.
5. Human-grade product quality, clarity, unnecessary work, and decision
   usefulness without seeing which variant ran.
6. Capture the full trace for diagnosis, but keep authoritative outcomes in
   GitHub and compact receipts.
7. Promote failures from live use into regression cases.
8. Expand sample size based on observed variance and risk, not a fixed
   portfolio-wide number.

Initial outcome metrics:

- ready issue to acceptable PR yield;
- first-pass local verifier and CI rates;
- accepted/attempted and deployed/merged rates;
- human review minutes and requested-change count;
- critic defect yield and false-positive rate;
- unauthorized or duplicate side effects;
- escaped defects, rollback, and failed durability re-probes;
- elapsed time and compute/model cost per accepted outcome;
- operator interventions and restart recoveries;
- with/without-skill improvement.

## 13. Security, provenance, and memory

### 13.1 Security pattern

A strong documented preview pattern is GitHub Agentic Workflows' two-stage
design: a read-only, network/tool-restricted agent produces a buffered artifact;
deterministic and threat checks inspect it; a separate narrowly authorized job
performs an allowlisted output. Verdify should reuse the analysis/effect
principle—not make the preview a dependency—for issue edits, comments,
pull-request creation, deployment, connector writes, and other consequential
effects.

Required boundaries:

- disposable task isolation before broad in-sandbox freedom;
- short-lived, audience-bound, minimum-scope credentials;
- no production credentials in worker contexts;
- deny-by-default egress or explicit destination allowlists;
- secret references only; no secret values in prompts, logs, Git, or evidence;
- separate untrusted content ingestion from effect-capable principals;
- check-before-act and idempotency for every external write;
- one bounded remediation loop, then human or controller escalation;
- exact artifact/head binding before review or promotion;
- security denials recorded without sensitive content.

The [MCP security guidance](https://modelcontextprotocol.io/docs/tutorials/security/security_best_practices)
reinforces audience validation, no token passthrough, server-side authorization,
minimal scopes, and confused-deputy defenses.

The [OWASP Agentic Skills Top 10](https://owasp.org/www-project-agentic-skills-top-10/)
is useful as an emerging threat checklist, but it is an incubator project in
active development, not a normative standard or a reason to adopt another
format.

### 13.2 Supply chain

Reuse mature primitives:

- [GitHub artifact attestations](https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations/using-artifact-attestations-to-establish-provenance-for-builds)
  for OIDC-bound build provenance and verification;
- [SLSA 1.2](https://slsa.dev/spec/v1.2/) for provenance requirements and
  assurance vocabulary;
- [Sigstore](https://docs.sigstore.dev/about/overview/) for ephemeral
  OIDC-backed signing identities, Fulcio certificates, and Rekor transparency;
- immutable workflow/action pins, SBOMs, package integrity, and repository
  allowlists.

Verdify 1.3.0 already demonstrates a strong internal version of this release
story. Do not create a custom provenance system. Extend the exact-source and
artifact-binding discipline to third-party skills, runner images, policy
bundles, and deployed revisions.

### 13.3 Memory is a cache, not authority

[Letta stateful agents](https://docs.letta.com/guides/core-concepts/stateful-agents)
and [Mem0](https://docs.mem0.ai/open-source/overview) provide useful
conversation and retrieval memory, but they introduce another runtime,
database, probabilistic extraction, and deletion/correction problem.
[MemoryAgentBench](https://arxiv.org/abs/2507.05257) finds current memory
systems weak across retrieval, learning, long-range understanding, and
selective forgetting. [AMA-Bench](https://arxiv.org/abs/2602.22769) finds
similarity-based memory often misses causal and objective-relevant information.

Verdify should keep:

- GitHub as work/delivery authority;
- approved repository artifacts as policy and contract authority;
- Git as the change journal;
- telemetry as diagnostics;
- Gravity as cited, tenant-scoped read-only evidence;
- optional agent memory only as a non-authoritative, reviewable cache.

Gemini CLI's reviewed auto-memory inbox is a useful precedent: learning
candidates should not directly edit active rules, credentials, project
instructions, or skills.

## 14. KISS target architecture

### 14.1 The minimum useful system

    GitHub issue / PR / checks / review / release
                        |
              deterministic verdify kernel
       route | validate | lease | policy | exact heads
            idempotency | gate | compact receipt
                        |
             one capability-negotiated adapter
                        |
       one isolated worktree/container + one existing agent
                        |
           deterministic tests/build/security/probes
                        |
          one fresh exact-head critic + risk human gate
                        |
                       merge
                        |
          optional deploy adapter -> probe -> re-probe
                        |
                accepted outcome receipt

The kernel is the owned operational core; the Verdify product/profile also
includes portable skills and assurance contracts. Agent workers, SCM, CI,
Kubernetes, GitOps, telemetry, catalogs, identity, signing, and retrieval are
composed products.

### 14.2 Minimal operational state

For the hot path, one compact run projection should be sufficient:

- run ID and idempotency key;
- repository, issue, lane, branch, and pull-request identities;
- base, implementation, evidence, reviewed, and current head SHAs;
- worker and critic adapter/session references;
- current state and state version;
- declared checks and their results;
- risk class, gate, and eligible authority;
- deploy/runtime/outcome references when applicable;
- timestamps, stop reason, retry count, and evidence links.

Do not copy the entire backlog, telemetry stream, model transcript, personal
context, or provider-specific session state into this record.

A new durable artifact or schema should be admitted only when all are true:

1. It crosses an actor, restart, authority, security, or release boundary.
2. A deterministic consumer reads it.
3. Existing GitHub, Git, CI, Kubernetes, GitOps, or telemetry records cannot
   represent it adequately.
4. Ownership, retention, versioning, migration, and validation are clear.
5. A real failure, explicit safety/compliance requirement, or concrete
   machine-consumer need demonstrates the value.

### 14.3 Three proportional paths

These are proposals for the next North Star loop; they do not silently change
current mandatory review policy.

| Path | Candidate work | Minimum controls |
| --- | --- | --- |
| Lightweight | Bounded docs, typo, generated metadata, or clearly reversible deterministic change. | Ready issue or authorized request, scoped branch, deterministic checks, exact head, PR, risk-proportional review, compact receipt. No production, credential, security-boundary, or protected-artifact effects. |
| Standard | Normal implementation. | One issue/lane/branch/worktree/session/PR, lease, isolated worker, deterministic checks, fresh exact-head critic, required GitHub review, bounded repair, merge receipt. |
| Protected | North Star lock, architecture contract, release authority, credentials, personal data, security boundary, production, destructive or irreversible change. | Standard controls plus typed durable human gate, separately scoped effect executor, rollback/snapshot where applicable, runtime verification, re-probe, and outcome acceptance. |

### 14.4 Minimal transition model

    ready -> leased -> executing -> pull_request_open
                   ^          |
                   |          v
                   +-- changes_requested

    pull_request_open -> deterministic_checks_passed
      -> exact_head_reviewed -> integration_ready -> merged
      -> deploying -> runtime_healthy -> durability_reprobed
      -> outcome_accepted -> complete

    any active state -> blocked | failed | cancelled
    deploying/probing -> rollback_in_progress
      -> rolled_back_incomplete | blocked | failed

Each transition must compare the expected prior state and version, recompute
current external facts, reject stale heads, and be safe to retry. A failed
deployment leaves the outcome incomplete even if merge succeeded. A Ready Pod
does not imply a successful agent loop; a successful loop does not imply a
correct change. Changes requested return to execution; a new implementation
head invalidates prior check, evidence, and review heads and requires fresh
binding.

## 15. Reuse, build, and stop-doing decisions

| Story | Reuse | Build only | Stop or defer |
| --- | --- | --- | --- |
| Backlog/delivery | GitHub issues, projects, branches, PRs, checks, reviews, deployments, releases, branch protection. | Verdify reconciliation, exact-head policy, and compact receipts. | Parallel private backlog or custom SCM dashboard. |
| Coding | Codex, OpenCode, OpenHands, Gemini, Goose, Claude, or another capable worker. | ACP/thin adapter and capability conformance. | Forking or creating a Verdify coding agent. |
| Tools | MCP servers with server-side authorization. | Task-specific allowlists and typed result adapters. | Exposing the entire tool catalog or treating MCP as policy. |
| Execution | Git worktrees, disposable containers/VMs, Kubernetes Jobs/controllers. | Lease/idempotency/state projection and recovery tests. | General scheduler or multi-agent graph before a measured need. |
| CI and delivery | Existing tests, GitHub Actions, Kaniko, registry, Argo CD, Kubernetes, environment protection. | Evidence mapping, deploy/probe/re-probe/outcome policy. | Custom CI, registry, GitOps controller, or environment manager. |
| Review | Deterministic checks, branch protection, GitHub review. | One independent exact-head critic and risk-proportional human gate. | Self-review, unlimited repair, or consensus on routine lanes. |
| Security | Kubernetes RBAC/NetworkPolicy, OIDC, secret broker/references, GitHub safe-output patterns. | Verdify risk router, denied-effect receipt, and contract-to-diff checks. | LLM permission classification as the security boundary. |
| Provenance | GitHub attestations, SLSA, Sigstore, npm provenance, SBOMs. | Binding into Verdify release and deploy evidence. | Bespoke signing, transparency, or provenance protocol. |
| Observability | OpenTelemetry, Prometheus, Grafana, Alertmanager, runtime/provider logs. | Correlation mapping and diagnostic links. | Custom telemetry backend or telemetry as authority. |
| Catalog/bootstrap | Backstage catalog/templates if broad golden paths are required. | Verdify-specific readiness, authority, and lifecycle deltas. | Rebuilding a general developer portal or catalog. |
| Evidence | Gravity cited read API; Git/repo evidence registry. | Narrow citation/ACL/status adapters. | Vector memory as policy/work authority. |
| Conversational UX | Orbit and existing agent UIs. | Thin intent-to-lifecycle facade. | Making Orbit, OpenClaw, Hermes, Codex, or Claude product authority. |

Mature precedents for bounded automation include
[Dependabot pull requests](https://docs.github.com/en/code-security/concepts/supply-chain-security/dependabot-pull-requests)
and [Renovate](https://docs.renovatebot.com/): a narrow trigger proposes a
reviewable change through the existing SCM and CI path, with concurrency and
update limits. Verdify's ordinary path should feel closer to that than to an
open-ended autonomous organization.

[Backstage Software Templates](https://backstage.io/docs/features/software-templates/)
already create repositories/components from reviewed skeletons, and the
[Software Catalog](https://backstage.io/docs/features/software-catalog/)
already models ownership and system relationships. Catalog ownership is
accountability/display metadata, not runtime authorization. Verdify should
integrate or link rather than duplicate it.

## 16. Recommended sequence with exit gates

This is an evidence sequence, not a commitment to a fixed issue count or date.
Refresh GitHub state before execution and reuse existing issues where they
already own a gap.

### Stage 0 — truth and security floor

Work:

- reproduce and issue/fix unmanaged host-path deletion in npm init;
- reject empty critic criterion coverage and bind every assessment to the lane
  contract;
- quote and semantically validate GitHub issue identities in YAML;
- enforce actual diff paths against owned/prohibited scope;
- give SprintHandoff the same terminal/schema semantics as other authority
  artifacts;
- implement the documented resume-check and check-before-act effect logic;
- replace hardcoded dynamic-worktree dispatch with truthful capability
  negotiation and the fixed-worker/local-worktree strategies that actually
  exist;
- close Agent Platform request-desynchronization, tracked-archive secret, and
  credential-probe destination security stops (#2884, #2887, #2906);
- repair Kubernetes access truth: the fleet MCP currently falls back to
  localhost and the service account lacks the promised own-namespace pod read.

Exit:

- malformed or stale authority always fails closed;
- no approving critic can omit a declared criterion;
- prohibited changed paths fail before PR readiness;
- install/upgrade/rollback preserves every unmanaged path;
- platform capabilities accurately advertise supported, disabled, and denied
  operations;
- no unattended effect path has production or personal-data authority.

### Stage 1 — measurable skill and host behavior

Work:

- turn real failures into clean with/without-skill behavior cases;
- add routing, contextual, and negative-trigger regression;
- run the same core cases across Codex and Claude first, then any supported ACP
  worker;
- measure artifact touches, operator steps, wrong triggers, context size, time,
  cost, and result quality;
- define the lightweight path only after its denied-risk cases pass.

Exit:

- each changed high-risk skill has objective behavior evidence;
- host variation is explicit and fail-closed;
- removing an instruction or artifact that adds no marginal value is safe;
- routine low-risk work can take the short path without bypassing current
  authority.

### Stage 2 — one single-repository standard lane

Work:

- choose one bounded non-runtime issue in Verdify Skills;
- lease one isolated worker using a supported adapter;
- run deterministic checks, open a PR, bind exact heads, use one fresh critic,
  obtain configured review, and reconcile completion;
- in a fixture or shadow repository with no production credentials or personal
  data, inject termination and duplicate dispatch at every transition.

Exit:

- zero unauthorized or duplicate side effects;
- every restart resumes from authoritative state without a second PR or lease;
- a stale reviewed head is rejected;
- the issue, branch, PR, receipt, and current route agree;
- cost/intervention/result are recorded against a human or no-skill baseline.

### Stage 3 — one runtime-changing lane

Work:

- deliver a small change that exercises build, registry, GitOps, deployment,
  health, rollback, and outcome evidence;
- in a disposable preview namespace with no production credentials or personal
  data, deliberately fail a deployment or probe;
- recover without rewriting history and re-probe after stabilization.

Any live failure exercise requires the approved change gate, bounded blast
radius, snapshot/rollback plan, and explicit human authorization.

Exit:

- merge success cannot mark deployment or outcome complete;
- exact source, image digest, GitOps revision, workload revision, probe, and
  rollback evidence correlate;
- failed deployment leaves a truthful incomplete outcome;
- later re-probe remains green;
- orphan/cleanup behavior is explicit given Argo <code>prune:false</code>.

### Stage 4 — one narrow cross-project dependency

Preferred candidate: a read-only Gravity search/evidence request from one
authorized consumer, because it tests identity, versioning, citations, typed
denial, MCP/HTTP mapping, and correlation without granting write authority.

Exit:

- capability/version negotiation is truthful;
- missing, stale, suppressed, deleted, unauthorized, and cross-tenant evidence
  fail closed;
- citations resolve under the same tenant context;
- duplicate requests do not duplicate effects;
- either side can restart and reconcile from durable state.

### Stage 5 — correlated four-project slice

Only after Stages 0–4:

- one project-owned issue traverses Skills policy, Agent Platform execution,
  Gravity cited evidence, and Orbit source-linked reporting;
- every project retains its own backlog, deployment, and outcome authority;
- one correlation ID and compact evidence links connect the transaction.

Exit:

- all four revisions and capability records are current;
- no project silently substitutes its own product authority;
- platform, evidence, context, review, deploy, durability, and outcome all pass;
- a failed or unavailable project produces a typed incomplete result rather
  than a false success.

### Stage 6 — consulting reuse

Bootstrap one customer-owned repository only after the pilot proof. The
customer retains identity, backlog, data/evidence tenancy, credentials,
deployment, review, and outcome authority. Jason-private Orbit context does not
transfer.

Exit:

- no second lifecycle is invented;
- no internal/private authority leaks;
- the customer can uninstall or replace workers without losing its work state;
- measured value justifies broader rollout.

## 17. Where the platform is incomplete today

### 17.1 Verdify Skills

Working:

- complete portable skill package and CLI;
- strong deterministic repository and release validation;
- exact package publication;
- durable planning/evidence structures;
- lane, critic, release, and outcome models.

Incomplete:

- unsafe host-link collision behavior in the published init path;
- empty critic coverage, diff-scope enforcement, YAML identity, handoff, and
  resume gaps;
- prose-only skill evaluation;
- no cross-host behavior contract;
- no kill/duplicate/stale-head/deploy-failure durability proof;
- no measured outcome advantage;
- stale approved current-state prose;
- the route correctly calls for strategy refresh, but issue state must be
  refreshed after the GraphQL quota reset.

### 17.2 Agent Platform

Registered July 9 evidence:

- 38 of 38 repo StatefulSets were Ready, but only 42 of 56 Argo applications
  were Synced and 48 of 56 Healthy;
- the Agents pod was Ready while its checkout was 119 commits behind an
  already-stale in-pod origin and used Verdify 1.0.0;
- Agents, Orbit, and Gravity loops had six consecutive failed headless
  iterations;
- the proposed task-worker/root-planner semantic contract did not exist.

Fresh July 11 read-only evidence:

- the fleet lists four fixed controller runtimes—Claude, Codex, OpenClaw, and
  Hermes—and each reports branch <code>main</code>;
- dynamic worktree add/remove is explicitly disabled and returns a structured
  501, while Verdify sprint orchestration still assumes
  <code>add_worktree_agent</code>;
- the fleet MCP read-only Kubernetes operation attempted
  <code>localhost:8080</code> and failed;
- direct kubectl reached the real API using
  <code>/var/lib/agent-state/kube/config</code>, but the service account was
  forbidden to list Pods in <code>agent-fleet-runners</code>, contradicting the
  stated own-namespace-read readiness expectation.

Incomplete:

- truthful capability negotiation and a supported dispatch adapter;
- own-namespace read/RBAC and MCP kubeconfig correctness;
- checkout/package convergence with repository branch policy;
- P0 security containment;
- healthy Argo reconciliation and session/loop recovery;
- correlated status that distinguishes Pod readiness from work success;
- bounded rate/quota/auth failure behavior;
- one restart-safe issue-to-runtime transaction.

### 17.3 Orbit

Working:

- a Ready repo pod and multiple runtime adapters exist;
- product intent and connector/security issue coverage exist.

Incomplete in the registered audit:

- no working Google accounts and no verified live enterprise, Slack, meeting,
  or transcript connector;
- headless loop recovery unproved;
- personal context and fleet actuation share a trust domain;
- broad source scope lacks normalized identity, ACL, freshness, provenance,
  retention, correction/deletion, and read audit;
- raw personal material remained in source pending a private-data split;
- no end-to-end cited digest with human-gated action proof.

### 17.4 Gravity

Working:

- active current product, Ready core deployments, authenticated live HTTP
  search, approximately 74,609 chunks/evidence rows, and read-only stdio MCP
  tools.

Incomplete in the registered audit:

- returned hits had zero resolved evidence spans because the read model did not
  hydrate authoritative span IDs;
- no trusted network MCP consumer path;
- tenant/vault scope is not full per-principal source ACL enforcement;
- canonical platform and Gravity readiness outputs were absent;
- an Argo conversion Job had failed after 29 hours and GitHub Actions capacity
  was exhausted;
- API/MCP citation parity, typed denial, durability, rollback, and Gate B remain
  unproved.

### 17.5 Cross-project platform

The approved integrated architecture is still a design:

- no current shared PilotProject transaction has been exercised;
- no one correlation ID has traversed issue, worker, PR, deploy, Gravity
  evidence, Orbit report, human gate, and accepted outcome;
- capability states such as implemented, deployed, exposed, integrated, and
  release-verified are modeled but not consistently live;
- Agent Platform security P0s prohibit the four-project slice;
- no seven-day unattended durability run or value baseline exists.

## 18. Bottom-line proof matrix

| Claim | Verdict as of 2026-07-11 |
| --- | --- |
| Verdify is a real, installable Agent Skills package. | Implemented and locally verified; published 1.3.0 exists. Safe preservation of every consumer-owned host path is not yet proven. |
| The repository can validate its declared structures and many lifecycle rules. | Locally verified with a broad green suite. Some semantic and effect rules remain fail-open. |
| Exact artifact/source/provenance publication works. | Level-5 exact-artifact evidence plus an observed live v1.3.0 publication. Full level 6 is not proven because executed rollback and later durability re-probe are not cited. |
| One issue/lane/worktree/PR and fresh-critic model is implemented. | Implemented and fixture-tested. A general live crash/recovery transaction and quality lift are not proven. |
| Skills improve agent behavior. | Not yet proven; evaluation cases are not executed with a with/without baseline. |
| Agent Platform can reliably dispatch and recover Verdify lanes. | Not proven; the assumed operation is disabled and current access/readiness signals conflict. |
| Orbit can safely combine personal and engineering context. | Not proven; core connectors and trust separation are incomplete. |
| Gravity can return trusted cited evidence to cross-pilot consumers. | Partially implemented; live retrieval works, citation hydration and network integration do not. |
| Merge-to-deploy-to-durable-outcome works generally. | Modeled and locally validated, but not operationally proven; the package publication does not prove application deployment, rollback, durability, or outcome recovery. |
| The four projects can build themselves as one autonomous platform. | Not proven and currently prohibited by security/readiness gates. |
| Verdify creates net user/business value. | Not proven; no comparative outcome dataset exists. |

## 19. Decisions preserved, challenged, and proposed

### Preserve

- GitHub as backlog and delivery authority.
- One issue/lane/branch/worktree/session/PR as the default unit.
- Durable repository evidence rather than hidden chat state.
- Separate worker and critic context.
- Exact implementation/evidence/review/current-head binding.
- Risk-sensitive human authority and separate North Star/release approval.
- Merge, deploy, health, durability, outcome, and completion as distinct.
- Four co-equal project ownership as the long-term pilot target.
- Proposal-only learning capture.

### Challenge in the next protected planning loop

- Treating the four-project slice as the first proof rather than the target
  after smaller proofs.
- Any assumption that every durable artifact needs its own schema before a
  machine consumer exists.
- Hardcoded dynamic-worktree dispatch.
- Material-plan consensus as a routine default; reserve multi-party consensus
  for genuinely protected decisions and measure its value.
- Broad PilotProject records that duplicate GitHub, telemetry, and provider
  state rather than linking compact authoritative receipts.
- Any user-facing exposure of all 101 modes.

### Propose

- Name the owned product the Verdify lifecycle and assurance profile.
- Treat the CLI/validator as a small deterministic policy kernel.
- Keep a provider-neutral worker-session boundary; evaluate ACP as an optional
  transport through a two-worker conformance, security, maintenance, and
  fallback spike. Keep MCP as the tool boundary.
- Define an artifact admission test and a compact run projection.
- Add a proportional lightweight path only after denied-risk tests and human
  approval of the policy change.
- Use exit-gated Stages 0–6 above.
- Make accepted outcome, intervention, cost, defects, and durability—not agent
  activity—the decision metrics.

## 20. Primary-source ledger

The links throughout the report are the claim-level citations. This ledger
groups the principal decision sources and records how they were used.

### 20.1 Skills and lifecycle practice

| Source | Use | Evidence caution |
| --- | --- | --- |
| [Agent Skills home](https://agentskills.io/home), [specification](https://agentskills.io/specification), and [evaluation guide](https://agentskills.io/skill-creation/evaluating-skills) | Portable skill structure, progressive disclosure, experimental allowed-tools status, with/without-skill evaluation. | Specification/guidance, not Verdify behavior proof. |
| [Anthropic skills](https://github.com/anthropics/skills), [OpenAI skills](https://github.com/openai/skills), [Awesome Copilot](https://github.com/github/awesome-copilot) | Current public skill libraries and catalog patterns. | Popularity and examples only. |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) at <code>4e8bd9fde4a38cd009053e649f4cdc7cd36b568b</code> | Close comparison and executable structural/routing/token evaluation. | Local suite proves that checkout's tests, not production delivery. |
| [obra/superpowers](https://github.com/obra/superpowers) at <code>d884ae04edebef577e82ff7c4e143debd0bbec99</code> | Narrow lifecycle, worktree/TDD/review practices, behavior-drill precedent. | External drill is not ordinary CI or Verdify evidence. |
| [skills.sh](https://skills.sh/) | Marketplace/adoption and aggregated scanning precedent. | Self-reported installs; scanning is not safe execution. |

### 20.2 Production agentic delivery

| Source | Use | Evidence caution |
| --- | --- | --- |
| [Stripe Minions part 2](https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents-part-2) | High-volume deterministic controller, isolated devbox, tiny tool envelope, bounded remediation, human review. | Vendor-reported internal operation. |
| [Spotify Honk part 1](https://engineering.atspotify.com/2025/11/spotifys-background-coding-agent-part-1), [part 2](https://engineering.atspotify.com/2025/11/context-engineering-background-coding-agents-part-2), [part 3](https://engineering.atspotify.com/2025/12/feedback-loops-background-coding-agents-part-3) | Existing-infrastructure reuse, thin worker abstraction, deterministic verifier before PR, small tools. | Vendor report; LLM judge is admitted unevaluated. |
| [OpenAI Harness Engineering](https://openai.com/index/harness-engineering/) | Repository knowledge, runnable worktrees, telemetry/browser feedback, mechanical architecture rules, internal throughput. | Provider case in a highly invested repository. |
| [Anthropic Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents) | Simplest composable workflows, transparent agent loops, tool design. | Provider guidance. |
| [Anthropic long-running harnesses](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) | Incremental work, Git/progress handoff, clean checkpoints, deterministic status. | Provider experiment. |
| [Anthropic multi-agent research](https://www.anthropic.com/engineering/multi-agent-research-system) and [multi-agent failure study](https://arxiv.org/abs/2503.13657) | Positive precedent for parallel separable research and counterevidence on coordination/specification/verification failure. | Provider system plus bounded empirical study; neither proves multi-agent delivery. |
| [GitHub Copilot coding agent](https://docs.github.com/en/copilot/concepts/coding-agent/coding-agent) | SCM-native issue/branch/PR/review and ephemeral Actions environment. | Product documentation. |
| [Claude Code GitHub Actions](https://code.claude.com/docs/en/github-actions), [Cursor Background Agents](https://docs.cursor.com/background-agent), and [Google Jules](https://jules.google/docs/) | Major commercial asynchronous-agent segment: CI/issue triggers, remote isolated workers, branch/PR handoff, and follow-up. | Product/design evidence; Cursor API and Jules have beta/experimental status and no transferable outcome proof. |
| [GitHub Agentic Workflows](https://github.github.com/gh-aw/) | Read-only analysis plus scanned safe-output effects, allowlists, budgets, audit. | Technical preview. |
| [OpenAI Symphony](https://github.com/openai/symphony) and [Draft v1 spec](https://github.com/openai/symphony/blob/main/SPEC.md) | Small issue-to-isolated-worker scheduler and explicit non-goals. | Engineering preview, experimental, no stable release. |
| [GitLab Duo Agent Platform](https://docs.gitlab.com/user/duo_agent_platform/) | SCM-integrated planner, coding, review, CI repair, security flows. | Feature maturity varies and some workflows are beta. |

### 20.3 Workers and worker protocol

| Source | Use | Evidence caution |
| --- | --- | --- |
| [ACP agents](https://agentclientprotocol.com/get-started/agents), [initialization](https://agentclientprotocol.com/protocol/v1/initialization), and [session lifecycle](https://agentclientprotocol.com/protocol/v1/session-setup) | Replaceable worker connection and capability/session vocabulary. | Does not provide delivery authority or assurance. |
| [OpenHands](https://github.com/OpenHands/OpenHands), [Docker sandbox](https://docs.openhands.dev/sdk/guides/agent-server/docker-sandbox), and [GitHub issue-to-PR](https://docs.openhands.dev/openhands/usage/run-openhands/github-action) | Pluggable isolation and worker automation. | Broad product/licensing surface; outcome evidence limited. |
| [mini-SWE-agent](https://github.com/SWE-agent/mini-swe-agent) | Minimal worker/harness counterexample. | Benchmark capability, not production SDLC proof. |
| [OpenCode](https://github.com/anomalyco/opencode), [Codex](https://github.com/openai/codex), [Gemini CLI](https://github.com/google-gemini/gemini-cli), [Cline](https://github.com/cline/cline), [Goose](https://github.com/aaif-goose/goose), [Aider](https://github.com/Aider-AI/aider), [Continue](https://github.com/continuedev/continue), [Open SWE](https://github.com/langchain-ai/open-swe) | Current replaceable worker landscape and feature boundaries. | Stars/releases prove adoption/activity only. |

### 20.4 Durable execution and reconciliation

| Source | Use | Evidence caution |
| --- | --- | --- |
| [Kubernetes controllers](https://kubernetes.io/docs/concepts/architecture/controller/), [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/), and [Kubebuilder good practices](https://book.kubebuilder.io/reference/good-practices) | Desired/actual reconciliation, retryable Jobs, idempotent handlers. | No business-step history or exactly-once effects. |
| [Temporal event history](https://docs.temporal.io/encyclopedia/event-history/event-history-java), [activities](https://docs.temporal.io/activity-definition), [human approval](https://docs.temporal.io/ai-cookbook/human-in-the-loop-python), and [self-hosting](https://docs.temporal.io/self-hosted-guide/deployment) | Mature replay, signals, timers, visibility, at-least-once effect caveat. | Operational and migration weight; vendor docs. |
| [DBOS workflow tutorial](https://docs.dbos.dev/python/tutorials/workflow-tutorial) and [dbos-transact-py](https://github.com/dbos-inc/dbos-transact-py) | Lightweight library-plus-Postgres durable workflow option. | Emerging and still requires idempotent external effects. |
| [Restate durable agents](https://docs.restate.dev/ai/patterns/durable-agents), [server overview](https://docs.restate.dev/server/overview), and [durable steps](https://docs.restate.dev/develop/python/durable-steps) | Journal/replay alternative and HA tradeoff. | Younger; HA/storage complexity. |
| [Dapr Agent concepts](https://docs.dapr.io/developing-ai/dapr-agents/dapr-agents-core-concepts/) and [workflow concepts](https://docs.dapr.io/developing-applications/building-blocks/workflow/workflow-features-concepts/) | Event-sourced workflow/agent and platform building blocks. | Agent layer is newer; platform-wide footprint. |
| [LangGraph persistence](https://docs.langchain.com/oss/python/langgraph/persistence), [OpenAI Agents sessions](https://openai.github.io/openai-agents-python/sessions/), and [Google ADK resume](https://adk.dev/runtime/resume/) | Inner-worker state and resume precedents. | Not outer delivery authority; duplicate-effect caveats remain. |

### 20.5 Protocols, evaluation, and empirical evidence

| Source | Use | Evidence caution |
| --- | --- | --- |
| [MCP specification 2025-11-25](https://modelcontextprotocol.io/specification/2025-11-25), [authorization](https://modelcontextprotocol.io/specification/2025-11-25/basic/authorization), and [security guidance](https://modelcontextprotocol.io/docs/tutorials/security/security_best_practices) | Tool/resource protocol, capability negotiation, identity and authorization threats. | Protocol cannot enforce operator consent or become workflow authority. |
| [A2A v1.0](https://a2a-protocol.org/v1.0.0/specification/), [task lifecycle](https://a2a-protocol.org/latest/topics/life-of-a-task/), and [async delivery](https://a2a-protocol.org/latest/topics/streaming-and-async/) | Cross-service task vocabulary and at-least-once notification caveat. | Young ecosystem; unnecessary for one local lane. |
| [OpenTelemetry GenAI conventions](https://github.com/open-telemetry/semantic-conventions-genai) | Portable diagnostic vocabulary. | Evolving; telemetry is not authority. |
| [Anthropic agent evals](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents), [OpenAI skill evals](https://developers.openai.com/blog/eval-skills), [SWE-bench](https://www.swebench.com/), and [SWE-Lancer](https://arxiv.org/abs/2502.12115) | Outcome/trace/routing evaluation patterns and benchmark breadth. | Provider interest and benchmark-to-production gap. |
| [DORA 2025](https://dora.dev/research/2025/dora-report/), [METR early-2025 RCT](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/), [METR 2026 update](https://metr.org/blog/2026-02-24-uplift-update/), and [METR time horizons](https://metr.org/time-horizons/) | Productivity/stability counterevidence and measurement cautions. | Population, selection, and task-specific limits. |
| [Public agent PR study](https://arxiv.org/abs/2602.08915) and [Python redundancy study](https://arxiv.org/abs/2601.21276) | Independent evidence that acceptance/outcome vary and more generated code is not automatically value. | Observational/domain limits. |

### 20.6 Security, provenance, platform, and memory

| Source | Use | Evidence caution |
| --- | --- | --- |
| [NIST AI RMF Generative AI Profile](https://www.nist.gov/publications/artificial-intelligence-risk-management-framework-generative-artificial-intelligence) and [NIST AI Agent Standards Initiative](https://www.nist.gov/artificial-intelligence/ai-agent-standards-initiative) | Risk throughout lifecycle; trusted identity, interoperability, authorization, and evaluation. | Framework/initiative, not implementation proof. |
| [GitHub artifact attestations](https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations/using-artifact-attestations-to-establish-provenance-for-builds), [SLSA 1.2](https://slsa.dev/spec/v1.2/), and [Sigstore overview](https://docs.sigstore.dev/about/overview/) | Reusable artifact provenance and identity. | Must still be configured and verified correctly. |
| [OWASP Agentic Skills Top 10](https://owasp.org/www-project-agentic-skills-top-10/) | Emerging skills threat checklist. | Incubator, not normative. |
| [Backstage catalog](https://backstage.io/docs/features/software-catalog/) and [templates](https://backstage.io/docs/features/software-templates/) | Existing software catalog and golden-path capability. | Catalog ownership is not authorization. |
| [Dependabot PR workflow](https://docs.github.com/en/code-security/concepts/supply-chain-security/dependabot-pull-requests) and [Renovate docs](https://docs.renovatebot.com/) | Mature bounded PR automation precedent. | Narrow domains, not open-ended delivery. |
| [Letta stateful agents](https://docs.letta.com/guides/core-concepts/stateful-agents), [Mem0](https://docs.mem0.ai/open-source/overview), [MemoryAgentBench](https://arxiv.org/abs/2507.05257), and [AMA-Bench](https://arxiv.org/abs/2602.22769) | Memory products and independent limitations. | Memory remains probabilistic and non-authoritative. |

## 21. Brave discovery-query ledger

Brave was used to find candidate primary sources. Result ranking and snippets
were not treated as claims. Representative exact queries:

- <code>Agent Skills specification evaluation progressive disclosure official 2026</code>
- <code>site:agentskills.io skill creation evaluating skills allowed-tools specification</code>
- <code>GitHub agent skills repositories workflow SDLC skills 2026</code>
- <code>site:github.com addyosmani agent-skills evals routing</code>
- <code>site:github.com obra superpowers skills TDD worktree review</code>
- <code>open source coding agents GitHub OpenHands SWE-agent aider Cline Continue Goose OpenCode 2026</code>
- <code>site:github.com open source coding agent Gemini CLI Codex Qwen Code Kilo Code 2026</code>
- <code>repository-native autonomous coding agent pull request CI open source 2026</code>
- <code>site:docs.openhands.dev OpenHands GitHub integration sandbox security</code>
- <code>site:mini-swe-agent.com mini SWE agent FAQ sandbox</code>
- <code>site:aider.chat/docs aider git lint test repository map</code>
- <code>site:docs.cline.bot Cline approvals checkpoints GitHub pull request</code>
- <code>site:docs.continue.dev Continue tool permissions GitHub PR review</code>
- <code>site:goose-docs.ai goose permissions sandbox subagents MCP</code>
- <code>site:opencode.ai/docs OpenCode GitHub permissions rules</code>
- <code>site:developers.openai.com/codex sandbox approvals GitHub Action</code>
- <code>site:geminicli.com/docs Gemini CLI sandbox auto memory</code>
- <code>Stripe engineering Minions coding agent pull requests</code>
- <code>site:engineering.atspotify.com background coding agent verification</code>
- <code>site:openai.com harness engineering Codex pull requests</code>
- <code>site:anthropic.com/engineering building effective agents simplicity</code>
- <code>site:anthropic.com/engineering long running agents harness evals</code>
- <code>site:anthropic.com/engineering multi agent research system parallel subagents</code>
- <code>Why Do Multi-Agent LLM Systems Fail primary research</code>
- <code>site:github.blog OR site:docs.github.com coding agents secure SDLC</code>
- <code>site:code.claude.com/docs GitHub Actions issue pull request agent</code>
- <code>site:docs.cursor.com background agents isolated VM GitHub branch</code>
- <code>site:jules.google/docs asynchronous coding agent experimental</code>
- <code>site:github.github.com/gh-aw safe outputs network permissions orchestrator</code>
- <code>site:github.com/openai/symphony SPEC issue tracker workspace agent</code>
- <code>Agent Client Protocol v1 supported agents sessions capabilities</code>
- <code>Model Context Protocol 2025-11-25 tasks authorization security official</code>
- <code>A2A protocol v1 task lifecycle push notification at least once</code>
- <code>Temporal durable execution AI agents human in loop replay official</code>
- <code>DBOS workflow Postgres durable execution idempotency official</code>
- <code>Restate durable agents journal replay official</code>
- <code>Dapr Agents workflow event sourced official</code>
- <code>LangGraph persistence interrupts idempotency official</code>
- <code>Kubernetes controllers reconciliation Jobs idempotent official</code>
- <code>software engineering agents productivity DORA METR 2026</code>
- <code>agent authored pull requests empirical study acceptance 2026</code>
- <code>SWE-bench SWE-Lancer software engineering agents primary research</code>
- <code>site:nist.gov AI agent standards identity authorization evaluation</code>
- <code>site:slsa.dev provenance software supply chain official</code>
- <code>site:docs.github.com artifact attestations build provenance</code>
- <code>site:sigstore.dev OIDC signing Fulcio Rekor official</code>
- <code>site:backstage.io software catalog templates ownership authorization</code>
- <code>agent memory benchmark long term selective forgetting causal 2026</code>

Queries that produced secondary listicles, unsupported retirement claims,
future-dated release candidates, or search-snippet-only claims were excluded.
One Brave result incorrectly suggested Gemini CLI had been retired; the active
official repository and July 2026 release contradicted it.

## 22. Lifecycle handoff

This report should be registered as North Star evidence, then consumed by
state-of-union strategy refresh. It should not directly rewrite the locked
North Star.

Likely existing backlog homes, subject to a fresh GitHub query:

- Verdify Skills #116 for the autonomous SDLC umbrella;
- Verdify Skills #211 for strategy refresh;
- #73, #74, and #75 for critic coverage, consumer/evidence validation, and
  executable evals;
- #43 and #70 for bounded-loop and proportional fast-path policy;
- Verdify #12 plus Agent Platform #2497/#655 for capability negotiation;
- Agent Platform #2884/#2887/#2906 for the security floor;
- Gravity #407/#184 for citations and readiness;
- Orbit #193–#198/#43 for trust, connectors, and lifecycle repair.

Before adding a new installer issue, reproduce the consumer-owned host-path
deletion against the published package, search the live backlog after rate
reset, and attach the exact reproducer. Do not create a duplicate from this
report alone.

## 23. Final recommendation

Verdify should keep its distinctive governance and assurance ideas and become
far less ambitious about the machinery underneath them.

The owned, defensible core is:

- turn source-backed intent into bounded issue-backed work;
- route authority deterministically;
- lease one isolated replaceable worker;
- verify mechanically;
- bind evidence to exact heads;
- review independently and proportionally;
- integrate through GitHub;
- prove deployment, durability, and accepted outcome separately;
- leave one compact reconstructable receipt.

Everything else should be composed from existing systems unless a measured
failure proves the need to build. The immediate objective is not more autonomy,
more agents, more artifacts, or more schemas. It is one truthful transaction
that survives failure, produces no duplicate or unauthorized effect, and
delivers an accepted outcome more efficiently than the baseline. Repeat that
at increasing scope; simplify from the evidence; only then call the platform
autonomous.
