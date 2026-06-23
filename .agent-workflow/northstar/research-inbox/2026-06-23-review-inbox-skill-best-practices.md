# Review Inbox Skill Best Practices

Date: 2026-06-23
Search method: Brave Search API, followed by primary-source documentation review.
Scope: Define the first stable `review-inbox` packet contract for Verdify
Skills without changing the 17-skill lifecycle kernel.

## Brave Search Queries

- `site:docs.github.com deployments environments deployment protection rules pull request checks API`
- `site:docs.github.com checks API pull request status checks deployments environments review official`
- `GitLab review apps environments deployments merge requests docs.gitlab.com`
- `GitLab review apps dynamic environments auto stop docs.gitlab.com`
- `Argo CD ApplicationSet Pull Request generator readthedocs security templating project`
- `OpenGitOps principles desired state versioned immutable automatically pulled continuously reconciled`
- `GitHub managing environments for deployment required reviewers wait timer docs.github.com`
- `GitHub reviewing deployments required reviewers environments docs.github.com`

## Primary Sources Reviewed

- GitHub Docs, REST API endpoints for deployment environments:
  https://docs.github.com/en/rest/deployments/environments?apiVersion=2026-03-10
- GitHub Docs, REST API endpoints for deployments:
  https://docs.github.com/en/rest/deployments/deployments?apiVersion=2026-03-10
- GitHub Docs, REST API endpoints for check runs:
  https://docs.github.com/en/rest/checks/runs?apiVersion=2026-03-10
- GitHub Docs, REST API endpoints for workflow runs:
  https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2026-03-10
- GitHub Docs, managing environments for deployment:
  https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments
- GitHub Docs, REST API endpoints for pull requests:
  https://docs.github.com/en/rest/pulls/pulls?apiVersion=2026-03-10
- GitHub Docs, REST API endpoints for pull request reviews:
  https://docs.github.com/en/rest/pulls/reviews?apiVersion=2026-03-10
- GitHub Docs, REST API endpoints for review requests:
  https://docs.github.com/en/rest/pulls/review-requests?apiVersion=2026-03-10
- GitLab Docs, Review apps:
  https://docs.gitlab.com/ci/review_apps/
- GitLab Docs, Environments:
  https://docs.gitlab.com/ci/environments/
- Argo CD Docs, ApplicationSet Pull Request Generator:
  https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Pull-Request/
- Argo CD Docs, ApplicationSet Security:
  https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Security/
- OpenGitOps:
  https://opengitops.dev/

## Source-Backed Findings

- GitHub exposes repository environments through API records that include
  environment names, URLs, protection rules, reviewer rules, wait timers, and
  branch-policy information. A review packet should therefore record both the
  intended environment and the observed environment/protection state.
- GitHub deployment status records can represent queued, in-progress, failed,
  successful, and related deployment states, and can carry log URLs and summary
  descriptions. A review packet should keep deployment state and log evidence
  separate from human approval.
- GitHub check runs and workflow runs provide machine validation evidence tied
  to the pull request head. A review packet should require the exact reviewed
  head SHA and named check/workflow results rather than a generic "CI passed"
  claim.
- GitHub pull requests are connected to issue, commit, review, requested
  reviewer, and status APIs. A review packet should carry PR identity, linked
  issue IDs, reviewer state, and requested human decision separately.
- GitHub pull request reviews support approval, change-request, and comment
  outcomes. Verdify should map those to local recommendations while preserving
  its additional `reject` and `escalate` outcomes for governance and safety.
- GitLab Review Apps are temporary test environments for branches or merge
  requests and can expose a preview URL. GitLab environments distinguish static
  and dynamic targets and track deployment target, rollback, protection, and
  health concerns. This supports making review URL, environment type, TTL or
  stop policy, and deployment proof required packet fields when applicable.
- GitLab route maps link source files to public pages in a review app. Verdify
  can model this as optional reviewer guidance: changed paths may map to
  targeted human test URLs.
- Argo CD ApplicationSet Pull Request generators discover open PRs through SCM
  APIs and can create or remove preview applications as PR criteria change.
  They expose PR number, branch, target branch, labels, author, and head SHA,
  so Verdify packets should preserve PR-to-preview traceability.
- Argo CD warns that ApplicationSets can create many Applications, affect
  Projects, and reveal privileged information; only admins should be able to
  create, update, or delete ApplicationSets. Packets should treat preview
  generator configuration, templated project fields, and source-of-truth
  control as security-sensitive evidence.
- OpenGitOps frames delivery around declarative desired state, immutable
  versioned state, automatic pulls, and continuous reconciliation. Review inbox
  packets should record desired state references, observed runtime state, and
  reconciliation evidence instead of relying only on pipeline completion.

## Implementation Implications

- Keep `review-inbox` as a promoted capability contract for now, not a new
  canonical lifecycle skill, until the packet shape has one reliable manual
  run and stable ownership.
- Validate packets with `review-inbox-packet.schema.yaml`.
- Attach the packet to `release-verification` as a review-before-release mode,
  because the current lifecycle already owns integration, deployment proof,
  and outcome review.
- Required packet groups should include scope, traceability, CI/checks,
  review/preview deployment, reviewer guidance, telemetry, rollback, risks,
  questions, evidence completeness, recommendation, and feedback route.
- The packet must block review-ready status when required checks, preview or
  deployed environment, critical security disposition, rollback readiness, or
  exact head SHA evidence is missing.
- The next least-defined capability after this loop is likely
  `wave-release-planning`, because it must produce the upstream CI/CD and
  preview expectations consumed by `review-inbox`.

## Limitations

- The research emphasized GitHub because GitHub is the current Verdify delivery
  control plane. GitLab and Argo CD were used as primary-source examples for
  review apps and GitOps preview environments, not as approved platform
  migrations.
- The packet contract is a first manual contract, not proof that a top-level
  `review-inbox` skill should be added to the canonical kernel.
