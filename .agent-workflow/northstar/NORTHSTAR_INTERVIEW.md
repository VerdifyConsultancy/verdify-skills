# North Star Interview

Status: `ready`
Generated at: `2026-06-23T04:30:38Z`
Evidence registry: `.agent-workflow/northstar/evidence-registry.yaml`
Product pair: `.agent-workflow/northstar/NORTHSTAR_PRODUCT.md`
Architecture pair: `.agent-workflow/northstar/NORTHSTAR_ARCHITECTURE.md`
Loop record: `.agent-workflow/northstar/northstar-artifacts.yaml`

## Review Summary

The North Star is coherent enough for review, but the newly registered
end-to-end SDLC evidence expands the product from a lifecycle skill package into
a product/service operating model. The strongest additions are:

- deterministic controller/workflow ownership rather than an LLM conversation as
  the outer loop;
- a Q&A/interview loop before final North Star lock;
- wave as an integrated product increment, with short-lived task branches and
  worktrees underneath;
- review-ready as immutable artifact plus deployed environment, provenance,
  exact human tests, telemetry, risks, and rollback;
- broader service surfaces: review inbox, diagnostics, session ledger,
  readiness certification, policy-as-code, supply-chain evidence, and versioned
  skill registry.

No question below records approval. Answers should be preserved as feedback and
routed through `northstar-planning` / `review-feedback` or `artifact-loop`.

## Proposed Priorities

| Priority | Proposed focus | Rationale | Evidence |
| --- | --- | --- | --- |
| P0 | Define the product/service boundary for Verdify Skills versus Agent Platform and Gravity. | The current North Star treats the skills repo as package plus workflow policy, while the new evidence frames a broader SDLC service model. | `northstar://evidence/NSE-20260623-end-to-end-agent-based-sdlc` |
| P0 | Decide whether the deterministic controller/workflow engine is a hard architecture invariant. | This affects controller-loop skill design, session ledger schema, state transitions, and what agents are allowed to infer. | `northstar://evidence/NSE-20260623-end-to-end-agent-based-sdlc` |
| P0 | Resolve task/branch/worktree/wave identity. | The new evidence gives a stronger default: short-lived task branches/worktrees; waves aggregate PRs and deployed evidence. | `northstar://evidence/NSE-20260623-end-to-end-agent-based-sdlc` |
| P0 | Confirm the human review and risk-gate model. | Earlier direction says only final North Star lock gates planning; the broader SDLC still needs risk-based implementation and promotion gates. | all registered evidence |
| P1 | Decide whether Backstage-like catalog concepts should be adopted or deferred. | Avoiding a custom catalog from scratch could shape Agent Platform integration and repo/application modeling. | `northstar://evidence/NSE-20260623-end-to-end-agent-based-sdlc` |
| P1 | Decide the minimum supply-chain evidence contract. | SBOM, provenance, signatures, policy checks, and immutable artifact promotion affect release-verification and platform-readiness scope. | `northstar://evidence/NSE-20260623-end-to-end-agent-based-sdlc` |
| P1 | Decide what a non-Gravity pilot must prove. | Platform readiness needs a concrete certification exercise before Gravity. | all registered evidence |
| P2 | Decide measurement strategy for throughput and quality. | DORA-style delivery measures should not become simplistic productivity scoring. | `northstar://evidence/NSE-20260623-end-to-end-agent-based-sdlc` |

## Decisions Ready For Human Review

| Decision ID | Decision | Proposed default | Priority | Affected IDs |
| --- | --- | --- | --- | --- |
| NQI-D001 | What is Verdify Skills' product boundary? | Verdify Skills owns reusable skills, prompts, schemas, artifact contracts, CLI workflows, and validation. Agent Platform owns hosted controller UX, terminals, environments, and runtime orchestration. Gravity is a gated customer. | P0 | `PRQ-001`, `PRQ-007`, `ARQ-007`, `ARCH-004` |
| NQI-D002 | Is deterministic controller architecture mandatory? | Yes. The controller-loop skill should specify a framework-neutral durable workflow engine that invokes bounded agents and never infers gates from chat. | P0 | `ARQ-005`, `ARCH-004`, `ARCH-009` |
| NQI-D003 | What is the canonical branch/wave model? | One short-lived task/issue branch and worktree by default; a wave is metadata plus integrated PRs, preview/review environment, milestone, and traceability. | P0 | `PRQ-006`, `PRQ-011`, `ARQ-006`, `ARQ-011` |
| NQI-D004 | How do planning gates relate to delivery gates? | The only North Star planning gate is final lock approval. Delivery still has risk-based gates for protected content, security, production, public APIs, destructive migrations, and policy exceptions. | P0 | `PRQ-002`, `PRQ-004`, `ARQ-002`, `ARCH-009` |
| NQI-D005 | Is the Q&A interview loop canonical? | Yes. Add `northstar-interview` as a canonical lifecycle skill between evidence/planning and final lock review. | P0 | `PRQ-001`, `PRQ-007`, `SURF-002` |
| NQI-D006 | Should Backstage concepts influence the Agent Platform catalog model? | Adopt the concepts as an architecture input, but do not commit to embedding Backstage until platform-readiness research validates fit. | P1 | `ARCH-005`, `IFACE-008` |
| NQI-D007 | What is the minimum supply-chain evidence for review-ready work? | Require immutable artifact identity, CI status, test report, preview deployment, rollback notes, and traceability first; add SBOM/provenance/signing as platform-readiness scope before production. | P1 | `PRQ-004`, `PRQ-006`, `ARQ-006`, `ARCH-009` |

