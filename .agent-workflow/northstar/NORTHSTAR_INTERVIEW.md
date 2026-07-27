# North Star Interview

Status: `ready`
Generated at: `2026-07-27T18:14:40Z`
Routed mode: `northstar-planning / human-review`
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
subject was observable.

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
The fresh hash-bound product/business, architecture/delivery/scalability, and
security/SRE/audit reviewers returned `no_changes_required`. This interview is
ready for Agent Platform, source-control, security, SRE, backup/recovery,
finance, Skills release, governance, and legal/IP owner dispositions plus
Jason's decisions; no approval is inferred.

## Proposed Priorities

| Priority | Decision or work | Classification |
| --- | --- | --- |
| P0 | Select the internal authority, signed release-envelope/consumer model, public-mirror posture, repository plus portfolio-work migration scope, bounded operating envelope, and mandatory trust boundaries. | must-decide |
| P0 | Require Agent Platform, source-control, security, SRE, backup/recovery, finance, Skills release/governance, legal/IP, and fresh product/architecture/security reviewers to return no required changes before asking Jason for final lock. | review gate |
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
| NQI-D018 | After a clean re-review and acceptance of D012-D017, explicitly lock iteration 26 as the next-milestone North Star. | Allows project definition, architecture contracts, issue-backed sprint planning, and implementation to consume the proposal. |

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
  250/month, four operator-hours/week, and thirty dual-run days; 99.5% monthly
  availability excluding approved maintenance; 24x7 automated alerting with
  attended release/cutover windows; 24-hour snapshot, 30-day restore rehearsal,
  365-day evidence, support-plus-365-day release retention, explicit
  transaction, latency, RPO/RTO, mirror, outage, 30-minute re-probe, and
  fourteen-day observation thresholds.
- Unbounded rollout. Faster nominal expansion but no objective finance,
  capacity, reliability, or “ready to cut over” verdict.

## Interview Questions

