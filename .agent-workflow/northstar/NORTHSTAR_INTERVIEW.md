# North Star Interview

Status: `ready` only with exact-review evidence
Generated at: `2026-07-27T18:14:40Z`
Routed mode: `northstar-planning / human-review` after exact-review evidence
Evidence registry: `.agent-workflow/northstar/evidence-registry.yaml`
Product pair: `.agent-workflow/northstar/NORTHSTAR_PRODUCT.md`
Architecture pair: `.agent-workflow/northstar/NORTHSTAR_ARCHITECTURE.md`
Loop record: `.agent-workflow/northstar/northstar-artifacts.yaml`

## Review Summary

Iteration 26 is a material authority and delivery-architecture revision. The
current repository still depends on GitHub for source, issues, pull requests,
reviews, required statuses, protection, workflow execution, promotion, npm
publication, deployment records, and GitHub Releases. Generic local Argo
components exist, but they still clone GitHub and reference public inputs; no
live internal Git/review/status authority or repository-specific Zot package
subject was observable. Shared platform issue `jvallery/agents#3047` owns the
internal-authority and offline-supply dependency for repository consumer issue
`#3044`, but remains open and proposed rather than approved.

The audit-revised proposal uses a capability-qualified supported Forgejo release
and internal IdP for repository and portfolio-work authority. Raw-body webhook
admission and a durable transaction/effect ledger precede Argo Events and
repository-owned Argo Workflows. A separated publisher and signer create an
immutable package subject plus one signed complete pre-promotion release
envelope in Zot; the ledger records every later lifecycle effect against it. A
stable digest-pinned Argo CD-owned harness verifies into a fresh volume, performs
a real install, and probes behavior. All executable inputs become internal and
immutable; coordinated recovery restores the internal authority; GitHub/npm
remain governed output mirrors unless a later gate separately retires them.

Iteration 25 remains the protected authority. No implementation, production
mutation, protection change, credential change, workflow disablement, public
package deletion, or authority cutover is authorized by this packet.
The historical clean-review evidence binds an earlier candidate and cannot
certify these bytes. This interview is ready for Agent Platform,
source-control, security, SRE, backup/recovery, finance, Skills release,
governance, and legal/IP owner assignments plus both identity-bound disposition
ledgers, followed by Jason's decisions, only when
`NSE-20260727-local-delivery-final-candidate-rereview` records three fresh
`no_changes_required` verdicts against the exact final-candidate hash manifest.
That separate evidence record must not mutate the reviewed packet; no approval
is inferred.

## Proposed Priorities

| Priority | Decision or work | Classification |
| --- | --- | --- |
| P0 | Select the internal authority, signed release-envelope/consumer model, public-mirror posture, repository plus portfolio-work migration scope, bounded operating envelope, and mandatory trust boundaries. | must-decide |
| P0 | Require Agent Platform, source-control, security, SRE, backup/recovery, finance, Skills release/governance, and legal/IP owners to complete every applicable identity-bound disposition without unresolved rejection or revision, and require fresh product/architecture/security reviewers to return no required changes, before asking Jason for final lock. | review gate |
| P1 | After lock, approve module contracts for identity, governance-history migration, raw event admission, ledger/status, package/envelope, stable consumer, immutable dependencies, coordinated recovery, public support, and attended cutover before implementation dispatch. | should-decide before sprint planning |
| P1 | Keep organization-level GitHub controls, live Argo/Zot state, IdP and status scope, backup/restore, signing custody, full-boundary cold-node proof, and service measurements in the exception ledger until owner-scoped evidence closes them. | research-needed |

## Decisions Ready For Human Review

