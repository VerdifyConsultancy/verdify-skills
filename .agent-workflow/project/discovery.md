# Project Discovery

Status: draft

The skills repository is the lifecycle package that should become capable of
turning transcript evidence into governed requirements, skills, loops, gates,
and implementation artifacts. The current source set supports moving from raw
North Star evidence into a draft project definition, but not yet into approved
architecture or sprint planning.

## Source Inventory

- `README.md`: current lifecycle and package model.
- `COMMON_OPERATING_CONTRACT.md`: universal operating rules and authority model.
- `docs/northstar/evidence/2026-06-23-walk-transcript-agent-platform-gravity-skills.md`: reported transcript evidence.
- `.agent-workflow/intake/transcript-replan.yaml`: routed transcript items, conflicts, and gate recommendations.
- `docs/decisions/ADR-0004-readiness-loop-skills.md`: readiness-loop skill decision.

## Known Decisions

- GitHub remains the backlog and delivery control plane.
- The package is being extended with readiness-loop skills.
- Gravity feature implementation remains blocked by readiness gates.

## Material Gaps

- Jason and James approval semantics for protected North Star changes.
- Branch/wave identity model.
- Repo/application/environment/namespace cardinality and RBAC.
- Gravity dependency on Onyx.

## Next Lifecycle Step

Continue `project-definition` in discovery, then requirements, product, and
design-surface modes. Do not route to architecture or sprint planning until the
project definition is approved or explicit gates are resolved.