| ID | Priority | Question | Proposed default | Options / tradeoffs | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| NSQ-015 | P0 | Approve a capability-qualified supported Forgejo release (v16 is the current candidate) as internal repository authority with GitHub as an output mirror? | Approve D012 only after exact-version capability, IdP, migration, policy, audit, upgrade, coordinated-restore, GitHub-unavailable, and attended-cutover proofs. | Approve; choose another internal forge and require the same contracts; keep GitHub primary, which does not satisfy independence. | `PRODUCT-015`, `ARCH-022`, `PRQ-039`, `ARQ-035`, `CON-011`, `CON-015` | all applicable 2026-07-27 migration evidence items | `approve default`, `choose alternative`, or `freeform constraint` |
| NSQ-016 | P0 | Approve the Zot package subject, signed immutable complete pre-promotion envelope, later-effect ledger receipts, and stable-harness/fresh-volume Argo CD consumer as authoritative release and non-production acceptance? | Approve D013; treat the consumer as an acceptance fixture and promote the fixed envelope digest while later effects remain ledger receipts. | Approve; select another internal package authority only with equivalent atomic signed-graph and GitOps proof; image-only does not prove the package. | `PRODUCT-015`, `ARCH-022`, `PRQ-041`, `PRQ-042`, `CON-012` | `NSE-20260709-verdify-skills-adversarial-review`, all three 2026-07-27 technical evidence items | `approve default`, `choose alternative`, or `freeform constraint` |
| NSQ-017 | P0 | Keep GitHub source, npm, and GitHub Releases as best-effort proprietary/source-available mirrors that preserve GitHub's in-Service rights, make no additional project grant beyond GitHub's Terms and applicable law for off-platform/package use, allow issue/security intake but no external code pending approved CLA/assignment terms, and use later separate licensing/intake/retirement gates? | Approve D014 subject to legal/IP confirmation of the exact rights statement. | Approve the GitHub-Terms-plus-no-additional-project-grant/non-acceptance default; choose and legally approve another license plus contributor-IP process; retire later through a separate attended gate. | `PRODUCT-015`, `ARCH-022`, `PRQ-047`, `ARQ-044` | `NSE-20260727-verdify-skills-local-delivery-inventory`, `NSE-20260727-local-delivery-adversarial-audit`, `NSE-20260727-verdify-skills-public-visibility-license`, `NSE-20260727-github-public-repository-license-terms` | `approve default`, `state approved license/IP terms`, or `state retirement rule` |
| NSQ-018 | P0 | Approve migration of repository and portfolio-work authority through provider-neutral IDs, portfolio metadata, imported-history markers, and cross-system links while retaining `jvallery/agents#3044` as the GitHub-side migration record until reconciliation? | Approve D015. | Approve; keep the global portfolio on GitHub, which leaves GitHub load-bearing; choose a different internal portfolio authority and define the bridge. | `PRODUCT-015`, `ARCH-022`, `PRQ-039`, `CON-014`, `CON-015` | `NSE-20260727-local-delivery-adversarial-audit` | `approve default`, `choose alternative`, or `freeform constraint` |
| NSQ-019 | P0 | Approve the complete proposed pilot envelope for repository/event scale and age, compute/storage/spend/operator limits, availability/support, latency, recovery/backup/retention, parity, transaction/outage evidence, 30-minute delayed re-probe, and fourteen-day observation? | Approve D016: one rehearsal and one live repository; 500 events/day and 20/minute burst; ten-minute ordinary event age; two workflows; one release/day; 16 vCPU, 32 GiB, 200 GiB, USD 250/month, four operator-hours/week, thirty dual-run days; 99.5% monthly availability excluding approved maintenance; 24x7 automated alerting with attended release/cutover windows; 24-hour snapshot, 30-day restore rehearsal, 365-day evidence and support-plus-365-day release retention; and all documented parity, latency, recovery, mirror, transaction, outage, delayed-probe, and observation thresholds. | Approve every value; revise named values with affected owner rationale; leave any value unbounded, which blocks objective cutover review. | `PRODUCT-015`, `PRQ-048`, `ARCH-022`, `ARQ-045`, `IFACE-031` | `NSE-20260727-local-delivery-adversarial-audit` | `approve default` or `state each revised threshold` |
| NSQ-020 | P0 | Approve immutable IdP subjects, raw-body event admission plus durable effect ledger, scoped trusted status reporting, and separated privileged principals as mandatory? | Approve D017 and reject any provider/design that cannot prove the boundary. | Approve; propose an equivalent mechanism with the same adversarial tests; waive, which leaves candidate self-certification/replay risk and is not recommended. | `PRODUCT-015`, `ARCH-022`, `PRQ-040`, `PRQ-044`, `ARQ-036`, `ARQ-040`, `ARQ-041` | `NSE-20260727-local-delivery-adversarial-audit` | `approve default` or `state equivalent controls` |
| NQI-Q021 | P0 | After the fresh independent re-review returns no required changes and NSQ-015 through NSQ-020 are resolved, do you explicitly approve and lock North Star iteration 26? | Approve D018 only after every prior condition is met. | Approve and lock; request named changes; reject. | all iteration-26 IDs; `northstar-artifacts.yaml`; North Star gate | complete iteration-26 review packet and owner dispositions | exact phrase: `approve and lock iteration 26`, `changes requested: ...`, or `reject: ...` |

## Answer Capture Rules

- Preserve answers as new review-feedback evidence and route them through
  `northstar-planning / review-feedback`.
- Interview answers do not themselves record final lock. Only the explicit
  NQI-Q021 decision, after a clean re-review and owner dispositions, may update `northstar-artifacts.yaml`,
  `northstar-plan.yaml`, `.agent-workflow/gates/northstar.yaml`, product and
  architecture status, and downstream handoff.
- A lock authorizes downstream project definition and architecture contracts;
  it does not authorize protected settings, production mutation, credential
  changes, workflow disablement, cutover, or destructive retirement.
- Any requested alternative forge, package authority, mirror policy, security
  boundary, or cutover rule starts another artifact-loop revision before lock.