| Decision ID | Proposed decision | Effect if accepted |
| --- | --- | --- |
| NQI-D012 | Use a capability-qualified supported Forgejo release (v16 is the current candidate) plus internal IdP as internal repository authority; keep GitHub as an output mirror. | Authorizes downstream definition and contract design, not authority cutover. |
| NQI-D013 | Make a package-specific Zot subject plus signed immutable pre-promotion release envelope the release authority and a stable-harness/fresh-volume Argo CD workload the non-production proof. | Fixes source, policy, package, checksum, test, provenance, SBOM, signature, attestation, and criticism digests; the durable ledger binds later approval, GitOps, consumer, rollback, release, and mirror receipts to that unchanged envelope. |
| NQI-D014 | Keep npm, GitHub Releases, and GitHub source as best-effort proprietary/source-available output mirrors: preserve GitHub's in-Service public-repository rights, make no additional project grant beyond GitHub's Terms and applicable law for off-platform/package use unless separately approved, allow issue/security intake, reject external code until approved CLA/assignment terms exist, and use separate gates for licensing, intake, retirement, or emergency authority transfer. | Separates internal recovery and independence from additional licensing, contributor rights, and public-distribution policy, subject to legal/IP confirmation. |
| NQI-D015 | Migrate repository and portfolio-work authority through provider-neutral IDs, portfolio metadata, imported-history markers, and cross-system links. | Prevents Git mirroring from being mistaken for governance migration. |
| NQI-D016 | Use the proposed maximum pilot envelope and measurable parity, latency, recovery, outage, and observation thresholds. | Bounds cost and creates an objective cutover verdict. |
| NQI-D017 | Require IdP immutable subjects, raw-body event admission, durable effect ledger, trusted status issuer, and separate candidate/validator/publisher/signer/mirror/GitOps principals. | Removes candidate self-certification and replay/partial-effect ambiguity. |
| NQI-D018 | After a clean re-review and acceptance of D012-D017, explicitly lock iteration 26 as the next-milestone North Star. | Allows project definition, architecture contracts, and execution strategy to consume the proposal. Implementation still requires approved backlog issues, sprint and lane contracts, protected-base validation, independent review, and every applicable human/change gate. |

## Architecture Options And Tradeoffs

### Source, review, and status authority

- **Proposed: capability-qualified supported Forgejo release, GitHub output
  mirror.** Best current match for local lightweight Git, pull requests, reviews,
  status checks, branch protection, webhooks, and mirroring. The exact version
  must prove repository and portfolio-work capability, IdP identity,
  governance-history migration, scoped trusted statuses, upgrade, audit, and
  coordinated restore. Git push mirroring does not carry governance records.
- GitHub primary with local CI only. Smaller immediate change, but fails the
  stated GitHub-unavailable and no-load-bearing-GitHub outcome.
- GitLab primary. Rich integrated platform, but overlaps Argo/Agent Platform
  mechanics, raises operational weight, and has no current deployed substrate
  in evidence.

### Authoritative package and non-production proof

- **Proposed: package subject plus signed release envelope and stable
  harness/fresh-volume GitOps consumer.** Proves the exact package installed by
  real consumers, prevents incomplete referrer graphs from appearing approved,
  and gives Argo CD a complete signed digest to promote. Requires separated
  builder/publisher/signer principals and a package-aware acceptance workload.
- Container image only. Fits the current Agent Fleet CI schema but can be green
  without proving the package archive or installer consumers receive.
- Internal npm registry only. Familiar package semantics, but adds another
  service and does not by itself solve multi-artifact provenance, GitOps
  promotion, or registry convergence.

### Public mirrors

- **Proposed: retain proprietary/source-available best-effort mirrors.**
  Reversible and low-risk; mirror failure is visible but non-blocking. Public
  docs preserve GitHub's in-Service public-repository rights and state that
  `UNLICENSED` makes no additional project grant beyond GitHub's Terms and
  applicable law for off-platform/package use, modification, redistribution,
  or derivatives unless separate written terms apply. Issue and security
  reports remain open, while external code is rejected until an approved
  CLA/assignment intake exists. Legal/IP confirms the exact statement.
  Freshness, outage, verification, support, licensing, intake, and retirement
  are separately governed. Costs storage and dual-path operations.
