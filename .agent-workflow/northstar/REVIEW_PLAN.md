# North Star Review And Signoff Plan

Status: `review_requested`
Iteration: `26`
Prepared: `2026-07-27`
Final lock authority: Jason
Current protected authority: iteration 25
Reviewers: Jason, James, Skills governance/release owner, legal/IP owner, Agent Platform owner, source-control owner, security owner, SRE owner, backup/recovery owner, finance owner

## Decision Requested

The first product/business, architecture/delivery, and security/SRE review
returned required changes. An earlier hash-bound candidate then received three
`no_changes_required` verdicts, but five reviewed artifacts changed afterward;
that historical result is not proof for the current bytes. The final candidate
may advance only when a separate evidence record binds these exact files and
the North Star gate to three fresh `no_changes_required` verdicts without
mutating the reviewed packet. Once that record exists, the remaining decision
path is:

1. inspect the exact final-candidate re-review evidence;
2. record Agent Platform, source-control, security, SRE, backup/recovery,
   finance, Skills release, governance, and legal/IP dispositions;
3. then ask Jason to resolve `NSQ-015` through `NSQ-020`; and
4. only if satisfied, explicitly say `approve and lock iteration 26`.

The proposed defaults are a capability-qualified supported Forgejo release plus
internal IdP; provider-neutral repository and portfolio-work authority; raw-body
event admission, durable effect ledger, and scoped trusted status reporting;
one package-specific Zot subject plus signed immutable release envelope; a
stable-harness/fresh-volume Argo CD consumer; governed public output mirrors; a
bounded operating envelope; coordinated internal recovery; and later separate
gates for retirement or emergency authority transfer.

Final lock authorizes downstream project definition and architecture contracts.
It does not authorize implementation, protection changes, credentials, direct
cluster mutation, cutover, production deployment, or destructive retirement.

## Evidence In Scope

- `northstar://evidence/NSE-20260727-verdify-skills-local-delivery-inventory`
- `northstar://evidence/NSE-20260727-local-delivery-control-plane-primary-sources`
- `northstar://evidence/NSE-20260727-local-delivery-adversarial-audit`
- `northstar://evidence/NSE-20260727-verdify-skills-public-visibility-license`
- `northstar://evidence/NSE-20260727-github-public-repository-license-terms`
- `northstar://evidence/NSE-20260727-shared-local-delivery-authority-live-state`
- `northstar://evidence/NSE-20260727-local-delivery-native-dependency-reconciliation`
- `northstar://evidence/NSE-20260727-local-delivery-clean-rereview` (historical candidate only)
- `northstar://evidence/NSE-20260727-local-delivery-final-candidate-rereview`
- `northstar://evidence/NSE-20260623-source-control-migration-local-forges`
- `northstar://evidence/NSE-20260623-kubernetes-gitops-cicd-cardinality`
- `northstar://evidence/NSE-20260623-environment-gitops-implementation-best-p`
- `northstar://evidence/NSE-20260623-session-ledger-implementation-best-pract`
- `northstar://evidence/NSE-20260623-secrets-credential-injection-patterns`
- `northstar://evidence/NSE-20260709-verdify-skills-adversarial-review`
- `.agent-workflow/strategy/state-of-union.yaml`
- `.agent-workflow/strategy/state-of-union.md`
- `.agent-workflow/strategy/github-backlog-sync.yaml`
- `jvallery/agents#3044`
- `jvallery/agents#3047`

## Content Review Checks

- [x] Current GitHub Actions, hosted runners, checks, artifacts, release,
  package, source, review, status, deployment, and authority dependencies are
  inventoried.
- [x] Unknown organization-level GitHub controls and unreadable Argo/Zot state
  remain explicit limitations.
- [x] Capability-qualified Forgejo, internal IdP, repository and portfolio work,
  governance-history migration, Argo transport/execution, Zot, GitOps, and
  public output mirrors have explicit authority and ownership boundaries.
- [x] Repository-owned behavior and platform-owned reusable mechanics are
  separated.
