# Autonomous Development Platform Plan

Date: 2026-07-10
Scope: Verdify Skills, Agent Platform, Gravity, Orbit, and the root planning
outer loop
Status: proposed strategy under Verdify Skills issue #211; issue #116 remains
the implementation and fleet-rollout umbrella

## Executive Verdict

The vision is no longer the problem. Iteration 25 already defines the right
North Star: four co-equal projects, one root portfolio loop, project-local
authority, a shared Verdify method, Agent Platform runtime capabilities,
Gravity evidence, and Orbit context and experience.

The system is best described as **four strong partial products without one
proven operating transaction**:

- The method is substantially built.
- The runtime substrate is operating.
- The evidence service is deployed.
- The Chief of Staff experience has prototype primitives.
- The end-to-end autonomous loop is not yet reliable, trusted, evaluated, or
  integrated enough to run unattended.

The plan forward is not to add more parallel agents. It is to make one complete
four-project cycle work, survive failure, and become the regression test for
every later fleet or customer rollout.

## Five-State Delivery Matrix

The five axes are independent and non-transitive. `Proven` in planning or merge
does not imply deployment or a live outcome. `Partial` means some evidence
exists but the axis is incomplete or internally inconsistent; `Unknown` means
revision identity was not established; `Not demonstrated` means the required
outcome has not occurred.

| Project or surface | Planning | Implemented | Merged | Deployed revision | Live verified |
| --- | --- | --- | --- | --- | --- |
| Verdify method and release | Proven: iteration 25 locked | Proven: 28 skills, 48 schemas, and release controls | Proven: `dev@314516e1` and release `main@416caf3f` | Proven: `v1.3.0` binds to release main | Proven for package and runner convergence only; not an integrated platform outcome |
| Verdify autonomous transition and eval | Proven: #43/#70/#71/#73/#74/#75/#116/#135 own the work | Partial: schemas and tests exist; trusted transitions/evals remain open | Partial: current controls are merged, required additions are not | Not demonstrated as a complete autonomous controller release | Not demonstrated: #135 recurred and no unattended transaction passed |
| Agent Platform repo-cell runtime | Partial: #2890 re-lock and readiness approval remain open | Proven: persistent cells, API, MCP, GitOps, telemetry, and loop code exist | Proven: `main@deae5f50` | Proven at follow-up: Argo synced exact main and 38 Ready repo pods used runtime digest `sha256:9936ffe0...` | Partial: 136/136 sessions Ready, but health, security, progress, and durability gates remain red |
| Agent Platform unattended controller | Partial: durable-substrate and provider decisions remain open | Partial: loop rails and watchdog exist | Partial: current loop implementation is merged | Unknown as an isolated controller source/image identity | Not demonstrated: Gravity/Orbit retained six failures at cutoff and lifecycle reported 152/152 invalid records |
| Gravity data plane | Partial: iteration 6 is unsigned and downstream definition is stale | Proven: acquisition, processing, packaging, indexing, and retrieval exist | Proven: `main@66cf5ccb` | Proven at follow-up: Argo synced exact main; running workload image IDs were observed separately | Partial: services and corpus are real, but conversion, work state, vector projection, and citations are degraded |
| Gravity trusted consumer boundary | Partial: Gate B and citation parity are issue-backed | Partial: authenticated HTTP and in-process MCP tools exist | Partial: current implementation is merged | Not demonstrated for a callable network MCP/citation-complete release | Not demonstrated: hydrated citations and HTTP/MCP parity have not passed acceptance |
| Orbit repo-cell and mission primitives | Partial: #197/#198 must reframe authority and stale sprint state | Partial: mission, dispatch, ledger, marker, reconcile, and tick primitives exist | Proven: `main@a5fbe68a` | Known mismatch: Ready pod checkout `3819f1d7` trailed main and was dirty at follow-up | Partial: pod is Ready and standalone OpenClaw is absent, but six failed loops and no behavioral CI remain |
| Orbit governed Chief of Staff | Partial: product intent exists; trust/source decisions remain open | Partial: prototype surfaces exist | Partial: prototype code is merged | Not demonstrated as a current governed product revision | Not demonstrated: no accepted source-to-citation-to-brief transaction exists |
| Integrated four-project transaction | Partial: locked target and issue-backed sequence exist | Not demonstrated | Not demonstrated | Not demonstrated | Not demonstrated: no correlated accepted cycle or durability window exists |

