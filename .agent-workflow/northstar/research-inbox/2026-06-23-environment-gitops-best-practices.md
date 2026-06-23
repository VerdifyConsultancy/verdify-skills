# Environment GitOps Implementation Best Practices

Date: 2026-06-23

Scope: Define the first stable `environment-gitops` reconciliation contract for Verdify platform readiness, wave planning, release verification, and OpenClaw SDLC release workflows.

Discovery method: Brave Search API using Jason's local Brave Search credential. Queries targeted official OpenGitOps, Argo CD, Flux, Kubernetes, and GitHub Actions documentation for desired state, reconciliation, health/sync status, preview environments, namespace policy, deployment environments, and remediation.

## Primary Sources

- OpenGitOps principles:
  https://opengitops.dev/
- Argo CD sync phases and waves:
  https://argo-cd.readthedocs.io/en/stable/user-guide/sync-waves/
- Argo CD resource health:
  https://argo-cd.readthedocs.io/en/stable/operator-manual/health/
- Argo CD ApplicationSet pull request generator:
  https://argo-cd.readthedocs.io/en/latest/operator-manual/applicationset/Generators-Pull-Request/
- Flux Kustomizations:
  https://fluxcd.io/flux/components/kustomize/kustomizations/
- Flux HelmReleases:
  https://fluxcd.io/flux/components/helm/helmreleases/
- Kubernetes ResourceQuotas:
  https://kubernetes.io/docs/concepts/policy/resource-quotas/
- Kubernetes NetworkPolicies:
  https://kubernetes.io/docs/concepts/services-networking/network-policies/
- Kubernetes liveness/readiness/startup probes:
  https://kubernetes.io/docs/concepts/configuration/liveness-readiness-startup-probes/
- GitHub Actions deployments and environments:
  https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments

## Findings

- GitOps environment evidence should explicitly separate desired state from observed state. OpenGitOps defines the core loop as declarative desired state, versioned/immutable storage, automatic pull, and continuous reconciliation.
- Argo CD reconciliation should record sync phase/wave, sync status, health status, hook or sync-failure behavior, ApplicationSet or pull-request generator context, and any security limitation around generated preview environments.
- Flux reconciliation should record Kustomization or HelmRelease status, ready conditions, inventory or applied resources, remediation behavior, and interval/suspend context when relevant.
- Kubernetes environment readiness should record namespace, ResourceQuota, LimitRange when relevant, NetworkPolicy/default-deny posture, service account/RBAC boundary, probe coverage, endpoint/ingress evidence, PVC/storage signals, and TTL or cleanup policy for preview environments.
- GitHub deployment environments should record environment name, required reviewers/protection, deployment URL, status, and relationship to CI/CD checks and release verification.
- A merged PR or successful CI check is not enough environment evidence; the artifact should capture the target environment's observed controller state, health, endpoint evidence, rollback/remediation path, and unresolved drift.

## Verdify Contract Implications

- Add `environment-gitops-reconciliation.schema.yaml` as the first environment GitOps mode artifact.
- Own the first manual runs under `platform-readiness`, with `sprint-planning` and `release-verification` consuming the artifact when wave/release proof depends on GitOps state.
- Require fields for environment identity, desired state refs, controller observations, namespace controls, deployment evidence, health signals, drift findings, remediation/rollback, review gate, and handoff.
- Keep production mutation outside this artifact; the record proves readiness/reconciliation and routes required action to the authorized control plane.

## Limitations

- This evidence defines reconciliation artifact shape and stop conditions. It does not grant cluster or GitOps mutation authority.
- Argo CD, Flux, GitHub environments, and Kubernetes policy features may not all be installed in a target environment; missing or not-applicable sources must be recorded explicitly.
