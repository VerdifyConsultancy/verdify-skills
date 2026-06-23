# Review Inbox And Wave Release Primary Sources

Date: 2026-06-23
Evidence status: observed

## Scope

This note follows primary or near-primary documentation for review-ready work,
CI/CD wave deployment, GitOps preview/review environments, branch/issue
coordination, and progressive delivery.

## Followed Sources

- GitHub deployments and environments:
  https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments
- GitHub managing environments:
  https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments
- GitHub issues:
  https://docs.github.com/en/issues/tracking-your-work-with-issues/learning-about-issues/about-issues
- GitHub sub-issues:
  https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/adding-sub-issues
- GitHub merge queue:
  https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue
- OpenGitOps principles:
  https://opengitops.dev/
- Argo CD pull request generator:
  https://argo-cd.readthedocs.io/en/latest/operator-manual/applicationset/Generators-Pull-Request/
- Argo CD sync phases and waves:
  https://argo-cd.readthedocs.io/en/stable/user-guide/sync-waves/
- Argo CD project README:
  https://github.com/argoproj/argo-cd
- Argo Rollouts:
  https://argo-rollouts.readthedocs.io/en/stable/
- Flux repository structure:
  https://fluxcd.io/flux/guides/repository-structure/

## Observed Findings

- GitHub environments provide deployment protection rules that can require
  manual approval, wait timers, branch restrictions, or custom protection rules
  before a job referencing an environment proceeds.
- GitHub required environment reviewers can include users or teams, with only
  one listed reviewer required to approve a deployment job before it proceeds;
  repository plan and visibility affect availability for private repositories.
- GitHub Issues now support metadata, dependencies, sub-issues, nested
  hierarchies, and CLI support for creating or attaching sub-issues. That makes
  issue trees a credible backbone for initiatives, waves, and task lanes.
- GitHub merge queues validate pull requests against the latest target branch
  plus queued changes before merge. Required CI must run on `merge_group`
  events for merge queues to work correctly.
- OpenGitOps defines GitOps through declarative desired state, versioned and
  immutable storage, automatic pull by agents, and continuous reconciliation.
- Argo CD's ApplicationSet pull request generator discovers open pull requests
  through SCM provider APIs and fits creating per-PR test environments.
- Argo CD sync phases support pre-sync checks, sync, post-sync checks, failure
  hooks, and deletion hooks. The docs explicitly describe pre-sync checks and
  post-sync smoke tests as deployment validation points.
- Argo CD sync waves are deployment-order mechanics. They should not be
  confused with Verdify product-delivery waves, but they are useful inside a
  release plan for sequencing resources.
- Argo CD's project README frames application definitions, configurations, and
  environments as declarative and version controlled, with automated,
  auditable deployment/lifecycle management.
- Argo Rollouts supplies Kubernetes CRDs and controller behavior for blue-green,
  canary, analysis, experimentation, and progressive delivery.
- Flux documents monorepo, repo-per-environment, repo-per-team, and repo-per-app
  structures. That supports treating repository/environment cardinality as an
  explicit platform-readiness decision instead of an ad hoc convention.

## North Star Implications

- `review-inbox` should require PR/issue identity, CI status, deployment
  environment state, preview/review URL, test steps, rollback context,
  questions, and a recommendation before work is marked review-ready.
- `wave-release-planning` should be promoted or modeled as a mode before lane
  dispatch because deployment evidence, preview environment shape, promotion,
  and rollback criteria affect implementation scope.
- Verdify product waves should remain distinct from Argo CD sync waves. Product
  waves describe delivery increments; Argo CD sync waves sequence resources
  during reconciliation.
- `github-backlog-sync` can remain mode-first, but it should account for issue
  dependencies, sub-issues, PR linkage, deployment checks, and merge queue
  constraints.
- GitOps promotion should keep desired environment state versioned and
  reconciled instead of relying on private controller state alone.

## Limitations

- This note covers public primary documentation, not a live GitHub organization
  settings audit.
- GitHub feature availability depends on repository visibility and plan.
- This note does not select Argo CD versus Flux for implementation; it records
  source-backed implications for the North Star.
