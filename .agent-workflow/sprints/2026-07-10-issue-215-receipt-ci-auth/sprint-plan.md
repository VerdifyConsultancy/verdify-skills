# Sprint: issue 215 receipt CI authentication

## Outcome

Make terminal-receipt GitHub evidence reads authenticated, least-privilege,
bounded, and fail-closed so correct receipt transactions pass Actions without an
administrative CI exception.

## Included

- One lane for GitHub issue #215.
- `github.token` scoped to the three exact receipt-validation steps.
- Read-only `actions`, `checks`, `contents`, and `pull-requests` permissions.
- Highest-required-check selection before workflow metadata hydration, with
  shared workflow-run deduplication.
- Authenticated failures that never fall back anonymously and expose only
  allowlisted status/rate diagnostics.
- A six-receipt equivalent bounded at 48 GitHub API reads plus focused and full
  policy regressions.

## Deferred

- Issue #70 owns the cross-policy lightweight fast path.
- No provider authentication, package release, runtime deployment, or later
  autonomous-platform issue is included.
- Deterministic terminal receipts still receive no second critic or routine
  human approval.

## Lane

| Lane | Issue | Branch | Owner | Reviewer |
| --- | --- | --- | --- | --- |
| `issue-215-receipt-ci-auth` | #215 | `lane/215-receipt-ci-auth` | `codex-issue215-worker` | fresh independent critic |

The lane owns only the two workflows, GitHub/receipt evidence loaders, focused
tests, repository workflow invariants, and integrity manifest named in its
contract.

## Gates

The implementation must stop if it needs write authority, a personal token,
token persistence, anonymous fallback after authenticated failure, weaker check
identity, more than 48 reads for the six-receipt equivalent, or paths outside
the contract.

One fresh critic reviews the implementation. Because the diff touches protected
workflows and policy libraries, integration uses CODEOWNERS when available or
the already delegated, exact-head, one-PR admin exception with immediate branch
protection restoration. No review is fabricated.

## Verification

The next QA milestone is the authenticated evidence and request-bound matrix,
followed by `validate-repo`, `actionlint`, `make test`, manifest verification,
and a redacted changed-commit secret scan. After merge, the normal terminal
receipt must show green pull-request policy, delivery policy, and critic gate,
then `project-router` must advance to issue #71 reconciliation.