- Retire at authority cutover. Simpler target state, but couples a reversible
  authority switch to destructive public state removal and weakens rollback.

### Event and status trust

- **Proposed: raw-body admission plus durable ledger and scoped reporter.**
  Verifies Forgejo HMAC before Argo, survives at-least-once/reordered delivery,
  records compare-and-set effects and authorized replay, and prevents candidate
  code from publishing protected success.
- Argo EventSource/Sensor state only. Fewer components, but does not provide the
  durable transaction/effect semantics, raw-body trust boundary, or recovery
  proof required by the audit.

### Operating envelope

- **Proposed: bounded pilot.** One rehearsal and one live repository; 500
  admitted events/day and 20/minute burst; ten-minute ordinary event age; two
  concurrent workflows; one release/day; 16 vCPU, 32 GiB, 200 GiB, USD
  250/month, at most four attended operator-hours per rolling seven days
  including incident response, and at most 30 consecutive dual-run days before
  extension; 99.5% monthly availability excluding approved maintenance; 24x7
  automated alerting with attended release/cutover windows; 24-hour snapshot,
  30-day restore rehearsal; raw admitted events and transaction, effect,
  status, audit, and acceptance evidence retained at least 365 days; supported
  package subjects, signed release envelopes, and immutable graphs retained
  through the later of support end or retirement plus at least 365 days; at
  least twenty consecutive distinct successful end-to-end change transactions;
  at least three consecutive distinct successful release-and-rollback
  transaction pairs; and the exact latency, RPO/RTO, mirror, outage, 30-minute
  re-probe, and fourteen-day observation thresholds.
- Unbounded rollout. Faster nominal expansion but no objective finance,
  capacity, reliability, or “ready to cut over” verdict.

### Decision owner assignments

The stable owner-role IDs below are the only role names accepted by the
iteration-26 decision records. `OWN-001` through `OWN-010` participate in the
question-specific disposition matrix, and `OWN-001` through `OWN-009`
participate in the `NSQ-019` threshold ledger. A role is not assigned merely
because a person has a display name, authored a proposal, controls a GitHub
service account, or responds in chat. Before Jason's final-lock question, every
required row must name one accountable human by immutable IdP subject and cite
a durable, versioned authority assignment. `pending` therefore remains a
blocking state, not an inferred assignment.

| Owner ID | Accountable role | Current human / immutable subject | Durable authority-assignment reference | Assignment state |
| --- | --- | --- | --- | --- |
| `OWN-001` | Final-lock and portfolio owner | Jason / immutable subject pending | pending review-feedback evidence | pending |
| `OWN-002` | Agent Platform service owner | pending | pending review-feedback evidence | pending |
| `OWN-003` | Source-control authority owner | pending | pending review-feedback evidence | pending |
| `OWN-004` | Security owner | pending | pending review-feedback evidence | pending |
| `OWN-005` | SRE owner | pending | pending review-feedback evidence | pending |
| `OWN-006` | Backup and recovery owner | pending | pending review-feedback evidence | pending |
| `OWN-007` | Finance owner | pending | pending review-feedback evidence | pending |
| `OWN-008` | Verdify Skills release owner | pending | pending review-feedback evidence | pending |
| `OWN-009` | Verdify Skills governance owner | pending | pending review-feedback evidence | pending |
| `OWN-010` | Legal/IP owner for `NSQ-017` only | pending | pending review-feedback evidence | pending |

### Decision applicability and dispositions

Every P0 decision has explicit applicable owner roles. Except for `NSQ-019`,
the decision ledger must contain one row for every question/owner pair below.
Each row contains question ID, owner ID, immutable human subject, versioned
authority-assignment reference, `accept`, `revise`, or `reject`, exact
alternative or constraints for `revise`, rationale, UTC timestamp, and
immutable review-feedback evidence reference. `NSQ-019` uses the more granular
owner/threshold ledger in the next section; its complete applicable-pair set is
the decision disposition for that question.