- [x] The package subject plus a signed complete pre-promotion release envelope,
  rather than an unrelated container image or eventually complete referrer set,
  is the immutable release unit; later lifecycle effects are ledger receipts
  against its fixed digest.
- [x] The non-production consumer has a stable digest-pinned harness, init
  pull/verify into a fresh volume, real main-container install/probes, readiness,
  Argo CD sole ownership, rollback, cleanup, and delayed durability.
- [x] Every executable dependency is covered by the internal immutable mirror,
  empty-node/CRI-cache, node/gateway/controller/repo-server denial, registry
  audit, isolated refresh, and offline bootstrap/recovery requirements.
- [x] Check semantics, protected-base policy/template digests, trusted status
  issuer, immutable identity subjects, fresh criticism, exact-head currentness,
  historical-only imported approvals, human approval, credential isolation,
  provenance, envelope completeness, audit, and retention are explicit.
- [x] The already-public `UNLICENSED` repository/package is explicitly
  proprietary/source-available: GitHub's in-Service public-repository rights
  are preserved, any additional project/off-platform/package grant is explicit
  and legal/IP-approved, separate written terms are identified, and external
  code stays disabled until an approved CLA/assignment intake exists.
- [x] Raw-body admission and a durable transaction/effect ledger cover
  duplicates, reorder, replay, partial effects, concurrent attempts, stale
  heads, changed approvals, forged statuses, candidate credential probes,
  mirror poisoning, registry/signer/publisher/GC/GitOps failure, unhealthy
  install/probes, controller loss, coordinated restore, rollback, and mirror
  failure.
- [x] Isolated rehearsal, coexistence, parity, coordinated snapshot/restore,
  human APPLY, dead-man, internal recovery deadline, post-verification, delayed
  probe, fourteen-day observation, emergency authority transfer, and later
  retirement are distinct; GitHub is not an implicit failback.
- [x] Functional, security, supply-chain, operational, rollback/recovery,
  performance, duration, logs, metrics, and GitHub-unavailable evidence are
  required before cutover.
- [x] A versioned exception ledger blocks silent, mutable, expired, unowned, or
  load-bearing dependencies; load-bearing entries cannot be waived at cutover.
- [x] A measurable pilot envelope names target repositories, event rate/burst
  and age, workflow/release concurrency, compute, storage, currency spend,
  operator time, availability, supported/attended hours, alert coverage,
  dual-run duration, transaction counts, latency, RPO/RTO, mirror freshness,
  snapshot/rehearsal age, evidence/release retention, outage, 30-minute delayed
  re-probe, and observation thresholds.
- [x] Closed issues #120 and #121 are completed absorbed predecessor contracts,
  carried into #3044/WAVE-011 without redispatch or parallel duplicate work.
- [x] Shared platform issue #3047 owns internal Git/event/status authority and
  offline dependency supply; #3044 remains the Verdify Skills consumer record,
  the native `#3044 blocked_by #3047` edge is recorded, duplicate issue
  proposals are retired, and neither issue's unapproved proposal is treated as
  authority.
- [x] `NORTHSTAR_INTERVIEW.md` defines stable `OWN-001` through `OWN-010`
  role-assignment slots and exact `OE-001` through `OE-034` threshold rows with
  units, applicable owners, required row-level fields, and conflict handling.
  Pending identities and dispositions remain blockers.
- [x] Iteration 25 remains the protected authority and this packet records no
  inferred approval.
- Exact-review completion is not self-asserted by this mutable checklist.
  `NSE-20260727-local-delivery-final-candidate-rereview` is the sole completion
  record: it must bind this exact packet and gate manifest to separate
  product/business, architecture/delivery/scalability, and security/SRE/audit
  `no_changes_required` verdicts. A missing record, missing lens, different
  verdict, or hash mismatch returns the packet to adversarial review.
- [ ] Every `OWN-001` through `OWN-010` role needed by `NSQ-015` through
  `NSQ-020` names one accountable human by immutable IdP subject and cites a
  versioned durable authority assignment before Jason's final-lock question.
