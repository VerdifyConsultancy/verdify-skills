# Schema Catalog

The 46 canonical artifact schemas under [`../../schemas/`](../../schemas/). Every
durable `.agent-workflow` artifact declares a `schema_ref` equal to its schema
filename and validates against JSON Schema draft 2020-12. Validate any artifact with:

```bash
bin/verdify artifact validate --file <path>          # schema inferred from schema_ref
```

`scripts/validate-repo.rb` additionally enforces schema structure (unique `$id`,
closed `additionalProperties`, `schema_ref` const = filename) and the example project.
"Owner" is the skill responsible for producing/maintaining the artifact; schemas with
owner **CLI/validator** are produced by `bin/verdify` or consumed cross-skill.

## Routing & lifecycle state

| Schema | Owner | Produced → consumed | Purpose |
|---|---|---|---|
| `route-decision` | project-router | router → operator/controller | The single next skill + mode with evidence. |
| `controller-state` | controller-loop | controller-loop → orchestrator, recovery | Durable lifecycle/wave state, child loops, current wave. |
| `session-ledger` | controller-loop | all roles → audit/recovery | Append-only typed event map across sessions. |
| `status-event` | sprint-orchestrator | orchestrator → controller, dashboards | Typed execution status events. |
| `status` | CLI/validator | generic | Generic lifecycle status envelope. |
| `human-gate` | router / repo-hygiene / sprint-planning | any skill → human | A blocking decision/approval gate record. |
| `compiled-prompt-manifest` | CLI/validator | `prompt compile` → worker/critic | Compiled prompt + input-hash manifest. |

## North Star & planning

| Schema | Owner | Produced → consumed | Purpose |
|---|---|---|---|
| `transcript-replan` | transcript-replan | transcript-replan → planning/strategy | Routed proposals, conflicts, issue/gate recommendations. |
| `northstar-evidence-item` | northstar-research-ingest | ingest → planning | One registered evidence record (hashed source). |
| `northstar-evidence-registry` | northstar-research-ingest | ingest → planning | The queryable evidence index. |
| `northstar-plan` | northstar-planning | planning → planning | Structured synthesis/index of the North Star. |
| `northstar-artifacts` | northstar-planning | planning → router/downstream | Loop state, sections, questions, review, signoff. |
| `northstar-learning-proposals` | northstar-planning | planning → maintainer | Proposal-only improvement packets. |
| `northstar-question-inventory` | northstar-question-resolution | resolution → resolution | Inventory of gated/open questions. |
| `northstar-question-cluster-map` | northstar-question-resolution | resolution → resolution | Questions clustered into shared decisions. |
| `northstar-question-resolution-register` | northstar-question-resolution | resolution → planning | Delegated answers + human escalation pack. |

## Definition & architecture

| Schema | Owner | Produced → consumed | Purpose |
|---|---|---|---|
| `project-definition` | project-definition | definition → architecture/strategy | Approved end-to-end project intent + lifecycle coverage. |
| `project-config` | CLI/validator | `init` → all skills | Per-repo Verdify config. |
| `architecture` | architecture-contracts | architecture → planning | North-star architecture record. |
| `module-contract` | architecture-contracts | architecture → sprint/lane | Black-box module inputs/outputs/interfaces/invariants. |

## Strategy & GitHub reconciliation

| Schema | Owner | Produced → consumed | Purpose |
|---|---|---|---|
| `state-of-union` | state-of-union | strategy → sprint-planning | Backlog/health triage + next sprint candidates. |
| `github-backlog-sync` | state-of-union | strategy → planning | Issue/PR/lane/delivery reconciliation findings. |
| `github-snapshot` | CLI/validator | `github snapshot` → reconcile | Local cache of issues/PRs. |
| `github-reconciliation` | CLI/validator | `github reconcile` → orchestrator | Snapshot-vs-contract comparison report. |

## Readiness gates

| Schema | Owner | Produced → consumed | Purpose |
|---|---|---|---|
| `repo-bootstrap` | repo-bootstrap | bootstrap → hygiene/platform | Safe self-discovery packet + gap backlog. |
| `repo-hygiene` | repo-hygiene | hygiene → sprint-planning | Wave 0 compliance assessment + gate. |
| `repo-agent-scope` | repo-hygiene | hygiene → controller/platform | Typed repo-agent scope/responsibility charter. |
| `platform-readiness` | platform-readiness | platform → orchestrator/gravity | k3s/RBAC/secrets/CI-CD/observability readiness. |
| `agent-platform-control-request` | platform-readiness | platform → Agent Platform | Proposed MCP/API op with policy/authz/result/review. |
| `environment-gitops-reconciliation` | platform-readiness / release-verification | platform → release | Desired/observed env state + drift + remediation. |
| `gravity-readiness` | gravity-readiness | gravity → approval gate | Gravity inventory + binary readiness checklist. |
| `gravity-core-extraction-plan` | gravity-readiness | gravity → pilot | Sunshine reuse matrix + generic-core/pack boundary. |

## Sprint & lane execution

| Schema | Owner | Produced → consumed | Purpose |
|---|---|---|---|
| `sprint-plan` | sprint-planning | planning → orchestrator | Approved sprint transaction snapshot. |
| `lane-map` | sprint-planning | planning → orchestrator | Lane topology + dependency order. |
| `lane-contract` | sprint-planning | planning → lane-delivery/critic | Executable bounded lane scope. |
| `wave-release-plan` | sprint-planning | planning → orchestrator/release | Branch/merge model, CI, environments, rollback. |
| `lane-lease` | CLI/validator | `lane create`/`review` → worker/critic | Durable lane identity + worktree lease. |
| `sprint-execution-runbook` | sprint-orchestrator | orchestrator → dispatch/recovery | Dispatch plan, cadence, session identities. |
| `lane-closeout` | lane-delivery | worker → critic | Worker closeout evidence (`ready_for_critic`). |
| `critic-report` | independent-critic | critic → orchestrator/release | Evidence-backed critic decision. |

## Review, release & operations

| Schema | Owner | Produced → consumed | Purpose |
|---|---|---|---|
| `review-inbox-packet` | release-verification | release → human reviewer | Aggregated review-ready evidence bundle. |
| `observability-diagnostic-packet` | release-verification / platform-readiness | release → reviewer | Correlated telemetry + signal assessment. |
| `release-verification` | release-verification | release → outcome | Integration + deployment verification record. |
| `outcome-review` | release-verification | release → router | Human outcome acceptance, separate from merge. |

## Compliance & evidence

| Schema | Owner | Produced → consumed | Purpose |
|---|---|---|---|
| `compliance-assessment` | CLI/validator (compliance gate) | assessor → CI | Executable operating-contract compliance result. |
| `evidence-manifest` | CLI/validator | packaging → audit | Hash manifest for an evidence bundle. |

See [`../authority-model.md`](../authority-model.md) for which artifact type owns
which truth when sources disagree.
