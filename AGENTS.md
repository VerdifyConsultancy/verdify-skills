# Agent instructions

Use the Verdify lifecycle skills for transcript intake, North Star planning,
project definition, architecture, repo hygiene, platform readiness, sprint
planning, controller coordination, lane delivery, review, integration, and
deployment verification.

Start or resume through `$project-router` unless the user explicitly names another lifecycle skill and its prerequisites are present.

Mandatory repository rules:

- GitHub Issues are the backlog source of truth.
- GitHub is the delivery control plane; do not replace issues or pull requests with private chat state.
- Treat `dev` as this repository's working branch. Before editing, confirm you are on `dev` or on a short-lived branch based on `dev` that targets `dev`.
- Commit and push normal repository changes through the `dev` workflow. Implementation/lane pull requests target `dev`; `main` only receives generated `dev -> main` release pull requests.
- Never edit, commit, or push normal work directly on `main`; `main` must stay aligned with the published npm package and GitHub release for the current version.
- Every pull request must use `.github/pull_request_template.md`: keep the required section headings, close the backing issue with a supported keyword, include the lane contract path under `.agent-workflow/sprints/.../lanes/contracts`, record the last substantive `Implementation head SHA`, change `Evidence head SHA` from `pending` to the closeout-only evidence commit before criticism, and update `Current head SHA` to the exact 40-character PR head commit.
- When adding or renaming a skill, run `make links` or `ruby scripts/setup-agent-hosts.rb` before validation and commit the resulting `.agents/skills/<skill>` and `.claude/skills/<skill>` symlinks with the skill source.
- One issue, lane, branch, worktree, worker session, and pull request is the default unit of implementation.
- Acquire a lane lease before coding and never share an active worktree between coding sessions.
- Create worker worktrees through `bin/verdify lane create`; it must seed the
  approved SprintPlan, wave release plan, and lane contract as a separate first
  post-baseline dispatch commit. Never edit those artifacts during
  implementation.
- Run candidate policy/review validation from the protected base checkout or an atomically installed trusted Verdify package, never from validator code supplied only by the candidate branch.
- Follow `COMMON_OPERATING_CONTRACT.md` and `config/authority-matrix.yaml`.
- Use durable `.agent-workflow` artifacts for approved definitions, contracts, status, and evidence.
- Route new transcript or walk evidence through `$transcript-replan` before
  rewriting protected planning artifacts.
- Use `$northstar-research-ingest` to copy research into North Star collateral
  and register it in the queryable evidence registry.
- Use `$northstar-planning` to synthesize registered evidence, ideation,
  requirements, PRDs, user stories, milestones, waves, product surfaces,
  architecture stories, architecture requirements, high-level designs,
  infrastructure, conflicts, issues, planning questions, research proposals,
  review feedback, and final lock approval into `NORTHSTAR_PRODUCT.md` and
  `NORTHSTAR_ARCHITECTURE.md` before project definition or architecture consumes
  that material. Ordinary North Star questions restart the planning loop; final
  approval is required only to lock the North Star for the next milestone.
- Use `$northstar-interview` when review-ready North Star drafts or new evidence
  need prioritized human questions, proposed defaults, tradeoffs, and answer
  capture before final lock approval.
- Use `$northstar-question-resolution` when a repo has many human-gated or open
  planning questions that should be inventoried, clustered, researched with
  registered evidence, answered under delegated authority, and reduced to a
  short human escalation pack.
- Use `$state-of-union` for comprehensive project triage or replanning across
  GitHub backlog, planning artifacts, sprint artifacts, deployment/log health,
  discovered health issues, execution sequence, and next sprint candidates.
- Run `$repo-hygiene` before feature execution when a repo has not passed Wave 0
  compliance.
- Keep Gravity implementation blocked until `$platform-readiness` and
  `$gravity-readiness` are approved.
- A fresh critic agent/session must review the closeout-only evidence head from a different worktree; only the critic report may change afterward, and a repository admin or maintainer other than the PR author must submit an `APPROVED`, commit-bound GitHub review matching the final PR head before integration.
- Runtime deployment must be verified separately from merge success.

Run `bin/verdify route --write` when lifecycle position is unclear and `ruby scripts/validate-repo.rb` before changing this skills repository.

