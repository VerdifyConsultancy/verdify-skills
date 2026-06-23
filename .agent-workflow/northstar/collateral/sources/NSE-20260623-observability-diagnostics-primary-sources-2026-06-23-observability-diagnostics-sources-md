# Observability And Diagnostics Primary Sources

Date: 2026-06-23
Evidence status: observed

## Scope

This note follows primary or near-primary documentation for CI/CD telemetry,
AI/agent observability, Grafana observability-as-code, and dashboard
provisioning as they relate to `observability-diagnostics`, `review-inbox`,
`wave-release-planning`, and release verification.

## Followed Sources

- OpenTelemetry CI/CD semantic conventions:
  https://opentelemetry.io/docs/specs/semconv/cicd/cicd-metrics/
- OpenTelemetry AI agent observability:
  https://opentelemetry.io/blog/2025/ai-agent-observability/
- OpenTelemetry semantic conventions:
  https://opentelemetry.io/docs/specs/semconv/
- Grafana AI Observability:
  https://grafana.com/docs/grafana-cloud/machine-learning/ai-observability/
- Grafana Observability as Code:
  https://grafana.com/docs/grafana/latest/as-code/observability-as-code/
- Grafana provisioning:
  https://grafana.com/docs/grafana/latest/administration/provisioning/

## Observed Findings

- OpenTelemetry CI/CD semantic conventions define pipeline run results and
  states, including successful, failed, skipped, pending, executing, and
  finalizing states, plus CI/CD worker state metrics.
- OpenTelemetry's AI agent observability writing distinguishes agent
  applications from agent frameworks and describes active work to standardize
  telemetry for AI agent frameworks such as AutoGen and LangGraph.
- Agent observability requires instrumentation that emits traces, metrics, and
  logs. Framework instrumentation can be built-in or integrated through
  observability tooling.
- Grafana AI Observability is built on OpenTelemetry and is aimed at monitoring
  production LLM agents, conversations, costs, quality, and performance.
- Grafana AI Observability lists automatic or built-in integrations for
  LangChain, LangGraph, OpenAI Agents, Vercel AI SDK, and related frameworks.
- Grafana Observability as Code supports versioned, automated, scalable
  management of dashboards, data sources, and observability workflows through
  code, CI/CD, and infrastructure-as-code patterns.
- Grafana provisioning can manage data sources and dashboards from YAML/JSON
  files, version those files, and load dashboards from local filesystem paths.
- Grafana provisioned dashboard updates have drift and overwrite semantics:
  UI changes are not automatically saved back to the provisioning source, and
  provisioning can overwrite database state.

## North Star Implications

- `observability-diagnostics` should define required correlation fields for
  issue, wave, session, PR, deployment, policy decision, and CI/CD run state.
- `review-inbox` should include links or evidence for CI/CD state, deployment
  markers, smoke tests, dashboards, logs, traces, and known missing telemetry.
- `wave-release-planning` should require telemetry expectations before dispatch:
  what pipeline states, runtime health signals, and rollback signals prove the
  wave is review-ready.
- Repositories should contribute dashboards and alerting assets as code, with
  clear ownership and drift behavior, rather than relying only on manually
  edited dashboards.
- Agent Platform observability should include agent activity and tool calls, not
  just application pod metrics.

## Limitations

- Grafana AI Observability is currently documented as public preview, so the
  exact product surface may change.
- This note does not inspect the local Grafana, Prometheus, or OpenTelemetry
  deployment state.
- OpenTelemetry agent conventions are still evolving; use them as a direction
  and compatibility target, not as a frozen schema.
