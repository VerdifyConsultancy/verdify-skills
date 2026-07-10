# ADR-0003: External Owned Interfaces For Platform, Orbit, And Gravity

Status: Approved

## Decision

Keep Agent Platform runtime, Orbit governed context, and Gravity evidence/data implementation in their owning repositories. Verdify Skills consumes versioned capability, connector, and evidence contracts and records readiness evidence without taking over external runtime or data authority.

## Alternatives

- Implement adapters and data behavior directly in Verdify Skills: rejected because it collapses ownership and creates privileged coupling.
- Allow runtime-specific assumptions without capability negotiation: rejected because deployments and agents vary.

## Consequences

Unsupported capabilities fail explicitly. Orbit requires connector identity and privacy controls. Gravity requires tenant-scoped read-only citations. Cross-project gaps are filed with owning repositories.
