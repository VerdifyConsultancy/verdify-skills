# Claude Code instructions

Use `/project-router` as the default entrypoint for Verdify lifecycle work. Invoke a later skill directly only when its prerequisite artifacts and approval gates exist.

Mandatory repository rules:

- GitHub Issues are the backlog source of truth.
- GitHub issues, pull requests, checks, releases, and deployments form the operational control plane.
- One issue, lane, branch, worktree, coding session, and pull request is the normal execution unit.
- Never reuse a worker worktree for a second coding session or for independent criticism.
- Use `.github/pull_request_template.md` for every PR. Preserve the required headings, close the linked issue, include the lane contract path, record implementation and evidence heads, and refresh `Current head SHA` to the exact PR head commit before checks run.
- Treat implementation, closeout evidence, critic report, and external review submission as distinct revisions. Worker and critic agents/sessions may never match, even after leases are released; the final approval must come from a different repository admin/maintainer; and any post-review commit invalidates it.
- Validate candidate branches with protected-base or atomically installed policy code, not validator code controlled only by the candidate.
- For new or renamed skills, run `make links` or `ruby scripts/setup-agent-hosts.rb` and commit both host symlinks under `.agents/skills/` and `.claude/skills/`.
- Obey `COMMON_OPERATING_CONTRACT.md`, the lane contract, and `config/authority-matrix.yaml`.
- Record all material decisions and evidence in durable artifacts.
- Do not merge, deploy, or close issues based only on narrative claims.

Use `bin/verdify route --write` to reconstruct the next lifecycle step.

<!-- BEGIN agent-fleet CI/CD contract (managed — rendered by jvallery/agents) -->
<!-- agent-fleet:contract-digest sha256:bb3388099d9d2704fccd4468422feaf2e35bb18605231ac69bcaf218051944a3 -->
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

**This repo publishes no image.** It runs PR checks and ships no artifact.

Checks are declared in `.agent-fleet/ci.yaml` under `checks.steps[]`; each step is a literal command whose exit code is pass/fail. This committed file and its registry authorization must move together.

### How this repo deploys

**Merging here deploys nothing** — this repo ships no artifact. A built image sits in the zot origin until something pins its digest.

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

_Fleet CI contract: `docs/fleet-ci-contract.md` in `jvallery/agents`. Delivery mode `validate-only`; autonomy `standard`. This block's freshness and integrity are gated by `repo_guidance_guard.py` — a stale or hand-edited block fails the fleet build._
<!-- END agent-fleet CI/CD contract (managed — rendered by jvallery/agents) -->
