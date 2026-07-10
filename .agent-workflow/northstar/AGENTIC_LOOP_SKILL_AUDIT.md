# Agentic Loop Skill Audit

Status: `proposed`
Date: `2026-06-24`
Repository: `verdify-skills`
Evidence baseline:

- `northstar://evidence/NSE-20260624-agentic-loop-sdlc-best-practices`
- `northstar://evidence/NSE-20260623-agent-platform-live-state-audit`
- `northstar://evidence/NSE-20260623-agent-platform-control-implementation-be`
- `northstar://evidence/NSE-20260623-cicd-sdlc-agent-orchestration-human-governed-delivery`
- `northstar://evidence/NSE-20260623-repo-controller-bootstrap-self-discovery`

## Baseline Used

Existing Verdify operating decisions:

- GitHub Issues remain the backlog source of truth; GitHub pull requests remain
  the delivery control plane.
- The default implementation unit is one issue, lane, branch, worktree, worker
  session, and pull request.
- Lifecycle outputs must be durable `.agent-workflow` artifacts, not private
  chat state.
- North Star product and architecture artifacts are still `iterating`; the
  current router decision is `NORTHSTAR_ARTIFACTS_INCOMPLETE` with next skill
  `northstar-planning` and mode `artifact-loop`.
- Feature execution must pass repo hygiene, lane leasing, fresh critic review,
  and release verification; runtime deployment proof is separate from merge
  success.
- Gravity implementation remains blocked until both `platform-readiness` and
  `gravity-readiness` pass with live evidence.

Observed agents.vallery.net platform baseline for this audit:

- Kubernetes context `vallery` is reachable locally.
- `https://agents.vallery.net/` responds with an SSO redirect to
  `auth.vallery.net`.
- `agent-fleet-dashboard` is running in namespace `agent-fleet-dashboard` using
  image `registry.vallery.net/jvallery/agents-agent-fleet-dashboard@sha256:6e6bb219547f184d346ab654294766b05292e1818e85f11a9791d87b3e6a4771`.
- `agent-fleet-runners` has repository runner pods, including
  `repo-verdifyconsultancy-verdify-skills-0`, using
  `registry.vallery.net/jvallery/agents-agent-dev-runtime@sha256:ce592ceec234e7058d1d85d68a7ff3921a548538b05d45400c9acd87884757fa`.
- `agent-fleet-ci` has Argo Events/Workflows sensors for validation,
  GitOps/governance policy, local runner smoke, release policy, and secret
  scanning.
- The observed platform still lacks the live MCP/API controls this audit needs
  as gates: runtime bundle identity, spend/rate/retry budgets, emergency
  brake/read-only mode, tool-call and policy-denial traces, untrusted-input
  guardrails, and supply-chain provenance.

## Audit Standard

Each Verdify skill should operate as a bounded planner-executor-validator loop,
or explicitly hand off to one. The minimum loop contract is:

| Control | Required behavior |
| --- | --- |
| Objective and scope | Name the problem, acceptance signal, authority, non-goals, and owned artifacts before action. |
| Evidence | Reconstruct repo, GitHub, runtime, planning, and prior artifact state; label evidence versus inference. |
| Plan | Decompose into bounded steps with dependencies, stop conditions, and the next handoff. |
| Permissions | Use least privilege, explicit approval gates, scoped credentials, and mutation level. |
| Execution | Operate only inside the skill's authority; one issue/lane/branch/worktree/session/PR by default. |
| Observation | Record tool results, GitHub state, tests, CI, runtime evidence, and missing telemetry. |
| Validation | Run deterministic validation, schema checks, tests, canaries, or review gates before claims. |
| Repair | Reflect on failed validation, route fix-forward work, or replan without hiding context in chat. |
| Stop | Stop on done, budget exhausted, risk threshold exceeded, human rejection, stale authority, or unsafe access. |
| Telemetry | Preserve session, tool-call, policy, cost/rate, trace, and stop-reason evidence when the platform exposes it. |
| Reproducibility | Record skill/prompt/tool/model/runtime bundle identity where execution depends on an agent runtime. |
| Security | Treat untrusted content as data, never instructions; redact secrets; preserve auditability and rollback. |

## Overall Findings

