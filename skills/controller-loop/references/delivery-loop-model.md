# The delivery loop

One loop, run by the controller. Decisions: ADR-0011 through ADR-0018.

## The loop

```text
PLAN -> EXECUTE -> VERIFY -> REVIEW -> (feedback) -> PLAN
```

- **PLAN** — snapshot state and feedback into one bounded wave: stories, tasks, exit
  gates. Rolling-wave: decompose only the next wave or two (ADR-0014).
- **EXECUTE** — the controller schedules ready tasks into single-writer lanes and runs
  one worker per lane; workers propose candidates (ADR-0012, ADR-0016).
- **VERIFY** — deterministic checks plus a fresh critic per task; a cumulative
  security/intent review plus CI green for the whole wave (ADR-0015).
- **REVIEW** — a human (or Orbit) reviews the landed wave; their feedback restarts PLAN.

A wave is one turn of this loop — a versioned delivery envelope, not a loop of its own
(ADR-0011). `wave-contract.status` is exactly these beats: `planning -> executing ->
verifying -> review`, ending `accepted` or `blocked`.

## It recurses

A task is the same four beats one altitude down: plan locally -> implement -> check ->
independent review -> candidate. Above the loop sits one thing: the North Star, the
target the loop aims at, locked by an approved PR (ADR-0014).

## Three rules keep it tight

1. **Workers propose; the controller authorizes.** A worker emits one of
   `candidate_done | blocked | scope_change_requested | human_decision_required |
   retry_recommended`; the deterministic controller validates it against state and
   policy and commits the transition. Polling only detects lost workers. Nothing
   self-certifies (ADR-0012, ADR-0015).
2. **One writer per lane.** A lane is a per-wave partition of non-conflicting tasks,
   derived from the dependency and write-conflict graph (ADR-0013); ADR-0003 isolation
   retained.
3. **Three sources of truth.** Git = approved intent; GitHub = backlog/delivery; the
   runtime state store = execution state. CI and policy are the gates. The runtime is
   Agent Platform's; this repo owns the contracts (ADR-0018).

## Glossary

milestone = a demonstrable outcome (never a branch/worktree) · wave = one loop turn and
review cadence · story = vertical user behavior · task = smallest committed unit (one
issue, one PR, one fresh critic) · lane = per-wave writer partition · attempt = one
worker run. "Sprint" survives only as a skill/directory name (ADR-0017).

## Decision rights

Plan and sequence -> planner. Approve the wave -> human (risk policy may auto-approve
low-risk). Assign lanes -> scheduler. Implement -> worker. Authorize a scope change ->
controller. Task done -> checks plus fresh critic. Wave releasable -> CI, security,
acceptance. Accept the wave -> human/Orbit. Production -> risk policy, human for high
risk.
