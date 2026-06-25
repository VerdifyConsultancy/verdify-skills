# Changelog

## Unreleased

## 1.1.0 - 2026-06-25

- Added the executable compliance gate: `verdify gate compliance` (`Verdify::ComplianceAssessor`) — a deterministic, hermetic, gem-free assessor of the fleet-standard repo shape (AGENTS.md managed markers, North Star present, vendored skills + discovery symlinks, no committed secrets), emitting a schema-valid `ComplianceAssessment`.
- Defaulted the gate to the relaxed **relaxed-to-North-Star v1** tier the standardized fleet repos meet (`northstar_present` accepts `.agent-workflow/northstar/NORTHSTAR_PRODUCT.md` OR the canonical project-definition/architecture artifacts); `--strict` reserves the rigorous tier (adds `access_project_block` + requires canonical artifacts); `--no-strict` is report-only.
- Added the reusable `workflow_call` CI workflow `.github/workflows/compliance-gate.yml` (npx- or vendored-sourced, `strict`/`report_only` inputs) and the `compliance-assessment.schema.yaml` schema, so any fleet repo can wire `verdify-compliance` as a check. Upstream of jvallery/agents#2026 enforcement.
- Added the North Star template scaffold under `templates/northstar/`.
- Added `northstar-question-resolution` as a lifecycle skill for large North Star question inventories, delegated answers, research handoff, and concise human escalation packs.
- Added the comprehensive planning/review-loop ADR for backlog, health, lane, sprint, QA, and review-packet reconciliation.
- Reconciled package-count documentation to the validated framing: eighteen lifecycle skills plus one standalone `issue-triage` skill, 19 total skills reported by `scripts/validate-repo.rb`.
- Indexed and traced ADR-0009 and ADR-0010 in the North Star architecture decision index.

## 1.0.0 - 2026-06-22

- Replaced the single `verdify-agentic-sprint` skill with eight coherent lifecycle skills.
- Preserved the full 17-stage lifecycle as skill modes and workflow states.
- Made GitHub primitives the typed operational source of truth and GitHub Issues the backlog.
- Adopted one issue/lane/branch/worktree/worker-session/PR as the default execution unit.
- Added machine-local lane leases, fresh critic worktrees, and isolated runtime namespaces.
- Added canonical schemas for project definition, architecture, modules, sprints, lanes, criticism, release verification, outcomes, gates, evidence, and GitHub snapshots.
- Added issue forms, a pull-request template, validation and PR-policy workflows.
- Added the dependency-free `bin/verdify` CLI and end-to-end tests.
- Removed duplicated prompt and schema trees.
