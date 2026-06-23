# End-to-End Agent-Based SDLC

I am treating "SLDC" as **SDLC**.

The system prescribed here is a **human-governed, agent-executed software delivery operating model**. Humans define intent, approve protected decisions, test delivered capabilities, and resolve ambiguity. A persistent controller coordinates specialist agents that research, plan, implement, validate, deploy, diagnose, and document the work.

```text
Conversation
  -> Structured intent
  -> North Star
  -> Research and adversarial review
  -> Design commitment
  -> Repository readiness
  -> Lane and wave planning
  -> Parallel agent implementation
  -> CI and supply-chain evidence
  -> Deployed review environment
  -> Human review
  -> Fix or replan
  -> GitOps promotion
  -> Production verification
  -> Wave sign-off
  -> Next wave or project completion
```

The most important architectural refinement is this:

> The controller should be a deterministic workflow system that invokes agents, not an LLM conversation pretending to be a workflow system.

The workflow engine owns states, gates, retries, permissions, history, and stop conditions. Agents reason and act within those states. Git, CI, policy engines, GitOps, and humans remain authoritative.

## 0. Platform Readiness Gate

Before an autonomous project such as Gravity begins, the delivery platform itself must be proven.

The readiness gate should require:

- Agent identity, authorization, and isolation.
- A working controller and session ledger.
- Versioned agent skills and repository instructions.
- Worktree creation and cleanup.
- CI pipelines and protected merge policies.
- Development and review environments.
- GitOps promotion into staging and production.
- Secret brokering and workload identities.
- Logs, metrics, traces, dashboards, and alerts.
- Rollback and disaster-recovery exercises.
- A functioning human review inbox.
- A small, non-critical end-to-end pilot.

This formalizes the requirement that Gravity cannot become the experiment used to discover whether the platform works. Gravity should be the first meaningful customer of a platform that has already passed a smaller certification exercise.

Security should be integrated throughout the lifecycle rather than added as a final approval stage. NIST's Secure Software Development Framework is designed to be incorporated into any SDLC, while SLSA provides progressively stronger assurance around build provenance and artifact integrity. Reference: https://csrc.nist.gov/pubs/sp/800/218/final

## 1. Conversational Intake

The top-level planning interface is a conversation: a walk transcript, meeting transcript, written memo, support feedback, or direct conversation with the planning agent.

### Intake agent responsibilities

The intake agent:

1. Preserves the original source.
2. Corrects likely transcription errors while retaining the original phrase and confidence.
3. Extracts decisions, candidate requirements, product feedback, architecture proposals, ideas, open questions, risks, and people/ownership information.
4. Routes each item to the correct repository and product area.
5. Compares new statements with prior decisions.
6. Flags contradictions rather than silently resolving them.
7. Creates proposed changes, not direct edits to protected documents.

Every intake event receives a stable ID so that later requirements can point back to the transcript passage that produced them.

### Best-practice addition

The ingestion stage should also:

- Detect and redact credentials, personal data, and sensitive production information.
- Record the source, speaker, date, confidence, and classification of every extracted item.
- Distinguish observation from interpretation.
- Require human confirmation before an inferred statement becomes a committed requirement.

The transcript is input evidence, not automatically the plan of record.

## 2. North Star Formation

The North Star is the root specification for the project.

It contains two separately governed but cross-linked models.

### Product North Star

- The current product.
- The desired product.
- The problem being solved.
- Target users and personas.
- User journeys.
- Business and operational outcomes.
- Priorities and milestones.
- Explicit non-goals.
- Measurable success criteria.
- Known gaps and assumptions.

### Architecture North Star

- System context and boundaries.
- Major components and responsibilities.
- Data ownership and flows.
- External dependencies.
- Security and privacy boundaries.
- Reliability and recovery objectives.
- Scalability and performance principles.
- Deployment and environment model.
- Observability requirements.
- Cost and resource constraints.
- Accepted architectural tradeoffs.

Each product requirement receives a stable identifier such as `PRD-023`. Each architecture principle receives an identifier such as `ARCH-011`. The two are cross-linked:

