# Review Packet Format

Use this reference when creating or reviewing a
`consensus-audit-workflow` packet. The packet is a durable review record for
skill architecture and planning consensus. It is not a source of approval for
protected decisions unless an authorized human approval is explicitly linked.

## Required Sections

- `scope`: audit id, repository, issue or PR refs, reviewed artifacts, baseline
  SHA, head SHA, affected skills, lifecycle modes, schemas, and packet status.
- `authority_boundary`: controlling GitHub issue, applicable lane contract,
  protected paths, ADR refs, human approval owners, and Agent Platform boundary
  refs.
- `evidence`: registered evidence refs, linked collateral refs, external
  research refs, source status, claim summary, quality score, and uncertainty.
- `skill_boundaries`: one entry per affected skill with owned surface,
  prohibited surface, adjacent skills, supporting evidence, and why the
  boundary exists.
- `consistency_checks`: lifecycle registration, host links, evaluations,
  referenced files, schema refs, tag use, issue linkage, validation commands,
  and result.
- `machine_reviewers`: separate Codex and Claude review loops with reviewer id,
  input refs, required changes, suggestions, unresolved findings, and final
  conclusion.
- `human_votes`: lane-owner and stakeholder-lens votes. Required lenses are
  product, manager, finance, infrastructure, SRE, and security.
- `decisions`: normalized dispositions in the four required categories.
- `objections`: objections, owner, severity, evidence, disposition, route, and
  whether the item blocks protected approval.
- `unresolved_issues`: final issues, route, owner, expected artifact, and
  whether implementation may proceed.
- `approval`: explicit human approvals only. Machine reviewers may recommend
  review readiness but cannot approve protected decisions.

## Decision Categories

- `accepted_decision`: already authorized or explicitly accepted by the correct
  human owner, with evidence and scope recorded.
- `proposed_change`: recommended but not yet approved. Route it to the owning
  GitHub issue, gate, ADR, North Star artifact, schema, or lane contract.
- `conflict`: unresolved contradiction between evidence, contracts, human
  votes, machine reviews, schemas, or platform boundaries.
- `rejected_suggestion`: considered and declined with rationale, evidence, and
  the rejecting owner or rule.

Every recommendation must use exactly one category. Do not hide a conflict in
free-form notes.

## Evidence Scoring

Use a 0 to 3 score for each dimension:

- `authority`: source is authoritative for the claim.
- `freshness`: source is current for the reviewed SHA or decision date.
- `relevance`: source directly supports the boundary or decision.
- `corroboration`: independent sources agree.
- `uncertainty`: lower is better; score 0 when the source is precise and 3
  when the claim is highly uncertain.

Record a short rationale for each score. A packet may proceed with weak
evidence only when the weakness is explicit and routed.

## Reviewer Separation

Machine reviewers and human voters are different evidence classes.

- Codex and Claude reviews record findings, required changes, suggestions, and
  final machine conclusions.
- Human and lane-owner votes record authority, lens, vote, rationale, and any
  approval conditions.
- A machine conclusion of `no_required_changes` is review evidence, not human
  approval.

## Stakeholder Lenses

Record all six lenses even when a vote is pending:

- product: customer value, scope, user story fit, decision clarity;
- manager: sequencing, ownership, dependencies, delivery risk;
- finance: cost, licensing, operational spend, opportunity cost;
- infrastructure: platform boundary, dispatch path, storage, network, runtime;
- SRE: reliability, observability, recovery, alerts, operational load;
- security: least privilege, secrets, approval boundaries, data exposure.

## Platform Boundary

When platform consensus is involved, cite
`docs/decisions/ADR-0016-package-platform-skill-reconciliation.md`.
Verdify Skills owns portable lifecycle evidence and review packets. Agent
Platform owns platform-native `consensus-review`, `consensus-report`, and
PR-native consensus state. Link platform consensus evidence when present; do
not synthesize it inside this packet as if it were the platform source of
truth.
