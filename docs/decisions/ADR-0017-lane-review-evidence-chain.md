# ADR-0017: Non-self-referential lane review evidence chain

- Status: Accepted
- Date: 2026-07-09
- Issue: #72

## Context

The original lane artifacts overloaded one `head_sha`. A closeout could either
name the implementation it validated or the commit containing the closeout,
but it could not name its own containing commit. Critic independence also
depended on a machine-local worker lease, so a released or missing lease let the
same declared session create a critic worktree. Routing then trusted
`outcome: approve` without proving artifact identity or Git ancestry.

## Decision

Lane review uses four distinct revision roles:

```text
baseline B -> approved dispatch D -> implementation I -> closeout evidence E -> critic report S
                                                                     dev critic status targets S
```

- `D` is the first commit after `B`. `bin/verdify lane create` seeds the
  approved SprintPlan, wave release plan, and canonical lane contract into the
  worker branch before coding. D is linear, contains the lane contract, changes
  no implementation path, and those dispatch artifacts cannot change in
  `D..I`.
- `I` is the last substantive commit. `LaneCloseout` v2 records it as both
  `implementation_head_sha` and `validated_head_sha`.
- `E` follows `I`. Every commit in `I..E` is linear and changes only the exact
  canonical closeout path. The critic records `E` as `evidence_head_sha` and
  `reviewed_head_sha`, plus the closeout path and SHA-256.
- `S` follows `E`. Every commit in `E..S` is linear and changes only the exact
  canonical critic-report path. The report does not try to record `S` inside
  itself; Git derives the report head.
- For a lane PR targeting `dev`, the required `critic-gate` status validates the
  exact D/I/E/S chain, independent worker/critic identities, and an `approve` or
  `approve_with_risks` outcome at current head S. It is transport-neutral and
  does not require the PR author to submit an impossible GitHub self-approval.
- On GitHub Free the candidate can define a workflow job under an existing
  required-context name. CODEOWNERS therefore protects all workflow and trusted
  delivery-control surfaces, and those paths additionally require a current
  non-author owner approval. Ordinary unowned lane paths retain the zero-review
  critic-status path. Protected-branch updates are restricted to the two owners.
- A `main` release promotion is a different authority boundary: the latest
  effective review must be `APPROVED` on the current head by `jvallery` or
  `jrvallery`, not the PR author or a workflow identity, with no unresolved
  change request. Any later commit invalidates the phase-appropriate gate.

After every required lane has an approving current-head critic status,
`release-verification` assembles a
separate controller evidence history from the SprintPlan baseline. The
controller history may copy only the approved sprint transaction, canonical
closeouts, critic reports, and release evidence; it never contains lane
implementation changes and is not an integration candidate. The review packet
must be the only changed path in its commit, called **P**. The packet names the
pushed `controller/<sprint-id>` branch, while Git derives P as the packet's last
change commit.

Only a linear suffix of canonical delivery evidence may follow P:
`release/release-verification.yaml`, `outcome/outcome-review.yaml`,
`status.yaml`, or one atomic terminalization commit changing only
`sprint-plan.yaml` and `status.yaml`. The packet bytes remain unchanged. Lane
PRs are merged or queued individually against their approved base; deployment
and runtime verification happen after integration and remain separate proof.

The closeout and critic retain both worker and critic agent IDs and session IDs.
Both pairs must differ regardless of lease availability. `lane review` fetches the live GitHub
PR head for GitHub repositories, creates a detached worktree at that commit,
and validates the closeout chain before issuing a critic lease.

Schemas move directly to version 2.0. The ambiguous v1 fields have no
compatibility alias. Tracked closeouts and examples are migrated to the new
field names, while historical prose may still describe the defect that led to
this decision.

## Enforcement

- `LaneReviewValidator` validates schemas, cross-document identity, worker and
  critic independence, the separate approved dispatch commit, closeout
  digests, commit ancestry, merge-free evidence suffixes, exact allowed paths,
  and external submission freshness.
- `bin/verdify lane create` refuses an uncommitted or unapproved sprint,
  wave, or contract transaction and writes D before handing the worktree to the
  worker.
- `bin/verdify lane review` uses the committed closeout rather than active lease
  state as the worker identity authority.
- `bin/verdify route` fails closed on invalid closeout or critic chains and
  requires an open non-draft PR, live required-check success including
  `critic-gate`, a clean merge state, and exact current-head approving critic
  status before ordinary `dev` integration. Protected control-plane changes
  also require code-owner approval. Human GitHub approval remains mandatory for
  `main` release promotion.
- Standard PR policy requires explicit implementation, evidence, and exact
  current-head metadata and validates it against the committed artifacts and
  Git chain. `Evidence head SHA: pending` is allowed only while the current
  head still equals the implementation head.
- CI executes the policy engine from the protected base checkout and supplies a
  separate full-history candidate checkout only as data. Controllers use a
  pinned, atomically installed package or protected-base validator for the same
  reason.
- The #72 pull request is the one-time bootstrap: its protected base runs the
  prior structural policy, its candidate validator runs supplemental tests,
  and a distinct repository admin must explicitly approve the complete change.
  Once merged to `dev`, later candidates cannot replace their authoritative
  policy engine.
- Multi-lane review packets carry one submission record per lane. The packet is
  the sole path in commit P on pushed `controller/<sprint-id>`, never on a lane
  PR branch. Only the constrained canonical release/outcome/status suffix above
  may follow P.

## Consequences

Workers stop after the closeout-only commit. Critics may write only the
canonical critic report after review. A shared worker/critic identity cannot
satisfy `critic-gate`; no workflow may manufacture the real owner approval
required for `main`. Evidence-only paths are fixed by the canonical sprint layout, not
supplied by an artifact, and the contract itself is hashed from its committed
snapshot at `I` rather than trusted from the working tree. D prevents a worker
from weakening the approved contract or wave policy inside an implementation
commit and then asking that weakened policy to certify itself.
The controller branch is durable evidence, not a combined implementation or
release candidate; integration still merges each approved lane PR separately.
