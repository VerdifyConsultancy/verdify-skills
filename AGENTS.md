# Agent instructions

Use the Verdify lifecycle skills for project definition, architecture, sprint planning, lane delivery, review, integration, and deployment verification.

Start or resume through `$project-router` unless the user explicitly names another lifecycle skill and its prerequisites are present.

Mandatory repository rules:

- GitHub Issues are the backlog source of truth.
- GitHub is the delivery control plane; do not replace issues or pull requests with private chat state.
- One issue, lane, branch, worktree, worker session, and pull request is the default unit of implementation.
- Acquire a lane lease before coding and never share an active worktree between coding sessions.
- Follow `COMMON_OPERATING_CONTRACT.md` and `config/authority-matrix.yaml`.
- Use durable `.agent-workflow` artifacts for approved definitions, contracts, status, and evidence.
- A fresh critic must review lane output before integration.
- Runtime deployment must be verified separately from merge success.

Run `bin/verdify route --write` when lifecycle position is unclear and `ruby scripts/validate-repo.rb` before changing this skills repository.
