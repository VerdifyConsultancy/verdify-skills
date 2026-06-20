# Prompt 13 — Deploy and Verdify the Runtime

## Variables

- `{{SPRINT_ID}}`
- `{{TARGET_ENVIRONMENT}}`
- `{{TARGET_REVISION}}`
- `{{DEPLOYMENT_COMMAND_OR_PIPELINE}}`
- `{{APPROVAL_POLICY}}`
- `{{ROLLBACK_POLICY}}`

## Prompt

Act as the deployment verifier for sprint `{{SPRINT_ID}}` targeting `{{TARGET_ENVIRONMENT}}` at revision `{{TARGET_REVISION}}`.

Read the integration report and common operating contract. Follow `{{APPROVAL_POLICY}}`; do not initiate a production-changing action without the required approval.

All target repositories are expected to test and deploy through GitHub CI/CD. Treat GitHub Actions workflow runs, check suites, deployment records, and environment approvals as primary deployment evidence.

### Before deployment

Record:

- current deployed revision/image digests;
- workload health and error baseline;
- pending migrations or irreversible actions;
- rollback target and rollback procedure;
- target artifacts and their provenance;
- GitHub CI/CD workflow run and check status;
- approval record.

### Deployment

Execute or observe `{{DEPLOYMENT_COMMAND_OR_PIPELINE}}`. Capture GitHub Actions workflow run IDs, job IDs, check URLs, timestamps, artifact digests, rollout events, and failures.

A successful pipeline is not sufficient proof of a successful release.

### Runtime verification

Verdify at minimum:

1. deployed revision or image digest matches `{{TARGET_REVISION}}` and the intended build;
2. workloads, pods/containers, services, jobs, and routes are healthy;
3. migrations completed in the intended order;
4. logs and events show no new material errors;
5. health/readiness checks are meaningful and passing;
6. sprint-level runtime acceptance criteria pass;
7. critical user journeys or synthetic checks pass;
8. metrics and resource behavior show no unacceptable regression;
9. rollback remains possible under `{{ROLLBACK_POLICY}}`.

For every check, record the environment, revision, command/source, result, artifact, and limitations.

On failure:

- stop further rollout when safe;
- follow the approved rollback or remediation policy;
- preserve evidence;
- do not claim success after a partial rollback;
- create an incident/follow-up record as required.

Create:

- `.verdify/sprints/{{SPRINT_ID}}/deployment/deployment-record.yaml`
- `.verdify/sprints/{{SPRINT_ID}}/deployment/evidence.yaml`
- `.verdify/sprints/{{SPRINT_ID}}/deployment/verification-report.md`

Choose exactly one outcome:

- `DEPLOYMENT_VERIFIED`
- `DEPLOYMENT_VERIFIED_WITH_FOLLOWUPS`
- `ROLLED_BACK`
- `FAILED_UNRESOLVED`
- `DECISION_REQUIRED`
