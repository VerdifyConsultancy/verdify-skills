# Autonomous Development Platform Best Practices

Date: 2026-07-10
Question cluster: `ADP-001`
Covered intake items: `TR-001` through `TR-011` from `SRC-NS-003`
Method: Brave Search API discovery using the configured local credential,
followed by primary-source review. Brave result ordering was not treated as
evidence of authority.

## Research Questions

1. Which orchestration pattern best fits a long-running software-development
   outer loop with bounded inner delivery loops?
2. What state, recovery, evaluation, observability, security, provenance, and
   human-control properties are required before calling the loop autonomous?
3. How should those practices change the execution sequence for Verdify Skills,
   Agent Platform, Orbit, and Gravity?

## Brave Queries

- `site:anthropic.com/research OR site:anthropic.com/engineering building effective agents workflows autonomy`
- `site:openai.com agents SDK evals tracing guardrails official`
- `site:docs.temporal.io durable execution AI agents workflows official`
- `site:langchain-ai.github.io/langgraph durable execution human in the loop official`
- `site:modelcontextprotocol.io specification authorization security official MCP`
- `site:nist.gov generative AI profile autonomous agents risk management official`
- `site:opentelemetry.io generative AI agent spans semantic conventions official`
- `site:slsa.dev provenance software supply chain official`
- `site:github.blog OR site:docs.github.com coding agents secure software development lifecycle official`
- `software engineering agents long horizon task reliability benchmark primary research SWE-bench METR`

The search returned useful primary sources from Anthropic, OpenAI, Temporal,
MCP, NIST, OpenTelemetry, SLSA, and GitHub. A future-dated MCP release-candidate
result and secondary summaries were excluded from decision support.

## Primary Sources