```text
PRD-023: A reviewer must be able to test a change in a deployed environment.

Supported by:
  ARCH-011: Every reviewable PR receives an ephemeral preview environment.
  ARCH-019: Review environments use sanitized non-production data.
  ARCH-027: Preview environments expire automatically.
```

Traceability then continues downward:

```text
North Star requirement
  -> Architecture decision
  -> Lane
  -> Wave
  -> Issue
  -> Agent session
  -> Pull request
  -> Test
  -> Artifact
  -> Deployment
  -> Review evidence
  -> Acceptance
```

### DESIGN_COMMITTED

During exploration, agents and humans may revise the North Star freely through normal review.

At `DESIGN_COMMITTED`:

- The approved product and architecture baseline becomes protected.
- Subsequent changes require a PR.
- The PR must explain the reason, effects, alternatives, migration impact, and affected work.
- Material changes require Jason and/or James according to an explicit approval matrix.
- The design is controlled, but not permanently frozen.

The best practice is to treat this as configuration-controlled change, not as a prohibition on learning.

## 3. Research and Adversarial Review

Once an initial North Star exists, the controller creates bounded research missions.

Specialist agents independently examine the proposed system from different perspectives:

- End user.
- Administrator.
- Operator or SRE.
- Security and privacy.
- Architecture.
- Performance and scalability.
- Accessibility.
- Historian or auditor.
- Cost and total cost of ownership.
- Finance.
- Support and maintainability.
- Developer experience.

Each research agent should receive:

- A narrow question.
- Read-only repository access unless mutation is necessary.
- An explicit source-quality standard.
- A tool allowlist.
- A deadline or token budget.
- A required output schema.
- A requirement to report uncertainty and conflicting evidence.

The outputs are synthesized by an architecture/planning agent into alternatives considered, evidence for and against each option, assumptions, risks, cost and operational implications, recommended decisions, and unresolved questions.

Using isolated contexts and restricted tool sets for specialized subagents is consistent with current agent tooling patterns: specialist agents can have separate context windows, restricted permissions, and narrowly scoped tool access. Reference: https://docs.anthropic.com/en/docs/claude-code/sub-agents

A human design review ends this stage. Agents may recommend commitment; they do not grant it.

## 4. Repository Readiness: Wave 0

Before feature development, every repository passes a state-of-the-union and hygiene wave.

The hygiene agent assesses:

- Canonical product and architecture documentation.
- `AGENTS.md` and scoped instruction files.
- ADR organization.
- Code ownership.
- Branch protection.
- Dependency management.
- Build reproducibility.
- Test reliability.
- Secret exposure.
- Static analysis.
- Infrastructure definitions.
- CI configuration.
- Deployment manifests.
- Observability conventions.
- Issue and label taxonomy.
- Stale branches, abandoned plans, and duplicated documents.
- Local development setup.
- Recovery and rollback documentation.

Safe mechanical fixes can be automated. Ambiguous deletions, architecture changes, or ownership changes should become reviewable PRs.

A layered `AGENTS.md` model is useful here: repository-wide rules at the root, with more specific overrides closer to individual components. This pattern is already supported by current coding-agent tooling. Reference: https://developers.openai.com/codex/guides/agents-md

### Community leverage

Do not build the complete software catalog from scratch. Backstage already provides models for components, systems, APIs, resources, ownership, templates, documentation-as-code, and Kubernetes visibility. The Agent Platform can extend or embed those concepts while adding agent sessions, waves, review status, and control-plane actions. Reference: https://backstage.io/docs/features/software-catalog/system-model/

Wave 0 concludes only when the repository either passes its readiness policy or has an approved exception with an owner and expiry date.

## 5. Implementation Planning: Lanes, Task Graphs, and Waves

The committed design is transformed into an executable dependency graph.

### Lanes

A lane is a stable area of responsibility, such as frontend, API, domain services, data and migrations, platform, security, observability, test automation, documentation, release, and networking.

Each lane definition states:

- Owned files and services.
- Public interfaces.
- Dependencies.
- Naming and schema conventions.
- Permitted infrastructure.
- Required tests.
- Prohibited changes.
- Escalation rules.

### Tasks

Tasks should be independently reviewable and attached to:

- One or more requirement IDs.
- Acceptance criteria.
- Dependencies.
- Risk classification.
- Test expectations.
- Observability expectations.
- Rollback or reversibility requirements.

