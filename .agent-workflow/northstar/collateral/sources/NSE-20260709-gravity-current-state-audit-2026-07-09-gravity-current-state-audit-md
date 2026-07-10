# Gravity Current-State Audit — 2026-07-09

Evidence status: verified or observed where stated. This is a point-in-time read-only audit of `VerdifyConsultancy/gravity`, GitHub, Argo, workloads, API, database counts, and MCP initialization.

## Current truth

- GitHub `main`, local `origin/main`, and live Argo revision match `1bb5507a7f608f16ba421620aa8cf7edf8278590`.
- Gravity is the restarted active in-flight project. It is not a legacy or grandfathered deployment.
- Argo reports Synced and Healthy, but the last sync operation failed because a conversion Job ran for 29 hours. Existing Gravity issues #326 and #376 own that failure and Argo Job coupling.
- Core Deployments are Ready and direct `/readyz` returns 200. GitHub Actions capacity is exhausted under Gravity #162.
- Product North Star, architecture North Star, project definition, and architecture definition are approved, but canonical platform-readiness and Gravity-readiness outputs are absent. State-of-union, sprint status, router, and ADR index are stale or inconsistent.

## Evidence API and MCP

- Live HTTP search exists at `POST /retrieval/search` and returned an authenticated successful result with five allowed hits.
- The live spine contained approximately 74,609 chunks and 74,609 evidence-span rows, but every returned hit had zero evidence spans.
- Verified cause: chunk records carry `evidence_span_ids`, while the current read-model projection reads `record.evidence_spans` without resolving the authoritative rows.
- Read-only stdio MCP initializes and exposes `gravity.search`, `gravity.get_evidence`, and `gravity.get_processing_status`.
- No network MCP service is exposed or registered in Gravity or Orbit pod configuration, so cross-pilot consumption is not yet integrated.
- Current query authorization is vault and tenant scoped rather than per-principal source ACL enforcement.

## Existing issue coverage

- Gate B API, MCP, citation, and durability acceptance: Gravity #184.
- MCP engine implementation: closed Gravity #178.
- Cross-pilot consumers: Orbit #43 and #165; Agents #2336, #2707, and #2709.
- Current authorization decision: closed Gravity #272.
- GitHub CI, conversion, and Argo failures: Gravity #162, #326, and #376.

## New issues

- Gravity #406: reframe Gravity as a co-equal active pilot under the root-planner outer loop.
- Gravity #407: hydrate live search results with evidence-span citations and prove API/MCP parity.

## Planning implications

- Gravity owns evidence and search semantics. Agent Platform owns shared runtime, identity, and transport. Orbit is a consumer and information-layer coordinator. The root planner coordinates dependencies and gates.
- Capability state must distinguish implemented, deployed, exposed, integrated, and release-verified.
- Gravity should expose a versioned tenant-scoped read-only HTTP API first, with a consumer-side MCP adapter until a trusted network MCP transport is accepted.
- Evidence references and typed denials are required capability outputs, not optional decorations on successful search.
- Gravity readiness is the trust and integration gate for cross-pilot consumption and promotion of the active project; it is not evidence that development has not started.

## Limitations

- Live counts and workload state can drift and must be reverified at implementation and release gates.
- This audit did not mutate Gravity source, GitHub, Argo, or runtime state.
