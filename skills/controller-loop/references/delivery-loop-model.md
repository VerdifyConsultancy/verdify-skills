# Delivery loop model, decision rights, and glossary

Canonical description of how the Verdify lifecycle skills compose into runtime
loops. Decisions recorded in ADR-0011 through ADR-0018.

## The wave is an envelope, not a loop

A **wave** is a versioned, bounded delivery envelope (stories, committed tasks,
dependencies, risk limits, exit evidence) that moves through one durable state
machine owned by the deterministic controller:

```text
Observe -> DraftWave -> Approve -> Execute -> Verify -> Integrate
        -> DeployPreview -> Review -> Accept
```

`Replan` (dependency or scope invalidated) and `Escalate` (risk, retry, cost, or
stagnation limit) are explicit transitions, not informal jumps. Planning and
implementation are phases of this one lifecycle. Once approved, the wave is
versioned; material scope change needs a wave amendment (audit record), a task
decommit, or a replanned successor wave.

## Nested loops

- **L0 North Star loop** (per repo / major reset): research + human conversation
  until an approved PR locks `NORTHSTAR_PRODUCT.md` / `NORTHSTAR_ARCHITECTURE.md`
  as plan of record. Skills: `northstar-research-ingest`, `northstar-planning`,
  `northstar-interview`, `northstar-question-resolution`.
- **L1 Wave lifecycle** (outermost runtime): the human/Orbit review cadence; the
  state machine above. Skills: `controller-loop` (+ `state-of-union`).
- **L2 Planning phase**: rolling-wave planning pass (see
  `../../sprint-planning/references/rolling-wave-planning.md`). Skills:
  `state-of-union` -> `sprint-planning` (+ `issue-triage`).
- **L3 Execution phase**: the reconciler schedules ready tasks into lanes, runs
  workers, verifies, integrates onto the wave branch. Skills:
  `sprint-orchestrator` + `controller-loop`, gated by `independent-critic` and
  `release-verification`.
- **L4 Lane/task loop** (innermost): one worker against one task contract:
  Orient -> LocalPlan -> ReproduceOrTest -> Implement -> LocalChecks ->
  SelfReview -> CommitCandidate -> IndependentReview. Worker output is a
  candidate; it never self-certifies. Skill: `lane-delivery`.

## Controller is a reconciler

On each normalized worker event the controller: loads durable state; validates
the event against state and policy; applies an idempotent transition; schedules
newly-ready tasks; enforces retry/cost/risk/time budgets; persists the decision
and evidence. Models propose; the control plane authorizes transitions. Polling
detects lost workers only.

## Sources of truth

- **Git** — approved intent: plans, ADRs, code, skills, acceptance specs.
- **GitHub** — backlog and delivery collaboration: issues, PRs, reviews,
  deployments.
- **Runtime state store** — execution state: claims, leases, attempts, events,
  costs, heartbeats, normalized provider state. (Agent Platform owned.)
- **CI and policy** — gate authority.

## Decision rights

| Decision | Authority |
| --- | --- |
| Product priority / North Star change | Human or delegated Orbit policy |
| Proposed wave objective and stories | Wave-planning agent (`sprint-planning`) |
| Approval of wave scope | Human initially; risk policy may auto-approve low-risk waves |
| Task decomposition and dependency DAG | Planning agent + deterministic validation |
| Assignment to lanes | Scheduler: readiness, path conflicts, risk, availability |
| Local implementation steps | Lane worker |
| Expansion/alteration of task scope | Controller via versioned change request; never silently by the worker |
| Whether a task is a completion candidate | Worker may report `candidate_done` |
| Whether a task is actually complete | Deterministic checks + independent verifier |
| Whether a wave is technically releasable | Integration CI, security, acceptance gates |
| Whether a wave meets product intent | Human or authorized Orbit reviewer |
| Production deployment | Risk policy; high-risk requires explicit human approval |

## Glossary

- **Milestone** — observable capability/outcome that can be demonstrated and
  accepted. Never a branch or worktree.
- **Wave** — approved bounded delivery envelope and review cadence; owns scope.
- **User story** — integrated user-observable behavior with acceptance scenarios;
  generally vertical even when it crosses lanes.
- **Task / issue** — smallest independently implementable, reviewable, mergeable
  unit; need not equal one method or file.
- **Lane** — temporary per-wave write-conflict partition one worker can own
  without colliding with other active writers (ADR-0013).
- **Attempt** — one worker run against a task contract; a failed attempt does not
  change the task's committed objective.
- **Evidence** — test outputs, builds, screenshots, security findings, review
  results, deployment identifiers proving acceptance.

"Sprint" is retained as a skill/directory name (`sprint-planning`,
`sprint-orchestrator`, `.agent-workflow/sprints/`) but is retired as a
scope-owning concept; a "sprint" artifact is the durable record of one wave's
execution (ADR-0017).
