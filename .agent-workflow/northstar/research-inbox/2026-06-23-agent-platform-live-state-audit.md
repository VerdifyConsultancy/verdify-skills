# Agent Platform Live-State Audit

Date: 2026-06-23
Evidence status: observed read-only GitHub, Git, Kubernetes, and Argo CD state.
Repository: `/Users/jason/repos/agents`
Remote: `https://github.com/jvallery/agents.git`

## Scope

This note closes the research-queue gap for Agent Platform live-state evidence.
It records read-only checks only. No raw secrets, kubeconfigs, tokens, secret
objects, pod exec, or production mutation were used.

## Commands And Sources Inspected

- `git -C /Users/jason/repos/agents fetch origin --prune`
- `git -C /Users/jason/repos/agents rev-parse --short HEAD`
- `git -C /Users/jason/repos/agents rev-parse --short origin/main`
- `git -C /Users/jason/repos/agents status --short --branch`
- `gh issue list --repo jvallery/agents --state open --limit 100 --json ...`
- `gh pr list --repo jvallery/agents --state open --limit 100 --json ...`
- `kubectl get namespace`
- `kubectl get applications.argoproj.io -n argocd`
- `kubectl get deploy,sts,po,svc,ingress,cm -n agent-fleet-runners`

## Observed Claims

- Local Agent Platform checkout is behind remote: local `HEAD` is `9a47ee19a`, while `origin/main` is `870a703f8` after fetch; the local branch reports `main...origin/main [behind 10]`.
- GitHub currently has 35 open issues in `jvallery/agents`, including active Agent Fleet MVP work, security tasks, runtime tasks, validation tests, and human-gated items.
- GitHub currently has 3 open pull requests in `jvallery/agents`: `#1766` per-repo agent enablement dashboard control, `#1765` legacy persona/catalog registry deletion, and `#1749` agents.vallery.net live e2e harness hardening.
- Kubernetes context `vallery` exposes relevant active namespaces including `agent-fleet-ci`, `agent-fleet-dashboard`, `agent-fleet-runners`, `argocd`, `gravity-dev`, `gravity-stage`, `openclaw`, `orbit`, `sunshine-club`, `verdify-platform`, and Verdify app namespaces.
- The `agent-fleet-runners` namespace has 31 StatefulSets and 31 running repo pods, including `repo-jvallery-agents-0`, `repo-verdifyconsultancy-gravity-0`, `repo-verdifyconsultancy-sunshine-club-0`, `repo-jvallery-openclaw-0`, and `repo-verdifyconsultancy-verdify-skills-0`.
- Argo CD reports 25 Agent Platform, Gravity, Sunshine, OpenClaw, Orbit, and Onyx-related Applications. Status grouping: 16 `Synced/Healthy`, 1 `Synced/Progressing`, 1 `Synced/Degraded`, 2 `OutOfSync/Healthy`, 2 `Unknown/Healthy`, and 3 `Unknown/Unknown`.
- Notable Argo states for readiness: `agent-sessions-local-staging` is `OutOfSync/Healthy`; `agent-fleet-ci-secrets`, `agent-fleet-dashboard-secrets-local-staging`, and `agent-fleet-runners-secrets-local-staging` are `Unknown/Unknown`; `gravity-dev` and `gravity-stage` are `Unknown/Healthy`; `sunshine-club-local-dev` is `Synced/Degraded`.
- The observed live state supports the North Star assumption that Agent Platform is a real k3s/GitOps/repo-pod control surface, but it also shows readiness gaps that should block broad autonomous platform claims until reconciled.

## Planning Relevance

- Supports `platform-readiness` as mandatory before autonomous Agent Platform or Gravity pilot execution.
- Supports `PRQ-017`, `PRQ-018`, `ARQ-016`, and `ARQ-017` with live evidence that source control, CI/CD, k3s apps, repo pods, Argo CD, and API/MCP control are one operating plane.
- Supports keeping the review/evidence loop active: live Argo and GitHub states currently contain Unknown, OutOfSync, Degraded, and human-gated work that must be reconciled before final readiness claims.

## Limitations

- This was not a full platform-readiness pass.
- No pod logs, secret values, Secret resources, live API endpoints, browser terminal, or MCP write tools were exercised.
- The current local checkout was not updated to `origin/main`; observations about current remote code are limited to Git metadata and selected previous local evidence.