| Question ID | Applicable owner IDs | Current disposition | Completion rule |
| --- | --- | --- | --- |
| `NSQ-015` | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-006`, `OWN-009` | pending | every listed question/owner pair resolves |
| `NSQ-016` | `OWN-001`, `OWN-002`, `OWN-004`, `OWN-005`, `OWN-006`, `OWN-008`, `OWN-009` | pending | every listed question/owner pair resolves |
| `NSQ-017` | `OWN-001`, `OWN-009`, `OWN-010` | pending | every listed question/owner pair resolves, including legal/IP |
| `NSQ-018` | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-009` | pending | every listed question/owner pair resolves |
| `NSQ-019` | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-006`, `OWN-007`, `OWN-008`, `OWN-009`, as mapped per `OE-*` row | pending | every applicable owner/threshold pair resolves |
| `NSQ-020` | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-006`, `OWN-008`, `OWN-009` | pending | every listed question/owner pair resolves |

A missing assignment or required ledger row keeps the question open. Any
`reject` keeps it open. Conflicting revisions are not averaged and cannot be
overridden by a generic approval or by `OWN-001`: affected owners must converge
on one exact proposal in a new evidence record and submit superseding
dispositions before Jason may decide. This ledger records prerequisite owner
advice; Jason retains the separate final decision and iteration-lock authority.

### NSQ-019 threshold dispositions

Each threshold has one exact default, unit or measurement rule, and explicit
applicable owner roles. `pending` means that every role named in that row must
still submit a separate disposition; the current rationale for every pending
cell is `no identity-bound owner entry recorded`, and the table itself records
no approval.

