# ADR-0005: Exact Artifacts, No Compatibility Shims, And Selective Recovery

Status: Approved

## Decision

Test and publish one exact package artifact, prefer one current accepted contract over compatibility shims, and recover historical work selectively from exact refs rather than merging stale trees wholesale.

## Alternatives

- Test source and rebuild during publication: rejected because the immutable consumer artifact may differ.
- Retain deprecated aliases indefinitely: rejected by the internal-first no-compatibility policy.
- Merge rescue branches wholesale: rejected because they can delete or downgrade newer accepted state.

## Consequences

Release identity and file selection require exact-set verification and a resumable ledger. Migrations are explicit. Recovery requires a checked-in disposition before redundant refs are deleted.
