# North Star Plan

Status: `review_requested`
Iteration: `26`
Updated: `2026-07-27`
Current protected authority: iteration 25

This is the human-readable summary of the proposed planning loop. The canonical
structured record is `northstar-plan.yaml`; product, architecture, review,
questions, and gate state live in `NORTHSTAR_PRODUCT.md`,
`NORTHSTAR_ARCHITECTURE.md`, `REVIEW_PLAN.md`,
`NORTHSTAR_INTERVIEW.md`, `northstar-artifacts.yaml`, and
`.agent-workflow/gates/northstar.yaml`.

## Proposed Outcome

Verdify Skills retains the approved four-project, internal-first, root-planner
model while moving its delivery path off every load-bearing GitHub Actions,
GitHub-hosted runner, public-registry, public-release, and GitHub-only
dependency:

- A capability-qualified supported Forgejo release (v16 is the current
  candidate) and internal IdP become repository, portfolio-work, issue,
  pull-request, review, trusted-status, protection, identity, and audit
  authority.
- Raw-body webhook admission and a durable transaction/effect ledger establish
  canonical identity, idempotency, exact-head currentness, immutable effects,
  archives, and authorized replay before Argo Events and repository-owned Argo
  Workflows execute.
- Zot stores an immutable exact-tested package subject plus one signed complete
  pre-promotion release envelope enumerating source/policy, checksums,
  provenance, SBOM, signature, attestations, and criticism through separated
  builder, publisher, and signer principals. The durable ledger records later
  approval, GitOps, consumer, rollback, release, and mirror receipts against
  that fixed envelope digest.
- Argo CD solely owns a stable digest-pinned non-production harness. An init
  container verifies the package and envelope into a fresh volume; the main
  container performs a real install and probes before readiness.
- Every executable dependency resolves from an internal mirror by digest or
  checksum; an empty-node/CRI-cache test denies public egress at node, gateway,
  workload, workflow-controller, and Argo CD repo-server boundaries.
- GitHub Actions, npm, GitHub Releases, and GitHub dual-run or mirror until
  parity and cutover. Public surfaces are proprietary/source-available output
  mirrors that preserve GitHub's in-Service public-repository rights while
  declaring any additional project/off-platform/package license, separate-user,
  issue/security, contributor-rights, verification, and support terms;
  external code remains unaccepted until an approved CLA/assignment process
  exists. Internal coordinated restoration, not an implicit GitHub failback,
  is the recovery path. Additional licensing, contribution intake, permanent
  retirement, and emergency authority transfer are separate authorized actions.

## Required Proof

Functional, security, supply-chain, operational, rollback/recovery,
performance, duration, logs, metrics, cold-node, sole-owner GitOps, and
GitHub-unavailable acceptance must all pass. Required checks retain behavioral
semantics with zero false accepts and trusted issuers; candidate policy executes
from protected-base authority; candidate, validator, critic, status, publisher,
signer, mirror, GitOps, verifier, approver, and recovery identities remain
distinct; duplicate/reordered/replayed events and controller loss cannot repeat
effects; no load-bearing exception remains at cutover.

The proposed pilot maximum is two concurrent workflows, one release/day,
200 GiB incremental storage, four operator-hours/week, and thirty dual-run
days. Cutover also requires twenty change and three release/rollback
transactions, p95 queue under two minutes, validation under fifteen minutes,
consumer health and rollback under ten minutes, Forgejo RPO at most five
minutes/RTO at most two hours, four GitHub-unavailable hours, and fourteen
healthy observation days.

## Sequence

1. Complete the fresh cross-functional audit; resolve `NSQ-015` through
   `NSQ-020`; explicitly lock iteration 26.
2. Produce approved project definition and architecture/module contracts.
3. Record closed issues #120/#121 as completed absorbed predecessor contracts
   without redispatch; create owning Agent Platform and Verdify Skills issues
   and non-overlapping one-lane implementation transactions.
4. In isolation, establish qualified Forgejo, IdP, portfolio migration,
   admission/ledger/status, immutable dependencies, Zot/signing, GitOps,
   coordinated backup/restore, audit, public-support, and service-objective
   foundations without changing current authority.
5. Dual-run local validation and signed release-envelope publication; close
   every parity, idempotency, security, digest, and service-objective gap.
6. Prove the stable-harness fresh-volume consumer, empty-node/CRI-cache
   denied-egress path, failure injection, coordinated recovery, rollback,
   cleanup, observability, and delayed durability.
7. Run an attended human-gated authority cutover and GitHub-unavailable proof.
8. Observe fourteen healthy days; retire only separately authorized exact
   targets.

## Current Hard Blockers

- Iteration 26 has no final lock.
- No live internal forge was observable.
- No approved internal IdP, event-admission service, durable delivery ledger,
  trusted status issuer, coordinated recovery set, or public-support owner was
  observable.
- Current generic local workflows still clone GitHub and use public inputs.
- Verdify Skills has no package-aware Agent Fleet CI contract or dedicated
  acceptance workload.
- Live Argo ownership/health and Zot contents are unreadable with the repository
  service account.
- Organization-level GitHub controls remain unknown.
- No empty-node/CRI-cache, full-boundary egress-denial, GitHub-unavailable,
  coordinated backup/restore, or rollback acceptance has run.

## Human Decision

Proposed defaults:

1. A capability-qualified supported Forgejo release as repository authority;
   GitHub as an output mirror.
2. Package subject plus signed release envelope and stable-harness/fresh-volume
   Argo CD acceptance.
3. npm and GitHub Releases remain best-effort output mirrors with a support
   contract; retirement is a later destructive gate.
4. Repository and portfolio-work authority migrate through provider-neutral
   IDs and history markers.
5. Approve or revise every named value in the bounded operating envelope:
   repository/event scale and age, compute/storage/spend/operator limits,
   availability/support, latency, recovery/backup/retention, parity,
   transaction/outage evidence, delayed re-probe, and observation.
6. Require IdP identity, raw-body admission, durable effect ledger, trusted
   status issuer, and separated privileged principals.

The hash-bound fresh independent re-review found no required changes. The
packet is ready for named owner dispositions and human decisions; no approval
is inferred.

## Handoff

Next route: `northstar-planning / human-review`, using
`NORTHSTAR_INTERVIEW.md` as the ready question pack. Captured answers return
through `northstar-planning / review-feedback` before any explicit final lock.

No implementation, protection change, credential change, cluster mutation,
cutover, public-package removal, release deletion, or destructive retirement is
authorized while the gate remains open.