| Source | Type | Observed | Relevant finding |
| --- | --- | --- | --- |
| [Anthropic: Building effective agents](https://www.anthropic.com/engineering/building-effective-agents) | provider engineering guidance | 2026-07-10 | Start with simple composable workflows. Use routing, parallel workers, orchestrator-workers, or evaluator-optimizer only where the task requires them. Autonomous agents need environmental ground truth, stopping conditions, sandboxing, testing, and human checkpoints. |
| [Anthropic: Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) | provider engineering experiment | 2026-07-10 | Fresh sessions need a comprehensive requirement list, incremental single-feature progress, clean Git state, descriptive commits, a durable progress record, and a baseline end-to-end test before new work. |
| [Anthropic: Measuring AI agent autonomy in practice](https://www.anthropic.com/research/measuring-agent-autonomy) | provider empirical research | 2026-07-10 | Effective oversight shifts from approving every action to monitoring and intervening. Product developers need post-deployment monitoring, trustworthy visibility, simple interruption, uncertainty-aware stops, and risk-sensitive autonomy. |
| [Anthropic: Demystifying evals for AI agents](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents) | provider evaluation guidance | 2026-07-10 | Evaluate outcomes and traces with deterministic, model, and human graders. Start with 20-50 real failure cases, separate capability from regression suites, isolate trials, and combine pre-deployment evals with production monitoring and calibrated human review. |
| [OpenAI: Evaluate agent workflows](https://developers.openai.com/api/docs/guides/agent-evals) | official provider documentation | 2026-07-10 | End-to-end traces should include model calls, tool calls, guardrails, and handoffs. Trace grading diagnoses workflow failures; datasets and repeatable eval runs protect quality over time. |
| [OpenAI: Building governed AI agents](https://developers.openai.com/cookbook/examples/partners/agentic_governance_guide/agentic_governance_cookbook) | official provider cookbook | 2026-07-10 | Centralize policy as versioned infrastructure, distribute capability through packages and registries, layer guardrails, trace behavior, test policies in CI, and apply controls proportionally to risk. |
| [Temporal: Understanding Temporal](https://docs.temporal.io/evaluate/understanding-temporal) | official durable-workflow documentation | 2026-07-10 | Durable event history, replay, configurable retries, timers, worker separation, and visibility allow long-lived work to resume from the last successful point after failure. |
| [Temporal: Human-in-the-loop AI agent](https://docs.temporal.io/ai-cookbook/human-in-the-loop-python) | official implementation pattern | 2026-07-10 | Risky actions can pause durably for an external approval signal, time out predictably, consume no waiting compute, and retain a complete audit trail. |
| [MCP: Security best practices](https://modelcontextprotocol.io/docs/tutorials/security/security_best_practices) | official protocol security guidance | 2026-07-10 | Prevent confused-deputy and token-passthrough behavior, validate audience and authorization server-side, start with minimal scopes, elevate progressively, sandbox local processes, and correlate authorization events. |
| [NIST AI RMF Generative AI Profile](https://www.nist.gov/publications/artificial-intelligence-risk-management-framework-generative-artificial-intelligence) | government risk-management profile | 2026-07-10 | Trustworthiness considerations belong across design, development, use, and evaluation rather than at a final launch review. |
| [NIST AI Agent Standards Initiative](https://www.nist.gov/artificial-intelligence/ai-agent-standards-initiative) | government standards initiative | 2026-07-10 | Agent adoption depends on trusted interoperability, identity, authorization, security evaluation, and open protocol work. |
| [OpenTelemetry GenAI semantic conventions](https://github.com/open-telemetry/semantic-conventions-genai) | open standard working repository | 2026-07-10 | GenAI clients, agents, model calls, metrics, events, and MCP operations can share a portable telemetry vocabulary rather than project-specific log strings. |
| [SLSA v1.2](https://slsa.dev/spec/v1.2/) | approved industry specification | 2026-07-10 | Build and source provenance should let consumers trace an artifact to source and verify increasing supply-chain guarantees. |
| [GitHub: Integrating agentic AI into the SDLC](https://docs.github.com/en/enterprise-cloud@latest/copilot/tutorials/roll-out-at-scale/enable-developers/integrate-ai-agents) | official platform guidance | 2026-07-10 | Asynchronous agent work should remain integrated with issues, shared context, tests, authorization, pull requests, review, security, and measurable rollout rather than becoming a parallel delivery system. |

## Source-Backed Observations And Verdify Synthesis

Each numbered item separates an observation made by the cited primary sources
from a Verdify-specific inference or proposal. Only the source-backed
observations are eligible for evidence registration.

### 1. Combine simple workflow and agent patterns deliberately

Source-backed observation: Anthropic distinguishes workflows that follow
predefined code paths from agents that dynamically direct their own process,
and recommends choosing the simplest pattern that fits the task. Temporal
documents durable event history, replay, worker separation, timers, retries,
and visibility as mechanisms for recovering long-lived workflows after failure.

Verdify inference/proposal: keep deterministic lifecycle state and GitHub as the
durable spine, use bounded model sessions as replaceable workers, and compare
the current controller loop with a proven workflow engine under the same
recovery tests. The sources do not prescribe this Verdify architecture.

### 2. Make long-running work reconstructable

Source-backed observation: Anthropic's long-running-agent experiment observed
oversized partial implementations and premature declarations of completion.
Its tested harness used a durable requirement list, Git history and progress
records, one-feature-at-a-time changes, clean descriptive commits, and a
baseline end-to-end test to make sessions reconstructable.

Verdify inference/proposal: preserve the issue/lane/worktree/PR unit, refresh
`PilotProject` authority before ranking work, and require every turn to leave a
clean checkpoint or explicit durable failure. A fresh heartbeat is not progress.

### 3. Evaluate outcomes and traces

Source-backed observation: Anthropic and OpenAI recommend evaluating
environment outcomes and execution traces with deterministic, model, and human
graders, repeatable datasets, pre-deployment evaluations, production
monitoring, and calibrated human review.

Verdify inference/proposal: put issues #71, #73, #74, and #75 on the critical
path, seed the evaluator with real failures, and require both fixture-backed
portfolio evaluation and live runtime acceptance for the first integrated run.

### 4. Scale oversight by risk

Source-backed observation: Anthropic's empirical autonomy research describes
effective oversight as monitoring and intervention supported by trustworthy
visibility, simple interruption, uncertainty-aware stops, and risk-sensitive
autonomy. Temporal documents durable external approval signals, predictable
timeouts, and audit trails for risky actions.

Verdify inference/proposal: use explicit Observe, Lightweight, Standard, and
Protected classes. Low-risk reversible work may proceed automatically only
with scope, budget, verifier, interruption, and rollback; protected work pauses
at durable typed gates owned by the authority matrix.

### 5. Enforce identity and authorization server-side

Source-backed observation: MCP security guidance forbids token passthrough,
requires validation that tokens were issued to the MCP server, recommends
progressive least-privilege scopes and server-side authorization, and calls for
correlated authorization logs. NIST identifies trusted interoperability,
identity, authorization, and security evaluation as agent-adoption concerns.

Verdify inference/proposal: issue #12 should define versioned capability and
operation schemas, idempotency keys, typed results, and supported dispatch
strategies. These interface details are local requirements derived from the
broader guidance, not requirements stated by MCP or NIST.

### 6. Use a portable trace vocabulary

Source-backed observation: OpenTelemetry's GenAI semantic conventions provide
a shared vocabulary for GenAI clients, agents, model calls, events, metrics,
and MCP operations.

Verdify inference/proposal: use one correlation ID across `PilotProject`,
controller event, lane, session, PR, workflow, deployment, Gravity query, Orbit
brief, human gate, and outcome. Pin the evolving convention version.

### 7. Preserve artifact provenance

Source-backed observation: SLSA provenance links artifacts to source and build
processes so consumers can verify software supply-chain guarantees.

Verdify inference/proposal: extend the exact-artifact discipline from release
1.3.0 to runtime bundles and agent-authored outputs. Gravity citation
resolution and typed degraded or denied evidence are separate Verdify product
requirements, not SLSA claims.

### 8. Expand incrementally

Source-backed observation: Anthropic recommends starting with simple composable
patterns and adding complexity only when it demonstrably improves outcomes.
GitHub guidance keeps asynchronous agent work integrated with issues, shared
context, tests, authorization, pull requests, review, security, and measured
rollout.

Verdify inference/proposal: apply that guidance to the locked Verdify North Star
by proving one four-project vertical slice before fleet or customer rollout.
The sources do not identify Verdify's four projects or prescribe this sequence.

## Verdify Options Considered

| Option | Strength | Failure mode | Decision |
| --- | --- | --- | --- |
| One free-running root model with shell and cluster access | Fast to prototype | State loss, unclear authority, compounding error, poor recovery | Reject as production outer loop. |
| Fully deterministic workflow with no model-directed routing | Predictable and testable | Cannot adapt decomposition and diagnosis to open-ended software work | Reject as complete solution. |
| Durable deterministic spine plus bounded model workers | Recoverable, inspectable, adaptive where needed | Requires contract, telemetry, and eval work | Recommended. |
| Build all four projects broadly in parallel before integration | Maximizes local activity | Integration and trust failures appear late | Reject. |
| Prove one four-project vertical slice, then expand | Early integration evidence and reusable regression suite | Initial slice must be chosen narrowly | Recommended. |
| Keep the custom loop substrate indefinitely | Avoids migration | Reimplements replay, retries, signals, timers, and visibility | Keep only through a time-boxed build-versus-adopt test. |
| Adopt a durable workflow engine immediately | Proven execution semantics | Migration cost and premature framework commitment | Do not decide without a recovery spike and operator fit test. |

## Verdify Proposed Default

Use a durable deterministic portfolio and lifecycle spine with bounded model
workers. Preserve GitHub and project-owned artifacts as authority. Automate
low-risk reversible work after objective, budget, verifier, monitoring,
intervention, and rollback are present. Retain durable typed gates for protected
decisions. Prove the model through one integrated four-project vertical slice,
then expand by replaying the same conformance and regression suite.

Confidence: high for the operating principles; medium for the durable-execution
technology choice until the current Agent Platform loop and a proven workflow
engine are compared with the same failure/recovery test.

## Human Or Protected Decisions

- No new North Star decision is required; iteration 25 already authorizes the
  four-project root-planner model.
- Jason retains North Star lock authority. Release, production, connector,
  personal-data, security-boundary, and destructive decisions retain their
  separately configured owners.
- Choosing or migrating the durable workflow engine is architecture-significant
  and requires a recorded architecture decision after the spike.

## Claims Ready For Evidence Registration

- Anthropic distinguishes predefined workflows from model-directed agents and
  recommends using the simplest agentic pattern that fits the task.
- Long-running-agent harness guidance uses incremental tasks, durable
  requirements and progress records, clean Git checkpoints, and end-to-end
  verification across sessions.
- Durable workflow execution uses persisted event history, replay, worker
  separation, retries, timers, and visibility to recover after failures.
- Agent evaluation guidance combines outcome grading, trace inspection,
  repeatable datasets, pre-deployment evaluations, production monitoring, and
  calibrated human review.
- Effective autonomy oversight emphasizes risk-sensitive autonomy, trustworthy
  visibility, uncertainty-aware stops, and simple human interruption.
- Secure MCP integrations should reject token passthrough, validate token
  audience, enforce server-side authorization, minimize scopes, preserve
  identity boundaries, and correlate authorization events.
- Portable GenAI telemetry conventions cover agents, model calls, events,
  metrics, and MCP operations; SLSA provenance links artifacts to sources and
  build processes.

The deterministic-spine choice, Verdify operation-version/idempotency/typed-
failure contract, and four-project vertical-slice sequence are Verdify
inferences or proposals. They are intentionally excluded from evidence
registration.

## Limitations

- Provider guidance reflects each provider's products and should not be treated
  as a mandate to adopt its framework.
- OpenTelemetry GenAI semantic conventions are actively evolving and should be
  pinned to an explicit version when implemented.
- The research establishes operating principles, not the current health of the
  four local projects; current-state audits and live probes supply that evidence.
- No destructive, private-data, credential, or production mutation was used.
