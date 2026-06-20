# Human-In-The-Loop Gates

Verdify gates are explicit pause points where a sprint cannot safely continue until a person, policy, or authorized managing agent resolves a narrow question.

## End-To-End Flow

1. A phase detects ambiguity, missing input, approval need, failed check, scope change, deployment risk, or final acceptance.
2. The active agent writes `.verdify/sprints/<sprint-id>/gates/<gate-id>.yaml`.
3. The gate artifact names the phase, reason, resolver, options, required evidence, and resume conditions.
4. Risky work stops.
5. The human, policy, or managing agent resolves the gate in the artifact.
6. The active agent updates `.verdify/sprints/<sprint-id>/state.yaml` and any impacted lane, decision, issue, PR, or deployment record.
7. Work resumes from durable state, not from hidden chat memory.

## Gate Classes

| Class | Example | Default Resolver |
|---|---|---|
| Input | Sprint review transcript is needed | human |
| Decision | Architecture tradeoff blocks planning | human |
| Approval | Lane topology is ready to launch | human |
| Scope change | Lane needs out-of-contract files | human or managing agent |
| Exception | Required quality check failed | human |
| Deployment | Production rollout needs approval | human or policy |
| Incident | Rollback choice is needed | human |
| Acceptance | Sprint closeout needs final signoff | human |

## Procedural vs Mechanical Gates

In a plain Codex, Claude Code, Aider, Goose, Cline, or OpenHands session, gates are procedural. The skill instructs the agent to stop and record the gate. This is common practice across public skill repositories because skills are portable instruction packages, not durable workflow engines.

Mechanical enforcement comes from one of these layers:

- host approval controls and sandbox policy;
- bundled scripts that fail closed;
- CI jobs and branch protection;
- MCP or app-level permission prompts;
- a managing agent that watches sprint artifacts;
- a durable workflow engine that consumes `verdify.workflow.yaml`.

## Managing Agent Rules

A managing agent may resolve a gate only when:

- the gate artifact allows `managing_agent` or `human_or_managing_agent`;
- a policy reference grants that authority;
- the choice is reversible and low enough risk for delegated handling;
- all required evidence exists;
- the resolution is written to the gate artifact before work resumes.

Otherwise, the managing agent must escalate to a human.

## Required Artifacts

- Gate schema: `schemas/human-gate.schema.yaml`
- Gate template: `templates/human-gate-record.md`
- Workflow map: `verdify.workflow.yaml`
- Sprint state: `.verdify/sprints/<sprint-id>/state.yaml`

## First Codex Test

Use the repo-scoped skill through `.agents/skills/verdify-agentic-sprint` and ask:

```text
$verdify-agentic-sprint start a test sprint for this repository with sprint id 2026-06-20-test. Create planning artifacts only and stop at the first human gate.
```

Expected behavior:

- Codex loads the skill explicitly.
- It reads only the common contract and current phase reference.
- It creates `.verdify/sprints/2026-06-20-test/` artifacts.
- It stops at the first human gate instead of proceeding from assumption.
