# Kubernetes, GitOps, And CI/CD Cardinality Research

Date: 2026-06-23

## Scope

Primary-source check for the Agent Platform pilot's repository, application,
environment, namespace, and wave deployment model.

## Sources

- Kubernetes Namespaces: https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/
- Kubernetes ResourceQuotas: https://kubernetes.io/docs/concepts/policy/resource-quotas/
- Kubernetes RBAC good practices: https://kubernetes.io/docs/concepts/security/rbac-good-practices/
- Kubernetes NetworkPolicies: https://kubernetes.io/docs/concepts/services-networking/network-policies/
- Flux repository structure: https://fluxcd.io/flux/guides/repository-structure/
- Flux multi-tenancy reference repository: https://github.com/fluxcd/flux2-multi-tenancy
- Argo CD ApplicationSet pull request generator: https://argo-cd.readthedocs.io/en/latest/operator-manual/applicationset/Generators-Pull-Request/
- GitHub Actions environments: https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments
- GitHub protected branches: https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches

## Evidence Notes

- Kubernetes namespaces are a scope for namespaced resources and can divide
  cluster resources between users through ResourceQuota. They are appropriate
  when their scoping features are needed, and the production default namespace
  should be avoided.
- ResourceQuota constrains aggregate resource consumption per namespace and can
  reject API requests that exceed hard limits.
- Kubernetes RBAC guidance recommends least privilege, namespace-level
  RoleBindings where possible, and care around secret listing, workload
  creation, and weak boundaries inside a namespace.
- NetworkPolicy defaults to allow traffic if no policy exists, so preview and
  environment namespaces need explicit default-deny or allow policies.
- Flux documents monorepo, repo-per-environment, repo-per-team, and repo-per-app
  structures; its multi-tenancy reference uses namespaces, RBAC, and tenant
  service accounts, with staging and production overlays.
- Argo CD's PR generator directly supports pull-request-driven test
  environments, but the docs warn that administrators should control
  ApplicationSet creation because PR generator configuration can leak secrets
  or grant out-of-bounds resource management.
- GitHub Actions environments can require reviewers before jobs run or secrets
  are exposed. Protected branches can require reviews, required status checks,
  and successful deployments before merge.

## Planning Implication

Treat a repository/application as the durable product boundary. Model dev,
staging, production, and preview as environment-scoped namespaces or namespace
sets with ResourceQuota, RBAC, NetworkPolicy, secret references, endpoints, and
observability declared per environment. Use CI/CD wave deployment as the core
delivery path: branch or PR creates CI evidence and a preview/review deployment;
protected environments and GitOps promotion control staging and production.