## Architecture Options And Tradeoffs

| Topic | Option A | Option B | Proposed direction | Tradeoff |
| --- | --- | --- | --- | --- |
| Controller substrate | LangGraph-first durable agent graph | Framework-neutral workflow contract with LangGraph as candidate | Framework-neutral contract first | Keeps portability and avoids designing around one library; delays concrete implementation choices. |
| Software catalog | Build custom catalog in Agent Platform | Reuse/extend Backstage concepts | Reuse concepts, defer technology choice | Reduces product invention risk; requires integration research. |
| Wave identity | One branch per wave | Task branches/worktrees; wave as metadata and integration/review unit | Task branches/worktrees | Aligns with trunk-based development and current worktree policy; requires stronger traceability metadata. |
| Human gates | Gate every uncertain question | Gate only final North Star lock plus risk-based delivery changes | Final-lock-only for planning; risk gates for delivery | Keeps planning loop moving while preserving consequential human control. |
| Review-ready threshold | CI green is enough | CI plus deployed immutable artifact, evidence bundle, rollback, telemetry | Full evidence bundle | Slower to reach review-ready; prevents humans reviewing untestable branches. |
| Supply chain | Basic CI evidence | SBOM, provenance, signing, policy-as-code | Phase in through platform readiness | Avoids overloading the first package milestone; keeps production path credible. |
| Browser terminal | Always-on terminal per agent | Time-limited audited terminal with just-in-time authorization | JIT/audited only | Less convenient; materially safer. |

## Interview Questions

