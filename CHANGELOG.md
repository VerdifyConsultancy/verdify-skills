# Changelog

## Unreleased

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
