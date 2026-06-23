# Session Ledger Best Practices

Date: 2026-06-23
Search method: Brave Search API, followed by primary-source documentation review.
Scope: Define the first stable `session-ledger` artifact contract for Verdify
Skills as a controller-loop ledger before promoting a standalone skill.

## Brave Search Queries

- `CloudEvents specification event id source type time subject data official docs CNCF`
- `W3C Trace Context traceparent tracestate correlation official recommendation`
- `OpenTelemetry logs events trace context semantic conventions official docs`
- `SLSA provenance predicate buildType materials invocation metadata official spec`
- `Sigstore Rekor transparency log inclusion proof official docs`
- `Temporal event history workflow durable execution official docs`
- `LangGraph persistence threads checkpoints official docs`
- `GitHub audit log REST API workflow run deployment checks official docs`
- `site:github.com/cloudevents/spec cloudevents spec.md id source type time subject datacontenttype`
- `site:w3.org/TR trace-context traceparent tracestate recommendation`
- `site:slsa.dev/spec provenance predicate buildDefinition runDetails materials official`
- `site:docs.sigstore.dev rekor transparency log inclusion proof official`
- `site:docs.temporal.io event history workflow execution official`
- `site:docs.langchain.com langgraph persistence checkpoints threads official`

## Primary Sources Reviewed

- CloudEvents specification:
  https://github.com/cloudevents/spec/blob/main/cloudevents/spec.md
- CNCF CloudEvents project:
  https://www.cncf.io/projects/cloudevents/
- W3C Trace Context:
  https://www.w3.org/TR/trace-context/
- OpenTelemetry semantic conventions:
  https://opentelemetry.io/docs/concepts/semantic-conventions/
- OpenTelemetry traces:
  https://opentelemetry.io/docs/concepts/signals/traces/
- SLSA provenance specification:
  https://slsa.dev/spec/v1.1/provenance
- Sigstore Rekor:
  https://docs.sigstore.dev/logging/overview/
- Temporal Workflow Execution Event History:
  https://docs.temporal.io/workflows#event-history
- LangGraph persistence:
  https://docs.langchain.com/oss/python/langgraph/persistence
- GitHub workflow runs API:
  https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2026-03-10
- GitHub check runs API:
  https://docs.github.com/en/rest/checks/runs?apiVersion=2026-03-10
- GitHub deployments API:
  https://docs.github.com/en/rest/deployments/deployments?apiVersion=2026-03-10

## Source-Backed Findings

- CloudEvents provides a portable event envelope with stable event ID, source,
  type, time, subject, data schema/content type, and extension attributes.
  Verdify ledger events should use equivalent fields rather than ad hoc status
  strings.
- W3C Trace Context separates trace identity from vendor-specific state and
  defines propagation fields for correlating distributed work. Verdify ledger
  records should preserve correlation IDs across parent/child sessions, waves,
  PRs, deployments, reviews, and diagnostics.
- OpenTelemetry traces and semantic conventions reinforce the need to model
  spans, resources, attributes, and events separately. Verdify should keep
  event metadata, artifact references, and evidence links distinct from raw log
  payloads.
- SLSA provenance separates subject identity, build definition, run details,
  materials, and metadata. Verdify session-ledger events should record source
  artifacts, inputs, outputs, and evidence refs for lifecycle-significant
  actions such as plan creation, prompt compilation, lease creation, PR open,
  review, deployment, rollback, and outcome acceptance.
- Sigstore Rekor demonstrates transparency-log patterns for recording signed
  entries and inclusion proofs. Verdify does not need signing for the first
  local contract, but should preserve fields for previous event ID, content
  hash, and optional external transparency/provenance references.
- Temporal event history treats workflow progress as a replayable sequence of
  events. Verdify should keep the session ledger append-oriented and make
  controller reconstruction possible after model context loss.
- LangGraph persistence uses threads and checkpoints to resume agent state.
  Verdify should preserve parent session, child session, checkpoint/state ref,
  and resume/handoff reason, while keeping GitHub and `.agent-workflow` as
  authority.
- GitHub workflow run, check run, and deployment APIs provide authoritative
  external event references. Verdify ledger entries should link to those
  records rather than copying full remote data.

## Implementation Implications

- Keep `session-ledger` as a controller-loop artifact contract first, not a
  top-level canonical skill, until one reliable manual run proves ownership and
  reuse across orchestrator, lane delivery, critic, release verification, and
  learning capture.
- Add `session-ledger.schema.yaml`.
- Required artifact groups should cover ledger metadata, retention/redaction,
  session graph, append-oriented events, artifact references, external refs,
  checksums, and open exceptions.
- Each lifecycle-significant event should record event ID, type, actor role,
  session identity, correlation IDs, authoritative artifact refs, evidence refs,
  external refs, result, previous event ID, content hash, and summary.
- `controller-loop` should validate both controller state and session ledger.
- `sprint-orchestrator`, `lane-delivery`, `independent-critic`,
  `release-verification`, and `northstar-planning` learning capture should
  treat the ledger as a durable source of session and wave evidence.

## Limitations

- This first contract is YAML and local-artifact based. It does not choose a
  future storage engine such as JSONL, SQLite, Postgres, or a service-backed
  event store.
- This contract preserves checksum and external-reference fields but does not
  implement signing, transparency-log inclusion, or automated trace ingestion.