- [ ] The disposition ledger contains one identity-bound `accept`, `revise`, or
  `reject` record for every applicable `OWN-*`/`OE-*` pair. Missing rows,
  rejections, or unresolved conflicting revisions keep `NSQ-019` open; a
  generic approval does not satisfy the operating-envelope gate.

## Adversarial Review Lenses

| Lens | Required challenge |
| --- | --- |
| User | Can a maintainer complete the full path when GitHub is unavailable? |
| Administrator | Are forge identity, backup, restore, upgrades, email, audit, and abuse controls operable? |
| Auditor | Can exact heads, reviewers, statuses, artifact digests, GitOps state, and human decisions be reconstructed? |
| Architect | Does a package-specific OCI subject avoid conflating package release with container mechanics? |
| SRE | Do cold-node, retry, replay, restart, drift, rollback, restore, delayed-failure, and alert paths work? |
| Scalability | Are templates, providers, mirrors, and evidence reusable across repositories without bespoke Sensors? |
| Finance | Are dual-run, retention, mirror, compute, storage, and operator costs visible and bounded? |
| Security | Are webhook trust, service accounts, registry writers, signing keys, mirror credentials, GitOps authority, and candidate policy isolated? |

All accepted findings must be represented in `ADV-020` through `ADV-035`,
`NSK-022` through `NSK-035`, or a named change request. A fresh critic may add
findings; it may not infer approval.

## Implementation Proof Required After Lock

1. Approved project definition and architecture/module contracts.
2. Owning issues in Verdify Skills and Agent Platform; one issue/lane/branch/
   worktree/session/PR by default.
3. Protected-base candidate validation and exact-head closeout/critic evidence.
4. closed #120/#121 absorbed-predecessor mapping and isolated
   Forgejo/IdP/portfolio migration,
   admission/ledger/status, immutable-dependency, signing, GitOps, public
   support, and coordinated-restore contract tests without changing authority.
5. At least twenty consecutive distinct successful end-to-end change
   transactions and at least three consecutive distinct successful
   release-and-rollback transaction pairs with 100% logical and failure parity,
   zero false accepts, trusted issuers, and objective latency.
6. Exact package subject, signed complete envelope, separated publisher/signer,
   Zot ACL/retention/GC/backup, and public-mirror verification.
7. Empty-node/CRI-cache full-boundary denied-egress, stable-harness fresh-volume
   consumer acceptance, registry audit, and offline recovery bundle.
8. Coordinated restore, recovery, rollback, cleanup, delayed durability,
   observability, RPO/RTO, and operating-envelope evidence.
9. Attended human-gated authority switch and four-hour GitHub-unavailable proof.
10. Fourteen healthy days and separately authorized exact-target retirement or
    emergency authority transfer.

## Known Hard Blockers

- No live internal forge was observable.
- No approved IdP, raw-body admission service, durable delivery ledger, scoped
  status issuer, separated signing path, or coordinated recovery set was
  observable.
- Current generic Argo templates still clone GitHub and use public inputs.
- The package repository has no first-class Agent Fleet package-artifact
  contract or dedicated acceptance workload.
- Live Argo object ownership/health and Zot package contents are unreadable with
  the repository service account.
- Organization-level GitHub runners, secrets, hooks, and inherited rules are
  unknown.
- No empty-node/CRI-cache full-boundary denial, GitHub-unavailable,
  coordinated backup/restore, or rollback acceptance has run.

These block milestone completion and cutover. They do not justify bypassing the
North Star lock or guessing protected authority.

## Handoff

Current route remains `northstar-planning / review-feedback` until
`NSE-20260727-local-delivery-final-candidate-rereview` binds the exact packet
to all three required `no_changes_required` verdicts. Then route once to
`northstar-planning / human-review` using `NORTHSTAR_INTERVIEW.md`: assign every
required `OWN-*` role by immutable subject and durable authority evidence,
record every applicable `OWN-*`/`OE-*` disposition without unresolved
conflict, and resolve `NSQ-015` through `NSQ-020`. Captured answers return
through `northstar-planning / review-feedback`. Only after Jason separately
locks iteration 26 may the canonical artifacts route to
`project-definition / discovery`.
