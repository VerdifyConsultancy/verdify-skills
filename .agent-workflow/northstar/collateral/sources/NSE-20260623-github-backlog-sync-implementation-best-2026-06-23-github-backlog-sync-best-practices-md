# GitHub Backlog Sync Implementation Best Practices

Date: 2026-06-23

Scope: Define a stronger `github-backlog-sync` contract for Verdify state-of-union and sprint reconciliation while preserving GitHub Issues, pull requests, checks, reviews, deployments, and projects as the operational source of truth.

Discovery method: Brave Search API using Jason's local Brave Search credential. Queries targeted official GitHub documentation for REST issues, pull requests, checks, workflow runs, deployments, environments, issue timeline events, issue dependencies, sub-issues, Projects, and issue/PR search.

## Primary Sources

- GitHub REST Issues, API version 2026-03-10:
  https://docs.github.com/en/rest/issues/issues?apiVersion=2026-03-10
- GitHub REST Issue Timeline, API version 2026-03-10:
  https://docs.github.com/en/rest/issues/timeline?apiVersion=2026-03-10
- GitHub REST Issue Dependencies, API version 2026-03-10:
  https://docs.github.com/en/rest/issues/issue-dependencies?apiVersion=2026-03-10
- GitHub REST Sub-Issues, API version 2026-03-10:
  https://docs.github.com/en/rest/issues/sub-issues?apiVersion=2026-03-10
- GitHub REST Pull Requests, API version 2026-03-10:
  https://docs.github.com/en/rest/pulls/pulls?apiVersion=2026-03-10
- GitHub REST Check Runs, API version 2026-03-10:
  https://docs.github.com/en/rest/checks/runs?apiVersion=2026-03-10
- GitHub REST Workflow Runs, API version 2026-03-10:
  https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2026-03-10
- GitHub REST Deployments, API version 2026-03-10:
  https://docs.github.com/en/rest/deployments/deployments?apiVersion=2026-03-10
- GitHub REST Deployment Statuses, API version 2026-03-10:
  https://docs.github.com/en/rest/deployments/statuses?apiVersion=2026-03-10
- GitHub REST Deployment Environments, API version 2026-03-10:
  https://docs.github.com/en/rest/deployments/environments?apiVersion=2026-03-10
- GitHub issue and pull request search:
  https://docs.github.com/en/search-github/searching-on-github/searching-issues-and-pull-requests
- GitHub Projects API guide:
  https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project/using-the-api-to-manage-projects
- GitHub Issues overview:
  https://docs.github.com/en/issues/tracking-your-work-with-issues/learning-about-issues/about-issues

## Findings

- GitHub's issue endpoints are shared with pull-request issue records, so backlog snapshots must distinguish issues from PR-backed issue objects and should also capture PR objects directly.
- Backlog reconciliation needs more than issue existence. It should record labels, assignees, milestone, issue type, state reason when available, updated timestamp, URL, linked pull requests, timeline signals, sub-issues, dependencies, and project fields when available.
- Lane reconciliation should compare lane contracts against issue IDs, branch names, PR head/base branches, PR state, draft state, closing-link coverage, checks/workflow runs, deployment records, and deployment statuses.
- GitHub search qualifiers remain useful for discovery, but durable reconciliation should store the exact query or API source used and treat snapshots as caches, not authority.
- Dependencies and sub-issues are now first-class enough to model separately from labels or markdown checklists when available.
- Runtime delivery evidence belongs with GitHub deployment, deployment status, environment, check-run, and workflow-run references instead of being inferred from a merged PR.

## Verdify Contract Implications

- Keep `github-snapshot.schema.yaml` as the cache contract, but include optional richer collections for checks, workflow runs, deployments, environments, project items, dependencies, and sub-issues.
- Strengthen `github-reconciliation.schema.yaml` into a `github-backlog-sync` mode artifact with source freshness, authority boundary, lane findings, issue findings, PR findings, delivery findings, actions, and handoff.
- Keep the first implementation under `state-of-union` and `sprint-orchestrator` rather than promoting a standalone top-level skill.
- Preserve compatibility with the current CLI by allowing older generated fields while adding optional richer sections and a template/example for manual use.

## Limitations

- This research defines backlog sync shape and reconciliation evidence. It does not grant GitHub write authority.
- Some repository features, including Projects fields, sub-issues, dependencies, rulesets, and environments, may depend on plan, organization, or feature availability. The contract must allow explicit unavailable or not-captured findings.