### Waves

A wave is a coherent, deployable product increment, not a large branch.

A wave may contain several task branches and PRs across multiple lanes. It ends when those changes work together in a deployed environment and satisfy a meaningful set of user stories.

This corrects one ambiguity in the transcript:

> Use one short-lived branch and worktree per task or issue, while representing the wave through metadata, milestones, integration environments, and traceability.

Long-lived wave branches create integration risk. DORA guidance favors trunk-based development, few active branches, and short-lived branches merged at least daily. Modern coding-agent tools also use isolated worktrees so multiple agents can work concurrently without interfering with one another. Reference: https://dora.dev/capabilities/trunk-based-development/

Wave size should be determined by integration risk, dependencies, human review capacity, acceptance criteria, deployment reversibility, and context required by the agents.

"One wave per day" can be an optimization target, but it should not be a governance rule.

## 6. Durable Controller and Session Ledger

The outer-loop controller owns the delivery state machine.

It should be durable across agent crashes, model changes, process restarts, human delays, CI failures, infrastructure outages, and context-window exhaustion.

The controller records:

- Project and wave.
- Current lifecycle state.
- Parent and child sessions.
- Agent identity and model.
- Issue, branch, worktree, and PR.
- Tool permissions.
- Inputs and outputs.
- Start and end time.
- Checkpoints.
- Decisions and approvals.
- Cost and resource use.
- Artifacts.
- Test and deployment evidence.
- Failure and retry history.

A framework such as LangGraph can supply checkpoints, resumability, human-interrupt points, and persistent thread state. The architecture should nevertheless remain framework-neutral so that a more general durable workflow engine can be substituted later without changing the project model. Reference: https://docs.langchain.com/oss/python/langgraph/durable-execution

### Required controller properties

The controller must support idempotent operations, explicit timeouts, bounded retries, cancellation, pause and resume, compensating or cleanup actions, concurrency limits, dependency-aware scheduling, human interrupt points, immutable execution events, and recovery from partially completed actions.

The controller must never infer that a gate passed merely from conversational context. It reads machine-verifiable evidence.

## 7. Agent Provisioning and Isolation

For each task, the controller provisions an ephemeral agent workspace containing:

- A fresh worktree.
- A dedicated branch.
- The applicable `AGENTS.md` hierarchy.
- Versioned project skills.
- The task specification.
- Relevant requirements and ADRs.
- Owned source boundaries.
- A dedicated service account.
- A tool allowlist.
- Compute and time budgets.
- Network rules.
- Stop conditions.

### Default security posture

Agents should begin with repository workspace access only, no uncontrolled network egress, no production write access, no reusable human credentials, no direct access to secret values unless strictly required, read-only access to unrelated code and infrastructure, and audited privilege escalation.

Current Codex security guidance follows a similar model: workspace-scoped writes, network restrictions, OS-level sandboxing, and explicit approval for broader access. Its cloud environment also separates setup-time secret availability from the later agent phase. Reference: https://developers.openai.com/codex/agent-approvals-security

### Kubernetes isolation

A namespace is an organizational boundary, not by itself a sufficient security boundary.

Each environment should also use:

- Least-privilege RBAC.
- A separate service account per workload or agent role.
- Default-deny NetworkPolicies.
- Resource quotas and limits.
- Pod Security controls.
- Restricted host access.
- Ephemeral workload identity.
- Secret-store integration.
- Audit logging.
- Stronger sandboxing for untrusted code execution.

Kubernetes' own multi-tenancy guidance emphasizes that namespaces must be combined with RBAC, network isolation, quotas, and potentially stronger runtime isolation for untrusted workloads. Reference: https://kubernetes.io/docs/concepts/security/multi-tenancy/

This replaces the transcript's broad "full access to the namespace" idea with least-privilege, task-specific authorization.

## 8. Parallel Implementation

The controller fans tasks out to worktree agents.

Each implementation agent receives a contract:

