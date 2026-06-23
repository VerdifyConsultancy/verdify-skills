# Wave Release Planning Best Practices

Date: 2026-06-23
Search method: Brave Search API, followed by primary-source documentation review.
Scope: Define the first stable `wave-release-planning` artifact contract for
Verdify Skills as a sprint-planning mode before dispatch.

## Brave Search Queries

- `site:docs.github.com actions environments deployment protection rules merge queue workflow concurrency official`
- `site:docs.github.com merge queue required checks merge_group GitHub Actions official docs`
- `site:argo-cd.readthedocs.io sync waves phases hooks health rollback official docs`
- `site:argo-rollouts.readthedocs.io canary blue green analysis rollback official docs`
- `site:fluxcd.io remediation rollback health checks HelmRelease Kustomization official docs`
- `site:kubernetes.io namespace ResourceQuota NetworkPolicy LimitRange preview environment official docs`
- `site:opengitops.dev GitOps principles declarative versioned immutable pulled automatically reconciled`

## Primary Sources Reviewed

- GitHub Docs, managing a merge queue:
  https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue
- GitHub Docs, workflow syntax and concurrency:
  https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax
- GitHub Docs, managing environments for deployment:
  https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments
- GitHub Docs, deployment environments API:
  https://docs.github.com/en/rest/deployments/environments?apiVersion=2026-03-10
- GitHub Docs, deployments API:
  https://docs.github.com/en/rest/deployments/deployments?apiVersion=2026-03-10
- Argo CD Docs, sync phases and waves:
  https://argo-cd.readthedocs.io/en/stable/user-guide/sync-waves/
- Argo Rollouts Docs, canary strategy:
  https://argo-rollouts.readthedocs.io/en/stable/features/canary/
- Argo Rollouts Docs, blue-green strategy:
  https://argo-rollouts.readthedocs.io/en/stable/features/bluegreen/
- Flux Docs, Kustomization:
  https://fluxcd.io/flux/components/kustomize/kustomizations/
- Flux Docs, HelmRelease:
  https://fluxcd.io/flux/components/helm/helmreleases/
- Kubernetes Docs, ResourceQuota:
  https://kubernetes.io/docs/concepts/policy/resource-quotas/
- Kubernetes Docs, LimitRange:
  https://kubernetes.io/docs/concepts/policy/limit-range/
- Kubernetes Docs, NetworkPolicy:
  https://kubernetes.io/docs/concepts/services-networking/network-policies/
- OpenGitOps:
  https://opengitops.dev/

## Source-Backed Findings

- GitHub merge queues validate queued pull requests against the latest target
  branch plus queued changes and require CI to report required checks for merge
  groups. Wave release plans should record whether `merge_group` checks are
  required, which checks are required, and whether queue group size or timeout
  settings affect release cadence.
- GitHub environments and deployment records provide deployment targets,
  protection rules, reviewers, wait timers, branch policies, deployment state,
  log URLs, and environment URLs. Wave plans should define environment
  protection and deployment evidence before dispatch.
- Argo CD sync phases and waves provide ordered GitOps application of resources
  and health-driven progression. Wave release plans should distinguish Verdify
  product waves from Argo CD sync waves while still recording any GitOps sync
  order and health requirements.
- Argo Rollouts canary and blue-green strategies support progressive delivery
  and analysis gates. Wave plans should record deployment strategy, traffic
  steps, promotion criteria, abort triggers, and rollback readiness when a wave
  affects runtime traffic.
- Flux Kustomizations reconcile desired state from Git artifacts and expose
  applied revision/status conditions. Flux HelmRelease remediation supports
  retry, rollback, or uninstall behavior for failed installs/upgrades. Wave
  plans should record desired-state refs, reconciliation checks, and remediation
  policy for Flux-managed systems.
- Kubernetes ResourceQuota and LimitRange constrain per-namespace resource use
  and admission behavior; NetworkPolicy controls pod communication. Preview or
  review environments should record namespace, quota, limit, network policy,
  TTL, and secrets scope before worker dispatch.
- OpenGitOps emphasizes declarative desired state, versioned immutable state,
  automatic pull, and continuous reconciliation. Wave plans should require both
  desired-state references and observed reconciliation evidence.

## Implementation Implications

- Keep `wave-release-planning` as a sprint-planning mode first, not a new
  top-level canonical skill, until one reliable manual run proves ownership and
  the artifact shape.
- Add `wave-release-plan.schema.yaml`.
- Required artifact groups should cover scope, branch/merge model, GitHub
  checks/queue, CI workflows, environments, GitOps desired state, deployment
  strategy, observability, rollback, release-health signals, review handoff,
  risks, and approval.
- `sprint-planning` should treat the wave release plan as part of the plan
  transaction and dispatch gate for any wave with deployment, preview, or
  release-health implications.
- `review-inbox` should consume the wave release plan as an upstream source for
  required checks, preview/review deployment evidence, rollback, and telemetry.

## Limitations

- GitHub remains the current Verdify delivery control plane. Argo CD, Argo
  Rollouts, Flux, and Kubernetes sources are implementation patterns for future
  pilots, not approvals for a specific runtime stack.
- This contract does not decide whether Verdify should use per-lane branches,
  wave branches, merge queues, or another release identity model in every repo;
  it records the decision and evidence requirements for a specific wave.
