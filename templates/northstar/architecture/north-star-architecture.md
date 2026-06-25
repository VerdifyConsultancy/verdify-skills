<!-- TEMPLATE: copy to .agent-workflow/architecture/north-star-architecture.md and complete via $architecture-contracts. -->

# North Star Architecture — <REPOSITORY>

## Target architecture narrative

> The intended end-state architecture in prose. What the system is, how its parts fit,
> and the principles that keep it coherent as it grows.

## Module map

- `<module-id>` — responsibility, owner, the requirements it realizes.
- `<module-id>` — responsibility, owner, the requirements it realizes.

## Data flows

- `<source> -> <sink>` — what data moves and over what transport.

## Integration points

- External systems, APIs, registries, or platforms this repository depends on or exposes.

## Deployment / runtime model

- Where it runs (e.g. pod-per-repo StatefulSet in k3s `agent-fleet-runners`), how it is
  rendered and promoted (registry -> render -> ArgoCD -> pod), and its runtime topology.

## Observability

- Health, metrics, logs, and traces that prove the system is behaving.

## Rollback strategy

- Known-good revision, how to detect a bad rollout, and how to revert through the
  change-gate without an autonomous destructive mutation.