| Threshold ID | Measure | Exact proposed default and unit | Applicable owner IDs | Current disposition |
| --- | --- | --- | --- | --- |
| `OE-001` | Rehearsal repositories | exactly 1 repository | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-005`, `OWN-008`, `OWN-009` | pending |
| `OE-002` | Live repositories | exactly 1 repository | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-008`, `OWN-009` | pending |
| `OE-003` | Admitted event volume | at most 500 events per rolling 24 hours | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-007` | pending |
| `OE-004` | Admitted event burst | at most 20 events per rolling minute | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005` | pending |
| `OE-005` | Ordinary event age | at most 10 minutes from signed source event to admission, excluding explicitly authorized replay | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005` | pending |
| `OE-006` | Concurrent workflows | at most 2 running workflows | `OWN-001`, `OWN-002`, `OWN-005`, `OWN-007`, `OWN-008` | pending |
| `OE-007` | Release frequency | at most 1 release transaction per rolling 24 hours | `OWN-001`, `OWN-002`, `OWN-005`, `OWN-007`, `OWN-008`, `OWN-009` | pending |
| `OE-008` | Compute allocation | at most 16 vCPU requested by the pilot control and execution plane | `OWN-001`, `OWN-002`, `OWN-005`, `OWN-007` | pending |
| `OE-009` | Memory allocation | at most 32 GiB requested by the pilot control and execution plane | `OWN-001`, `OWN-002`, `OWN-005`, `OWN-007` | pending |
| `OE-010` | Retained storage | at most 200 GiB across pilot forge, ledger, workflow, mirror, evidence, and recovery stores | `OWN-001`, `OWN-002`, `OWN-005`, `OWN-006`, `OWN-007` | pending |
| `OE-011` | Incremental spend | at most USD 250 per calendar month | `OWN-001`, `OWN-002`, `OWN-007`, `OWN-009` | pending |
| `OE-012` | Operator effort | at most 4 attended operator-hours per rolling 7 days, including incident response; any exceedance requires an explicit threshold revision or extension record | `OWN-001`, `OWN-002`, `OWN-005`, `OWN-007`, `OWN-009` | pending |
| `OE-013` | Dual-run duration limit | at most 30 consecutive days before an explicit extension decision is required | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-005`, `OWN-007`, `OWN-008`, `OWN-009` | pending |
| `OE-014` | Service availability | at least 99.5% per calendar month, excluding approved maintenance windows | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-005`, `OWN-007`, `OWN-008`, `OWN-009` | pending |
| `OE-015` | Alert and support coverage | automated alerting 24x7; human attendance required for every release and cutover window | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-007`, `OWN-008`, `OWN-009` | pending |
| `OE-016` | Snapshot age | latest restorable coordinated snapshot at most 24 hours old | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-006` | pending |
| `OE-017` | Restore-rehearsal age | latest successful coordinated restore rehearsal at most 30 days old | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-006` | pending |
| `OE-018` | Evidence retention | retain raw admitted events and transaction, effect, status, audit, and acceptance evidence for at least 365 days | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-006`, `OWN-008`, `OWN-009` | pending |
| `OE-019` | Release retention | retain each supported package subject, signed release envelope, and immutable graph through the later of support end or retirement, plus at least 365 days | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-006`, `OWN-007`, `OWN-008`, `OWN-009` | pending |
| `OE-020` | Logical and failure parity | 100% of approved legacy-path logical and injected-failure cases pass on the candidate path | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-008`, `OWN-009` | pending |
| `OE-021` | False accepts | exactly 0 candidate-path false accepts across the approved parity corpus | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-008`, `OWN-009` | pending |
| `OE-022` | Change transactions | at least 20 consecutive distinct successful end-to-end change transactions | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-008`, `OWN-009` | pending |
| `OE-023` | Release and rollback transactions | at least 3 consecutive distinct successful release-and-rollback transaction pairs | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-006`, `OWN-008`, `OWN-009` | pending |
| `OE-024` | Queue latency | p95 admitted-event-to-workflow-start latency under 2 minutes over the observation corpus | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-005`, `OWN-008` | pending |
| `OE-025` | Validation latency | p95 workflow-start-to-trusted-validation-result latency under 15 minutes over the observation corpus | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-005`, `OWN-008` | pending |
| `OE-026` | Health latency | p95 desired-state-commit-to-Synced-and-Healthy plus acceptance-probe latency under 10 minutes | `OWN-001`, `OWN-002`, `OWN-005`, `OWN-008` | pending |
| `OE-027` | Rollback latency | p95 rollback-approval-to-prior-digest-Synced-and-Healthy plus probe latency under 10 minutes | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-006`, `OWN-008` | pending |
| `OE-028` | Forgejo RPO | at most 5 minutes of authoritative forge/control-plane data loss | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-006` | pending |
| `OE-029` | Forgejo RTO | at most 2 hours to coordinated authoritative forge/control-plane recovery | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-006` | pending |
| `OE-030` | Git mirror freshness | outbound GitHub Git mirror at most 15 minutes behind internal authority while the endpoint is available | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-008`, `OWN-009` | pending |
| `OE-031` | Package mirror freshness | npm and GitHub Release output mirrors at most 4 hours behind an internally released envelope while endpoints are available | `OWN-001`, `OWN-002`, `OWN-004`, `OWN-005`, `OWN-007`, `OWN-008`, `OWN-009` | pending |
| `OE-032` | GitHub-unavailable proof | at least 4 continuous hours with GitHub network access denied while the approved local fixture completes the protected path | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-006`, `OWN-008`, `OWN-009` | pending |
| `OE-033` | Delayed durability probe | rerun the literal post-change acceptance probe 30 minutes after the initial green result | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-006`, `OWN-008`, `OWN-009` | pending |
| `OE-034` | Healthy observation | 14 consecutive 24-hour periods meeting all accepted availability, latency, parity, recovery, and alert objectives | `OWN-001`, `OWN-002`, `OWN-003`, `OWN-004`, `OWN-005`, `OWN-006`, `OWN-007`, `OWN-008`, `OWN-009` | pending |

