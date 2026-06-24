# ADR-0013: Platform vs Gravity readiness boundary

- Status: accepted
- Date: 2026-06-24
- Related issue: #10

## Context

`platform-readiness` and `gravity-readiness` both appear in the lifecycle before
Gravity pilot execution. Both skills mention operational evidence such as
credentials, RBAC, namespaces, CI/CD, observability, browser inspection, review
environments, and pilot readiness. Without an explicit boundary, agents can
duplicate platform evidence in Gravity artifacts or try to remediate platform
gaps from the Gravity-specific readiness loop.

Issue #10 asks for the order, ownership boundary, and artifact handoff between
the two readiness skills for Gravity pilot gating.

## Decision

`platform-readiness` is the authoritative owner of environment and
control-plane readiness for Agent Platform. It owns Kubernetes and namespace
evidence, RBAC, secrets and credential injection readiness, CI/CD, GitOps,
ingress, DNS, observability, browser terminals, review inbox/platform APIs, and
the minimum non-Gravity autonomous pilot proof. Its canonical readiness state is
recorded under `.agent-workflow/platform/`.

`gravity-readiness` owns Gravity-specific product, architecture, repository,
dependency, Onyx, integration, review, sign-off, and pilot-wave readiness. It
consumes `platform-readiness` output when deciding whether Gravity can proceed
to an autonomous pilot, but it does not duplicate, override, or become the
authoritative owner of platform readiness state. Its canonical Gravity-specific
state remains under `.agent-workflow/gravity/`.

When both platform readiness and Gravity readiness are incomplete, run
`platform-readiness` first to establish whether any autonomous pilot can safely
run on the shared delivery platform. `gravity-readiness` may collect
Gravity-specific repository and product evidence in parallel, but it cannot
mark the Gravity pilot ready until the current platform-readiness artifact is
linked and has a passing or explicitly accepted verdict for the required
platform domains.

The handoff from platform readiness to Gravity readiness is a reference, not a
copy. Gravity readiness artifacts must cross-link the relevant
`.agent-workflow/platform/` readiness artifact, capture the platform verdict,
timestamp, and evidence identifiers they consumed, and state which Gravity
pilot criteria depend on that platform evidence. `.agent-workflow/gravity/`
must not become the authoritative owner for platform state or platform
remediation scope.

## Acceptance Examples

### Platform not ready for any autonomous pilot

`platform-readiness` marks the shared platform readiness artifact `fail` or
`blocked` because a required platform domain, such as namespace isolation,
runtime secret injection, CI/CD, observability, review deployment, or controller
API evidence, is missing. `gravity-readiness` records the linked platform
artifact and marks the Gravity pilot blocked by platform readiness. The Gravity
readiness artifact may still list Gravity-specific findings, but it must not
declare the pilot ready or move platform remediation into
`.agent-workflow/gravity/`.

### Platform ready but Gravity repo or pilot criteria still failing

`platform-readiness` records a passing or explicitly accepted platform verdict,
including non-Gravity pilot proof. `gravity-readiness` links that platform
artifact and consumes the pass, then independently fails the Gravity pilot
because Gravity-specific criteria such as approved product scope, repository
hygiene, dependency readiness, Onyx status, tests, review sign-off, or the
proposed pilot wave are not ready. The platform remains ready; the failing work
belongs to Gravity readiness issues or gates.

## Consequences

- Gravity pilot routing has a stable order: prove or accept platform readiness
  before declaring the Gravity pilot ready.
- Platform evidence is maintained once under the platform artifact owner and
  referenced from Gravity readiness.
- Gravity readiness can fail even when the platform is ready, and platform
  readiness can block Gravity before Gravity-specific pilot approval.
- This ADR resolves the decision scope for issue #10 without changing skill
  definitions, workflow transitions, lifecycle documentation, or any runtime
  infrastructure.
