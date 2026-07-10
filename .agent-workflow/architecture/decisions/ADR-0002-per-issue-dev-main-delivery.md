# ADR-0002: Per-Issue Delivery With Dev Integration And Main Release

Status: Approved

## Decision

Use one issue, lane, branch, leased worktree, worker session, and PR as the default implementation unit. Integrate normal work into `dev`; promote `dev` to `main` only through a generated new-version release PR with exact-artifact checks and authorized release approval.

## Alternatives

- One branch per wave: rejected because it weakens ownership, isolation, and independent review.
- Direct implementation PRs to `main`: rejected because accepted integration and package release are distinct transitions.

## Consequences

Wave coordination operates above lane branches. Release automation must avoid duplicate promotions and cannot reuse an already-published version. `dev` and `main` need enforceable policy and effective reviewers.
