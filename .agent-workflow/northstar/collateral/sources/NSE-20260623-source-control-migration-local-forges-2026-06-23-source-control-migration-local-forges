# Source-Control Migration And Local Forge Patterns

Date: 2026-06-23
Discovery method: Brave Search API, followed by direct URL reachability checks.
Status: researched for North Star evidence ingest.

## Brave Search Coverage

- Query: `self hosted GitLab Gitea Forgejo CI runners container registry migration GitHub Actions alternatives`
- Follow-up queries: `GitLab import project from GitHub official docs`, `GitLab CI CD runners container registry official docs`, `Gitea actions runner packages container registry mirroring official docs`, `Forgejo Actions runner package registry official docs`.
- Selection rule: prefer official GitLab, Gitea, and Forgejo documentation.

## Primary Sources Followed

- GitLab import from GitHub: https://docs.gitlab.com/user/project/import/github/
- GitLab CI/CD: https://docs.gitlab.com/ci/
- GitLab Runner: https://docs.gitlab.com/runner/
- GitLab container registry: https://docs.gitlab.com/user/packages/container_registry/
- Gitea Act Runner: https://docs.gitea.com/usage/actions/act-runner
- Gitea repository mirroring: https://docs.gitea.com/usage/repo-mirror
- Gitea container registry/packages: https://docs.gitea.com/usage/packages/container
- Forgejo runner installation: https://forgejo.org/docs/latest/admin/actions/
- Forgejo Actions reference: https://forgejo.org/docs/latest/user/actions/reference/
- Forgejo packages: https://forgejo.org/docs/latest/user/packages/
- Forgejo container packages: https://forgejo.org/docs/latest/user/packages/container/

## Source-Backed Findings

- GitLab provides first-class GitHub project import, CI/CD, runners, and a container registry, making it the most complete single-platform migration target among the reviewed options.
- GitLab's breadth also implies more platform scope for readiness: project import, CI runner lifecycle, registry auth/storage, deployments, environments, and policy all need explicit operating ownership.
- Gitea provides repository mirroring, Actions via `act_runner`, and package/container registry support, making it a lighter local forge candidate when GitHub remains the authority or when only partial migration is desired.
- Forgejo provides Actions runner support and package/container registry documentation, making it a community-governed local forge candidate with GitHub Actions-like workflows.
- Because the current Verdify operating contract makes GitHub Issues and PRs the authoritative delivery control plane, a local forge should start as a mirrored or staged migration surface unless an explicit ADR changes backlog and delivery authority.

## Planning Relevance

- Supports `PRQ-010` and `ARQ-010`: GitHub remains authority until a migration ADR changes the control plane.
- Supports platform-readiness coverage for source-control migration: imports/mirrors, issue and PR authority, CI runner placement, registry auth/storage, deployment environment modeling, and reconciliation between GitHub and any local forge.
- Supports `ARCH-009` by treating source control, CI/CD, registry, and GitOps as one operating-plane release surface.

## Limitations

- This pass did not deploy GitLab, Gitea, or Forgejo locally.
- This pass did not validate migration fidelity for issues, PRs, reviews, checks, deployments, protected environments, or GitHub Projects.
