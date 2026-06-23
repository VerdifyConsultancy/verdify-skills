# Review Inbox Product Examples

Date: 2026-06-23
Discovery method: Brave Search API, followed by direct URL reachability checks.
Status: researched for North Star evidence ingest.

## Brave Search Coverage

- Query: `review inbox GitHub Checks deployments GitLab review apps Backstage Argo CD UI approval queue`
- Follow-up queries: `GitHub Checks API reviewing deployments environments official docs`, `GitLab review apps official docs`, `Backstage Argo CD plugin official docs`, `Argo CD ApplicationSet pull request generator official docs`.
- Selection rule: prefer official GitHub, GitLab, Backstage, and Argo CD documentation.

## Primary Sources Followed

- GitHub deployments and environments: https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments
- GitHub reviewing deployments: https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/review-deployments
- GitHub Checks REST API: https://docs.github.com/en/rest/checks
- GitLab Review Apps: https://docs.gitlab.com/ci/review_apps/
- Backstage plugins directory: https://backstage.io/plugins/
- Red Hat Argo CD plugin for Backstage: https://docs.redhat.com/en/documentation/red_hat_plug-ins_for_backstage/1.0/html/argocd_plugin_for_backstage/argocd-plugin-for-backstage
- Argo CD ApplicationSet Pull Request generator: https://argo-cd.readthedocs.io/en/latest/operator-manual/applicationset/Generators-Pull-Request/

## Source-Backed Findings

- GitHub environments and deployment reviews provide a native approval queue for jobs that target protected environments; reviewers can approve or reject pending deployments.
- GitHub Checks provide a structured surface for CI/status evidence associated with commits and pull requests.
- GitLab Review Apps provide per-branch or per-merge-request environments that let reviewers inspect live changes before merge.
- Backstage has a plugin ecosystem, including Argo CD visibility integrations, that can surface deployment and service context inside a developer portal.
- Argo CD ApplicationSet Pull Request generators can discover open pull requests and create matching Argo CD applications, but the official docs warn about admin-only creation and project templating risks because generated Applications can leak or misuse secrets if mis-scoped.
- A Verdify review inbox should compose these primitives rather than inventing everything from scratch: issue/PR identity, CI checks, deployment review status, preview/review URL, GitOps health, test steps, known risk, rollback context, and reviewer decisions.

## Planning Relevance

- Supports `SURF-004`, `IFACE-004`, `PRQ-004`, and `ARCH-008` with concrete product examples for review-ready work.
- Supports `ARCH-009` by linking review inbox state to protected deployments, dynamic review environments, GitOps preview generation, and rollback evidence.
- Supports platform-readiness checks for Argo CD ApplicationSet PR generators because misconfigured generated Applications can cross security boundaries.

## Limitations

- This pass did not build a Verdify review inbox UI.
- This pass did not test GitHub deployment approvals, GitLab Review Apps, Backstage plugins, or ApplicationSet PR generation in a live environment.
