# State of Union — local CI and authority migration

Status: blocked
Baseline: `d226b7f244fd4612ab44739fd275b8158e1d9159`
Owning work item: `jvallery/agents#3044`
Shared platform dependency: `jvallery/agents#3047`

## Outcome

The requested migration is not ready for an implementation sprint. The
iteration-26 North Star packet now proposes capability-qualified Forgejo and
portfolio-work authority, internal identity, trusted event admission and a
durable effect ledger, trusted status reporting, immutable Zot package subjects
plus signed release envelopes, stable-harness GitOps acceptance, local immutable
dependencies, coordinated recovery, measurable coexistence, and attended
cutover. Iteration 25 remains protected because the audit revision is still
iterating, not locked.

The next handoff remains blocked inside `northstar-planning`. A separate
hash-bound record must first prove that fresh product/business,
architecture/delivery, and security/SRE reviewers returned
`no_changes_required` for the exact final candidate. Only then may the named
service owners record row-level dispositions before Jason is asked to resolve
`NSQ-015` through `NSQ-020` and the separate final-lock decision.

## Current truth

- `origin/dev` is
  `d226b7f244fd4612ab44739fd275b8158e1d9159`; no pull request is open and all
  recorded sprints are complete.
- Seven checked-in workflow files plus one active dynamic Copilot workflow
  remain. All required contexts are bound to GitHub Actions app `15368`, and
  the latest jobs used GitHub-hosted runners. The latest dev push invoked
  `validate`, `compliance-selftest`, `release PR`, and `delivery-gate`; the
  delivery gate failed.
- Version `1.3.0` is distributed through npm and GitHub Releases. No equivalent
  locally authoritative package release exists.
- The fleet has generic `repo-validate` and `repo-build` WorkflowTemplates,
  Argo Events objects, Argo Workflows, and Zot publication.
- Open shared platform issue `jvallery/agents#3047` owns the reusable internal
  Git/event/status authority and offline dependency supply; draft PR `#3060`
  proposes its North Star changes but currently has failing exact-head checks.
  The native GitHub dependency records `#3044 blocked_by #3047`. Neither the
  issue, dependency edge, nor draft PR grants design, implementation, or
  cutover authority.
- Verdify Skills has no `.agent-fleet/ci.yaml`, Dockerfile, Sensor binding,
  local package path, Argo Application, or immutable desired-state pin.
- The generic fleet path still clones `github.com` with
  `agent-github-token`, uses GitHub webhooks/statuses, sources desired state
  from GitHub, and retains public image and Helm repository references.
- No verified internal forge or equivalent Git/event/status/approval/promotion
  authority was found. GitHub-unavailable acceptance therefore remains a hard
  blocker unless platform evidence proves otherwise.
- The authorized Kubernetes probe could read only named objects in
  `agent-fleet-runners`. The controller pod is Ready on an immutable Zot
  digest, but it is a production-labeled repo cell, not a non-production
  migration deployment; Argo status and Zot catalog metadata were forbidden.

## Strategic sequence

1. Complete fresh cross-functional review and owner dispositions, resolve
   `NSQ-015` through `NSQ-020`, and explicitly lock the replacement authority
   and product outcome.
2. Refresh project definition, architecture ADRs, module contracts, package
   representation, ownership, rollback, and staged migration rules.
3. Preserve `#3047` as the single shared platform and offline-supply owner.
   Split only `#3044`'s Verdify Skills adoption, package, parity,
   non-production verification, and attended-cutover work into issue-backed
   slices; create no duplicate shared platform issue.
4. Map closed #120/#121 as completed absorbed predecessors without redispatch,
   then implement isolated identity, admission/ledger, trusted-status, stable
   local validation, and immutable Zot package/envelope publication while
   keeping the old path intact.
5. Prove stable-harness/fresh-volume GitOps ownership, coordinated recovery,
   rollback, delayed health, empty-node/CRI-cache full-boundary denial, and
   GitHub-unavailable authority within the approved service envelope.
6. Only then perform an attended reversible ruleset cutover and retire proven
   obsolete dependencies.

## Blocking gaps

- Exact final-candidate re-review evidence, stable named-owner assignments,
  row-level operating-envelope dispositions, and final lock remain open;
  project definition, architecture, and module contracts remain stale for the
  proposal.
- The local package form is undecided; the fleet CI schema currently requires
  at least one Docker image.
- Shared issue `#3047` and failing-check draft PR `#3060` track internal
  authority and offline supply, but the capability is unapproved and unproved.
- Public image/chart endpoints and GitHub-hosted desired state remain in the
  live platform path despite that tracked dependency.
- There is no clean local run, Zot digest/provenance, non-production
  reconciliation, rollback, delayed re-probe, cold-cache test, or
  GitHub-unavailable test.
- Org-level ARC/runner groups, inherited rulesets, hooks, secrets, and audit
  history are unavailable to the current token and must remain explicit
  unknowns.

## Gates

The existing path remains enabled. Production syncs, restarts, credential
replacement, protection changes, runner deletion, and webhook retirement
require explicit attended authority. Destructive Kubernetes changes require
the fleet change-gate.

The canonical evidence and full issue/action inventory is
`.agent-workflow/strategy/state-of-union.yaml`.
