# Release Safety Sprint

## Outcome

Build and prove one new `1.3.0` npm artifact and release transaction from the
fully recovered `dev` baseline. The lane may integrate release machinery to
`dev`; it may not publish or promote `main`.

## Lane

| Lane | Issue | Branch | Responsibility | Review |
| --- | --- | --- | --- | --- |
| `issue-120-release-safety` | `#120` | `lane/120-release-safety` | Pack once, exercise the exact tarball, enforce exact ZIP set equality, implement resumable publication state, prevent duplicate release PRs, and make pack conflicts transactional | Fresh independent critic |

## Required Proof

- Root and all 28 skill metadata versions equal `1.3.0`, with no skill body or
  behavior change.
- One tarball path and digest across every consumer test and publish input.
- Fresh install, reinstall, upgrade from `1.2.1`, Node 18, collision,
  corruption, rollback, and installed-command behavior.
- No partial skill-pack links or manifest after a failed install.
- Exact ZIP verification rejects missing, altered, and unlisted files.
- Release state resumes after npm success without duplicate issues, tags, or
  releases and reconciles package integrity, provenance, `gitHead`, and source.
- Actions and npm are pinned; `scripts/package-file-list.rb` remains unchanged.

## Boundaries

The worker receives no npm or production authority. Version `1.3.0` can reach
`dev`, but the generated release PR remains pending until issue `#121` is
integrated, live branch rules are reconciled, and a non-author release approver
accepts the exact final candidate.
