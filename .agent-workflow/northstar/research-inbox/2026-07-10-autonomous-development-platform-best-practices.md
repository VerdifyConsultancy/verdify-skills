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

## Source-Backed Findings

### 1. Use a deterministic workflow spine with agentic decision points

The outer loop should not be one unconstrained model conversation. Deterministic
code should own persisted state, scheduling, retries, budgets, authorization,
timeouts, and transitions. Models should perform the parts that benefit from
open-ended reasoning: evidence synthesis, decomposition, issue selection,
implementation, criticism, and diagnosis. This matches Anthropic's distinction
between predictable workflows and adaptive agents and Temporal's separation of
durable workflow state from workers.

Verdify implication: keep the typed lifecycle and GitHub control plane. Make
`controller-loop` the durable portfolio/workflow state machine and use model
sessions as replaceable workers. Do not make Orbit, Codex, Claude, OpenClaw, or
Hermes the sole state holder.

### 2. Make every long-running turn incremental, reconstructable, and clean

Long-running agents fail when they attempt too much, inherit unclear partial
state, or declare completion from superficial progress. A new session should
begin by reading authoritative state, Git history, the failing acceptance set,
and a baseline health check. It should select one bounded outcome, leave a clean
commit or explicit failure record, and update durable progress for the next
session.

Verdify implication: the one-issue/lane/worktree/PR unit is an asset. Add a
portfolio resume-check and `PilotProject` refresh before ranking work; require
each inner turn to leave GitHub, lane state, session ledger, and runtime evidence
consistent. A fresh heartbeat is not progress.

### 3. Grade environment outcomes, not agent declarations

Tests and state checks must prove the resulting repository, deployment, API,
database, connector, or user-visible outcome. Trace grading explains how the
agent got there, but a clean narrative or `status: complete` is not proof. Start
with a small suite built from real failures, then grow separate capability and
regression suites. Combine deterministic checks, rubric-based review, and
periodic human calibration.

Verdify implication: issues #71, #73, #74, and #75 are on the critical path.
The first four-project slice needs a fixture-backed portfolio eval plus live
runtime acceptance, not only schema validation. Every production failure should
become a regression case when reproducible.

### 4. Scale autonomy by consequence, visibility, and reversibility

Human approval on every tool call creates friction and is not the same as
effective oversight. Low-risk, reversible actions can run automatically when
their scope, budget, verifier, rollback, monitoring, and interruption controls
are explicit. Protected, privileged, personal-data, release, production,
destructive, or irreversible actions should pause at durable typed gates with
timeouts and audit trails.

Verdify implication: issue #70 should introduce a change/risk class fast path,
while protected decisions retain the authority matrix. The platform needs an
operator-visible interrupt/read-only control and stop-reason telemetry before
long unattended runs are trustworthy.

### 5. Treat capability, identity, and policy as versioned contracts

Interoperable agents require explicit operation versions, schemas, identities,
scopes, authorization checks, idempotency, failure results, and audit. MCP
guidance specifically rejects token passthrough and broad up-front scopes. The
provider, not the prompt, must enforce authority.

Verdify implication: issue #12 is a P0 dependency. Agent Platform capabilities
must advertise supported dispatch strategies and fail closed. Orbit connector
identity must be separate from fleet actuation. Gravity authorization and
citations must survive through its HTTP and consumer-side MCP interfaces.

### 6. Use one trace vocabulary across portfolio, workflow, and tool layers

Autonomy cannot be managed from pod readiness and free-form logs. A useful trace
links portfolio decision, issue, lane, session, model/runtime bundle, tool calls,
policy decisions, Git commits, CI, deployment, evidence queries, human gates,
cost, latency, errors, stop reason, and outcome. OpenTelemetry's GenAI/MCP work
provides a portable base; GitHub and Kubernetes identities supply delivery and
runtime joins.

Verdify implication: implement correlation IDs that connect `PilotProject`,
controller event, lane, PR, workflow run, deployment, Gravity query, Orbit brief,
and outcome. Distinguish scheduler liveness, worker success, useful progress,
blocked state, and intervention availability.

### 7. Make provenance and knowledge citations acceptance criteria

The platform must know which source, prompt/skill/tool/model/runtime bundle, and
artifact produced an outcome. SLSA-style provenance supports package trust;
Gravity-style resolvable citations support knowledge trust. An evidence result
without a resolvable source should be a typed degraded or denied outcome, not a
successful verified answer.

Verdify implication: extend the exact-artifact discipline proven by release
1.3.0 to runtime bundles, agent-authored artifacts, and cross-project evidence.
Orbit reports and root-planner decisions should retain source, freshness,
tenant, ACL, and query identifiers.

### 8. Prove one integrated slice before fleet-wide autonomy

The practices above favor a thin vertical slice over simultaneous broad
implementation. The slice should exercise planning, dispatch, execution,
criticism, CI/CD, deployment, cited knowledge, governed reporting, outcome
acceptance, recovery, and learning feedback. Only then should the same contract
fan out to more repositories or customer work.

Verdify implication: the first portfolio outcome is not "implement all open
issues." It is "one platform improvement traverses all four pilots and the loop
can reconstruct, verify, report, recover, and select the next action without
private chat state."

## Options Considered

| Option | Strength | Failure mode | Decision |
| --- | --- | --- | --- |
| One free-running root model with shell and cluster access | Fast to prototype | State loss, unclear authority, compounding error, poor recovery | Reject as production outer loop. |
| Fully deterministic workflow with no model-directed routing | Predictable and testable | Cannot adapt decomposition and diagnosis to open-ended software work | Reject as complete solution. |
| Durable deterministic spine plus bounded model workers | Recoverable, inspectable, adaptive where needed | Requires contract, telemetry, and eval work | Recommended. |
| Build all four projects broadly in parallel before integration | Maximizes local activity | Integration and trust failures appear late | Reject. |
| Prove one four-project vertical slice, then expand | Early integration evidence and reusable regression suite | Initial slice must be chosen narrowly | Recommended. |
| Keep the custom loop substrate indefinitely | Avoids migration | Reimplements replay, retries, signals, timers, and visibility | Keep only through a time-boxed build-versus-adopt test. |
| Adopt a durable workflow engine immediately | Proven execution semantics | Migration cost and premature framework commitment | Do not decide without a recovery spike and operator fit test. |

## Recommended Default

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

- Reliable long-running agents need incremental tasks, durable progress,
  authoritative reconstruction, clean checkpoints, and end-to-end verification.
- A deterministic workflow spine plus bounded agent workers is a stronger fit
  than either a free-running root model or a fully hardcoded workflow.
- Agent quality requires outcome and trace evaluation, production monitoring,
  and periodic human calibration; schema validity alone is insufficient.
- Autonomy should be risk-proportional and intervention-ready rather than gated
  by per-action approval or enabled by universal auto-approval.
- Cross-project tools require versioned capability, identity, authorization,
  least-privilege scope, telemetry, and typed failure contracts.
- The first safe scale milestone is one fully verified four-project vertical
  slice, followed by fleet and customer rollout through the same contract.

## Limitations

- Provider guidance reflects each provider's products and should not be treated
  as a mandate to adopt its framework.
- OpenTelemetry GenAI semantic conventions are actively evolving and should be
  pinned to an explicit version when implemented.
- The research establishes operating principles, not the current health of the
  four local projects; current-state audits and live probes supply that evidence.
- No destructive, private-data, credential, or production mutation was used.
