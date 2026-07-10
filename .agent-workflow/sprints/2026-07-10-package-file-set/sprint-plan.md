# Sprint plan: package file set

The sprint includes only issue #130. It establishes one reproducible tracked
file selection for root manifests and release archive staging, proves ignored
and untracked host files cannot enter either output, and preserves tracked host
discovery links without dereferencing local targets.

The single lane is `issue-130-package-file-set` on
`lane/130-package-file-set`, owned by the package file-set worker and reviewed
by a fresh independent critic. The lane starts from
`32038e3a0637192699af09ad60da48031b7575bc` and targets `dev` through a pull
request with validate, pull-request-policy, and compliance checks.

Issue #126 is intentionally the immediate following sprint, not a second lane
on this frozen baseline. Its recovery proof must consume the integrated #130
selector. Issues #120 and #121 remain deferred release-safety and live-control
work. No version, npm, GitHub release, main, GitOps, or runtime change is
authorized here.

The first QA milestone is the contaminated-worktree regression. The human
review milestone follows fresh criticism and exact-head checks, using
`.agent-workflow/sprints/2026-07-10-package-file-set/review/review-inbox-packet.yaml`.
