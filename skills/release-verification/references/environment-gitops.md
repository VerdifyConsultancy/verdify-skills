# Environment GitOps Reconciliation

Use this reference when deployment verification depends on GitOps desired state,
observed controller state, namespace controls, drift, remediation, rollback, or
cleanup evidence.

## Inputs

- Desired-state refs: commit, manifest path, chart, Kustomization, image
  digest, workflow run, deployment record, or equivalent source of truth.
- Controller observations: Argo CD, Flux, GitHub deployment environment, or an
  explicitly named manual controller.
- Namespace controls: namespace, resource quotas, limits, network policy,
  service account, RBAC summary, secrets model, storage, and cleanup policy.
- Runtime evidence: health checks, probes, smoke tests, logs, metrics, traces,
  deployment markers, migration evidence, endpoint status, and rollback refs.

## Procedure

1. Identify the environment, cluster or controller, namespace, protection level,
   URL, and TTL or cleanup policy.
2. Record desired state separately from observed state, with exact revision or
   artifact refs for each.
3. Record controller sync and health status with observation timestamps and
   evidence refs.
4. Record namespace controls and explicitly mark any missing controls.
5. Record deployment proof, observed revision, image refs, endpoints, logs,
   migrations, and runtime checks separately from CI status.
6. Record drift, remediation, rollback, and cleanup findings with severity,
   evidence, required action, and whether approved mutation is required.
7. Validate any environment reconciliation artifact against
   `../../schemas/environment-gitops-reconciliation.schema.yaml`.

Stop deployment verification and route to the authorized platform or release
owner when desired and observed state disagree, controller health is degraded,
namespace controls are unsafe, protected-environment mutation lacks approval, or
runtime health evidence is missing for a material release decision.
