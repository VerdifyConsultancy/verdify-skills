# Prompt 09 — Lane Status and Controller Guidance

This file contains two prompt variants: one for the lane worker and one for the controller.

---

## A. Lane worker status prompt

### Variables

- `{{SPRINT_ID}}`
- `{{LANE_ID}}`

### Prompt

Report the current state of lane `{{LANE_ID}}` in sprint `{{SPRINT_ID}}` using only verified information.

Update the lane's `status.yaml`, then return this structure:

```yaml
lane_id: <id>
state: <standard state>
head_sha: <sha>
working_tree_clean: <true|false>
completed:
  - <completed outcome with evidence ID>
in_progress:
  - <current work>
next_actions:
  - <next action>
acceptance_progress:
  passed: [<criterion IDs>]
  pending: [<criterion IDs>]
  failed: [<criterion IDs>]
blockers:
  - id: <blocker ID>
    description: <specific blocker>
    evidence: <source>
decisions_requested:
  - id: <decision ID>
    question: <one decision question>
    options: [<option>]
    recommendation: <recommended option and rationale>
scope_change_requested:
  requested: <true|false>
  reason: <reason>
  affected_paths_or_contracts: [<items>]
risks:
  - <new or changed risk>
evidence_added:
  - <evidence IDs>
```

Do not provide a narrative progress performance. Surface only state, evidence, decisions, blockers, and next actions.

---

## B. Controller guidance prompt

### Variables

- `{{SPRINT_ID}}`
- `{{LANE_ID}}`
- `{{STATUS_REPORT_PATH}}`

### Prompt

Review the structured status report for lane `{{LANE_ID}}` at `{{STATUS_REPORT_PATH}}` against the approved sprint plan, lane contract, decisions, dependencies, and other active lanes.

Do not casually expand scope. Determine whether the issue can be resolved from existing artifacts before asking the human.

Choose exactly one action:

- `CONTINUE`
- `REDIRECT`
- `PAUSE`
- `APPROVE_SCOPE_CHANGE`
- `REJECT_SCOPE_CHANGE`
- `ESCALATE_TO_HUMAN`
- `CANCEL`

Return:

```yaml
action: <one allowed action>
rationale: <brief evidence-based rationale>
instructions:
  - <precise next action>
contract_changes:
  - <approved contract edit, or none>
dependencies_or_other_lanes_affected:
  - <impact, or none>
human_question: <only if escalation is required>
resume_condition: <objective condition>
```

If approving a scope change, update the lane contract, sprint plan, conflict matrix, and affected lane contracts before work resumes. Never authorize a material API, schema, security, or production-risk change through a casual chat reply.
