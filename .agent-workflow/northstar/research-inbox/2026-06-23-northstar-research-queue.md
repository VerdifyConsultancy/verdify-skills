# North Star Research Queue

Date: 2026-06-23
Status: active

This queue tracks the current objective: keep looping on the North Star, read
the context, links, and ideas, search each topic, follow links, and persist
findings as evidence in the North Star registry.

## Completed This Pass

| Topic | Status | Evidence target |
| --- | --- | --- |
| Review inbox and review-ready delivery evidence | searched | `review-inbox-wave-release-primary-sources` |
| CI/CD wave release planning and GitOps preview/review environments | searched | `review-inbox-wave-release-primary-sources` |
| GitHub issues, sub-issues, merge queue, deployments, and environments | searched | `review-inbox-wave-release-primary-sources` |
| Argo CD, Argo Rollouts, Flux, and OpenGitOps deployment/reconciliation patterns | searched | `review-inbox-wave-release-primary-sources` |
| Observability diagnostics, OpenTelemetry CI/CD, AI agent observability, and Grafana as code | searched | `observability-diagnostics-primary-sources` |
| Controller, session ledger, MCP/API control, Backstage-style catalog, and knowledge-store primitives | searched | `controller-ledger-platform-control-primary-sources` |
| Supply-chain provenance, policy-as-code, Kubernetes RBAC/multi-tenancy, and storage tradeoffs | searched | `supply-chain-policy-knowledge-store-primary-sources` |
| Agent Platform local repository evidence | inspected and ingested | `agent-platform-local-repo-evidence` |
| Gravity local repository evidence | inspected and ingested | `gravity-local-repo-evidence` |
| OpenClaw/Hermes local repository evidence | inspected and ingested | `openclaw-hermes-local-evidence` |
| Sunshine Club reusable Gravity substrate evidence | inspected and ingested | `sunshine-gravity-reuse-local-evidence` |
| Agent Platform live-state audit | checked and ingested | `agent-platform-live-state-audit` |
| Gravity remote and Onyx confirmation | checked and ingested | `gravity-remote-onyx-confirmation` |
| Sunshine Club extraction architecture audit | inspected and ingested | `sunshine-gravity-extraction-architecture-audit` |
| OpenClaw/Hermes reuse decision | inspected and ingested | `openclaw-hermes-reuse-interface-security-audit` |
| Browser terminal security patterns | searched and ingested | `browser-terminal-security-patterns` |
| Secrets and credential injection patterns | searched and ingested | `secrets-credential-injection-patterns` |
| Source-control migration and local GitLab/Gitea/Forgejo patterns | searched and ingested | `source-control-migration-local-forges` |
| OpenGitOps event/session specificity | searched and ingested | `opengitops-events-session-specificity`, `opengitops-session-shortlist` |
| Long-horizon learning loop source verification | searched and ingested | `long-horizon-learning-loop-source-verification` |
| Review inbox product examples | searched and ingested | `review-inbox-product-examples` |
| Brave Search credential reference | located, validated, and recorded without raw secret | `.agent-workflow/northstar/credential-references.yaml` |

## Still Pending

No pending topics remain from this pass. Follow-up work should be opened only
when a downstream readiness gate or architecture claim requires deeper proof,
such as watching an individual GitOpsCon recording, testing a live browser
terminal, probing runtime endpoints, or inspecting secret controller
configuration.

## Loop Rule

Do not mark the overall research objective complete until every pending topic is
either researched and ingested, explicitly superseded by stronger evidence, or
recorded as impossible to verify with a concrete reason.
