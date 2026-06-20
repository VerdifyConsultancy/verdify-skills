# Prompt 06 — Decompose Work into Lanes

## Variables

- `{{SPRINT_ID}}`
- `{{MAX_CONCURRENT_LANES}}`
- `{{AVAILABLE_AGENT_PROFILES}}`

## Prompt

Decompose the approved GitHub issue backlog for sprint `{{SPRINT_ID}}` into the smallest safe set of logical lanes, subject to `{{MAX_CONCURRENT_LANES}}` and `{{AVAILABLE_AGENT_PROFILES}}`.

A lane is a bounded stream of responsibility. A Git worktree is the isolation mechanism used to execute it. Do not equate the two.

Each included GitHub issue must be assigned to exactly one lane. A lane may contain multiple GitHub issues only when they share one coherent objective, one feature branch/PR boundary, and one validation path. Do not assign one issue to multiple lanes; split the GitHub issue first if multiple agents must work independently.

### Optimize for

- coherent domain ownership;
- clear GitHub issue ownership;
- independently testable outcomes;
- minimal shared interfaces and files;
- minimal merge and deployment coupling;
- clear acceptance criteria;
- safe parallelism;
- understandable human supervision.

### Analyze collision across

- source and test paths;
- APIs, message contracts, schemas, and generated clients;
- database models and migrations;
- shared configuration and feature flags;
- infrastructure and deployment resources;
- common fixtures, snapshots, and build files;
- specifications, architecture docs, and issue dependencies;
- GitHub issue dependencies and PR merge order;
- rollout and backward-compatibility requirements.

### Rules

1. Give each lane one primary objective.
2. Assign every included GitHub issue to exactly one lane.
3. Do not create a lane simply because a directory exists.
4. Prefer serial dependency over unsafe parallelism.
5. If two lanes must modify the same contract, define who owns the contract and how the dependent lane consumes it.
6. Identify integration-only work separately when it cannot be owned by a single lane.
7. Keep high-risk migrations and cross-cutting architecture changes explicit.
8. Flag lanes that are too broad, too small, or insufficiently specified.
9. Include a human-readable explanation of why the topology is safer than plausible alternatives.

For each lane propose:

- lane ID and title;
- primary outcome;
- assigned GitHub issue IDs/URLs;
- owned domains and paths;
- prohibited or coordination-required paths;
- owned interfaces/contracts;
- inputs and outputs;
- hard and soft dependencies;
- acceptance criteria;
- validation commands;
- risk and escalation conditions;
- recommended agent profile;
- branch/worktree naming;
- expected pull request naming and issue links;
- expected critic profile.

Create:

- `.verdify/sprints/{{SPRINT_ID}}/plan/lane-topology.yaml`
- `.verdify/sprints/{{SPRINT_ID}}/plan/lane-topology.md`
- `.verdify/sprints/{{SPRINT_ID}}/plan/conflict-matrix.md`

Include a dependency DAG and a wave plan showing which lanes can start immediately and which must wait.

Conclude with one of:

- `SAFE_TO_APPROVE`
- `REQUIRES_SCOPE_REDUCTION`
- `REQUIRES_ARCHITECTURE_DECISION`
- `UNSAFE_TO_PARALLELIZE`