```yaml
task:
  issue: AGENT-143
  wave: WAVE-006
  requirements:
    - PRD-023
    - ARCH-011
  owned_paths:
    - services/review-environment/**
  allowed_interfaces:
    - PreviewEnvironmentAPI.v2
  acceptance_tests:
    - AT-023-01
    - AT-023-02
  required_evidence:
    - unit_tests
    - integration_tests
    - deployment_manifest
    - telemetry
    - documentation
  stop_conditions:
    - interface_change_required
    - cross_lane_edit_required
    - production_access_required
```

Agents should examine existing behavior before editing, add or update tests with the implementation, keep changes narrowly scoped, commit incrementally, produce a structured handoff, escalate interface or architecture changes, avoid crossing another lane's ownership boundary without approval, and record assumptions and unresolved risks.

The same agent should not be the sole reviewer of its own work. An independent context, reviewer agent, and eventually a human should inspect the change.

## 9. Pull Request and CI Evidence Pipeline

A pull request is not merely a code diff. It is an evidence package.

Depending on the repository and risk class, CI should run:

1. Formatting and linting.
2. Type and schema validation.
3. Unit tests.
4. Component and contract tests.
5. Integration and end-to-end tests.
6. Secret scanning.
7. Static application security testing.
8. Dependency and license analysis.
9. Container and infrastructure scanning.
10. Database migration compatibility checks.
11. Documentation validation.
12. Observability-contract validation.
13. Policy-as-code checks.
14. Artifact construction.
15. Preview deployment.

The pipeline should build an immutable artifact once and promote that same artifact digest through subsequent environments.

For software supply-chain evidence:

- Generate an SBOM using CycloneDX or an equivalent standard.
- Generate SLSA-compatible provenance.
- Sign artifacts and attestations.
- Verify provenance and policy before promotion.
- Preserve evidence with the release record.

CycloneDX provides standardized models for components, services, dependencies, vulnerabilities, and build formulation. SLSA defines provenance and assurance tracks for source and build integrity. OPA can externalize policy decisions across CI/CD, Kubernetes, APIs, and other control points. Reference: https://cyclonedx.org/specification/overview/

Fast, reliable feedback and keeping the software continuously deployable are central continuous-delivery practices. Reference: https://dora.dev/capabilities/continuous-delivery/

## 10. Review Environment

A PR cannot become review-ready merely because CI is green.

The exact immutable artifact must be deployed into a reachable review environment containing:

- A predictable URL.
- A TTL and automatic cleanup.
- Sanitized or synthetic data.
- Required feature flags.
- Relevant logs and dashboards.
- Test identities.
- Seeded scenarios.
- Known limitations.
- Version and commit metadata.

### Environment topology

A refined namespace model is:

```text
Application
  - development namespace
  - staging namespace
  - production namespace
  - ephemeral preview namespaces
```

This resolves the transcript's "one repository equals one namespace" ambiguity. The application is the catalog entity; namespaces are environment-scoped runtime units.

Git should contain the desired environment state. CI produces and verifies artifacts; GitOps applies approved desired-state changes. Argo CD can manage synchronization, while its phases and sync waves should remain distinct from product-delivery "waves." Reference: https://argo-cd.readthedocs.io/en/stable/user-guide/sync-waves/

## 11. Automated Review and Human Review Inbox

Once the review environment is healthy, independent review agents inspect the result.

Possible reviewers include correctness, test quality, security, architecture, performance, accessibility, operations and reliability, documentation, product acceptance, and North Star traceability.

The combined review inbox should present one review packet per change:

```text
What changed
Why it changed
North Star requirements satisfied
Architecture decisions involved
PRs and commits
CI results
Artifact digest and provenance
Review URL
Exact human test procedure
Expected results
Screenshots or recorded evidence
Metrics and logs
Known risks
Data or migration effects
Rollback procedure
Agent recommendations
Questions requiring human judgment
```

### Risk-based approval

Not every change needs identical human intervention.

Low-risk changes may be automatically accepted when all policies and tests pass. Human approval should remain mandatory for changes involving protected North Star content, security boundaries, permissions, secrets, identity, production networking, public APIs, destructive migrations, irreversible operations, privacy-sensitive data, material cost or architectural changes, and exceptions to policy.

This preserves human judgment where it is valuable without making humans approve routine mechanical work.

## 12. Feedback, Fix, and Replanning Loop

The controller pauses the next protected wave while review feedback is unresolved.

Feedback is classified as:

