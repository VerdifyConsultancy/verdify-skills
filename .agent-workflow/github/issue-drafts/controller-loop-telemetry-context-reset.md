# Controller-loop telemetry, context reset, and recovery contract

## What

Extend the `controller-loop` skill contract to cover the long-running repo controller operating model from the 2026-06-23 walk:

- outer loops, inner loops, and cron-triggered loops;
- durable state checkpoints before context reset;
- context-window reset thresholds and resume prompts;
- loop metrics and KPIs required in every plan;
- failure reporting and handoff to Agent Fleet observability.

## Why

The fleet will not be reliable if controller behavior only lives in model context. Loop state, metrics, and recovery semantics need to be specified once in the skills repo and consumed by repo controllers consistently.

## Acceptance

- `controller-loop` documents outer-loop, inner-loop, cron, context-reset, and resume semantics.
- Loop records include status, owner, repo, issue/PR references, checkpoint path, current objective, last action, last error, and next prompt.
- Plans are required to declare KPIs and loop metrics before dispatch.
- The skill defines the minimum metrics Agent Fleet must scrape or receive: loop starts, completions, failures, context resets, active child sessions, alert count, and last successful checkpoint.
- The skill defines prompt-injection-safe alert/resume prompt handling at the contract level.
- Tests or examples cover an interrupted loop, a context reset, and a failed outer loop that produces a recoverable status event.

## Related

- Evidence: `NSE-20260623-repo-controller-bootstrap-self-discovery`
- Runtime counterpart: Agent Fleet controller observability and recovery issue