| Area | Compliant now | Drift or missing control | Improvement path |
| --- | --- | --- | --- |
| Lifecycle spine | The package has 19 validating skills, a router, GitHub authority, durable `.agent-workflow` artifacts, issue/lane/branch/worktree/PR defaults, critic separation, and release verification. | Some planning docs still describe 17 skills or the older agents platform skill count; validator and docs disagree. | Resolve `VerdifyConsultancy/verdify-skills#19`, `#30`, `jvallery/agents#1987`, then make `config/lifecycle.yaml` or the chosen source the single lifecycle model. |
| Agentic-loop discipline | Most skills require reconstruction, canonical artifacts, validation, stop conditions, and handoff. | Several skills are written as procedures rather than explicit loop runtimes with budget, tool telemetry, retry policy, and incident stops. | Resolve `VerdifyConsultancy/verdify-skills#43` by adding a shared loop-control section or reference to every applicable skill: objective, evidence, plan, execute, observe, validate, repair, stop, budget, telemetry, handoff. |
| Evidence and planning | Research ingest, North Star planning, state-of-union, and sprint planning preserve evidence and GitHub traceability. | External attachments were not automatically detected by `route`; the new report had to be manually ingested before planning. | Teach router/planning intake to detect unregistered supplied evidence or require a pre-route evidence scan. |
| Security | The common contract forbids raw secrets, requires least privilege, and separates worker/critic/release roles. | Ingestion skills need stronger content-trust guidance; research ingest lacks hard secret scanning; worker credential isolation is asserted more than enforced. | Resolve skills issues `#16`, `#21`, `#34`; platform issue `jvallery/agents#1999` adds shared untrusted-input guardrails. |
| Runtime/platform grounding | Platform-readiness has the first Agent Platform control request schema and the sprint plan identifies real MCP/API drift. | Sprint-orchestrator still references idealized MCP dispatch paths and needs live agents.vallery.net contracts. | Resolve skills issues `#12`, `#33`, `#36`; platform issues `#1977`-`#1987` and `#1995`-`#2000`. |
| Testing/evals | `ruby scripts/validate-repo.rb` passes and there are schema/CLI tests. | Evals are mostly prose; hard behaviors, safety refusals, budget exhaustion, chaos, and live canaries are incomplete. | Resolve skills issues `#24`, `#25`; platform live canary `jvallery/agents#1986`. |
| Observability and recovery | Session ledger, review inbox, diagnostics, and platform control contracts exist as first artifacts or modes. | Tool-call traces, policy denials, cost/rate budgets, and emergency brake/read-only mode are not first-class live platform capabilities. | Platform issues `jvallery/agents#1996`, `#1997`, `#1998`; skills issue `#2` for controller recovery. |
| Reproducibility and provenance | Runtime image digests and artifact hashes are used in places. | Sessions do not yet record model/prompt/tool/skill/eval/image bundle identity; skill bundle and agent-authored artifact provenance are not a rollout gate. | Platform issues `jvallery/agents#1995`, `#2000`; integrate with session-ledger and canary evidence. |

## End-To-End SDLC Chain

| SDLC stage | Current skill chain | Required agentic-loop proof |
| --- | --- | --- |
| Ideation and requirements | `project-router` -> `transcript-replan` -> `northstar-research-ingest` -> `northstar-planning` | Registered evidence, routed transcript, source trust classification, questions answered or queued, no raw secrets. |
| Product design | `northstar-planning` -> `northstar-interview` -> `project-definition` | Product intent, users, stories, requirements, acceptance signals, final lock or explicit draft acceptance. |
| Architecture | `architecture-contracts` after approved/accepted definition | Components, interfaces, trust boundaries, deployment, observability, ADRs, module contracts, validation. |
| Strategy and backlog | `state-of-union` -> `issue-triage` when creating/updating GitHub issues | Fresh GitHub state, duplicate search, issue source of truth, candidate sequence, no private backlog. |
| Readiness | `repo-hygiene` -> `platform-readiness` -> `gravity-readiness` when Gravity is in scope | Repo compliance, platform/k3s/RBAC/secrets/CI/CD/observability gates, Gravity blocked until approved. |
| Sprint and wave planning | `sprint-planning` with `wave-release-planning` mode | Issue readiness, lane contracts, dependency order, review plan, CI/CD/preview/rollback evidence. |
| Dispatch and control | `controller-loop` + `sprint-orchestrator` + `session-ledger` mode | Durable state, session ledger, one leased worktree per worker, platform MCP/API contract or approved fallback. |
| Implementation | `lane-delivery` | One bounded issue/lane/branch/worktree/session/PR; tests and closeout evidence; no self-expansion. |
| QA and review | `independent-critic` -> `review-inbox` mode -> `observability-diagnostics` mode | Fresh critic, exact SHA, checks, preview/runtime evidence, risks, rollback, human reviewer packet. |
| Integration and deployment | `release-verification` + `environment-gitops` mode | Merge proof, deployment proof, runtime health, rollback readiness, outcome acceptance separate from merge. |
| Operations and incident response | `controller-loop`, `platform-readiness`, `release-verification`, platform emergency controls | Alerts, tool traces, policy denials, budget stops, incident brake, evidence preservation, recovery prompt. |
| Learning | `northstar-planning` / `learning-capture` mode | Proposal-only learning packets with evidence, redaction, risk, approval, loop-readiness before scheduling. |

