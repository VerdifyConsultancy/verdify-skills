# Prompt 01 — Discover and Adversarially Audit

## Variables

- `{{SPRINT_ID}}`
- `{{RECENT_HISTORY_WINDOW}}`
- `{{TARGET_ENVIRONMENT}}`
- `{{DEPLOYMENT_ACCESS_POLICY}}`

## Prompt

Continue as the Controller for sprint `{{SPRINT_ID}}`. Perform a read-only reconstruction and adversarial audit of the current project and, where authorized, the deployed system.

Your goal is not merely to summarize documentation. Your goal is to determine what is actually true, where sources disagree, what is fragile, and what decisions or work the next sprint may require.

### Evidence to inspect

1. Repository instructions and architecture/design documentation.
2. Documents modified during `{{RECENT_HISTORY_WINDOW}}`.
3. Recent commits, merges, tags, releases, and meaningful diffs.
4. Open and recently closed GitHub issues, PRs, milestones, discussions, and planning/MVP documents.
5. Source architecture, dependency boundaries, public and internal interfaces, data flows, configuration, and generated code.
6. Test suites, coverage indicators, CI/CD workflows, failed or flaky checks, and release gates.
7. Deployment manifests and infrastructure code.
8. In `{{TARGET_ENVIRONMENT}}`, subject to `{{DEPLOYMENT_ACCESS_POLICY}}`: deployed revision/image digest, workloads, pods/containers, services, routes, health, logs, events, resource state, and externally observable behavior.
9. Drift among docs, issues, code, CI, and runtime.

### Review method

Use independent read-only subagents when available. Suggested review domains are:

- repository history and planning;
- architecture and code boundaries;
- tests, reliability, and security;
- infrastructure and runtime;
- product/UI behavior where relevant.

Subagent reports are inputs, not truth. Reconcile them yourself and remove unsupported claims.

For every material finding, record:

- severity: `CRITICAL`, `HIGH`, `MEDIUM`, `LOW`, or `NOTE`;
- confidence;
- status: `verified`, `observed`, `reported`, `inferred`, or `unknown`;
- evidence source and location;
- consequence;
- likely remediation or decision required;
- related issue/PR/spec if one exists.

Do not modify production, code, issues, or specs during this phase. You may draft candidate issue text under the sprint workspace.

### Required artifacts

Create or update:

- `.verdify/sprints/{{SPRINT_ID}}/baseline/repository-map.md`
- `.verdify/sprints/{{SPRINT_ID}}/baseline/runtime-map.md`
- `.verdify/sprints/{{SPRINT_ID}}/baseline/adversarial-audit.md`
- `.verdify/sprints/{{SPRINT_ID}}/baseline/evidence.yaml`
- `.verdify/sprints/{{SPRINT_ID}}/baseline/candidate-issues.md`

The audit must include:

- current-system summary;
- component and interface map;
- deployed-state summary and confidence;
- issue/documentation drift;
- recent-change risk review;
- top defects and operational concerns;
- architecture uncertainties;
- candidate sprint themes;
- questions that cannot be answered from available evidence.

Conclude with one of:

- `READY_FOR_HUMAN_REVIEW`
- `BLOCKED_MISSING_EVIDENCE`
- `INCIDENT_REQUIRES_IMMEDIATE_ATTENTION`
