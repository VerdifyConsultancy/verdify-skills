# Verdify Skills Approved Architecture

The canonical architecture is `.agent-workflow/architecture/architecture.yaml`. This view summarizes its approved iteration-25 boundaries.

## System Boundary

Verdify Skills owns method, planning, contracts, validation, delivery coordination, review evidence, and package release behavior. GitHub owns backlog and delivery state. Agent Platform owns execution runtime. Orbit owns governed personal and engineering context. Gravity owns cited evidence processing and versioned access. Target repositories own their deployment and runtime state.

## Local Components

1. Governance and routing kernel.
2. Evidence and North Star subsystem.
3. Definition, architecture, and strategy subsystem.
4. Planning and hygiene subsystem.
5. Execution control subsystem.
6. Lane assurance subsystem.
7. Readiness integration subsystem.
8. Release and package subsystem.
9. Quality and enablement subsystem.

## External Components

- Agent Platform provider: capability-negotiated workers, sessions, resources, terminals, and events.
- Orbit context plane: governed connectors, classification, privacy, retention, audit, and approval.
- Gravity evidence service: versioned tenant-scoped read-only API/MCP, citations, provenance, and authorization.

## Runtime And Delivery

Roles run as short-lived CLI or agent sessions against a Git repository and GitHub. Durable planning and execution state lives in versioned artifacts and GitHub; machine-local leases live in the Git common directory. One coding or critic session owns one worktree. Normal work integrates to `dev`; only a generated, reviewed, new-version release promotion reaches `main`. Package publication and target deployment remain separate transactions.

## Security And Authority

Typed gates separate product, release, security, production, destructive, readiness, and outcome decisions. Workers and critics receive scoped authority. Current-head GitHub review is distinct from worker closeout and critic evidence. Secrets and sensitive reproduction detail stay outside Git and packages. External text is untrusted data. Agent Platform, Orbit, and Gravity enforce their owned identity and data boundaries.

## Architecture Risks

The principal risks are the shared CLI hotspot, ceremonial artifact drift, duplicate invalid release generation, reviewer availability, external interface drift, host-local package contamination (#130), and unsafe historical replay (#126). Module contracts and issue ownership make each risk explicit for later strategy and sprint selection.
