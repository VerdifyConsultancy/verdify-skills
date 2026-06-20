# Prompt 07 — Compile Lane Contracts and Worker Prompts

## Variables

- `{{SPRINT_ID}}`
- `{{APPROVAL_RECORD_PATH}}`
- `{{WORKER_PROMPT_LIMIT}}` — default: 4,000 characters

## Prompt

Using the approved sprint plan, lane topology, decision register, GitHub issue assignments, and `{{APPROVAL_RECORD_PATH}}`, compile an authoritative contract for every lane in sprint `{{SPRINT_ID}}`.

GitHub issue assignment is part of the lane contract. Every included issue must appear in exactly one lane contract. If an issue is missing, duplicated across lanes, or too broad for one lane, stop and request topology correction before dispatch.

### Authoritative artifact

Create `.verdify/sprints/{{SPRINT_ID}}/lanes/<lane-id>/lane.yaml` conforming to `schemas/lane-contract.schema.yaml`.

It must include:

- identity, objective, desired outcome, and non-goals;
- assigned GitHub issue IDs/URLs;
- baseline revision and branch/worktree names;
- owned domains, paths, interfaces, and runtime resources;
- prohibited changes and coordination-required areas;
- hard/soft dependencies and expected inputs;
- implementation constraints;
- acceptance criteria;
- validation commands;
- required evidence;
- documentation/spec/GitHub issue update duties;
- feature branch, PR, and GitHub issue update rules;
- escalation conditions;
- critic and integration requirements;
- exact definition of done.

Also create:

- `lane.md` — human-readable contract;
- `worker-prompt.md` — no more than `{{WORKER_PROMPT_LIMIT}}` characters;
- `status.yaml` initialized to `NOT_STARTED`;
- `evidence.yaml` initialized empty.

### Worker-prompt compilation rules

The short worker prompt must:

1. identify the lane and objective;
2. tell the worker to read the common contract and authoritative `lane.yaml`;
3. summarize assigned GitHub issues, scope, boundaries, dependencies, acceptance criteria, and escalation conditions;
4. direct the worker to work autonomously within bounds;
5. require GitHub issue/PR updates, evidence, clean Git state, and adversarial self-audit;
6. avoid copying large repository context that the worker can inspect itself;
7. never omit a safety-critical constraint merely to fit the character limit.

Validate every lane YAML. Detect ownership overlaps and either remove them or add an explicit coordination rule and sequencing constraint.

Return a dispatch table with:

- lane ID;
- assigned GitHub issues;
- readiness;
- dependencies;
- worktree/branch;
- worker prompt character count;
- validation result;
- reason if not dispatchable.