| Feedback type | Result |
| --- | --- |
| Implementation defect | Create a fix task in the current wave |
| Missing test | Add evidence requirement and test task |
| Requirement misunderstanding | Reopen planning and clarify acceptance criteria |
| New product requirement | Propose a North Star change |
| Architecture change | Create or amend an ADR and return to design review |
| Operational issue | Add instrumentation, runbook, or reliability work |
| Cosmetic or optional enhancement | Backlog unless required for acceptance |
| Reviewer misconception | Improve documentation or review instructions |

A fix goes through the same implementation, CI, deployment, and review gates as the original change.

The system does not silently proceed to the next wave while material feedback remains open.

## 13. Staging and Production Promotion

Agents may deploy freely only into authorized development or preview environments.

Staging and production changes occur through controlled promotion:

```text
Approved PR
  -> Merge to trunk
  -> Verified immutable artifact
  -> Development validation
  -> Staging promotion
  -> Automated acceptance and operational checks
  -> Required production approval
  -> Progressive production rollout
```

The same artifact digest moves through every environment. Nothing is rebuilt specifically for production.

Infrastructure and edge changes should be governed by both a designated owning agent or team and enforced policy/protected promotion workflows.

Relying on "the network agent is the only one allowed" is weaker than enforcing the rule through identities, repository protection, policy-as-code, and GitOps.

### Progressive delivery

Production rollout should use canary, blue-green, or another progressive approach where risk warrants it. Argo Rollouts supports progressive traffic movement, metric analysis, automated promotion, and automated rollback. Reference: https://argo-rollouts.readthedocs.io/en/stable/

Rollback should be triggered by defined release-health criteria:

- Availability.
- Error rate.
- Latency.
- Saturation.
- Business transaction success.
- Data-integrity indicators.
- Critical security events.

It should not roll back because "any alert" happened. The criteria need thresholds, evaluation windows, baseline comparisons, and a defined stabilization period.

## 14. Production Verification and Diagnostics

Observability is part of every feature's definition of done.

The standard telemetry contract should include:

- Metrics.
- Structured logs.
- Distributed traces.
- Correlation IDs.
- Deployment markers.
- Feature-flag state.
- Artifact and commit identifiers.
- Namespace and environment.
- Controller and agent session identifiers.
- Requirement, issue, PR, and wave identifiers.

OpenTelemetry semantic conventions provide standard attribute models and now include conventions applicable to CI/CD and generative-AI or agent activity, making it a suitable foundation for cross-system correlation. Reference: https://opentelemetry.io/docs/specs/semconv/

A diagnostic agent should be able to accept feedback such as:

> "The review page became slow after I enabled filtering."

It can then, within its permissions:

1. Identify the relevant requirement and release.
2. Find the deployed artifact.
3. Examine traces and metrics.
4. Follow correlation IDs.
5. Inspect logs.
6. Find likely source paths and dependencies.
7. Compare current behavior with prior deployments.
8. Generate ranked hypotheses.
9. Recommend or create bounded investigation tasks.

Production access should use read-only telemetry APIs and, where necessary, masked or replicated data stores. All queries should be audited. Agents should not receive unrestricted access to live customer data.

## 15. Wave Sign-Off and Continuous Learning

A wave closes only when:

- Its user stories are accepted.
- Required tests pass.
- Review findings are resolved or explicitly deferred.
- The deployed behavior is verified.
- Documentation and runbooks are current.
- Operational ownership is clear.
- Rollback is proven.
- Traceability is complete.
- The human approval rule is satisfied.

The controller then creates a structured handoff for the next wave:

- What changed.
- Current architecture.
- Accepted decisions.
- Outstanding risks.
- Deferred work.
- New constraints.
- Relevant telemetry.
- Lessons from failures and rework.

Agents in the next wave receive a fresh context window plus this structured handoff, rather than inheriting an indefinitely growing conversation.

The project reaches `NORTH_STAR_PROVEN` only when all in-scope product outcomes and architecture obligations have evidence and sign-off. The controller then becomes idle until a new transcript, incident, metric signal, or requirement reopens planning.

## Reference Lifecycle State Machine