<!-- BEGIN agent-fleet CI/CD contract (managed — rendered by jvallery/agents) -->
<!-- agent-fleet:contract-digest sha256:7a4df1965712fb0421f0b2d7c021eb384d5e364e1df3c08f9a633673c1828a34 -->
## CI/CD contract — `VerdifyConsultancy/verdify-skills`

This block is **rendered centrally** by `jvallery/agents` from `control-plane/agent-fleet-control/registry/repos/gh-1275486978.yaml` (`scripts/render_repo_guidance.py`).

**Do not hand-edit anything between the sentinels.** Edits here are overwritten on the next render, and a hand-edit is a *gate failure*, not a merge conflict. To change what this says, change the registry record and open a PR against `jvallery/agents`. Everything outside the sentinels is this repo's own, and the renderer never touches it.

**For CI/CD, this managed block is the repo's durable plan of record.** It supersedes conflicting repo-local CI/CD instructions, approval holds, workflow handoffs, and historical status notes outside the sentinels. Product governance, privacy, Secret handling, storage safety, and destructive-change controls still apply. Resolve a contract conflict in the central registry; do not bypass either boundary.

### How this repo validates and builds

Run CI **from this repo's fleet pod**, against an exact pushed commit:

```
agent-ci-validate --submit --wait --revision <40-character-sha>
```

The helper reads this repo's committed `.agent-fleet/ci.yaml` `checks.steps[]`. The server-side admission policy independently binds this pod's ServiceAccount to the same repository URL, exact commands, images, fixed `repo-validate` template, metadata, and parameter order; the SHA is the only caller-variable. An arbitrary Workflow, command, image, Secret selector, or cross-repo checkout is denied.

Checkout credentials are short-lived, repository-restricted GitHub App tokens minted inside the platform template. They are never caller-selected and never passed to the validation container. Success means the created Workflow reaches `Succeeded`; `agent-ci-validate --wait` exits non-zero on red, error, or timeout.

**This repo publishes no container image.** Its exact validation builds and verifies the external package `@verdify-cli/cli`; publication is the separate release path below.

Checks are declared in `.agent-fleet/ci.yaml` under `checks.steps[]`; each step is a literal command whose exit code is pass/fail. This committed file and its registry authorization must move together.

### How this repo deploys

**Routine merges to `dev` deploy nothing.** Package delivery is a separate generated `dev` → `main` release PR.

Merging that release PR triggers `.github/workflows/publish-npm.yml` on `main`. It uses npm Trusted Publishing/OIDC to publish the npm package `@verdify-cli/cli`, an immutable Git tag, and a GitHub release with release assets. No long-lived npm token is delivered to the repo pod.

**That release merge is an irreversible external delivery action.** Run the exact repo-pod validation first, verify the version is intentionally releasable and not already published, then merge the generated release PR. Do not create a throwaway public package version merely to smoke-test CI/CD.

For fleet acceptance without a real version release, the terminal proof is the exact-SHA repo-pod run building and verifying the package archive; record the external release path as available-but-not-invoked.

### Its required check

Check results are check-runs; verify them on the **head commit** of the PR:

```
gh pr checks <n> --repo VerdifyConsultancy/verdify-skills
gh api repos/VerdifyConsultancy/verdify-skills/commits/<sha>/check-runs
```

**There is no required check on this repo, and there cannot be one.** Measured 2026-08-02: the branch-protection API returns `403 Upgrade to GitHub Pro or make this repository public` — this is a private repo on a **Free-tier organisation**, where branch protection does not exist at any configuration.

VerdifyConsultancy is on the GitHub Free plan, so this private repository cannot enforce required status checks. The repo agent must run the exact in-cluster validation and must not merge red.

So "enforced" here means exactly this: **the check runs, it is visible on the PR, and the repo agent does not merge red.** It does not mean anything will stop you. Treat a red or absent check as if merging were blocked — because nothing else will. Do not write `enforced` about this repo in any ledger; the honest word is `advisory`.

**A red check in this estate frequently means the job never ran.** Before you believe either colour, look at the run's `steps` and `runner_name`. Classify every failure before retrying: a *code-failure* is yours to fix and retrying it without a diff is prohibited; an *infra-failure* (runner pickup timeout, image pull) may be retried.

### Where its secrets come from (NAMES only — never values)

