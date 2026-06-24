# Comprehensive Planning And Review Loop Research

Date: 2026-06-24
Method: Brave Search API using the configured local `brave_search_key.txt`
credential reference. Raw credential values were not printed, copied, logged, or
stored.

## Scope

This note supports reworking Verdify planning and review skills so a prompt like
"familiarize yourself with this project, triage all issues and planning docs,
check live deployment/log health, create tracked health issues, carve lanes,
define waves/sprints/milestones, and report the next QA and human review
milestone" can execute as an evidence-backed lifecycle loop.

## Brave Queries

- `GitHub Issues Projects milestones dependencies issue triage official docs`
- `Scrum Guide sprint planning sprint review product backlog official`
- `DORA software delivery performance metrics lead time deployment frequency change fail rate official`
- `Google SRE monitoring distributed systems four golden signals logs alerts`
- `OpenTelemetry observability logs metrics traces semantic conventions official`
- `Kubernetes liveness readiness startup probes application health official docs`
- `Argo CD GitOps application health sync status deployment rollback official docs`
- `Architecture Decision Record ADR context decision consequences official guidance`
- `software engineering incident review action items issue tracking best practices official`
- `human in the loop AI agent software engineering task decomposition verification research`

## Sources Found

| Source | Type | URL | Relevance |
| --- | --- | --- | --- |
| GitHub Docs, "About issues" and related issue dependency/project pages | primary product docs | https://docs.github.com/en/issues | Supports keeping backlog intent, dependencies, labels, milestones, Projects, issue types, and PR/deployment references in GitHub rather than private plans. |
| The Scrum Guide | primary methodology source | https://scrumguides.org/scrum-guide.html | Supports sprint planning around a sprint goal, selected backlog items, an actionable plan, and sprint review with stakeholders. |
| DORA software delivery performance metrics | primary research/practice source | https://dora.dev/guides/dora-metrics/ | Supports tracking delivery performance with deployment frequency, lead time for changes, change failure rate, and recovery time. |
| Google SRE, "Monitoring Distributed Systems" | primary SRE source | https://sre.google/sre-book/monitoring-distributed-systems/ | Supports runtime health review using latency, traffic, errors, and saturation, and discourages unactionable alert noise. |
| OpenTelemetry semantic conventions | primary specification/docs | https://opentelemetry.io/docs/concepts/semantic-conventions/ | Supports recording telemetry links and signal names consistently across logs, metrics, traces, resources, and events. |
| Kubernetes probes docs | primary platform docs | https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ | Supports separating liveness, readiness, and startup health checks when evaluating live deployment behavior. |
| Argo CD docs | primary GitOps docs | https://argo-cd.readthedocs.io/en/stable/ | Supports comparing desired Git state with live cluster state and treating out-of-sync drift as deployment evidence, not narrative status. |
| Microsoft Learn, "Maintain an architecture decision record" | vendor architecture guidance | https://learn.microsoft.com/en-us/azure/well-architected/architect-role/architecture-decision-record | Supports durable decision records with context, rationale, decisions, consequences, ownership, and review. |
| AWS Prescriptive Guidance, "ADR process" | vendor architecture guidance | https://docs.aws.amazon.com/prescriptive-guidance/latest/architectural-decision-records/adr-process.html | Supports minimum ADR fields of context, decision, and consequences. |
| Martin Fowler, "Humans and Agents in Software Engineering Loops" | expert practice article | https://martinfowler.com/articles/exploring-gen-ai/humans-and-agents.html | Supports nested loops: outer planning and delivery loops decompose work for lower loops and validate results before advancing. |

## Findings

1. The comprehensive planning prompt should not become one private chat plan.
   It should execute as a coordinated loop whose durable records are GitHub
   Issues/Projects/milestones/dependencies plus Verdify strategy, sprint,
   lane, review, diagnostic, and release artifacts.
2. Full project triage needs source freshness as an explicit output: Git,
   GitHub Issues, PRs, checks, deployments, planning artifacts, sprint
   artifacts, runtime logs, telemetry, and operator-supplied evidence may each
   be fresh, stale, missing, unavailable, or limited.
3. Deployment and log health belong in planning only as evidence-backed
   findings. Health issues discovered during triage should become proposed or
   applied GitHub issue actions and, when runtime proof matters, an
   observability diagnostic packet.
4. Sprint planning should preserve the stakeholder-facing shape of the plan:
   what is in, what is deferred, lane ownership, dependency order, QA/review
   milestones, user stories intended for review, deployment expectations, and
   human gates.
5. Review readiness should be a first-class lifecycle state before integration
   when a lane or wave claims review-ready status. The review packet should bind
   issue/lane/sprint IDs, exact reviewed SHA, checks, preview/review deployment,
   telemetry, rollback, questions, and feedback route.
6. Runtime health evidence should distinguish deployment identity from behavior:
   exact commit/image/configuration, live desired-vs-observed GitOps state,
   Kubernetes probes/events/logs, service checks, logs, metrics, traces, alerts,
   and known limitations.
7. Human review should receive short escalation packs and review-ready packets,
   not raw issue dumps, raw logs, or hidden chat context. Agents can propose
   defaults under delegated authority, but protected decisions remain gated.

## Recommended Default

Keep Verdify decomposed into lifecycle skills, but make the planning/review path
explicitly comprehensive:

- `state-of-union` owns full operating triage and strategy refresh. It should
  reconstruct source freshness, planning/sprint artifact state, GitHub backlog,
  PR/check/deployment state, runtime/log health, gaps, issue actions, candidate
  sequences, and one handoff.
- `github-backlog-sync` remains the detailed GitHub control-plane companion
  artifact for issue/PR/lane/delivery reconciliation.
- `release-verification` owns planning-time diagnostics and review inbox packet
  assembly when live deployment/log evidence or human review readiness matters.
- `sprint-planning` owns the approved execution transaction and must produce the
  stakeholder-readable sprint answer: included work, deferred work, lanes,
  owners, dependency order, QA/review milestones, user stories for review, wave
  release plan, risks, and approval gate.
- `controller-loop` supervises the multi-skill loop durably when the plan spans
  planning, research, hygiene, sprint execution, review, fixes, replanning,
  deployment, and human signoff.

## Limitations

- Brave Search result order is not authority; source authority comes from the
  linked primary/vendor/specification documents.
- This note validates the workflow shape. Each target repository still needs
  live GitHub, CI/CD, deployment, log, and telemetry evidence gathered at triage
  time.
- Some incident-review search results were secondary practice articles, so the
  recommended Verdify default uses GitHub-backed issue tracking and existing
  review/diagnostic artifacts rather than relying on a specific incident
  framework.