## Fresh Current-State Audit Ledger

Initial synthesis cutoff: `2026-07-10T13:23:11Z`. A critic-triggered read-only
follow-up rechecked the exact source, GitHub, GitOps, Kubernetes, API, database,
job, and in-pod revision claims at `2026-07-10T14:06:56Z`. The commands below
used the existing authorized local operator context, printed no credential
values, and made no runtime mutation. These are point-in-time observations, not
proof of seven-day durability, mutation safety, rollback, or an accepted
four-project outcome.

### Verdify Skills probe VS-20260710

- Source authority: `dev@314516e1ba110fa981a235b21f09750bcbc42500`;
  release `main@416caf3ff005cdb78b58b7c991351edd627fd00b` and
  [v1.3.0](https://github.com/VerdifyConsultancy/verdify-skills/releases/tag/v1.3.0).
- Commands: `git rev-parse origin/dev origin/main`, GitHub issue/PR/check/release
  reads, `bin/verdify route --repo . --write`, `ruby scripts/validate-repo.rb`,
  and `make test`.
- Result: release identity is verified; repository validation passes; the
  committed route record returns `SPRINT_TRANSACTION_AMBIGUOUS` because four
  completed transactions still appear active. Verdify #135 owns the recurrence.
- Limitation: a verified package release and green repository do not establish
  a working portfolio controller or runtime outcome.

### Agent Platform probe AP-20260710

- Source authority: [main `deae5f50848597fb90057b2914c105113a23e3c0`](https://github.com/jvallery/agents/commit/deae5f50848597fb90057b2914c105113a23e3c0),
  `.agent-workflow/platform/platform-readiness.yaml`, the router record, and
  `LOOP.md`.
- Commands: `git -C /Users/jason/repos/agents rev-parse origin/main`; GitHub
  issue/PR reads; `kubectl get applications.argoproj.io -A`; Kubernetes pod and
  image-ID JSON rollups in `agent-fleet-runners`; and authorized in-pod reads of
  dashboard `/api/live-agents`, `/api/lifecycle`, and `/api/good-morning`.
- Follow-up result: 130 open issues and two open PRs; Argo
  `argocd/Application agent-sessions-local-staging` was `Synced/Healthy` at the
  exact main SHA; 38 Ready repo pods used runtime digest
  `sha256:9936ffe09d2e5f10999bd63a45488739179c8a5feb71714ef4e72a8afea2e50b`;
  `/api/live-agents` reported 34 repos and 136/136 Ready sessions;
  `/api/lifecycle` reported 152/152 invalid controller records and no workers;
  `/api/good-morning` had no populated sources/items. Initial loop/watchdog
  probes recorded Gravity and Orbit at six failures.
- Security result: #2884, #2887, and newly triaged #2906 are P0 stop gates.
- Limitation: Argo follows mutable `main`; Ready sessions and a current digest
  do not prove useful progress, safe credential handling, replay, or durability.

### Gravity probe GRAV-20260710

- Source authority: [main `66cf5ccb78bb3e5332da6539db669a73bb37fe46`](https://github.com/VerdifyConsultancy/gravity/commit/66cf5ccb78bb3e5332da6539db669a73bb37fe46),
  iteration-6 North Star review state, and Gate B issues #184/#407.
- Commands: `git -C /Users/jason/repos/gravity rev-parse origin/main`; GitHub
  issue/PR reads; Argo Application, Deployment, pod image-ID, and Job JSON
  reads in `gravity-dev`; aggregate read-only PostgreSQL counts; and in-cluster
  HTTP probes of `/healthz` and `/readyz` from the Orbit cell.
- Follow-up result: 21 open issues and two open PRs; Argo
  `gravity-dev/Application gravity-dev` was `Synced/Healthy` at exact main; nine
  enabled Deployments were Ready; API health/readiness returned 200. The corpus
  held 66,452 sources, 30,403 artifacts, 5,846 generations/packages, 5,844
  manifests, and 74,685 chunks/evidence/lexical projections, with zero vector
  projections. Work state was 143,103 completed, 24,195 queued, 7,211 dead
  lettered, and one retry scheduled; 66,452 outbox records were pending. The
  conversion Job remained failed. Running image IDs were observed for every
  Ready workload, but a callable network MCP service and hydrated citations
  were not proven.
- Limitation: aggregate counts and Ready workloads prove a deployed data plane,
  not tenant-safe cited retrieval, conversion durability, rollback, or Gate B.

### Orbit probe ORBIT-20260710

- Source authority: [main `a5fbe68a8d5cf655f1540fdc2ef43e9418822be0`](https://github.com/jvallery/orbit/commit/a5fbe68a8d5cf655f1540fdc2ef43e9418822be0),
  current state-of-union, and issues #193 through #198.
- Commands: `git -C /Users/jason/repos/orbit rev-parse origin/main`; GitHub
  issue/PR/workflow/ruleset reads; Kubernetes pod/image JSON for
  `agent-fleet-runners/Pod repo-jvallery-orbit-0`; and an in-pod Git/status and
  vendored-Verdify version read with `safe.directory` scoped to the checkout.
- Follow-up result: 62 open issues and two conflicting PRs; no branch ruleset or
  repository behavioral workflow was present. The repo pod was Ready with zero
  restarts on Agent Platform digest `sha256:9936ffe0...`, but its checkout was
  `3819f1d72a90e09ea902a622a10bd89f2ec4b9d5`, eight paths were dirty, and its
  vendored Verdify was 1.1.2. Initial loop/watchdog probes recorded six failures;
  the obsolete standalone OpenClaw deployment was absent.
- Limitation: a Ready shared runtime and prototype scripts do not prove accepted
  main is deployed, behavioral CI exists, connectors are governed, citations
  resolve, or a Chief of Staff outcome is live.

## 1. What Is Working

### Verdify supplies a real method and assurance spine

- GitHub Issues are backlog truth, PRs/checks are delivery truth, default
  branches are accepted code truth, and runtime outcome is independently proven.
- Twenty-eight skills and 48 schemas cover transcript intake, evidence,
  North Star planning, definition, architecture, strategy, readiness, sprints,
  workers, critics, release, and recovery.
- The issue/lane/branch/worktree/session/PR unit gives agents bounded work and a
  clean context handoff.
- The fresh-critic and exact-head gates materially reduce self-certification.
- Release 1.3.0 proves exact artifact, integrity, provenance, npm identity, tag,
  release assets, ledger recovery, protected promotion, and live runner
  convergence as one transaction.

This is the strongest part of the system and should become the common policy
package, not be replaced by a separate Agent Platform or Orbit SDLC.

### Agent Platform supplies real persistent execution infrastructure

- Persistent repo cells, four fixed session kinds, PVC-backed workspaces,
  Authentik, Kubernetes, Argo, in-cluster builds, registry digest pinning, APIs,
  MCP probes, telemetry, and loop/watchdog code all exist.
- The four target workspaces currently have live sessions and healthy attached
  storage.
- The platform can report fleet, MCP, loop, Kubernetes, Argo, and storage state.

This is not a mock platform. The remaining problem is making its control
contracts, security, state truth, and recovery match the capacity already
running.

### Gravity supplies a real knowledge and evidence substrate

- The dev service is deployed at exact GitHub main and its enabled Deployments
  are Ready.
- The corpus contains tens of thousands of sources/artifacts and roughly 74,000
  chunks/evidence/lexical projections.
- Authenticated HTTP retrieval and in-process MCP tools exist, and anonymous
  access fails with a typed 401.

Gravity is therefore a viable evidence provider once citations, authorization,
transport, durability, and readiness are closed.

### Orbit has useful product intent and prototype operations

- Orbit's purpose as Jason's personal assistant and engineering Chief of Staff
  is explicit.
- Mission, dispatch, trace-ID, ledger, done-marker, reconciliation, and tick
  primitives demonstrate the intended experience.
- The obsolete standalone OpenClaw deployment is actually gone, reducing one
  source of architectural confusion.

Orbit should remain a thin governed information and workflow experience over
Verdify, Agent Platform, and Gravity. It should not become the portfolio state
machine or a second delivery control plane.

### The organization already captures failures as durable work

The important defects are mostly in GitHub rather than hidden in chat. That
includes dispatch mismatch, stale routing, semantic transition bypasses, eval
gaps, platform security, loop health, Gravity citation readiness, and Orbit
trust boundaries. The new missing architecture decision is recorded as Agents
#2905.

## 2. Gaps To Close

### A. Truth and transition enforcement

Current schema richness can create a false sense of safety. A router that reads
an unvalidated status, an approval with no assessed criteria, or a completed
sprint still marked active is not trustworthy autonomy.

Close in order:

1. Verdify #135: truthful sprint terminalization.
2. Verdify #71: trusted schema and semantic validation before routing.
3. Verdify #73: non-empty contract-complete evidence for approval.
4. Verdify #75: executable capability/regression eval runner.
5. Verdify #74: make those validators and evals required in consumers.

### B. One executable outer/inner-loop contract

The pieces exist, but no shared contract binds objective, evidence, plan,
permissions, budget, execution, observation, validation, repair, interruption,
stop, provenance, and handoff across every runnable skill.

- Verdify #43 owns that contract.
- Verdify #70 supplies a risk-based lightweight path.
- Verdify #116 owns rollout as the one fleet SDLC.
- Agents #2905 owns the durable execution substrate decision.

### C. Provider capability negotiation

Verdify currently requires `add_worktree_agent`; the platform intentionally
returns a permanent 501 because dynamic worktrees were removed. Both sides are
internally consistent and mutually unusable.

Resolve Verdify #12 and Agents #2497/#655 with a versioned provider contract:

- operation and schema version;
- supported/disabled/degraded status;
- fixed-cell, detached-worker, local leased worktree, or optional dynamic
  strategy;
- identity, scopes, tenancy, concurrency, resource and network policy;
- idempotency key, result ID, heartbeat, evidence and failure refs;
- typed unsupported, unauthorized, busy, degraded, failed, and completed
  outcomes.

Do not force one topology into every repository. Fail closed when no authorized
strategy satisfies the lane contract.

### D. Truthful platform health and durable recovery

Ready pods and fresh heartbeats are infrastructure signals, not autonomous
progress. The platform currently has:

- two open P0 security findings;
- materially degraded Argo, Longhorn, node placement, and alert state;
- 152/152 invalid lifecycle controller records;
- stale/dirty in-pod checkouts;
- Gravity and Orbit loops at six failures;
- no seven-day unattended proof;
- no coherent replayable portfolio execution history.

The health contract must distinguish scheduler liveness, worker execution,
useful progress, blocked reason, authority wait, intervention readiness,
recovery point, and accepted outcome.

### E. Trusted knowledge and context

Gravity and Orbit are complementary, not interchangeable:

- Gravity owns evidence semantics, provenance, citation resolution, query
  authorization, and typed denial/degradation.
- Orbit owns governed source access, personal/enterprise context, source
  freshness, read audit, user experience, and human-controlled actions.
- Agent Platform owns runtime identity and transport.
- Verdify owns lifecycle, capability adapters, review, and outcome evidence.

Gravity #184/#407 and Orbit #193-#198/#43 must close before a live Chief of
Staff can use portfolio evidence safely.

### F. Evaluation, observability, and provenance

The platform needs one trace that joins:

`portfolio decision -> evidence refs -> issue -> sprint/lane -> session/runtime
bundle -> tool/policy events -> commits/PR -> checks -> deployment -> Gravity
query/citations -> Orbit output -> human gate -> outcome -> next decision`.

Use OpenTelemetry GenAI/MCP conventions as a base, but pin a version. Record
source, skill, prompt, model, tools, runtime image, policies, costs, retries,
stop reason, and artifact provenance. Extend the exact-artifact discipline from
Verdify release 1.3.0 to runtime and agent-authored outputs.

### G. Evidence-driven simplification

Verdify #76 correctly identifies nominal modes and unexercised schemas, but its
current wholesale parking proposal conflicts with the locked four-project
architecture. Apply a stricter rule:

1. Exercise a capability in the vertical slice.
2. Keep it if it removes a demonstrated risk or coordination cost.
3. Collapse or delete it if a simpler contract proves equivalent.
4. After atomic consumer convergence, remove the old path with no compatibility
   shim.

## 3. How To Operate The Platform

### Portfolio outer loop

Run a deterministic controller around replaceable model workers:

```text
refresh PilotProject records
  -> validate authority, revisions, capabilities, gates, health, and evidence
  -> rank one bounded portfolio outcome
  -> create/update the owning GitHub issue
  -> select the Verdify lifecycle skill and provider strategy
  -> dispatch one or more dependency-ready inner loops
  -> observe heartbeats, progress, policy, budget, and failures
  -> critic + CI + deployment + runtime + outcome verification
  -> persist lesson proposal and update the next portfolio decision
```

Deterministic code owns state, scheduling, retries, timers, idempotency,
authorization, budgets, and transitions. Models own evidence synthesis,
decomposition, implementation, criticism, and diagnosis. GitHub and project
artifacts remain authority; model memory never does.

### Required `PilotProject` record

Each project refresh must expose:

- repository and product identity;
- accepted source, deployed revision, and dirty/stale status;
- North Star, definition, architecture, strategy, sprint, and gate state;
- issue, PR, check, deployment, and outcome state;
- supported capability/operation versions and provider strategy;
- runtime health, useful-progress health, last success/failure, and recovery
  point;
- identity, tenancy, scopes, idempotency, and audit references;
- Gravity evidence refs and Orbit source/freshness refs where applicable;
- next action, blocked reason, owner, timeout, and escalation path.

### Inner delivery loop

For each selected issue:

1. Reconstruct Git, GitHub, contract, runtime, and prior failure state.
2. Compile a bounded lane contract with acceptance, owned paths, resources,
   risk class, verifier, stop, rollback, and provider capability requirement.
3. Acquire one lease/worktree/session and write a dispatch-only commit.
4. Make incremental progress on one acceptance outcome at a time.
5. Run deterministic tests and leave a clean checkpoint plus durable progress.
6. Use a fresh critic at the exact head; never let the worker self-certify.
7. Integrate through required checks and current authority.
8. Verify deployment/runtime and outcome separately from merge.
9. Release the lease, terminalize the sprint, and emit the next handoff.

### Risk-proportional autonomy

| Class | Typical work | Default control |
| --- | --- | --- |
| Observe | Read-only research, inventory, diagnostics | Automatic with audit and data boundaries |
| Lightweight | Narrow reversible code/docs with no deployment/security/interface effect | Automatic lane after trusted tests and fresh critic |
| Standard | Shared code, interfaces, migrations, preview/dev deployment | Critic, required CI, bounded provider policy, rollback |
| Protected | Main release, production, secrets/RBAC, personal data, destructive or irreversible action | Durable named human gate, timeout, exact evidence, rollback |

The target is not zero human involvement. The target is zero unnecessary human
involvement while keeping humans able to monitor, interrupt, and decide where
consequence requires authority.

## First Four-Project Vertical Slice

### Outcome

**A cited Gravity result drives a source-linked Orbit portfolio brief; the root
planner selects one bounded improvement; Agent Platform executes it through the
Verdify inner loop; deployment and outcome are verified; the resulting evidence
and lesson drive the next outer-loop decision.**

Use Gravity #407 as the capability anchor, narrowed to one deterministic query
and citation-hydration path. Do not begin with personal email or production
mutation.

### Prerequisites

- Verdify #135, #71, #73, #75, and #74 establish truthful control/eval state.
- Agents #2884/#2887/#2906 are contained and live-verified, #2890 is locked,
  #2905 is decided, and a supported dispatch strategy is advertised. #2906
  requires fixed provider destinations, an unknown-provider no-network result,
  runtime egress containment, running-image refusal proof, and protected
  prior-use/rotation disposition; issue closure or unit tests alone do not clear
  the gate.
- Gravity iteration 6 is signed off, Gate B dependencies are current, and one
  citation path is deployable with rollback.
- Orbit #197/#198 align authority and lifecycle; #193-#195 establish the
  read-only trust/source boundary; Orbit runs current Verdify and protected CI.

### Flow

1. Root planner refreshes all four `PilotProject` records with exact revisions.
2. Gravity answers one bounded project-state query with resolvable source
   citations and a typed authorization/availability result.
3. Orbit renders a read-only source-linked engineering brief from that result.
4. Root planner selects the owning GitHub issue and writes a bounded Verdify
   transaction with one portfolio correlation ID.
5. Agent Platform negotiates and launches the supported worker strategy.
6. Worker delivers incrementally; critic and required evals validate exact head.
7. Owning project deploys through GitOps; verifier proves exact revision,
   runtime behavior, rollback, and citation resolution.
8. Orbit reports the accepted outcome without gaining fleet-actuation authority.
9. Gravity retains/retrieves the new evidence; learning capture proposes one
   improvement; the root loop selects or blocks the next action from durable
   state.
10. Kill/restart the controller or worker during a rehearsal and prove replay
    does not duplicate dispatch, approval, merge, deployment, or outbound action.

### Acceptance

- Every project reports current accepted and deployed revisions.
- All portfolio and inner-loop transitions validate against trusted code.
- Provider selection uses advertised capability, not a hardcoded operation.
- One correlation ID joins decision, issue, session, PR, deployment, query,
  brief, and outcome.
- Gravity citations resolve to authorized sources; missing/denied evidence is
  typed and never presented as verified.
- Orbit records source, freshness, tenant, and read audit and performs no
  privileged action.
- Controller/worker restart resumes from the last durable event with no
  duplicate side effect.
- Budget, timeout, stop reason, recovery point, and human intervention are
  visible.
- The outcome is accepted independently from merge and feeds one reviewed
  learning proposal into the next decision.

### Typed stop contract

This is a required implementation contract for Verdify #43/#116 and Agents
#2905; it does not claim current controllers emit these outcomes.

Every stop must write a recovery checkpoint, emit a `VerdifyStatusEvent` with
the exact type below, append a `SessionLedger` `exception_recorded` event with
`result: blocked` and an owner, and prevent the next phase transition.

| Event type | Trigger | Remediation owner | Resume rule |
| --- | --- | --- | --- |
| `stop.stale_revision` | Accepted, base, PR-head, deployed, provider-policy, or evidence revision differs from recorded authority | Checkpoint controller and owning repository/release verifier | Refresh authority and rebuild the affected exact-head or deployment chain |
| `stop.authorization_denied` | Policy, tenant, scope, gate, or subject-access review denies the operation | Policy/security owner | Never retry with broader authority; require a new explicit policy decision |
| `stop.missing_citation` | Required evidence is absent, stale, unresolved, or denied | Gravity evidence owner and consuming-project owner | Resolve an authorized citation or remove/reclassify the unsupported claim |
| `stop.provider_unavailable` | No advertised authorized provider satisfies the contract after bounded retry/failover | Agent Platform capability owner and checkpoint controller | Require fresh capability/health evidence; never force a hardcoded topology |
| `stop.budget_expired` | Wall-clock, iteration, retry, tool-call, token, or cost budget is exhausted or lacks reserve | Controller budget-policy owner | Stop tool use and checkpoint; require a newly authorized budget |

| Checkpoint | Required lifecycle result | Required evidence | Rollback or recovery trigger |
| --- | --- | --- | --- |
| Pre-dispatch | `SprintStatus.state: BLOCKED`; no worker launch | Route/authority snapshot, `AgentPlatformControlRequest`, diagnostic packet, status event, controller checkpoint, session ledger | Any stop cancels dispatch and releases an unstarted lease; no credential use or automatic retry |
| Pre-merge | `CHANGES_REQUESTED` for stale revision/missing citation; otherwise `BLOCKED` | Closeout, exact-head critic, current PR/check/review refs, status event, session ledger | Any stop invalidates merge readiness; preserve code and rebuild the required I/E/S chain |
| Pre-deploy | `BLOCKED`; `ReleaseVerification` remains non-ready | Environment/GitOps reconciliation, deployment gate, exact image/revision evidence, status event, session ledger | Hold deployment; if rollout began, restore known-good revision and record `deployment_failed` then `rolled_back` |
| Next-loop selection | `BLOCKED`; `OutcomeReview` is incomplete/rejected; no new dispatch | Outcome review, live revisions/citations, diagnostic packet, learning proposal, status event, session ledger | Preserve the last accepted outcome and refresh every `PilotProject` before reselection |

An expected authorization-refusal drill passes its negative test but does not
satisfy the positive vertical slice.

## Delivery Sequence

### Stage 0: Truth and security floor

- Verdify #135.
- Agents #2884, #2887, and #2906. Clear #2906 only with the fixed server-side
  destination registry, no-network unknown result, runtime egress policy,
  running-image refusal proof, sanitized audit event, and protected
  prior-use/rotation disposition.
- Reconcile stale/dirty target checkouts and runtime package versions.
- Hold unattended mutation while these are red.

Exit: truthful global route, all three P0s contained and live-verified, clean
exact target revisions.

### Stage 1: Trusted autonomous core

- Verdify #71, #73, #75, #74, then #43 and #70.
- Agents #2905 architecture spike.
- Add failure-derived evals and useful-progress telemetry.

Exit: transitions cannot self-certify, evals fail on known regressions, and
autonomy class is machine-enforced.

### Stage 2: Provider and one-SDLC convergence

- Agents #2890 plus refreshed definition/architecture/readiness.
- Verdify #12 and #116 plus Agent Platform #2497/#655.
- Versioned `PilotProject`, capability, dispatch, result, and trace contracts.

Exit: one low-risk lane runs through an advertised provider strategy and
survives a worker/controller restart.

### Stage 3: Evidence and Chief of Staff trust

- Gravity signoff, #184/#407, conversion/CI/readiness dependencies.
- Orbit #193-#198/#43 and Verdify #117.
- Current Verdify package and protected validation in both consumers.

Exit: one authorized cited Gravity query is rendered by Orbit with read audit
and no actuation authority.

### Stage 4: Integrated slice and durability window

- Execute the flow above.
- Run missed-tick, auth-expiry, quota, stale-marker, duplicate-wake,
  push-conflict, pod-restart, provider-unavailable, and citation-denial drills.
- Exercise `stop.stale_revision`, `stop.authorization_denied`,
  `stop.missing_citation`, `stop.provider_unavailable`, and
  `stop.budget_expired` at their phase boundaries and verify no later transition
  occurs.
- Run seven scheduled days without hidden manual repair.

Exit: accepted four-project outcome, correlated trace, recovery proof, stable
metrics, and a consumed Orbit brief.

### Stage 5: Simplify, fan out, and onboard customers

- Use issue #76 to delete nominal or duplicate surfaces proven unnecessary.
- Canary the one-SDLC release across a small repo cohort, then the fleet.
- Onboard one customer consulting repository through the same bootstrap,
  authority, evidence, delivery, review, deployment, and outcome contracts.
- Never inherit Jason-private Orbit context into customer tenancy.

Exit: repeatable onboarding without a second lifecycle or manual hidden state.

## Measures

| Dimension | Measure |
| --- | --- |
| Truth | Percent of PilotProject records with exact accepted/deployed revisions and no stale authority conflict |
| Progress | Useful-progress ticks / scheduled ticks; accepted outcomes / selected outcomes |
| Reliability | Task success by risk class, retry rate, duplicate-action count, mean recovery time, seven-day unattended success |
| Quality | Capability and regression eval pass rates, critic changes-requested rate, escaped defects |
| Delivery | Lead time, deployment verification time, change-failure rate, rollback success |
| Evidence | Citation resolution rate, typed denial/degradation rate, stale-source rate |
| Oversight | Human interventions by risk class, time waiting on gates, interrupt success, unauthorized action count |
| Security | Policy denials, scope elevations, secret findings, trust-boundary violations |
| Efficiency | Cost/token/tool calls per accepted outcome, idle/rework ratio |
| Experience | Orbit brief consumption, source-link follow-through, actions accepted/rejected by Jason |

## What Not To Do

- Do not run all four backlogs broadly in parallel before the first integrated
  slice.
- Do not equate Ready pods, fresh heartbeats, green schemas, or merged PRs with
  an autonomous outcome.
- Do not grant universal auto-approval to make the loop feel hands-off.
- Do not let Orbit become the global control plane or let personal context share
  fleet-actuation identity.
- Do not accept uncited Gravity results as verified evidence.
- Do not allow a model or caller to select where credential material is probed;
  #2906 remains a pre-dispatch stop until the deployed refusal boundary passes.
- Do not create another private backlog, session truth store, or second SDLC.
- Do not add schemas/modes until a real run needs them; do not delete required
  boundaries merely because they have not yet been exercised.
- Do not choose Temporal, LangGraph, or another framework without the same local
  crash/recovery comparison against the current substrate.

## Immediate Control-Plane Actions

1. Reopened Verdify Skills #135 with the verified 1.3.0 recurrence.
2. Created Agent Platform #2905 for the durable-execution build-versus-adopt
   architecture spike.
3. Created Agent Platform #2906 for the credential-probe destination P0 and made
   it a Stage 0 stop gate.
4. Registered this strategy and research under Verdify Skills #116.
5. Reframed Verdify #76 around evidence-driven simplification after the vertical
   slice.
6. Plan issue #135 as the next single-issue sprint after strategy review.

## Research Basis

Brave Search API was used for discovery and primary sources were reviewed:

- [Anthropic: Building effective agents](https://www.anthropic.com/engineering/building-effective-agents)
- [Anthropic: Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Anthropic: Measuring agent autonomy](https://www.anthropic.com/research/measuring-agent-autonomy)
- [Anthropic: Demystifying evals](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents)
- [OpenAI: Evaluate agent workflows](https://developers.openai.com/api/docs/guides/agent-evals)
- [Temporal durable execution](https://docs.temporal.io/evaluate/understanding-temporal)
- [Temporal human-in-the-loop pattern](https://docs.temporal.io/ai-cookbook/human-in-the-loop-python)
- [MCP security best practices](https://modelcontextprotocol.io/docs/tutorials/security/security_best_practices)
- [NIST AI RMF Generative AI Profile](https://www.nist.gov/publications/artificial-intelligence-risk-management-framework-generative-artificial-intelligence)
- [NIST AI Agent Standards Initiative](https://www.nist.gov/artificial-intelligence/ai-agent-standards-initiative)
- [OpenTelemetry GenAI semantic conventions](https://github.com/open-telemetry/semantic-conventions-genai)
- [SLSA v1.2](https://slsa.dev/spec/v1.2/)
- [GitHub agentic SDLC guidance](https://docs.github.com/en/enterprise-cloud@latest/copilot/tutorials/roll-out-at-scale/enable-developers/integrate-ai-agents)

The registered research record is
`northstar://evidence/NSE-20260710-autonomous-development-platform-best-practices`.
