# Sprint: issue 71 route authority validation

## Outcome

Make live routing consume only schema-valid, semantically valid lifecycle
authority and eliminate stale committed route snapshots as a competing source of
truth.

## Included

- One lane for GitHub issue #71.
- A caller-selected fail-closed loader for every upstream routing artifact.
- Typed producer routing for malformed, semantically invalid, or impossible
  lifecycle state.
- Legal dynamic handoff checks without rebuilding specialized lane, critic,
  release, outcome, or receipt validation.
- Ignored local route YAML/Markdown cache with generated-pair agreement tests.
- Focused, installed-package, manifest, full-suite, and security evidence.

## Deferred

- Issue #73 owns criterion-complete critic evidence.
- Issues #75 and #74 own executable evaluations and consumer CI.
- Issues #43 and #70 own the bounded loop, risk classes, and proportional human
  gates.
- No Agent Platform, provider, Gravity, Orbit, correlated transaction, or
  durability work is included.

## Lane

| Lane | Issue | Branch | Owner | Reviewer |
| --- | --- | --- | --- | --- |
| `issue-71-route-authority-validation` | #71 | `lane/71-route-authority-validation` | `codex-issue71-worker` | fresh independent critic |

The lane owns only router loading, repository validation, derived-cache
tracking, focused tests, and directly affected package/docs surfaces named in
its contract.

## Gates

Stop if the repair needs a schema change, weakens a specialized validator,
adds network-sensitive validation to routine repository checks, exposes
unbounded artifact values, or expands into later issues. One fresh critic
reviews the exact implementation. Protected-path integration uses CODEOWNERS
when available or the delegated exact-head exception with immediate protection
restoration; no review is fabricated.

## Verification

The first QA milestone is a malformed-producer and impossible-handoff matrix.
The second proves route files are untracked ignored cache, generated views
agree, package installation works, and the full suite is green. After merge, a
normal terminal receipt and global project-router verification must complete
before issue #73.