The disposition ledger is a Cartesian set of every threshold and every
applicable owner in its row. Each ledger entry must contain the threshold ID,
owner ID, immutable human subject, versioned authority-assignment reference,
`accept`, `revise`, or `reject`, an exact replacement value and unit for
`revise`, rationale, UTC timestamp, and immutable review-feedback evidence
reference. Missing assignments or rows keep the gate open. Conflicting
revisions are not averaged or resolved by a generic approval: every affected
owner must converge on one exact value in a new evidence record, after which
`OWN-001` may select it only as part of the separate final-lock decision. Any
`reject` leaves `NSQ-019` unresolved.

## Interview Questions

| ID | Priority | Question | Proposed default | Options / tradeoffs | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| NSQ-015 | P0 | Approve a capability-qualified supported Forgejo release (v16 is the current candidate) as internal repository authority with GitHub as an output mirror? | Approve D012 only after exact-version capability, IdP, migration, policy, audit, upgrade, coordinated-restore, GitHub-unavailable, and attended-cutover proofs. | Approve; choose another internal forge and require the same contracts; keep GitHub primary, which does not satisfy independence. | `PRODUCT-015`, `ARCH-022`, `PRQ-039`, `ARQ-035`, `CON-011`, `CON-015`; applicable roles above | all applicable 2026-07-27 migration evidence items, including `NSE-20260727-shared-local-delivery-authority-live-state` and `NSE-20260727-local-delivery-native-dependency-reconciliation` | one identity-bound ledger entry per applicable question/owner pair; no generic response |
| NSQ-016 | P0 | Approve the Zot package subject, signed immutable complete pre-promotion envelope, later-effect ledger receipts, and stable-harness/fresh-volume Argo CD consumer as authoritative release and non-production acceptance? | Approve D013; treat the consumer as an acceptance fixture and promote the fixed envelope digest while later effects remain ledger receipts. | Approve; select another internal package authority only with equivalent atomic signed-graph and GitOps proof; image-only does not prove the package. | `PRODUCT-015`, `ARCH-022`, `PRQ-041`, `PRQ-042`, `CON-012`; applicable roles above | `NSE-20260709-verdify-skills-adversarial-review`, `NSE-20260727-verdify-skills-local-delivery-inventory`, `NSE-20260727-local-delivery-control-plane-primary-sources`, `NSE-20260727-local-delivery-adversarial-audit` | one identity-bound ledger entry per applicable question/owner pair; no generic response |
| NSQ-017 | P0 | Keep GitHub source, npm, and GitHub Releases as best-effort proprietary/source-available mirrors that preserve GitHub's in-Service rights, make no additional project grant beyond GitHub's Terms and applicable law for off-platform/package use, allow issue/security intake but no external code pending approved CLA/assignment terms, and use later separate licensing/intake/retirement gates? | Approve D014 subject to legal/IP confirmation of the exact rights statement. | Approve the GitHub-Terms-plus-no-additional-project-grant/non-acceptance default; choose and legally approve another license plus contributor-IP process; retire later through a separate attended gate. | `PRODUCT-015`, `ARCH-022`, `PRQ-047`, `ARQ-044`; applicable roles above | `NSE-20260727-verdify-skills-local-delivery-inventory`, `NSE-20260727-local-delivery-adversarial-audit`, `NSE-20260727-verdify-skills-public-visibility-license`, `NSE-20260727-github-public-repository-license-terms` | one identity-bound ledger entry per applicable question/owner pair; no generic response |
| NSQ-018 | P0 | Approve migration of repository and portfolio-work authority through provider-neutral IDs, portfolio metadata, imported-history markers, and cross-system links while retaining `jvallery/agents#3044` as the GitHub-side migration record, natively blocked by shared platform issue `#3047`, until reconciliation? | Approve D015. | Approve; keep the global portfolio on GitHub, which leaves GitHub load-bearing; choose a different internal portfolio authority and define the bridge. | `PRODUCT-015`, `ARCH-022`, `PRQ-039`, `CON-014`, `CON-015`; applicable roles above | `NSE-20260727-local-delivery-adversarial-audit`, `NSE-20260727-shared-local-delivery-authority-live-state`, `NSE-20260727-local-delivery-native-dependency-reconciliation` | one identity-bound ledger entry per applicable question/owner pair; no generic response |
| NSQ-019 | P0 | Approve the complete proposed pilot envelope for repository/event scale and age, compute/storage/spend/operator limits, availability/support, latency, recovery/backup/retention, parity, transaction/outage evidence, 30-minute delayed re-probe, and fourteen-day observation? | Approve D016 exactly as `OE-001` through `OE-034`. | Approve every applicable row; revise a named row with exact replacement value/unit and rationale; reject a named row; omit a row or identity, which keeps the gate open. | `PRODUCT-015`, `PRQ-048`, `ARCH-022`, `ARQ-045`, `IFACE-031`, `OWN-001`–`OWN-009`, `OE-001`–`OE-034` | `NSE-20260727-local-delivery-adversarial-audit`; the completed immutable disposition ledger | one ledger entry per applicable owner/threshold pair using the required fields above; no generic approval |
| NSQ-020 | P0 | Approve immutable IdP subjects, raw-body event admission plus durable effect ledger, scoped trusted status reporting, and separated privileged principals as mandatory? | Approve D017 and reject any provider/design that cannot prove the boundary. | Approve; propose an equivalent mechanism with the same adversarial tests; waive, which leaves candidate self-certification/replay risk and is not recommended. | `PRODUCT-015`, `ARCH-022`, `PRQ-040`, `PRQ-044`, `ARQ-036`, `ARQ-040`, `ARQ-041`; applicable roles above | `NSE-20260727-local-delivery-adversarial-audit` | one identity-bound ledger entry per applicable question/owner pair; no generic response |
| NQI-Q021 | P0 | After the fresh independent re-review returns no required changes, required `OWN-*` roles have immutable identity/authority evidence, both identity-bound ledgers are complete as mapped above with no missing assignment or row, rejection, unresolved conflicting revision, or generic approval remaining, and NSQ-015 through NSQ-020 are resolved, do you explicitly approve and lock North Star iteration 26? | Approve D018 only after every prior condition is met. | Approve and lock; request named changes; reject. | all iteration-26 IDs; `northstar-artifacts.yaml`; North Star gate | complete iteration-26 review packet, assignments, and both row-level disposition ledgers | exact phrase: `approve and lock iteration 26`, `changes requested: ...`, or `reject: ...` |

## Answer Capture Rules

- Preserve answers as new review-feedback evidence and route them through
  `northstar-planning / review-feedback`.
- Owner assignments and threshold dispositions must preserve the stable
  `OWN-*`/`OE-*` IDs and every required field defined above. Decision
  dispositions must preserve the stable `NSQ-*`/`OWN-*` pairs. Prose summaries
  do not replace either row-level evidence set.
- Interview answers do not themselves record final lock. Only the explicit
  NQI-Q021 decision, after a clean re-review and complete `NSQ-*`/`OWN-*` and
  `OWN-*`/`OE-*` disposition ledgers, may update `northstar-artifacts.yaml`,
  `northstar-plan.yaml`, `.agent-workflow/gates/northstar.yaml`, product and
  architecture status, and downstream handoff.
- A lock authorizes downstream project definition and architecture contracts;
  it does not authorize protected settings, production mutation, credential
  changes, workflow disablement, cutover, or destructive retirement.
- Any requested alternative forge, package authority, mirror policy, security
  boundary, or cutover rule starts another artifact-loop revision before lock.