## Per-Skill Audit

| Skill | Compliant loop elements | Drift / missing controls | Required improvement |
| --- | --- | --- | --- |
| `project-router` | Deterministic route, Git/GitHub/artifact reconstruction, explicit next skill/mode, route artifact validation. | Does not see externally supplied unregistered evidence; route enum/mode drift and approval-gate bypass are known issues. | Add pre-route evidence detection, enforce approved artifacts/gates, validate all target modes. Track `#13`, `#15`, `#20`. |
| `transcript-replan` | Normalizes unstructured planning input into durable proposed decisions, requirements, conflicts, issues/gates. | Handles untrusted conversational text but lacks explicit prompt-injection/content-trust handling. | Add untrusted-input rules, redaction checks, issue-action boundary with state-of-union. Track `#21`, `#11`. |
| `northstar-research-ingest` | Copies source, hashes it, registers evidence, supports query proof and schema validation. | No hard secret scan before commit; provenance/license and injection handling are soft guidance. | Add secret scan, source trust status, license/provenance fields or gate, adversarial content handling. Track `#16`, `#21`. |
| `northstar-planning` | Strong artifact loop: evidence, synthesis, questions, learning proposals, review feedback, final lock only when ready. | Current drafts now cite the agentic-loop report, but final lock remains unavailable while review status is `changes_requested` and count/status drift remains open. | Keep this audit linked, resolve count drift and new platform/skills issue maps, then request review only when artifacts are coherent enough for final lock. |
| `northstar-interview` | Produces prioritized human questions with defaults/tradeoffs without self-approving lock. | Needs tighter tie to consensus/adversarial review and explicit answer-to-artifact lifecycle. | Link interview decisions to `consensus-audit-workflow` once approved; keep final approval separate. |
| `northstar-question-resolution` | Inventories/clusters many questions, researches under delegated authority, leaves a small escalation pack. | Schema refs are invalid in current issue record; evidence ingestion and answer confidence need validator coverage. | Fix schema refs and validation. Track `#14`. |
| `project-definition` | Defines scope, users, requirements, design surfaces, operations, lifecycle readiness before architecture. | Router can advance past unapproved definition; authority boundary with North Star/architecture is ambiguous. | Enforce approval/draft-acceptance semantics. Track `#8`, `#15`. |
| `architecture-contracts` | Converts approved definition into system architecture, ADRs, module contracts, invariants, validation. | The skills package itself currently lacks repo-level architecture/module contracts; incident, eval, and platform controls are not fully modeled. | Add self-architecture or explicitly defer; ensure platform controls from `#1995`-`#2000` are architecture requirements. |
| `state-of-union` | Reconciles North Star, artifacts, GitHub, PRs, gates, sprint history, runtime health into strategy. | Issue-action boundary with `issue-triage` is unclear; current strategy is approved but North Star remains iterating. | Keep strategy as sequencing authority only after source freshness; use issue-triage for concrete issue creation. Track `#11`. |
| `repo-hygiene` | Wave 0 compliance: docs, source of truth, GitHub, CI, secrets exposure, ownership. | Repo-agent scope and bootstrap are mode-like but not yet a first-class skill; content trust and package validation need hard checks. | Add `repo-agent-scope` proof and bridge to repo-bootstrap. Track `#1`, `jvallery/agents#1810`, `#1980`. |
| `sprint-planning` | Creates atomic sprint transaction, lane contracts, dependency order, review plan. | Wave-release planning is still mode-first; dependency/runbook defects are filed. | Keep wave-release plan as required for deployment-affecting work; enforce dependency order in runbook. Track `#18`. |
| `sprint-orchestrator` | Coordinates lanes, GitHub, CI/CD, gates, handoffs; does not implement or self-review. | Dispatch contract references platform MCP tools that do not exist from this laptop; overlaps controller-loop; lacks budget/tool-trace controls. | Reground to live `agents.vallery.net` API/MCP contracts, require platform control request, session ledger, budget, and telemetry. Track `#12`, `#18`, `#23`, `#36`, `jvallery/agents#1956`, `#1948`, `#1995`-`#1998`. |
| `controller-loop` | Owns durable outer loop, child sessions, gates, status events, handoffs, context recovery. | Schema cannot store all mandated child-session fields; wave-supervision mode is under-specified; runtime budget and emergency stops are missing. | Extend controller state/session ledger, context reset, budget, stop-reason, and recovery contract. Track `#2`, `#22`, `jvallery/agents#1981`, `#1996`, `#1997`. |
| `platform-readiness` | Inventories k3s/RBAC/secrets/CI/CD/GitOps/ingress/observability/MCP contracts before autonomous work. | Mentions wrong/old edge provider in places; modes need grounding; control request lacks semantic guard for protected writes. | Ground in live agents platform, add API/MCP canary, semantic guard, emergency brake, trace/budget/provenance readiness. Track `#27`, `#33`, `jvallery/agents#1995`-`#2000`. |
| `gravity-readiness` | Keeps Gravity gated, inventories product/source/dependencies/Onyx/env/platform, defines pilot criteria. | Boundary with platform-readiness can overlap; Gravity extraction is mode-first and must stay non-implementation. | Keep Gravity blocked until platform and Gravity approvals; use core extraction plan before feature lanes. Track `#10`. |
| `lane-delivery` | Bounded worker in leased worktree with issue/branch/contract, incremental validation, PR closeout. | READY_FOR_CRITIC/fix-forward lifecycle drift; credential isolation is not enforced enough; no runtime bundle/budget recording. | Fix closeout state, enforce worker credential boundary, record session bundle and budget stop evidence. Track `#26`, `#34`, `jvallery/agents#1995`, `#1996`. |
| `independent-critic` | Fresh context, separate worktree/session, reviews issue/contract/diff/tests/CI/worker closeout. | Does not yet submit GitHub review in the planned way; consensus/multi-party review is separate and missing. | Add GitHub review submission support and integrate with future consensus-audit workflow without losing critic independence. Track `#35`, `#3`, `jvallery/agents#1834`, `#1985`. |
| `release-verification` | Separates review inbox, integration, deployment proof, rollback, and outcome acceptance. | Broken cross-skill reference; review inbox/diagnostics are mode-first; incident response and emergency brake need platform hooks. | Fix reference validation, keep deployment proof separate from merge, integrate diagnostics, emergency brake, and provenance. Track `#17`, `jvallery/agents#1997`, `#2000`. |
| `issue-triage` | Uses GitHub as backlog authority, searches duplicates, records evidence, creates/updates issue-template issues. | Boundary with state-of-union needs clearer policy; needs stricter untrusted-input and template/label validation when creating issues. | Keep issue creation here; state-of-union should recommend. Add content-trust and template validation. Track `#11`, `jvallery/agents#1999`. |

