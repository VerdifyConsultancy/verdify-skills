# Recovery ledger - 2026-07-10

This ledger is the durable disposition record for
[issue #126](https://github.com/VerdifyConsultancy/verdify-skills/issues/126).
It records selective recovery onto baseline
`17b3762f024186a336556f60c27268006a8d59b6`; it does not authorize ref,
branch, worktree, runner, or checkout deletion.

Snapshot time: `2026-07-10T05:17:25Z`.

## Recovery sources

| Source | Exact commit | Retrieval ref | Disposition |
|---|---|---|---|
| Pilot rescue | `fe1f94eb32b9518b472350429c53135437de0266` | `origin/rescue/pilot-artifacts-wip-2026-07-07` | Select timeline-historian and its registered evidence; retain the ref through a later verified main release. |
| Delivery-loop lane | `f425515c1d20a344ed5447250893c312b306ba43` | `origin/lane/northstar-delivery-loop-architecture` | Select historical evidence only; reject the alternate architecture/schema implementation; retain the ref through a later verified main release. |
| Live-runner rescue | `22f81bdc35e4f1e5a70797624c93bc86bc66056c` | `origin/rescue/live-runner-crm-email-skill-packs-2026-07-10` | Select CRM email and skill-pack behavior; preserve current package identity and immutable stager; retain the ref through a later verified main release. |

## Selected artifacts

### `fe1f94e`: timeline historian

| Source path | Target path | Result |
|---|---|---|
| `skills/timeline-historian/**` | same | Recovered. All source files are byte-identical except `SKILL.md`, whose unpublished `metadata.version: 1.1.0` was advanced to current package version `1.2.1`, and `sunshine_manifest_seed.py`, which imports its previously missing `sys` dependency so error paths work. |
| `evaluations/timeline-historian/evals.json` | same | Byte-identical recovery. |
| `.agents/skills/timeline-historian` | same | Regenerated as `../../skills/timeline-historian`. |
| `.claude/skills/timeline-historian` | same | Regenerated as `../../skills/timeline-historian`. |
| `.agent-workflow/northstar/research-inbox/2026-06-27-timeline-historian-claims-provenance-brave-research.md` | same | Byte-identical recovery. |
| `.agent-workflow/northstar/collateral/NSE-20260627-timeline-historian-claims-provenance-and.yaml` | same | Byte-identical recovery. |
| `.agent-workflow/northstar/collateral/sources/NSE-20260627-timeline-historian-claims-provenance-and-2026-06-27-timeline-historian-claims-provenance` | same | Byte-identical recovery; SHA-256 `6d688411cbe15a12899bdf016737ebb6da39ee4bb3a58d2f1765ef0acade1d98`. |
| Registry item `NSE-20260627-timeline-historian-claims-provenance-and` | `.agent-workflow/northstar/evidence-registry.yaml` | Exact item merged into the current sorted registry; the old registry file was not replayed. |
| No source page existed | `docs/skills/per-skill/timeline-historian.md` | Current package-registry documentation added. |

Source/target audit at this snapshot: 20 selected source-tree files, 18
byte-identical and two documented current-baseline adaptations.

### `f425515`: historical delivery-loop evidence

The following nine files are byte-identical recoveries:

- `.agent-workflow/northstar/AGENTIC_LOOP_SKILL_AUDIT.md`
- `.agent-workflow/northstar/collateral/NSE-20260624-agentic-loop-audit-closeout.yaml`
- `.agent-workflow/northstar/collateral/NSE-20260624-agentic-loop-sdlc-best-practices.yaml`
- `.agent-workflow/northstar/collateral/NSE-20260625-recommended-event-driven-sdlc-control-plane.yaml`
- `.agent-workflow/northstar/collateral/NSE-20260625-walk-transcript-delivery-loop-topology.yaml`
- `.agent-workflow/northstar/collateral/sources/NSE-20260624-agentic-loop-audit-closeout-pasted-text-1-txt`
- `.agent-workflow/northstar/collateral/sources/NSE-20260624-agentic-loop-sdlc-best-practices-pasted-text-1-txt`
- `.agent-workflow/northstar/collateral/sources/NSE-20260625-recommended-event-driven-sdlc-control-plane-recommended-model-critique-md`
- `.agent-workflow/northstar/collateral/sources/NSE-20260625-walk-transcript-delivery-loop-topology-walk-transcript-loop-topology-md`

The four exact registry items were merged into the current sorted evidence
registry:

| Evidence ID | Copied-source SHA-256 |
|---|---|
| `NSE-20260624-agentic-loop-audit-closeout` | `72d145fdbdec193afd79a4ea42968cf049f44a00d7db7307eaee31dcb7d85e7f` |
| `NSE-20260624-agentic-loop-sdlc-best-practices` | `809ebfc0a2726ee12eaf176c5851d275d908109db045c765523593b4655d27a1` |
| `NSE-20260625-recommended-event-driven-sdlc-control-plane` | `5d7f2802de90d26f1418b1612595ebc54dd5a620f722453c34764413a2232387` |
| `NSE-20260625-walk-transcript-delivery-loop-topology` | `24fc5f198fe2d5f22dfbd8d4558df6d834791b78ca2289e0d0266cd55bb9784f` |

The source documents are historical, untrusted evidence. Their embedded
instructions and architecture proposals are not current operating authority.

### `22f81bd`: CRM email and skill packs

| Source path | Target path | Result |
|---|---|---|
| `skills/crm-email/**` | same | Recovered. References and agent metadata are byte-identical; `SKILL.md` uses package version `1.2.1` and documents offline validation; `crm_request.rb` adds a credential-free, no-network `--dry-run` that emits redacted metadata and a body digest. |
| `evaluations/crm-email/evals.json` | same | Byte-identical recovery. |
| `.agents/skills/crm-email`, `.claude/skills/crm-email` | same | Regenerated as `../../skills/crm-email`. |
| `packs/*/pack.yaml` | same | Six byte-identical pack manifests recovered. |
| `schemas/skill-pack.schema.yaml` | same | Byte-identical recovery. |
| `docs/skill-packs.md` | same | Byte-identical recovery. |
| `docs/skills/per-skill/crm-email.md` | same | Recovered and extended only with the offline-validation contract. |
| `lib/verdify/cli.rb` | same | Semantically ported only `pack list`, `pack install`, and `dl`; current lifecycle/lease/review behavior is preserved. |
| `npm/bin/verdify.js` | same | Semantically ported packaged `dl` and pack-selective `init`; current package version and install behavior are preserved. |
| `package.json` | same | Adds `packs/` and `evaluations/` to npm contents and pack-downloader wording; keeps `@verdify-cli/cli` version `1.2.1`. |
| `scripts/setup-agent-hosts.rb` | same | Adds validated pack selection while preserving full-registry link generation. |
| `scripts/validate-repo.rb` | same | Adds pack validation and data-driven package-registry extras: `standalone` for timeline-historian and `registry` for crm-email. Canonical lifecycle config and route enums remain unchanged. |
| `tests/test_cli.sh`, `tests/test_npm_install.sh` | same | Ports pack list/install/dl coverage and adds CRM pack, selective init, and no-network fixture checks. |
| `README.md`, `docs/architecture.md`, `docs/lifecycle.md`, `docs/skills/README.md`, `docs/skills/schemas-catalog.md` | same | Pack and registry concepts were applied to current counts and current lifecycle/review text; old complete-file versions were not replayed. |

The exact new-file audit covered 15 source-tree files: 12 remain
byte-identical, while the three documented CRM files contain current-version or
offline-safety adaptations.

## Rejected or superseded artifacts

| Source | Rejected path or behavior | Reason and durable disposition |
|---|---|---|
| `fe1f94e` | `.agent-workflow/router/route-decision.yaml` | Generated state from an old planning point; not authority and outside the lane. |
| `fe1f94e` | `.agent-workflow/sprints/2026-06-27-ship-verify-skills/**` and `docs/sprint-plans/2026-06-27-verdify-skills-replan.md` | Historical sprint residue; later reviewed PRs and current sprint artifacts supersede it. Retrieval remains through the rescue ref. |
| `fe1f94e` | Whole-file `README.md`, `config/lifecycle.yaml`, `schemas/route-decision.schema.yaml`, `scripts/validate-repo.rb`, and `tests/test_schema_validator.rb` | Old canonical skill-count/router approach would overwrite newer lifecycle behavior. Timeline is recovered as an out-of-lifecycle package-registry standalone skill instead. |
| `f425515` | `.agent-workflow/northstar/NORTHSTAR_ARCHITECTURE.md` | Protected obsolete alternate architecture; historical evidence is registered but the proposal is not accepted design. |
| `f425515` | `docs/decisions/ADR-0011-wave-delivery-envelope-state-machine.md`, `skills/controller-loop/SKILL.md`, and `skills/controller-loop/references/delivery-loop-model.md` | Alternate loop implementation superseded by current approved lifecycle/controller behavior. |
| `f425515` | `schemas/wave-contract.schema.yaml`, `schemas/task-contract.schema.yaml`, and `schemas/worker-run-event.schema.yaml` | Explicitly prohibited proposed schemas; not replayed. |
| `f425515` | Whole-file `.agent-workflow/northstar/evidence-registry.yaml` | Only the four historical records were merged into the current registry. |
| `22f81bd` | `.mcp.json` and generated route state | Deliberately excluded from the rescue commit and not reconstructed. |
| `22f81bd` | Source `VERSION`, source package version `1.1.0`, and old skill metadata versions | Current accepted identity is `1.2.1`; no version, tag, npm, release, or main promotion is authorized here. |
| `22f81bd` | `scripts/package.sh` archive rename to `verdify-skill-registry-*` | Obsolete archive-name proposal. Current identity remains `verdify-lifecycle-skills-v1.2.1.zip`. |
| `22f81bd` | Raw-worktree/package staging behavior and any change to `scripts/package-file-list.rb` | Superseded by issue #130. The immutable Git-index object stager integrated at `17b3762` is retained unchanged. |
| `22f81bd` | Whole-file shared docs, CLI, npm wrapper, validator, setup script, and tests | Only source hunks that remain compatible with the current baseline were applied; newer lifecycle, release, policy, and review behavior is retained. |

No source ref was merged or cherry-picked wholesale.

## Shared runner checkpoint

Issue #126 records the following observed state before this lane:

- Agent Platform pod `repo-verdifyconsultancy-verdify-skills-0` was Ready.
- Its shared controller checkout remained on `main` at `74833e7986dda464e32b8eab46db40d21c40a425`, 47 commits behind the then-current `origin/main`, with the CRM/pack work still modified or untracked.
- Codex, Claude Code, OpenClaw, and Hermes controller sessions were bound to that checkout.
- Rescue commit `22f81bdc35e4f1e5a70797624c93bc86bc66056c` was created with a temporary index and `commit-tree`; `.mcp.json` and generated route state were excluded; the checkout, HEAD, files, and sessions were not changed.

This lane did not access production credentials, send email, write CRM data,
or mutate that checkout. The runner state above is evidence reported in issue
#126, not a fresh live-state assertion. Cleanup remains deferred until the
recovered work is accepted on `dev`, promoted in a new-version release to
`main`, and independently verified.

## Worktree disposition

| Worktree | Snapshot head | State | Disposition |
|---|---|---|---|
| `/Users/jason/repos/verdify-skills` | `dev` at `c78db1bf86d85719a367e0a5c461db6e6f92e22e`, equal to `origin/dev` | Primary checkout | Retain. It is not a cleanup target for this worker lane. |
| `/Users/jason/repos/verdify-worktrees/2026-07-10-recovery-publication/issue-126-recovery-publication` | Dispatch head `b4ea69b1aa9d3142057239123f13d9178ca4c2ec` at snapshot; advances to I/E under issue #126 | Active leased worker worktree | Retain through PR, fresh criticism, integration disposition, and lease-controlled cleanup. |
| `/Users/jason/repos/verdify-worktrees/2026-06-27-ship-verify/orchestrator` | `fffa61c` | Previously clean, zero unique commits, removed before this lane | Proven redundant. Its local `orchestrator/2026-06-27-ship-verify` branch was also removed; history remains in `main`. |

## Current local branch disposition

| Branch | Head at snapshot | Disposition |
|---|---|---|
| `dev` | `c78db1bf86d85719a367e0a5c461db6e6f92e22e` | Active integration branch; equals `origin/dev`; retain. |
| `main` | `898d7c78845f11a4cec29556e698ebd27aa58ef1` | Published branch; equals `origin/main`; retain. |
| `lane/126-recovery-publication` | `b4ea69b1aa9d3142057239123f13d9178ca4c2ec` at snapshot | Active issue #126 lane; retain through controller closeout. |
| `rescue/pilot-artifacts-wip-2026-07-07` | `fe1f94eb32b9518b472350429c53135437de0266` | Recovery source; deletion prohibited until verified main release. |
| `lane/northstar-delivery-loop-architecture` | `f425515c1d20a344ed5447250893c312b306ba43` | Historical evidence source plus rejected design; deletion prohibited until verified main release. |
| `controller/2026-07-10-package-file-set-dispatch` | `002297257dc7dda3704315a8eeaf98229ee6e9e4` | Divergent controller evidence for PR #166, including its admin-merge override; not owned by issue #126. Retain for controller disposition. |

## Merged-branch map from issue #126

The following historical lane branches were mapped to merged pull requests
before cleanup. They are accepted-history retrieval handles, not recovery
sources:

| Pull request | Historical branch | Pull request | Historical branch |
|---|---|---|---|
| #37 | `lane/dec-authority-boundaries` | #38 | `lane/dec-readiness-boundary` |
| #39 | `lane/dec-eval-strategy` | #40 | `lane/dec-issue-action-boundary` |
| #41 | `lane/dec-platform-reconciliation` | #42 | `lane/dec-controller-ownership` |
| #44 | `lane/validator-engine` | #45 | `lane/route-decision-enum` |
| #46 | `lane/eval-uplift` | #47 | `lane/controller-state-fields` |
| #48 | `lane/orphan-artifacts` | #49 | `lane/skill-count-drift` |
| #50 | `lane/router-gate-bypass` | #51 | `lane/schema-contradictions` |
| #52 | `lane/platform-control-regrounding` | #53 | `lane/qr-schemarefs` |
| #55 | `lane/lane-delivery-correctness` | #56 | `lane/prompt-injection-guidance` |
| #57 | `lane/controller-recovery` | #58 | `lane/cli-hardening` |
| #59 | `lane/readiness-grounding` | #60 | `lane/canonical-lifecycle` |
| #61 | `lane/missing-northstar-capabilities` | #62 | `lane/consensus-audit-workflow` |
| #63 | `lane/repo-bootstrap-skill` | #64 | `lane/secret-scanning` |
| #66 | `lane/cicd-gates-2026` | #68 | `lane/release-1.1.0` |
| #78 | `pilot/first-test-pass` | #94 | `lane/90-sprint-replan` |
| #95 | `lane/91-subagent-worktree` | #96 | `lane/92-controller-merge` |
| #97 | `lane/93-adversarial-audit` | #99 | `feat/sprint-handoff-skill` |
| #113 | `docs/northstar-refresh-2026-07-07` |  |  |

Issue #126 also classified `codex/issue-4-question-resolution-loop` and an old
local `dev` ref as contained by current default-branch history with zero unique
patches. Those obsolete local refs are no longer present in the current branch
snapshot.

## Current remote-ref snapshot

Containment below is a Git ancestry observation at the snapshot time, not an
instruction to delete a branch.

### Contained by `origin/main`

- `origin/docs/northstar-refresh-2026-07-07` at `849dbe82453afd18886f2aa9f0ee127c4a516890`
- `origin/lane/90-sprint-replan` at `2d7f99a3af2a34284e7632ce0913010800fa894e`
- `origin/lane/91-subagent-worktree` at `a79e1759ba70ae089ae45706a0374fb0e1f0a4c8`
- `origin/lane/92-controller-merge` at `1fcb935da6e3688b95b6316804bbcdabb1689873`
- `origin/lane/93-adversarial-audit` at `5f556b0f5441396c89224ad470b7fa0fd8a81e75`
- `origin/loop-substrate-1.2.0` at `c0bebe10a72c11bbd6bdc0e842c2f1ce55bc413b`
- `origin/release-1.2.0` at `67d19b80edd6a25c904d44903e0eb1d2f00ebf68`

These are cleanup-eligible only after the checked-in ledger is accepted and a
controller verifies that no repository policy or release record still needs the
branch ref.

### Contained by `origin/dev` but not `origin/main`

- `origin/controller/2026-07-10-package-file-set` at `345955999a19cda0b535ace6bf9685322ea8de1b`
- `origin/controller/2026-07-10-recovery-local-fallback` at `c3947b06f5ecd737bfacc44f428d756a6d0c22b5`
- `origin/controller/2026-07-10-recovery-publication` at `c3fde8c8d5d393bf68da843a3f1bdf3f9b73b177`
- `origin/fix/135-sprint-terminal-routing` at `08350751b0dcb8ab21fda1f930b3e646eea62dc6`
- `origin/fix/143-strategy-baseline-routing` at `929b361bbc97be2e9b971e39d798056977c63ec5`
- `origin/hygiene/153-wave0-controller-scope` at `9985d503bd9835cff25c3b0dd90002d7b1fc413b`
- `origin/lane/119-northstar-review-feedback` at `decc7a177f669150ffa8767fbde063f5a4e9fe31`
- `origin/lane/130-package-file-set` at `b2911c9c3db215fbd70d65cfed4fe160f91fa7ac`
- `origin/lane/72-exact-head-evidence` at `71e3f6eee0c5fb58f118536ce9b43ebcc1cfe1a5`
- `origin/strategy/142-recovery-and-release` at `8e51f36db8307e9130126c040b8415829a9c0fd0`
- `origin/strategy/143-post-fix-refresh` at `bdab60ca8327eb7961c3a3f68068d4505377a0de`
- `origin/strategy/153-final-baseline` at `ec7ff957c82093533ee102c94d79b452c9aeda58`
- `origin/strategy/153-post-hygiene-refresh` at `2efbb3221ddd397849732b3675977ba7691a850c`

Retain these until a valid new-version release promotes the accepted `dev`
history to `main`, then let the owning controller assess cleanup.

### Divergent or superseded remote refs

| Ref | Head | Disposition |
|---|---|---|
| `origin/controller/2026-07-10-package-file-set-dispatch` | `002297257dc7dda3704315a8eeaf98229ee6e9e4` | Unique controller evidence; retain for controller disposition. |
| `origin/fix/manifest-integrity-109` | `811c3590187475a68c4a9aba5be6e9befbf71838` | Closed mis-targeted PR #110; replacement PR #111 and release PR #115 supersede it. Cleanup-eligible only after controller verification. |
| `origin/pilot/first-test-pass` | `3949a0ba9c81a852511920b166cd53f9a22a99db` | Mapped to merged PR #78; tree contains old versions/deletions and no unique current artifact to replay. Retain until controller cleanup. |
| `origin/lane/northstar-delivery-loop-architecture` | `f425515c1d20a344ed5447250893c312b306ba43` | Recovery source; retain through verified main release. |
| `origin/rescue/pilot-artifacts-wip-2026-07-07` | `fe1f94eb32b9518b472350429c53135437de0266` | Recovery source; retain through verified main release. |
| `origin/rescue/live-runner-crm-email-skill-packs-2026-07-10` | `22f81bdc35e4f1e5a70797624c93bc86bc66056c` | Recovery source and shared-runner checkpoint; retain through verified main release and runner cleanup audit. |

## Cleanup gate

No destructive cleanup occurred in this lane. A later controller may consider
cleanup only after all of the following are true:

1. Issue #126 is integrated into `dev` through its reviewed PR.
2. A genuinely new package version is promoted through the approved
   `dev -> main` release path and exact-artifact publication gates.
3. `main`, the GitHub release, npm package, package archive, evidence registry,
   historian/CRM skills, pack CLI, and installed-package checks agree.
4. A fresh branch/worktree/runner audit confirms every retained ref has another
   durable retrieval handle and no unique uncommitted data remains.
5. The owning controller, not a worker lane, performs and records each deletion.

Until then, the three source refs, shared runner checkout, issue #126 lane, and
unique controller evidence remain retained.
