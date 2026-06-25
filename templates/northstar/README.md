# North Star template

Per-repo North Star scaffold for any fleet-standardized repository. Copy these four
files into the **canonical authority-matrix paths** (NOT the legacy
`.agent-workflow/northstar/NORTHSTAR_PRODUCT.md`, which does not exist in standardized
repos and would false-fail the compliance gate):

| Template file | Canonical destination | Owner authority |
| --- | --- | --- |
| `project/product.md` | `.agent-workflow/project/product.md` | `approved_project_definition` |
| `project/project-definition.yaml` | `.agent-workflow/project/project-definition.yaml` | `approved_project_definition` |
| `architecture/north-star-architecture.md` | `.agent-workflow/architecture/north-star-architecture.md` | `approved_architecture` |
| `architecture/architecture.yaml` | `.agent-workflow/architecture/architecture.yaml` | `approved_architecture` |

Two owner-approved pairs (a narrative `.md` plus a machine-checkable `.yaml`):

- **Product pair** — mission, problem/why-now, target operators, outcomes, scope
  boundaries, constraints, evidence links (`product.md`), and the structured
  `project-definition.yaml` validated against `schemas/project-definition.schema.yaml`.
- **Architecture pair** — target architecture narrative, module map, data flows,
  integration/deployment/observability/rollback (`north-star-architecture.md`), and the
  structured `architecture.yaml` validated against `schemas/architecture.schema.yaml`.

## What the compliance gate checks (and what it does not)

`verdify gate compliance` checks only the deterministic shell at these canonical paths:

1. **Presence** of all four files.
2. **Schema validity** of the two `.yaml` artifacts against their schemas.
3. **Approval state** — `approval.status` is one of `approved`, `pending`, `blocked`.

It does **not** judge content quality — that is the job of the `$northstar-planning`,
`$project-definition`, and `$architecture-contracts` skills. The `.yaml` files here are
starter scaffolds: complete them through their owning skills until they are schema-valid
and `approval.status: approved` before downstream lifecycle skills treat them as authority.

Owners (operator scoping): Jason -> `jvallery`, James -> `jrvallery`, Emily -> `evallery`.
Never hand one operator another's personal credentials; scope access through the platform
identity model.