## Missing Skills And Capabilities For Full SDLC Coverage

These are missing or mode-first in Verdify Skills. Promotion should require a
stable contract, one reliable manual run, validation, and owner approval.

| Capability | Current home | Gap | Recommendation |
| --- | --- | --- | --- |
| `repo-bootstrap` | Proposed skills issue `#1`, platform `jvallery/agents#1810` and `#1980` | No top-level Verdify skill yet; platform implementation is incomplete. | Build after authority-boundary decisions; keep secret-safe bootstrap packet and `repo-agent-scope`. |
| `consensus-audit-workflow` | Proposed skills issue `#3`, platform `#1834`, `#1985` | Multi-party/cross-model consensus is not integrated with independent critic or degraded-mode policy. | Create only after platform reconciliation ADR; degraded mode must be provisional or human-override gated. |
| `eval-runner` | Skills issues `#24`, `#25`, platform `#1986` | Evals are prose-heavy and do not exercise hardest declared behavior, safety refusals, chaos, or live canaries. | Define executable eval runner and per-skill fixtures; gate canary/batch rollout. |
| `review-inbox` | `release-verification` mode | Packet/schema exists, not top-level. | Promote after reliable manual run and ownership proof. |
| `wave-release-planning` | `sprint-planning` mode | Plan/schema exists, not top-level. | Keep required for deployment-affecting waves; promote after repeated use. |
| `observability-diagnostics` | `release-verification` mode | Diagnostic packet exists but platform tool-call traces are missing. | Pair with `jvallery/agents#1998`; promote after live diagnostics prove value. |
| `session-ledger` | `controller-loop` mode | Ledger schema exists; runtime fields and recovery are incomplete. | Resolve `#2`, `#22`, `jvallery/agents#1981`; keep as controller-owned until reused broadly. |
| `agent-platform-control` | `platform-readiness` mode | Request schema exists; live MCP/API executor and semantic guards are incomplete. | Resolve `#12`, `#33`, `#36`, `jvallery/agents#1956`, `#1948`, `#1998`. |
| `learning-capture` | `northstar-planning` mode | Proposal schema exists; recurring scans need source, redaction, budget, and manual proof. | Keep proposal-only until loop-readiness is proven. |
| `incident-response` / emergency brake | Platform capability | No active live Northstar issue before this audit. | Implement via `jvallery/agents#1997`; expose as platform-readiness/release-verification gate before making a Verdify skill. |
| Runtime governance bundle | Platform capability | No session-level model/prompt/tool/skill/eval/image identity. | Implement via `jvallery/agents#1995`; link to session-ledger and review/canary evidence. |
| Budget/rate controls | Platform capability | No per-session cost/rate/retry budget stop. | Implement via `jvallery/agents#1996`; make controller-loop consume stop reasons. |
| Tool-call/policy telemetry | Platform capability | API traces exist historically, but not live agent MCP/session tool outcome traces. | Implement via `jvallery/agents#1998`; feed observability-diagnostics and review inbox. |
| Content-trust guardrails | Cross-cutting skill/platform capability | Skills and platform handle untrusted inputs piecemeal. | Implement skills `#21` and platform `jvallery/agents#1999`. |
| Supply-chain provenance | Platform capability | Image/build work exists, but skill/runtime/agent-authored artifact provenance is not a current gate. | Implement via `jvallery/agents#2000`; connect to canary and runtime bundle. |

