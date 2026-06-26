# ADR-0018: M0–M8 build order and the Skills/Platform layer boundary

- Status: accepted
- Date: 2026-06-25

## Context

The recommended-model critique prescribes a build order (M0 contracts/state machine
through M8 Orbit multi-repo) and warns that parallelism does not make an unreliable
single-agent loop reliable — "it makes the failures concurrent." The proposed architecture
overlaps the existing `jvallery/agents` platform (loop-runtime / loop-state epic `#1816`,
ArgoCD, dashboard API plus in-pod MCP), which is the subject of
`VerdifyConsultancy/verdify-skills#36`.

## Decision

1. **Hold the layer boundary** (reinforces `ARCH-013` and `NSQ-007`): verdify-skills owns
   lifecycle **method** — skills, typed contracts/schemas, gates, and durable artifacts;
   the Agent Platform (`jvallery/agents`) owns the control-plane **runtime** — the
   deterministic state machine, the durable event/state store, the DAG scheduler, the
   worker adapters, runtime leases, and telemetry. We do **not** build a parallel control
   plane in this repository; the control-plane specification lands as the resolution of
   `#36` against loop-runtime / loop-state.
2. **Adopt the M0–M8 build order** as the program sequence: M0 contracts + state machine;
   M1 single-task closed loop; M2 independent verification; M3 sequential wave; M4 parallel
   lanes; M5 provider parity; M6 risk-based autonomy; M7 learning + eval loop; M8 Orbit
   multi-repo. Prove correctness on one task before adding parallelism.
3. **Risk-based autonomy classes** (low / medium / high / critical) govern auto-integration
   versus human approval; worker agents hold no production credentials or broad repo-admin
   rights.

## Consequences

The current skills-hardening backlog is re-rooted so that M0 (these contracts) precedes
parallel-execution work. This ADR set delivers the M0 method-layer contracts
(`wave-contract`, `task-contract`, `worker-run-event` schemas plus the affected skill
specifications). Platform issues `jvallery/agents#1995`–`#2000` and `#1816` carry the
runtime. Program metrics track accepted outcomes (stories accepted, first-pass verifier
success, attempts per accepted task, escaped defects, human review minutes, cost per
accepted story), not agent activity (lines changed, turns, subagents spawned, issues
closed).

- Evidence: `NSE-20260625-recommended-event-driven-sdlc-control-plane`,
  `NSE-20260624-agentic-loop-sdlc-best-practices`,
  `NSE-20260623-agent-platform-sunshine-gravity-ip-priorities`.
- Relates to: ADR-0012, ADR-0016; `#36`, `#43`, `NSQ-007`, `NSQ-011`, `ARCH-013`.
