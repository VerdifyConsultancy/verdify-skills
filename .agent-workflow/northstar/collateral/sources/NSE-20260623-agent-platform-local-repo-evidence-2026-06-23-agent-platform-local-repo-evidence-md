# Agent Platform Local Repository Evidence

Date: 2026-06-23
Evidence status: observed local repository evidence
Repository: `/Users/jason/repos/agents`
Observed local HEAD: `9a47ee19a63d5a04a1c31f74072c10d92dfdbb4a`

## Scope

This note captures locally observed evidence from the Agent Platform repository
and its `control-plane/agent-fleet-control/` subtree for the Verdify Skills
North Star loop. It contains planning and architecture evidence only. No raw
secrets, private keys, kubeconfigs, tokens, or credential values were copied.

## Source Files Inspected

- `/Users/jason/repos/agents/README.md`
- `/Users/jason/repos/agents/AGENTS.md`
- `/Users/jason/repos/agents/control-plane/agent-fleet-control/README.md`
- `/Users/jason/repos/agents/docs/observability-standard.md`
- `/Users/jason/repos/agents/docs/kubernetes-namespace-lifecycle.md`

## Observed Claims

- `jvallery/agents` describes itself as the control plane for the Vallery agent
  fleet, with agents running as a pod-per-repo runtime in k3s namespace
  `agent-fleet-runners`.
- The documented work flow is UI button to API to registry write to render to
  Argo CD to live pod, which matches the North Star direction of declarative
  control-plane state plus reconciled runtime state.
- The `control-plane/agent-fleet-control/` README names YAML under `registry/`
  as the source of truth and the render chain
  `registry/agent-sessions/*.yaml` to `scripts/render_agent_sessions.py` to
  `manifests/agent-sessions/generated/**` to Argo CD to StatefulSets as the
  durable deliverable.
- The Agent Platform already treats GitHub Issues as the live work board and
  source of truth for work, with one issue-scoped branch/worktree per active
  execution lane as an operating rule.
- The repo includes explicit gates for destructive actions, ACP completion,
  durability re-probe, and completion contracts, providing source evidence for
  North Star gate and verification requirements.
- The observability standard requires every project profile to declare logs,
  metrics, traces, runbooks, health checks, deployment metadata, dashboard
  references, and MVP evidence before moving beyond bootstrap.
- The issue-scoped lifecycle dashboard shape is documented as GitHub issue to
  Agent Deck session to branch/worktree to PR to preview or environment to
  cleanup.
- The Kubernetes namespace lifecycle contract uses `<project>-dev`,
  `<project>-preview-pr-N`, `<project>-staging`, and `<project>-prod`, with
  generated Namespace, ResourceQuota, LimitRange, deployer ServiceAccount,
  Role/RoleBinding, and default-deny ingress NetworkPolicy.
- Preview deployers intentionally do not receive Secret access, and production
  secrets must not be copied to preview namespaces.
- The local Agent Platform docs already encode several North Star target
  behaviors: registry authority, deterministic rendering, GitOps convergence,
  issue-scoped work identity, namespace/environment modeling, no-plaintext
  secret posture, and observability/deployment metadata expectations.

## Planning Relevance

- Supports keeping Agent Platform as an API/control-plane runtime dependency
  for future controller, worktree, review, deployment, and observability loops.
- Supports North Star requirements for CI/CD wave deployment, preview
  environments, namespace-scoped resources, and issue/session/worktree/PR
  traceability.
- Supports promoting `agent-platform-control`, `review-inbox`,
  `wave-release-planning`, `observability-diagnostics`, and `session-ledger`
  from design ideas into concrete planning work once interfaces are specified.
- Supports resolving repo/application/environment/namespace cardinality around
  durable application identity plus environment-scoped namespaces.

## Limitations

- This is local repository evidence, not a live cluster audit.
- Local HEAD may differ from remote `main`; this note records the local state
  observed during planning.
- GitHub board state, Argo CD live sync state, Kubernetes live resources, and
  current credential availability were not validated in this note.
