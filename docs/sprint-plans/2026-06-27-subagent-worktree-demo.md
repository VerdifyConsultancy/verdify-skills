# Subagent Worktree Demo

This demo shows the local fallback flow for one approved lane when Agent Platform
dynamic worktree dispatch is unavailable or out of scope.

## Inputs

- Sprint: `2026-06-27-ship-verify-skills`
- Lane: `issue-91-subagent-worktree`
- Issue: #91
- Baseline: `fffa61c09cbe09f8d0dd32681029a967c59066ee`
- Local fallback gate:
  `.agent-workflow/sprints/2026-06-27-ship-verify-skills/gates/local-subagent-fallback.yaml`

## Dispatch Shape

```bash
bin/verdify lane create \
  --repo /Users/jason/repos/verdify-skills \
  --sprint 2026-06-27-ship-verify-skills \
  --lane-id issue-91-subagent-worktree \
  --issue 91 \
  --session-id worker-91-20260627a \
  --agent codex \
  --base fffa61c09cbe09f8d0dd32681029a967c59066ee \
  --path /Users/jason/repos/verdify-worktrees/2026-06-27-ship-verify/issue-91-subagent-worktree
```

## Review Evidence

The controller records the lease, prompt manifest, PR, validation results, and
closeout. The lane is not review-ready until the worker closeout is valid and a
fresh critic has reviewed the current PR head.