## Platform Issue Map

Existing platform issues that cover the agents-specific Skills Fleet gaps:

- `jvallery/agents#1977` - runtime image does not ship agents-specific skills or Verdify entrypoint.
- `jvallery/agents#1978` - agents-specific skills are not discoverable by controllers.
- `jvallery/agents#1979` - skill validation contract split and installed Verdify package fails validator.
- `jvallery/agents#1980` - Skill A take-control incomplete and runtime import path mismatch.
- `jvallery/agents#1981` - Skill B loop-runtime is reference harness, not live loop.
- `jvallery/agents#1982` - Skill C observability lacks live alert-to-interrupt-to-recycle datapath.
- `jvallery/agents#1983` - Skill D / Orbit digest lacks conductor runtime and live connectors.
- `jvallery/agents#1984` - Skill E infra-standards lacks assessors, backlog writer, actuators.
- `jvallery/agents#1985` - Skill F degraded single-model mode can reach final consensus.
- `jvallery/agents#1986` - live canary acceptance harness for A-F skills.
- `jvallery/agents#1987` - reconcile approved platform North Star docs with expanded Verdify package.

New platform issues created from this audit:

- `jvallery/agents#1995` - runtime governance bundle for model/prompt/tool/skill/eval/image identity.
- `jvallery/agents#1996` - per-session spend, rate, retry, and budget stop controls.
- `jvallery/agents#1997` - emergency brake and read-only mode for controller dispatch and MCP writes.
- `jvallery/agents#1998` - tool-call trace and policy-denial telemetry for MCP/session operations.
- `jvallery/agents#1999` - untrusted-input guardrails for controller feeds and MCP tool arguments.
- `jvallery/agents#2000` - supply-chain provenance for runtime images, skill bundles, and agent-authored artifacts.

New skills issue created from the follow-up planning turn:

- `VerdifyConsultancy/verdify-skills#43` - shared bounded agentic-loop control contract for all lifecycle skills.

## Recommended Plan

1. Keep the North Star in `iterating` until this audit, the new evidence items,
   the platform issue map, and `VerdifyConsultancy/verdify-skills#43` are
   incorporated into product/architecture drafts.
2. Execute the approved skills-hardening sprint in dependency order: decisions,
   validator safety net, schema/security fixes, platform regrounding, lifecycle
   reconciliation, eval uplift, then deferred capabilities.
3. In parallel, advance platform issues `#1977`-`#1987` and `#1995`-`#2000`
   enough for `platform-readiness` to prove a real agents.vallery.net
   controller can discover skills, run canaries, record runtime bundles,
   enforce budgets, trace tool calls, and stop safely.
4. Do not dispatch a Gravity implementation lane until platform-readiness and
   gravity-readiness both pass with live evidence.
5. Run one non-Gravity pilot through the full chain from intake to release
   verification and learning capture before broad fleet rollout.
