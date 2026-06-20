# Gate: <gate-id>

## Status

- Sprint: `<sprint-id>`
- Lane: `<lane-id or none>`
- Type: `<review_input | decision | plan_approval | scope_change | policy_exception | deployment_approval | incident | outcome_acceptance>`
- State: `<OPEN | RESOLVED | CANCELLED>`
- Created: `<ISO-8601 timestamp>`

## Trigger

- Phase: `<workflow phase>`
- Reason: `<why progress cannot safely continue>`
- Source artifacts:
  - `<path or URL>`

## Question

`<single decision, approval, or input request>`

## Options

| ID | Option | Impact | Risk |
|---|---|---|---|
| `<id>` | `<label>` | `<expected impact>` | `<low | medium | high | critical>` |

## Required Evidence

- `<artifact, test, policy, or runtime proof required before resolution>`

## Resolver

- Allowed resolver: `<human | managing_agent | human_or_managing_agent | policy>`
- Policy reference: `<policy path or URL>`
- Assigned to: `<name, team, or role>`

## Resume Conditions

- `<condition that must be true before work resumes>`

## Resolution

- Selected option or answer: `<pending>`
- Resolved by: `<pending>`
- Resolved at: `<pending>`
- Evidence:
  - `<pending>`
- Notes: `<pending>`