**No workflow in this repo may carry a secret value, and no agent may print, paste, commit or log one.** Everything below is a reference: a Kubernetes Secret name, a SOPS/ksops path, or a scoped identity. Values live sealed in `jvallery/agents` under `platform/gitops/secrets-ksops/` and are mounted by the substrate.

| what | reference |
| --- | --- |
| GitHub auth | `github-app-installation` / profile `repo-agent-standard` / activation `enabled` |
| External package publisher | `.github/workflows/publish-npm.yml` → npm Trusted Publishing/OIDC; no long-lived npm token in the repo or repo pod |

**The validation command container gets no secrets and no Kubernetes authority.** A separate platform-owned fetch init mints a short-lived, contents-read token from the CI GitHub App and hands over only the checkout; the repo pod cannot select the App Secret or read it. Repo/org Actions secrets are not part of this path. A GitHub Actions job that listens on `pull_request` and references a secret fails lint. `packages: write` is a lint failure everywhere (it only exists to reach ghcr, which is banned).

A Kubernetes `Secret` is secret-bearing **in full**, including every annotation value — `kubectl.kubernetes.io/last-applied-configuration` replays the entire `data` block. Never dump annotations on a Secret; select named fields only.

### What you may do WITHOUT asking

This section exists to remove human gates, not to add them. If an action is listed here, **do it — do not ask.**

**James leads this shared-org repo; repo-local standard autonomy is explicitly enabled for this repo agent.** It applies only to the agent's own branches, PRs, issues, and the fleet CI/CD contract below. Never merge, close, rewrite, or alter James's work or environment.

- **Commit and push** routine changes on a branch, and **open the PR**.
- **Merge your own green PR** — it is not a draft, its check is green *on the head commit after any rebase*, and merging it is not itself a delivery action into a live cluster.
- **Re-run a generated artifact's renderer** and commit the result. Generated files are regenerated, never merged by hand: on a conflict, rebase and re-run the renderer.
- **Retry an infra-failure** (runner pickup timeout, image pull); classify first.
- **Fix your own red check** and push again, as many times as it takes.

**Ask first** — these are irreversible or reach beyond this repo:

- Any **destructive cluster mutation** (delete a workload, wipe a PVC) or any change to an un-IaC'd surface (UniFi/UDM, the NAS). These go through the **change-gate** (snapshot → human `APPLY` → dead-man → post-verify) and never run autonomously.
- **History rewrite / force-push** to a shared branch, credential rotation, mass changes across repos, and anything touching another operator's environment.
- **`--admin` or any protection bypass.** Never. If a rule blocks you, the rule is working; report it.

When you cannot tell how reversible something is, propose it and confirm.

**Never claim done from a merge.** Merging is not shipping. A claim carries a UTC timestamp and the literal probe, and is re-probed later with the identical command (`GREEN at <T>, re-verified at <T+N>`). A regressed re-probe is not done. Bare "GREEN/done/✅" is banned.

### Runner constraints that will bite you

**ARC runners set `no_new_privs`.** `sudo` cannot elevate, so installing a tool to a system path fails — while the download succeeds, which is why this was twice misdiagnosed as absent runners and then as blocked egress:

```
sudo mv /tmp/kustomize /usr/local/bin/
  -> sudo: The "no new privileges" flag is set, which prevents sudo from running as root.
```

Install to your own path instead:

```yaml
mkdir -p "$HOME/.local/bin"
install -m 0755 /tmp/<tool> "$HOME/.local/bin/<tool>"
echo "$HOME/.local/bin" >> "$GITHUB_PATH"
export PATH="$HOME/.local/bin:$PATH"   # so THIS step's own verification resolves
```

`$GITHUB_PATH` covers *subsequent* steps; the in-step `export` is what makes the install's own verification line work. This hardening is deliberate and is not to be relaxed.

**The runner service account has no RBAC.** A validation job reaches the Kubernetes API and may read nothing (`kubectl auth can-i list nodes` → `no`). A job needing cluster reads must ship an explicit, minimal, reviewed grant — and creating one is a change-gated mutation, not part of onboarding.

---

_Fleet CI contract: `docs/fleet-ci-contract.md` in `jvallery/agents`. Delivery mode `validate-only` + external release `npm-trusted-publishing`; autonomy `standard`. This block's freshness and integrity are gated by `repo_guidance_guard.py` — a stale or hand-edited block fails the fleet build._
<!-- END agent-fleet CI/CD contract (managed — rendered by jvallery/agents) -->
