# ADR-0015: Two-tier verification with no self-certification

- Status: accepted
- Date: 2026-06-25

## Context

In the transcript, James wanted a lane to do "one straight shot" without adversarial
audit. The Common Operating Contract forbids self-certification (`PRQ-012`). The
recommended-model critique requires every candidate to pass deterministic checks plus
fresh-context review, and adds that the cumulative wave diff also needs review because
individually routine tasks can compose into vulnerable or off-intent end states.

## Decision

Verification is **two-tier**, and the implementer never certifies itself.

1. **Per-task:** a worker emits `candidate_done` with evidence. Deterministic checks
   (tests, schemas, static analysis, build, policy) plus a **fresh-context independent
   verifier** that sees the diff and the task contract — not the implementer's reasoning —
   decide whether the task is complete.
2. **Per-wave:** a **cumulative wave-diff review** (security and intent) at integration,
   over the whole intended end state rather than isolated task PRs.

Evidence strength order: deterministic checks -> behavior/browser evidence -> fresh-context
review against the task contract -> LLM semantic judgment for not-yet-testable requirements
-> human review for ambiguity or high risk. Bounded repair: a failed verification with
remaining budget produces a focused repair attempt; stop on pass, attempt limit, a
no-longer-changing remaining delta, or a human-decision-required condition.

## Consequences

`independent-critic` gains an explicit per-task fresh-context responsibility **and** a
cumulative wave-review responsibility. `lane-delivery` worker output is candidate-only
(`candidate_done`), never integrated or complete. This keeps `PRQ-012` intact and
reconciles James's single-pass lane coding with mandatory independent review at the task
and wave boundaries. The MOSAIC-Bench compositional-vulnerability citation in the source is
unverified and post-cutoff; the cumulative-review requirement stands on its design merits
regardless.

- Evidence: `NSE-20260625-recommended-event-driven-sdlc-control-plane`,
  `NSE-20260625-walk-transcript-delivery-loop-topology`,
  `NSE-20260624-agentic-loop-sdlc-best-practices`.
- Relates to: ADR-0011, ADR-0016; `PRQ-012`, `PRQ-004`, `ARQ-029`; `#43`.
