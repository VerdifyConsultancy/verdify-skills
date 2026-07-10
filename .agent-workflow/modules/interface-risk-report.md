# Interface Risk Report

## No Blocking Contract Risk

The nine local contracts have exclusive owned path patterns and an acyclic hard-dependency graph. External project implementation is explicitly out of local ownership.

## High Risks

- `lib/verdify/cli.rb` is a shared command hotspot. Only `governance-routing` owns it; other modules request coordinated CLI changes and test through public commands.
- Release workflows regenerate invalid `1.2.1` promotions after each `dev` merge. Issues #120 and #121 own transaction intent and branch-policy remediation.
- Raw-worktree packaging can include ignored host files. Issue #130 owns a reproducible shipped-file selection and regression tests.
- Exact-head review can deadlock without an independent authorized identity. Issue #121 owns effective reviewers and enforceable current-head policy.
- Recovery refs `fe1f94e` and `f425515` contain useful and obsolete content. Issue #126 must use selective path-level reconciliation and a checked-in disposition.
- Three delivered sprint plans remain marked active and make global routing ambiguous. Issue #135 owns terminal-state reconciliation and a router/validator guard.

## External Interface Risks

- Agent Platform capability and session contracts are not implemented here; unsupported capabilities must fail explicitly and readiness owns live proof.
- Orbit connector identity, privacy, classification, retention, and approval rules must be defined before context activation.
- Gravity API/MCP versioning, tenancy, citations, authorization, and availability need owning-repository contract tests and readiness evidence.

## Coordination Rules

- Shared CLI changes: governance-routing owner plus affected module contract test.
- Shared validation/docs changes: quality-enablement owner plus affected module evidence.
- Release/package file-set changes: release-package owner and issue #120/#130 exact-artifact tests.
- External interface changes: owning repository first, then versioned contract and readiness reconciliation here.
