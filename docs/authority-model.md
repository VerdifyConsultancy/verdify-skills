# Typed authority model

“GitHub is the source of truth” is useful only when authority is assigned by information type.

| Information | Authoritative owner |
|---|---|
| Backlog problem, discussion, desired outcome | GitHub Issue |
| Hierarchy and blocking relationships | GitHub sub-issues and dependencies |
| Approved implementation scope | Versioned lane contract linked from issue and PR |
| Proposed code | Pull-request branch |
| Accepted code | Default branch |
| Architecture intent | Architecture artifact and ADRs on the default branch |
| Quality status | Required GitHub checks and linked evidence |
| Review decision | PR review plus critic report plus review inbox packet and diagnostic packet when runtime evidence is material |
| Release identity | Git tag and GitHub release |
| Deployment state | GitHub deployment/environment or platform deployment record |
| Runtime proof | Deployment verification evidence |
| Environment GitOps reconciliation | Validated environment reconciliation artifact plus controller/runtime evidence |
| Agent Platform control request | Validated control request artifact plus policy and review verdict |
| Gravity core extraction | Validated Gravity extraction plan plus source-object/provenance evidence |
| Local worktree owner | Machine-local lane lease |
| Session and wave history | Controller session ledger |
| Current lifecycle route | Fresh `bin/verdify route` computation over validated authority inputs |

A Project view, local dashboard, YAML status file, GitHub snapshot, or
`.agent-workflow/router/route-decision.{yaml,md}` file is derived unless listed
above. Route files are ignored, untracked local views; regenerate them with
`bin/verdify route --write` instead of committing or reconciling them as an
alternate authority. `generated_at` is provenance only. The stable YAML fields
`current_state`, `next_skill`, `next_mode`, and `reason` must agree with the
generated Markdown view.

## Route authority validation

The router selects the expected schema in code. An artifact cannot substitute
its own `schema_ref`, kind, status vocabulary, or handoff contract. Before any
authority field is consumed, the router safely parses the artifact, applies its
expected schema, then applies semantic validation. Invalid content produces
only a typed, bounded diagnostic and routes to the owning producer.

| Authority input | Expected schema | Repair route |
|---|---|---|
| Transcript replan | `transcript-replan.schema.yaml` | `transcript-replan / ingest` |
| North Star evidence registry | `northstar-evidence-registry.schema.yaml` | `northstar-research-ingest / ingest-research` |
| North Star plan | `northstar-plan.schema.yaml` | `northstar-planning / synthesis` |
| North Star artifacts | `northstar-artifacts.schema.yaml` | `northstar-planning / artifact-loop` |
| Project definition | `project-definition.schema.yaml` | `project-definition / discovery` |
| Architecture | `architecture.schema.yaml` | `architecture-contracts / north-star-architecture` |
| Each module contract | `module-contract.schema.yaml` | `architecture-contracts / module-contracts` |
| State of union | `state-of-union.schema.yaml` | `state-of-union / strategy-review` |
| Repository hygiene | `repo-hygiene.schema.yaml` | `repo-hygiene / assess` |

Dynamic handoffs must name a skill and mode declared by `config/lifecycle.yaml`,
and the target skill must be reachable from the artifact producer's state in
`verdify.workflow.yaml`. A globally declared but producer-illegal pair routes to
the artifact producer and never becomes a router exception or downstream
transition.

## Exact non-vacuous review evidence

Approving evidence is authoritative only when it is exact and non-vacuous
(issue #73). Semantic validation enforces the document-local rules for every
consumer, and the lane review path (`route`, `pr-policy`, `delivery-gate`,
terminal-receipt lane bindings) reconciles reports against the approved lane
contract before any review inbox, integration, or terminalization decision:

- An `approve`/`approve_with_risks` critic report must carry a non-empty
  acceptance assessment whose criterion IDs equal the lane contract criterion
  IDs exactly, order-independent. Duplicate, unknown, and missing criterion
  IDs each fail with a distinct bounded error naming the offending IDs.
- Every assessment in an approving report must be `satisfied` with non-empty
  evidence.
- Non-approving reports (for example `request_fixes`) may stay partial or
  empty, but supplied criterion IDs must be unique and contract-valid.
- Worker closeout acceptance evidence must be a truthful contract-valid
  subset: claimed criterion IDs must be unique and exist in the lane
  contract, omissions are allowed, and evidence not recorded in the
  closeout's own `validation_results` may not claim critic, CI, integration,
  deployment, or outcome evidence — none of that exists at worker closeout
  time.
- A verified release still rejects empty `integration_results`
  (schema-enforced and pinned by regression).

Historical committed sprint artifacts predate the reconciliation rule and are
out of scope; enforcement binds at validation time on the live lane review
path, so no new vacuous or fabricated approving evidence can authorize
review-inbox packet validation, delivery-gate critic evaluation, or
terminal-receipt validation.

When authoritative records disagree, stop the transition, reconstruct current state, and use a decision or scope-change gate. Do not edit intent retroactively merely to make an implementation appear compliant.
