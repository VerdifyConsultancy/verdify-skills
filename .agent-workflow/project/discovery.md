# Verdify Skills Project Discovery

This is the human view of `.agent-workflow/project/project-definition.yaml`; the YAML is authoritative. The packet distills approved North Star iteration 25 and introduces no new product decision.

## Status

- Project: `verdify-skills`
- Definition: `approved`
- Discovery: `approved`
- Baseline: integrated `dev` after PR #122
- Approval source: Jason's approved iteration-25 North Star lock

## Evidence Inventory

The definition uses fourteen sources:

- Repository and operating authority: `README.md`, `COMMON_OPERATING_CONTRACT.md`, `config/authority-matrix.yaml`, and `config/lifecycle.yaml`.
- Approved planning authority: `NORTHSTAR_PRODUCT.md`, `NORTHSTAR_ARCHITECTURE.md`, `northstar-artifacts.yaml`, and `northstar-plan.yaml`.
- Delivery and distribution: `docs/github-operating-model.md` and `docs/vendoring-standard.md`.
- Live backlog truth: issues #120, #121, #126, #129, and #130.

## Approved Decisions

- GitHub owns backlog and delivery state; versioned artifacts own planning authority; the default branch owns accepted code.
- Verdify Skills is the internal-first method and planning layer for a four-project pilot with Agent Platform, Orbit, and Gravity.
- Project ownership remains separate: Agent Platform owns runtime execution, Orbit owns governed context, and Gravity owns cited evidence services.
- One issue, lane, branch, worktree, worker session, and PR is the default implementation unit; normal work integrates to `dev`, while `main` receives release promotion.
- Jason owns North Star lock authority; Jason or James may approve releases; workers do not self-certify.
- Approved replacements need not preserve deprecated compatibility.
- Package publication must test and publish one exact artifact through a recoverable transaction.
- Historical work is selectively ported forward; obsolete trees are evidence, not accepted code.

## Resolved Contradictions

- Per-wave branches were replaced by per-issue delivery units coordinated at wave level.
- Joint North Star authority was replaced by Jason's lock authority and Jason-or-James release approval.
- Gravity/Onyx uncertainty was replaced by current Gravity authority and retired-deployment history.
- Duplicate `1.2.1` promotions were closed because a release must use a genuinely new unpublished version.

## Assumptions

- The canonical source remains `VerdifyConsultancy/verdify-skills`.
- Agent Platform capabilities are negotiated through owned provider contracts.
- GitHub and npm remain the current control planes for source and package distribution.
- Orbit and Gravity implementation can evolve behind their approved interfaces; this remains an owner-validated assumption, not local implementation authority.

## Owner-Routed Gaps

No gap blocks project-definition approval. Issues #120, #121, #126, and #130 own release safety, delivery controls, recovery, and reproducible package file selection. Agent Platform, Orbit, and Gravity owners retain their implementation and readiness gaps.

## Handoff

Architecture contracts may consume the approved definition. Sprint planning remains gated by architecture/module contracts, current strategy, and hygiene evidence. Release promotion remains gated by issue #120 and a new version.
