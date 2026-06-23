# Browser Terminal Security Patterns

Date: 2026-06-23
Discovery method: Brave Search API, followed by direct URL reachability checks.
Status: researched for North Star evidence ingest.

## Brave Search Coverage

- Query: `browser terminal Kubernetes exec ephemeral containers ttyd wetty gotty security session recording network isolation Argo CD terminal`
- Follow-up queries: `Argo CD web based terminal official docs exec privilege`, `Kubernetes kubectl exec official documentation ephemeral containers debug official`, `ttyd official GitHub terminal over web TLS basic auth`, `Wetty official GitHub web terminal`, `GoTTY official GitHub terminal web`.
- Selection rule: prefer official project documentation, Kubernetes documentation, and upstream repositories over blogs and mirrors.

## Primary Sources Followed

- Argo CD web-based terminal: https://argo-cd.readthedocs.io/en/stable/operator-manual/web_based_terminal/
- Argo CD source doc mirror in upstream repository: https://github.com/argoproj/argo-cd/blob/master/docs/operator-manual/web_based_terminal.md
- Kubernetes ephemeral containers: https://kubernetes.io/docs/concepts/workloads/pods/ephemeral-containers/
- Kubernetes debug running pods: https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/
- Kubernetes `kubectl exec` reference: https://kubernetes.io/docs/reference/kubectl/generated/kubectl_exec/
- `ttyd` upstream repository: https://github.com/tsl0922/ttyd
- `WeTTY` upstream repository: https://github.com/butlerx/wetty
- `GoTTY` upstream repository: https://github.com/yudai/gotty

## Source-Backed Findings

- Argo CD's web terminal is explicitly equivalent to browser-mediated shell access into a running Kubernetes pod and depends on `exec/create` authorization against managed pods.
- Argo CD's documentation warns that terminal users can run arbitrary code in authorized pods; if those pods mount service account tokens, terminal access can expose the Kubernetes API permissions available to the pod.
- Kubernetes treats `kubectl exec`, `kubectl debug`, and ephemeral containers as troubleshooting mechanisms; ephemeral containers are specifically for interactive troubleshooting when normal `exec` is insufficient.
- Generic browser terminal projects such as `ttyd`, `WeTTY`, and `GoTTY` expose terminals or commands over HTTP/WebSocket-style browser surfaces; the upstream project docs show these as generic terminal-sharing primitives rather than full authorization, audit, or Kubernetes policy systems.
- A safe Agent Platform browser terminal therefore needs an explicit product/security boundary: disabled by default for production, scoped to non-production or break-glass contexts, authorized through least-privilege Kubernetes RBAC, network-isolated, time-bound, and tied to session audit evidence.

## Planning Relevance

- Supports `SURF-005` browser terminal as a high-risk surface rather than a default developer convenience.
- Supports `ARQ-003` least-privilege runtime access and `ARCH-007` prohibitions on broad production mutation and broad secret access.
- Supports platform-readiness checks that require explicit terminal enablement policy, RBAC, audit/session recording, token exposure controls, and network isolation before any browser terminal is accepted.

## Limitations

- This pass did not test a running Argo CD terminal, `kubectl debug`, `ttyd`, `WeTTY`, or `GoTTY` deployment.
- This pass did not evaluate commercial terminal-session recording products or Agent Deck-specific implementation details.
