# Rolling-wave planning, wave envelope, and dynamic lanes

How a wave is planned. Decisions: ADR-0011 (wave envelope), ADR-0013 (dynamic
lanes), ADR-0014 (rolling-wave), ADR-0017 (vocabulary). Contracts:
`../../schemas/wave-contract.schema.yaml`, `../../schemas/task-contract.schema.yaml`.

## Rolling-wave principle

Maintain complete **outcome-level** traceability across the whole roadmap (North
Star -> milestone -> wave), but decompose only the **next one or two waves** to
issue/task-level contracts. Exhaustive decomposition of every hypothetical future
feature goes stale. Traceability must be complete for what is currently
committed, not falsely detailed for what is not.

## Planning-pass order

Issues are an **output** of planning, not its raw input:

1. Snapshot facts: merged code, open PRs, CI state, telemetry, feedback, backlog,
   unresolved decisions, current North Star.
2. Select the next outcome; define the wave objective.
3. Define user stories and their acceptance evidence.
4. Discover the implementation delta.
5. Derive or update tasks and dependencies (the task DAG).
6. Compute write conflicts, sequencing, risk, and likely capacity.
7. Materialize or update GitHub issues.
8. Produce an immutable proposed wave plan / `WaveContract`.
9. Approve it. 10. Execute it.

## Wave envelope

A `WaveContract` records: objective, milestone links, user stories with
acceptance, committed tasks, lane partition policy, exit gates
(`all_committed_tasks_terminal`, `integration_ci_green`,
`cumulative_security_review_passed`, `acceptance_scenarios_passed`,
`preview_deployment_healthy`, `evidence_bundle_complete`), branch model (wave
integration branch), review, and approval mode. The `wave-release-plan.yaml`
remains the deployment facet for deployment-affecting waves.

## Dynamic lanes

A **lane is a temporary, per-wave write-conflict partition**, not a permanent
codebase silo. Derive lanes from the task DAG and the expected write-set /
file-conflict graph, seeded from functional areas (API, frontend, database,
backend). Invariant: one active writer per worktree and branch; parallelize only
tasks whose dependencies are satisfied and whose expected write sets do not
conflict. Each task carries `write_scope.expected_paths` so the scheduler can
compute conflict-free partitions.

## Task contracts

A `TaskContract` is the committed unit: goal, non-goals, dependencies,
write_scope, acceptance (deterministic commands + behavior scenarios),
required_evidence, risk class, attempt budgets, and escalate_when. The planner
commits the scope; the worker chooses the implementation method; scope changes
become explicit, controller-authorized change requests.

## Scope ownership

The wave owns committed scope; the planner owns sequencing. A lane worker may
make a local implementation plan but cannot redefine committed scope or add
"while I'm here" work — that is a versioned change request or a replanned
successor wave (ADR-0011, ADR-0017).
