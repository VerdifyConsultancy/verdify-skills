# Human And Managing-Agent Gates

Use this reference whenever the sprint reaches a human, policy, or managing-agent gate.

## Gate Lifecycle

1. Detect the gate condition from the current phase, lane status, policy, or failed deterministic check.
2. Write `.verdify/sprints/<sprint-id>/gates/<gate-id>.yaml`.
3. Include the smallest decision needed, available options, evidence, risk, and the allowed resolver.
4. Stop risky work until the gate is resolved.
5. Resume only after the artifact records a decision, resolver, timestamp, and evidence links.
6. Update `.verdify/sprints/<sprint-id>/state.yaml` and any affected lane, decision, issue, PR, or deployment record.

## Gate Types

| Type | Trigger | Default Resolver |
|---|---|---|
| `review_input` | Sprint review transcript, notes, or recording is needed | human |
| `decision` | Product, architecture, scope, sequencing, or risk choice is blocking progress | human |
| `plan_approval` | Sprint plan and lane topology are ready for approval | human |
| `scope_change` | A lane needs work outside its contract | human or managing agent, if policy allows |
| `policy_exception` | A required check failed and an exception is requested | human |
| `deployment_approval` | Deployment requires explicit authorization | human or deployment policy |
| `incident` | Deployment failed or rollback needs a decision | human |
| `outcome_acceptance` | Sprint closeout requires final acceptance | human |

## Managing-Agent Resolution

A managing agent may resolve a gate only when all of these are true:

- the gate artifact sets `resolver.allowed` to `managing_agent` or `human_or_managing_agent`;
- the policy cited in `resolver.policy_ref` grants that authority;
- the decision does not involve irreversible production, security, legal, financial, or data-loss risk;
- the managing agent records the evidence and reasoning used;
- the decision can be audited from artifacts without hidden chat context.

If any condition is missing, escalate to a human.

## Gate Artifact Requirements

Every gate artifact must include:

- `id`, `sprint_id`, `type`, `state`, `created_at`;
- `trigger.phase` and `trigger.reason`;
- `question`;
- at least one `options` item, unless the gate is pure input collection;
- `resolver.allowed`;
- `evidence_required`;
- `resume_conditions`.

Resolved gates must also include:

- `decision.selected_option` or `decision.answer`;
- `decision.resolved_by`;
- `decision.resolved_at`;
- `decision.evidence`;
- `state: RESOLVED`.

## Resume Rule

Never resume risky work from a gate based only on a chat reply. First write the resolved gate artifact, then update workflow state and downstream contracts.