| ID | Priority | Question | Proposed default | Options / tradeoffs | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| NQI-001 | P0 | What should Verdify Skills own versus Agent Platform and Gravity? | Skills repo owns reusable lifecycle skills, schemas, CLI commands, artifact contracts, validation, and repo-local instructions. Agent Platform owns hosted controller UX/runtime, environment views, terminals, review inbox UI, and integrations. Gravity is a gated customer. | A: Skills-only package is simpler but may underspecify service behavior. B: Skills + service contract is more useful but broader. C: Full platform in skills repo is too coupled. | `PRQ-001`, `PRQ-007`, `ARCH-004` | `NSE-20260623-end-to-end-agent-based-sdlc` | approve default or edit boundaries |
| NQI-002 | P0 | Should the deterministic workflow controller be a non-negotiable architecture principle? | Yes. The controller owns states, gates, retries, permissions, history, and stop conditions; agents reason within states. | A: Hard invariant improves safety and auditability. B: LLM-led loop is faster to prototype but brittle. C: Hybrid is acceptable only if deterministic state remains authoritative. | `ARQ-005`, `ARCH-004`, `ARCH-009` | `NSE-20260623-end-to-end-agent-based-sdlc` | choose one |
| NQI-003 | P0 | Should `northstar-interview` become a canonical lifecycle skill before final lock? | Yes. Use it after new evidence or before final review when priorities, tradeoffs, or human decisions need structured answers. | A: Canonical skill increases package surface but makes the human planning interface repeatable. B: Keep as reference under `northstar-planning` reduces skill count but hides the workflow. | `PRQ-001`, `PRQ-007`, `SURF-002` | `NSE-20260623-end-to-end-agent-based-sdlc` | approve canonical skill or keep embedded |
| NQI-004 | P0 | Is the branch/wave identity default now resolved? | Yes: one short-lived task/issue branch and worktree; waves aggregate PRs, review environments, milestones, and traceability. | A: Resolves transcript conflict and aligns with worktree policy. B: Wave branches simplify labels but increase integration risk. | `PRQ-006`, `PRQ-011`, `ARQ-006`, `ARQ-011` | `NSE-20260623-end-to-end-agent-based-sdlc` | approve default or specify exception |
| NQI-005 | P0 | How should we express `DESIGN_COMMITTED` relative to the final-lock-only planning gate? | Treat final North Star lock for a milestone as the current `DESIGN_COMMITTED` equivalent; later protected changes use PR/review/change-control. | A: One term avoids confusion. B: Keep both terms if `DESIGN_COMMITTED` means a stronger downstream state. | `PRQ-002`, `ARQ-001`, `northstar-artifacts.yaml` | all registered evidence | choose term and semantics |
| NQI-006 | P0 | Which changes always need human review in the broader SDLC, even if ordinary planning questions do not gate? | Protected North Star content, security boundaries, permissions/secrets/identity, production networking, public APIs, destructive migrations, irreversible operations, privacy-sensitive data, material cost/architecture changes, and policy exceptions. | A: Risk-based gates reduce review burden. B: Human approval for every change is safer but slows throughput. C: More automation requires stronger policy evidence. | `PRQ-004`, `ARQ-002`, `ARCH-009` | `NSE-20260623-end-to-end-agent-based-sdlc` | approve list or modify |
| NQI-007 | P0 | What minimum proof must the non-Gravity pilot produce before Gravity readiness can pass? | A complete intake -> North Star/Q&A -> task planning -> worktree -> CI -> preview -> review -> fix/replan -> signoff loop with ledger, telemetry, rollback, and review evidence. | A: Full lifecycle proof is slower but credible. B: Narrower proof starts Gravity sooner but risks discovering platform flaws in Gravity. | `MS-004`, `WAVE-002`, `PRQ-003` | all registered evidence | approve default or define smaller pilot |
| NQI-008 | P1 | Should Backstage concepts be adopted for application/catalog modeling? | Use Backstage's component/system/API/resource model as a reference architecture, not a committed dependency yet. | A: Reference concepts reduce custom modeling risk. B: Embedding Backstage may accelerate UI but adds dependency and integration work. C: Custom model maximizes control but duplicates mature patterns. | `ARCH-005`, `IFACE-008` | `NSE-20260623-end-to-end-agent-based-sdlc` | choose reference, embed, or defer |
| NQI-009 | P1 | What supply-chain evidence is required for review-ready versus production-ready? | Review-ready requires immutable artifact ID, CI/test evidence, preview deployment, traceability, rollback notes. Production-ready adds SBOM, provenance, signatures, and policy verification. | A: Phase in keeps first pilot manageable. B: Full supply chain from day one improves trust but expands platform scope. | `PRQ-004`, `PRQ-006`, `ARQ-006`, `ARCH-009` | `NSE-20260623-end-to-end-agent-based-sdlc` | choose phased or full |
| NQI-010 | P1 | Should diagnostic access to production data be categorically prohibited for agents? | Agents should use read-only telemetry APIs and masked/replicated data; live customer data requires audited break-glass human authorization. | A: Stronger privacy and audit posture. B: Broader read access improves debugging speed but increases risk. | `ARQ-003`, `ARCH-007`, `ARCH-008` | `NSE-20260623-end-to-end-agent-based-sdlc` | approve default or specify exceptions |
| NQI-011 | P1 | What is the canonical review inbox output shape? | One packet per change: why, requirement IDs, architecture IDs, PRs/commits, CI, artifact digest, review URL, test procedure, expected results, telemetry, risks, migration/data effects, rollback, recommendation, and human questions. | A: Rich packet optimizes human attention. B: Minimal PR summary is faster but may miss evidence. | `SURF-004`, `IFACE-004`, `PRQ-004` | all registered evidence | approve fields or trim |
| NQI-012 | P1 | Should skill distribution include lockfiles and compatibility metadata? | Yes, but after the current package kernel: versioned skills plus compatibility metadata, conformance tests, and target-repo lockfiles. | A: Improves safe upgrades. B: Adds packaging complexity. | `PRQ-013`, `ARQ-014`, `WAVE-004` | `NSE-20260623-end-to-end-agent-based-sdlc` | approve roadmap item or defer |
| NQI-013 | P1 | Which personas are missing from the current product North Star? | Add or strengthen security/policy reviewer, auditor/historian, support/maintainability owner, developer experience owner, diagnostic user, and release owner. | A: More complete review coverage. B: More personas increase planning overhead. | `PRODUCT-002`, `PRODUCT-004`, `ARCH-002` | `NSE-20260623-end-to-end-agent-based-sdlc` | approve additions or select subset |
| NQI-014 | P1 | Should policy-as-code become a named architecture requirement? | Yes, as the enforcement layer for gates, RBAC, supply chain, environment promotion, and exceptions. | A: More enforceable than instructions. B: Requires choosing/adapting policy engine later. | `ARQ-002`, `ARQ-003`, `ARCH-009` | `NSE-20260623-end-to-end-agent-based-sdlc` | approve requirement or defer |
| NQI-015 | P2 | Which metrics should the platform optimize after pilots? | DORA-style flow plus quality, safety, rework, approval latency, rollback confidence, and North Star coverage. Avoid raw activity/productivity scoring. | A: Outcome-oriented metrics reduce perverse incentives. B: More detailed telemetry takes longer to build. | `ARCH-008`, `PRQ-015` | `NSE-20260623-end-to-end-agent-based-sdlc` | rank metrics |
| NQI-016 | P2 | Is one wave per day a goal, metric, or discarded hypothesis? | Keep it as a later optimization hypothesis only after actual pilot data exists. | A: Avoids premature speed target. B: A target can help sizing but may distort quality gates. | `WAVE-002`, `MS-004` | all registered evidence | choose hypothesis/goal/discard |

## Answer Capture Rules

- Preserve answers in this file or as a new registered evidence item.
- Accepted changes route to `$northstar-planning` in `review-feedback` or
  `artifact-loop` mode.
- Do not record final lock approval unless Jason/James explicitly provide it.
- When an answer changes protected scope, create a proposed North Star patch and
  leave `.agent-workflow/gates/northstar.yaml` open until approval.
