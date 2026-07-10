# ADR-0001: Typed Authority And Artifact Pipeline

Status: Approved

## Decision

Use GitHub and schema-valid repository artifacts as complementary typed authorities. Issues own backlog problems; protected artifacts own approved intent and contracts; PRs/checks/reviews own delivery evidence; the default branch owns accepted code; deployment and outcome records separately own runtime truth.

## Alternatives

- Treat chat or controller memory as authority: rejected because it is not durable or independently reviewable.
- Treat GitHub alone as all planning authority: rejected because structured definitions and contracts need versioned schemas and cross-reference validation.

## Consequences

Every transition must reconcile its authoritative owners. Duplicate narrative state is a derived view, not a competing source. Missing or contradictory authority fails closed.
