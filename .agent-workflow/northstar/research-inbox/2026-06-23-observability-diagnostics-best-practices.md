# Observability Diagnostics Best Practices

Date: 2026-06-23
Search method: Brave Search API, followed by primary-source documentation review.
Scope: Define the first stable `observability-diagnostics` packet contract for
Verdify Skills as a release-verification diagnostic mode.

## Brave Search Queries

- `site:opentelemetry.io semantic conventions deployments CI CD logs metrics traces official docs`
- `site:opentelemetry.io semantic conventions kubernetes http server client official docs`
- `site:prometheus.io alerting rules recording rules official docs`
- `site:grafana.com docs provisioning dashboards alerting official docs`
- `site:kubernetes.io probes events logs debug services official docs`
- `site:docs.github.com deployments statuses checks workflow runs logs official docs observability`

## Primary Sources Reviewed

- OpenTelemetry Docs, semantic conventions:
  https://opentelemetry.io/docs/concepts/semantic-conventions/
- OpenTelemetry Docs, resources:
  https://opentelemetry.io/docs/concepts/resources/
- OpenTelemetry semantic conventions:
  https://opentelemetry.io/docs/specs/semconv/
- Prometheus Docs, alerting rules:
  https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/
- Prometheus Docs, recording rules:
  https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/
- Grafana Docs, provisioning:
  https://grafana.com/docs/grafana/latest/administration/provisioning/
- Grafana Cloud Docs, dashboard automation:
  https://grafana.com/docs/grafana-cloud/as-code/observability-as-code/foundation-sdk/dashboard-automation/
- Kubernetes Docs, liveness/readiness/startup probes:
  https://kubernetes.io/docs/concepts/workloads/pods/probes/
- Kubernetes Docs, debug running pods:
  https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/
- Kubernetes Docs, observability:
  https://kubernetes.io/docs/concepts/cluster-administration/observability/
- GitHub Docs, workflow runs API:
  https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2026-03-10
- GitHub Docs, check runs API:
  https://docs.github.com/en/rest/checks/runs?apiVersion=2026-03-10
- GitHub Docs, deployments API:
  https://docs.github.com/en/rest/deployments/deployments?apiVersion=2026-03-10

## Source-Backed Findings

- OpenTelemetry semantic conventions and resources give telemetry a consistent
  vocabulary for services, hosts, containers, Kubernetes metadata, HTTP, and
  other runtime dimensions. Diagnostic packets should preserve correlation
  fields such as service, namespace, pod, deployment, commit, PR, wave, session,
  trace, and policy identifiers.
- Prometheus alerting and recording rules separate raw time series from derived
  health signals and alert conditions. Diagnostic packets should record both
  source metric links and interpreted release-health signals.
- Grafana provisioning and dashboard automation support dashboards as code and
  CI/CD-managed observability assets. Diagnostic packets should link dashboards
  and record whether telemetry is provisioned or ad hoc.
- Kubernetes probes, pod lifecycle, events, logs, and debugging docs define
  the practical runtime evidence needed to distinguish healthy processes from
  ready services. Diagnostic packets should include probes, events, logs, pod
  phase, restarts, endpoint health, and namespace context.
- GitHub workflow runs, check runs, and deployments provide delivery and
  deployment markers that should be correlated with runtime telemetry before a
  review or release health conclusion is accepted.

## Implementation Implications

- Keep `observability-diagnostics` as a release-verification diagnostic packet
  first, not a top-level canonical skill, until one reliable manual run proves
  the contract and owner.
- Add `observability-diagnostic-packet.schema.yaml`.
- Required packet groups should cover scope, correlation IDs, hypotheses,
  telemetry links, signal assessments, runtime checks, deployment markers,
  findings, missing instrumentation, recommendation, and feedback route.
- `review-inbox` should consume diagnostic packets when telemetry is material
  to review-ready status.
- `platform-readiness` should use the same packet shape for missing
  instrumentation and environment-readiness diagnostics.

## Limitations

- This research defines diagnostic evidence shape, not a mandate to adopt a
  specific metrics, logs, traces, dashboard, or alerting product.
- The first packet contract is manual and evidence-link based. Automated
  telemetry collection remains future Agent Platform/API work.
