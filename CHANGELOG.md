# Changelog

## Unreleased

## 1.2.1 - 2026-07-07

Patch release: manifest integrity fix + CI gate, fleet vendoring standard, and
North Star/doc refresh. No new skills or schemas.

- Fixed `MANIFEST.sha256` integrity (#109, #111): the committed root manifest
  was hand-generated and never regenerated in the release path, so it froze at
  an old commit (95 of 296 entries stale, 102 tracked files missing entirely) —
  downstream vendors could not use it for `sha256sum -c` verification (v1.1.0
  had the same defect). The manifest is now regenerated against the tree.
- Extracted the manifest generator into `scripts/gen-manifest.sh` (single source
  of truth for the exclude set + hashing), shared by `scripts/package.sh` and the
  new `make manifest` / `make manifest-check` targets so the in-zip and committed
  manifests can never diverge.
- Wired `make manifest-check` into `make test` (the `validate` CI job), so any
  future manifest drift fails the PR rather than riding a release unnoticed.
- Added `docs/vendoring-standard.md` (#113): the fleet vendoring/version
  standard — one pinned version dir under `.agent-skills/verdify-skills/<ver>/`,
  an `UPSTREAM.yaml` provenance record, per-vendor manifest verification, and
  host symlink layout — with the 2026-07-07 consumer census.
- North Star iteration 24 (#113): reconciled `NORTHSTAR_PRODUCT.md` to the
  shipped 1.2.0 reality and the Orbit chief-of-staff model (PRQ-007 corrected
  to 25+1 skills, NSQ-007 resolved in practice, WAVE-010 added).
- Skill-count truth pass (#113): WORKFLOW.md, docs/lifecycle.md,
  docs/architecture.md, and README.md now state the real skill counts
  (25 lifecycle skills + standalone issue-triage; validator reports 26).

## 1.2.0 - 2026-07-05

- Bound the loop/recovery contract to the platform durable-loop substrate:
  `controller-loop` gains the Platform Loop Substrate section (work-level
  heartbeat file contract and session-start freshener duty, watchdog takeover
  semantics with wake signals and memory-pressure deferral, resume-check-first
  on any controller restart, stranded-branch recovery, `.agent-fleet/loop.yaml`
  as the per-repo config surface, and the session-scoped-cron trap warning),
  plus the heartbeat and `loop.yaml` canonical-artifact pointers.
- Added durable-output lane discipline to `sprint-orchestrator` (push lane
  branches early, branch-or-PR visibility at all times, no scratchpad-only
  artifacts), the off-pod heavy-workload rule (Kubernetes Jobs with their own
  resource limits), and resume-check at controller (re)start.
- Added the "durable loop armed" readiness domain to `platform-readiness`
  (supervisor loop mode active, heartbeat fresh or watchdog armed, valid
  `.agent-fleet/loop.yaml` with a repo-committed iteration prompt).
- Added the durable-loop scaffolding step to `repo-bootstrap` (commit
  `.agent-fleet/loop.yaml` and the iteration prompt when initializing a
  long-lived repo controller).

## 1.1.4 - 2026-07-03

- Added the `sprint-handoff` lifecycle skill for sprint-boundary status packets
  with previous sprint status, next sprint plan summary, agent handoff state,
  and ordered human-attention items.
- Documented the required pull request template fields and new-skill host
  symlink workflow for future agents and contributors.
- Added the missing Codex and Claude host symlinks for `sprint-handoff`.

## 1.1.3 - 2026-07-03

- Added four lifecycle skills from the failed sprint PR set:
  `sprint-replan`, `subagent-worktree`, `controller-merge`, and
  `adversarial-audit`.
- Reconciled shared lifecycle registration, route schema, validator,
  host links, per-skill docs, evaluations, and reference demos for the merged
  skill set.

## 1.1.2 - 2026-06-26

- Clarified that `dev` is the repository working branch for current changes,
  while `main` is the protected release branch that mirrors the published npm
  package and GitHub release.
- Added mandatory agent instructions to work from `dev` or branches targeting
  `dev`, never directly from `main`.
- Aligned branch-protection documentation with the live release flow, which
  requires checks and conversation resolution but not approving reviews.

## 1.1.1 - 2026-06-26

- Added npm release automation: PR release preflight checks, a `main` publish workflow using Trusted Publishing/OIDC, GitHub release artifact creation, and documentation for updating installed target repositories.
- Added the `dev -> main` release branch model, auto-generated release PR workflow, release-specific PR policy validation, and documentation for protecting `main` from direct pushes.
- Added package repository metadata required by npm provenance verification and allowed same-version release-repair PRs when npm confirms that version is still unpublished.

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
