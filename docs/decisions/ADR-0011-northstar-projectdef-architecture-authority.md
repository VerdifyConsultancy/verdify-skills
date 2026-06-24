# ADR-0011: North Star, project definition, and architecture authority boundaries

- Status: accepted
- Date: 2026-06-24
- Resolves: #8

## Context

`northstar-planning`, `project-definition`, and `architecture-contracts` all use
requirements, product, design, and architecture language. That overlap is useful
for traceability, but it creates an authority risk: an agent can treat draft
planning text as approved requirements, rewrite approved project intent from an
architecture pass, or assign module ownership before the architecture contract
owns that decision.

The lifecycle needs one owner for each information type while preserving the
handoff from planning intent to approved project definition to implementable
architecture and module contracts.

## Decision

Separate authority by artifact state and information type:

| Information type | Authoritative artifact | Owning skill | Notes |
| --- | --- | --- | --- |
| Planning intent, milestone framing, PRD drafts, product and architecture questions, candidate waves, draft stories, draft high-level design, research-backed options, and review feedback before lock | `.agent-workflow/northstar/NORTHSTAR_PRODUCT.md`, `.agent-workflow/northstar/NORTHSTAR_ARCHITECTURE.md`, and `.agent-workflow/northstar/northstar-artifacts.yaml` | `northstar-planning` | Draft North Star content is planning input, not approved delivery authority. Locked North Star content is approved milestone input for downstream definition and architecture, not an implementation contract. |
| Approved requirements, product scope, users, jobs, workflows, design surfaces, public behavior, acceptance criteria, lifecycle constraints, relationships, and unresolved project gaps | `.agent-workflow/project/project-definition.yaml` | `project-definition` | The YAML is canonical. Markdown views summarize it and must not introduce new decisions. |
| Approved system architecture, topology, data flow, storage, integrations, trust boundaries, deployment model, observability, failure modes, architecture ADRs, and major implementation tradeoffs | `.agent-workflow/architecture/architecture.yaml`, `.agent-workflow/architecture/north-star-architecture.md`, and `.agent-workflow/architecture/decisions/ADR-*.md` | `architecture-contracts` | Architecture must trace back to approved project definition and accepted North Star input. |
| Module ownership, owned and prohibited paths, stable public interfaces, typed inputs and outputs, invariants, dependencies, runtime resources, validation commands, and completion evidence | `.agent-workflow/modules/contracts/<module-id>.contract.yaml` and `.agent-workflow/modules/module-map.md` | `architecture-contracts` | Sprint lanes consume module contracts but do not invent module ownership. |
| Backlog problem statements, acceptance intent, dependencies, and discovered work | GitHub Issues | GitHub control plane, reconciled by the relevant lifecycle skill | Issues describe why work matters. Lane contracts bound what a worker may change. |

## Artifact states

Verdify agents must distinguish these states when choosing a route:

| State | Meaning | Allowed downstream use |
| --- | --- | --- |
| Draft North Star input | North Star product or architecture drafts exist but final lock approval is missing. | Use as evidence for continued `northstar-planning`; do not treat as approved requirements, product scope, architecture, or module ownership. |
| Locked North Star input | `northstar-artifacts.yaml` records final approval for the milestone. | Use as approved milestone input for `project-definition` and `architecture-contracts`; do not treat it as the canonical project definition or architecture contract. |
| Approved project definition | `project-definition.yaml` validates and records required approval with no blocking gaps. | Use as canonical requirements, product, design-surface, and lifecycle-constraint authority for architecture, strategy, hygiene, and sprint planning. |
| Approved architecture and module contracts | `architecture.yaml` and module contracts validate and record required approval with no blocking interface risks. | Use as canonical architecture and ownership authority for state of union, repo hygiene, sprint planning, lane contracts, workers, critics, and integration. |

## Routing rules

For ambiguous requirement, product, architecture, or high-level-design changes,
`project-router` and lifecycle agents should route by the first matching owner:

1. If the input is an unrouted transcript, meeting note, walk note, or raw
   research file, route to `transcript-replan` or `northstar-research-ingest`
   before synthesis.
2. If the change affects planning intent, milestone framing, PRD direction,
   draft product/architecture stories, draft high-level design, open North Star
   questions, or review feedback before final lock approval, route to
   `northstar-planning`.
3. If the North Star is locked but approved requirements, product scope, users,
   workflows, design surfaces, public behavior, acceptance criteria, or
   lifecycle constraints are missing, stale, or contradictory, route to
   `project-definition`.
4. If project definition is approved but system boundaries, topology, trust
   boundaries, deployment model, observability, architecture decisions, module
   ownership, owned paths, or public interfaces are missing, stale, or
   contradictory, route to `architecture-contracts`.
5. If architecture and module contracts are approved and a later change would
   alter product scope or public behavior, route back to `project-definition`
   and then re-evaluate architecture impact.
6. If architecture and module contracts are approved and a later change would
   alter only architecture tradeoffs, trust boundaries, module ownership,
   interfaces, paths, invariants, dependencies, or runtime resources while
   preserving approved project intent, route to `architecture-contracts`.
7. If a sprint lane discovers work outside its contract, the worker stops or
   records a discovered issue. It does not update North Star, project
   definition, architecture, module contracts, router rules, or skill files from
   the implementation lane.

These routing rules clarify authority only. Follow-up edits to skill files,
`docs/lifecycle.md`, schemas, or router rule implementation are outside this
decision lane.

## North Star architecture vs approved architecture

`NORTHSTAR_ARCHITECTURE.md` is an architecture planning artifact. It owns
architecture stories, architecture requirements, candidate high-level design,
infrastructure intent, interface ideas, security/RBAC intent, observability
intent, release/rollback intent, ADR references, questions, and traceability
while the North Star loop is forming or locking a milestone.

`.agent-workflow/architecture/architecture.yaml` is the approved architecture
authority. It owns the system design that downstream state-of-union,
repo-hygiene, sprint-planning, lane-delivery, criticism, integration, and
release-verification must obey. It may cite `NORTHSTAR_ARCHITECTURE.md`, but it
must not be replaced by it.

## Worked ambiguous-change request

Request: "Add browser terminal review for lane sessions, and make sure it is
secure and visible to reviewers."

Route by current artifact state:

| Current state | Correct route | Reason |
| --- | --- | --- |
| The request came from a walk note and has not been routed. | `transcript-replan` | The source is raw conversational evidence. |
| North Star drafts are still open. | `northstar-planning` | The request may affect milestone intent, review surfaces, architecture stories, and security questions. |
| North Star is locked, but project definition lacks reviewer workflows or approval surfaces. | `project-definition` | Users, workflows, public behavior, and design surfaces are project-definition authority. |
| Project definition is approved, but no trust boundary or terminal session ownership exists. | `architecture-contracts` | Trust boundaries, topology, module ownership, and interfaces are architecture/module-contract authority. |
| A worker lane is adding a doc-only ADR and notices the browser-terminal gap. | Stop or create a discovered issue | The lane contract does not own product, architecture, or skill implementation changes. |

## Consequences

- Agents can cite North Star artifacts without treating drafts as approved
  delivery contracts.
- `project-definition` remains the source of approved product, requirements,
  design-surface, and lifecycle constraints.
- `architecture-contracts` remains the source of approved architecture
  decisions and module ownership.
- Sprint lanes stay bounded by approved lane contracts and module contracts.
- Future implementation work can update router language, skill instructions, or
  lifecycle docs to encode this decision without reopening the authority choice.
