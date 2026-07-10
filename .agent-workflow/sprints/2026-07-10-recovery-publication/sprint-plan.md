# Sprint 2026-07-10 Recovery Publication

## Outcome

Recover the useful unpublished timeline-historian, delivery-loop evidence,
crm-email, and skill-pack work from exact refs `fe1f94e`, `f425515`, and
`22f81bd` onto current `dev` without replaying stale trees. Produce a checked-in
ledger that makes every retained, recovered, superseded, merged, or
cleanup-eligible ref/worktree legible.

## Lane

| Lane | Issue | Branch | Responsibility | Reviewer |
| --- | --- | --- | --- | --- |
| `issue-126-recovery-publication` | `#126` | `lane/126-recovery-publication` | Selective port, provenance registry, skill/pack compatibility, full validation, and disposition ledger | Fresh independent critic |

The lane is deliberately single: all recovered work converges on the same
evidence registry, package manifest, skill catalogs, host links, CLI, npm
surface, and final recovery ledger. Splitting it would create competing edits
to those shared authorities.

## Hard Boundaries

- No wholesale merge or cherry-pick of a rescue tree.
- No protected North Star/product/architecture rewrite.
- No `VERSION`, package version, workflow, npm, GitHub release, `main`, CRM,
  email, runtime, or GitOps mutation.
- No rescue-ref deletion or shared-runner cleanup before final main-release
  verification.
- `scripts/package-file-list.rb` remains the issue `#130` immutable Git-index
  staging authority.

## Review

QA requires source-to-target mapping, evidence hashes, timeline/CRM/pack tests,
isolated npm install, exact package verification, the complete recovery ledger,
secret scan, `make test`, and live exact-head checks. Fresh critic review is
followed by non-author review when available or the explicitly recorded
user-authorized admin integration policy.

Issues `#120` and `#121`, new-version promotion to `main`, publication, and
destructive cleanup remain subsequent work.
