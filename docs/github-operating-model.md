# GitHub operating model

## Issues as backlog problems

Open an issue for a problem, desired outcome, defect, decision, or discovered work. The issue should explain why the work matters and what observable outcome would resolve it. Implementation detail belongs in approved contracts and pull requests.

Use native sub-issues for decomposition and native dependencies for blocked-by relationships. Use milestones or Projects for sprint grouping and fields such as Sprint, Lane, Workflow state, Risk, Target environment, and Evidence.

## One issue per lane by default

The normal cardinality is:

```text
one issue -> one lane contract -> one branch -> one worktree -> one worker session -> one PR
```

A multi-issue lane is permitted only when the issues are inseparable at the acceptance and merge boundary. The contract must list a coupling justification and the plan approval must explicitly accept it.

## Pull requests

Every implementation PR links its issue with a supported closing keyword, names the lane contract, states the outcome, proves scope, provides evidence, and describes deployment risk. The linked issue is not considered verified merely because GitHub auto-closes it after merge; outcome reconciliation may reopen or use a policy that delays closure.

## Branch model

This repository uses two long-running branches:

- `dev` is the development integration branch and the working branch for current
  repository changes. Humans and agents make normal changes on `dev`, or on
  short-lived lane branches based on `dev` with PRs back to `dev`. The normal
  one issue -> one lane contract -> one branch -> one worktree -> one worker
  session -> one PR policy still applies to implementation lanes.
- `main` is the protected release branch. It should only receive generated
  release PRs from `dev`, and it should match the package version published to
  npm and the corresponding GitHub release.

Pushing to `dev` runs validation and `.github/workflows/release-pr.yml`. That
workflow opens or updates one release PR from `dev` to `main`, creates or reuses
a GitHub Issue for the package version, and writes a release-specific PR body.
The PR policy treats this as a release gate rather than a worker lane, but still
requires a closing GitHub Issue, exact package version evidence, current head
SHA, and rollback notes.

Automatic release PR creation requires a `VERDIFY_RELEASE_PR_TOKEN` repository
secret with issue and pull-request write access. The VerdifyConsultancy
organization currently blocks the repository setting that would let the built-in
`GITHUB_TOKEN` create pull requests.

Merging the release PR into `main` triggers `.github/workflows/publish-npm.yml`.
Direct pushes to `main` are not part of the operating model and should be
blocked by branch protection or a repository ruleset.

## Required controls

Configure a repository ruleset or protected branch for `main` to require:

- validation, policy, and compliance self-test checks;
- strict up-to-date checks;
- resolved conversations;
- no direct pushes;
- no force pushes or branch deletion;

The current release flow does not require approving reviews. Add review gates,
code-owner gates after CODEOWNERS is configured, or a merge queue only through
an explicit governance decision.

## Deployments

Use GitHub environments or an equivalent deployment control with separate credentials, environment-specific approvals, deployment history, and a concurrency policy. Worker lanes do not receive production secrets.

## Local snapshots

`bin/verdify github snapshot` writes `.agent-workflow/github/snapshot.json` as an ignored cache. Refresh it before planning or reconciliation. It never overrides live GitHub state.

When a state-of-union decision depends on GitHub backlog or delivery reality,
write `.agent-workflow/strategy/github-backlog-sync.yaml` and validate it
against `schemas/github-backlog-sync.schema.yaml`. The artifact records
snapshot freshness, source limitations, issue findings, PR findings, lane
findings, delivery findings, and which control plane must carry each action.
