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