```text
INTAKE
  -> CLASSIFY_AND_ROUTE
  -> NORTH_STAR_DRAFT
  -> RESEARCH_FAN_OUT
  -> ADVERSARIAL_REVIEW
  -> DESIGN_REVIEW
  -> DESIGN_COMMITTED
  -> REPOSITORY_READINESS
  -> WAVE_PLANNED
  -> TASKS_EXECUTING
  -> INTEGRATING
  -> CI_EVIDENCE_READY
  -> PREVIEW_DEPLOYED
  -> AUTOMATED_REVIEW
  -> HUMAN_REVIEW
      |-> FIX_REQUIRED
      |     -> FIXING
      |     -> CI_EVIDENCE_READY
      |-> REPLAN_REQUIRED
      |     -> CHANGE_CONTROL
      |     -> DESIGN_REVIEW or WAVE_PLANNED
      |-> APPROVED
            -> MERGED
            -> STAGING_PROMOTION
            -> PRODUCTION_APPROVAL
            -> PROGRESSIVE_ROLLOUT
            -> PRODUCTION_VERIFICATION
            -> WAVE_SIGNED_OFF
                  |-> NEXT_WAVE
                  |-> NORTH_STAR_PROVEN
```

Every active state also supports:

```text
PAUSED
FAILED_RETRYABLE
FAILED_REQUIRES_HUMAN
CANCELLED
ROLLING_BACK
ROLLED_BACK
```

## Principal Agents

| Agent | Primary responsibility |
| --- | --- |
| Transcript Intake Agent | Converts conversations into attributable proposed changes |
| North Star Agent | Maintains product and architecture specifications |
| Research Agents | Investigate alternatives and persona-specific risks |
| Architecture/Planning Agent | Produces lanes, dependency graphs, tasks, and waves |
| Controller Agent | Executes the durable lifecycle and enforces gates |
| Repository Hygiene Agent | Brings inherited repositories to readiness |
| Lane Agents | Implement bounded tasks in isolated worktrees |
| Integration Agent | Validates cross-lane compatibility |
| Security and Policy Agent | Evaluates supply-chain, code, identity, and infrastructure risk |
| Test Agent | Designs and verifies acceptance evidence |
| Release Agent | Builds, promotes, deploys, and rolls back immutable artifacts |
| Network/Platform Agent | Owns protected cluster, ingress, DNS, and environment changes |
| Observability Agent | Enforces telemetry and dashboard contracts |
| Diagnostic Agent | Investigates feedback and incidents using code and telemetry |
| Independent Review Agent | Reviews changes from a fresh context |
| Knowledge/Ledger Agent | Preserves decisions, sessions, evidence, and history |

## Most Important Refinements to the Original Model

| Original concept | Best-practice implementation |
| --- | --- |
| One branch per wave | One short-lived task branch/worktree; waves aggregate multiple integrated PRs |
| LLM as the persistent outer loop | Durable deterministic workflow engine invoking bounded LLM agents |
| Controller owns all credentials | Short-lived workload identity and brokered access; no reusable secrets in prompts |
| Full agent access to its namespace | Task-specific least-privilege service accounts, RBAC, NetworkPolicy, and quotas |
| One repository equals one namespace | One application catalog entity with separate environment and preview namespaces |
| Human insertion is optional | Explicit risk-based gates; mandatory for protected and high-impact changes |
| Roll back when any alert fires | SLO- and release-health-based analysis with thresholds and evaluation windows |
| One wave per day | Outcome- and risk-based sizing; daily delivery is a target, not a rule |
| Agent reviews its own work | Independent reviewer context plus human review where risk requires it |
| Direct production database inspection | Audited, masked, read-only telemetry or replica access |
| Browser SSH to every agent | Authenticated, audited, time-limited terminal access with just-in-time authorization |
| Skills copied informally into repos | Versioned skills registry, compatibility metadata, lockfiles, and conformance tests |
| Activity dashboard as productivity | DORA-style delivery measures plus quality, rework, safety, and outcome measures |

The resulting system is not simply autonomous coding. It is a traceable software-delivery institution encoded as workflows, policies, evidence, and constrained agents. Humans own intent and consequential judgment; agents handle research, implementation, testing, coordination, diagnostics, and operational bookkeeping within enforceable boundaries.
