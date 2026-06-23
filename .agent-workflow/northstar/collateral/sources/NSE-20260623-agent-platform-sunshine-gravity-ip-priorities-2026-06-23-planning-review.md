# Planning Evidence: Agent Platform, Sunshine Gravity, OpenClaw, And Owned IP Priorities

Captured: 2026-06-23

## User Feedback

- The core product is not only an Agent Delivery OS. It is also Jason's source control, CI/CD, pipeline, and k3s management story tied together.
- `agents.vallery.net` is likely the control surface, but normal operation may happen through MCP with a higher-level planning agent via Hermes/OpenClaw rather than through frequent direct UI use.
- Gravity should remain blocked until a non-Gravity pilot proves the delivery loop.
- Gravity's first MVP story is local filesystem evidence ingestion.
- All of Gravity should be treated as reusable platform capability, not a one-off application.
- Sunshine Club should be reviewed as a source of reusable Gravity implementation because much of the desired platform shape may already exist there.

## Observed Agent Platform Context

- `jvallery/agents` is a live Agent Fleet / control-plane repository for `agents.vallery.net`.
- The repo contains a CPv1 North Star, API surface manifest, repo-pod runtime contract, telemetry/trace contracts, desired-state GitOps writer ADR, and onboarding/API contracts.
- The live platform has Authentik-protected dashboard/API behavior, a public `/install` onboarding script, repo/agent discovery, reconcile state, telemetry, and Kubernetes-backed repo pods.
- Current readiness is meaningful but not complete: observed live state included drift/degraded signals and open P0 work around durability, token rotation, NAS removal, and onboarding proof.

## Observed Sunshine Club / Gravity Context

- `VerdifyConsultancy/sunshine_club` is not just a prototype. It contains FastAPI, Next.js dashboard, workers, agent service, Kubernetes manifests, Postgres/Qdrant/object-storage integration, Gravity routers/scripts, and a substantial GitHub backlog labeled `gravity`.
- Sunshine's Gravity plan already implements a file-centric, content-addressed evidence pipeline: filesystem/NFS discovery, SHA-256 identity, managed S3 source objects, Postgres operational truth, Qdrant/FTS search, review queues, MCP tools, Ray/agent surface, vault projection, and governed access concepts.
- Sunshine's docs explicitly separate generic Gravity file enrichment from Sunshine-specific prompt/schema/persona packs.
- Reuse is high value, but extraction is required: current code and manifests still carry Sunshine-specific package names, environment variables, namespace names, paths, taxonomy, and business-story assumptions.

## Observed OpenClaw / Orbit Context

- `jvallery/openclaw` is a local-first personal AI assistant/gateway with channels, sessions, tools, skills, sandboxing, and gateway protocol surfaces.
- `jvallery/orbit` is Jason's private OpenClaw workspace and k3s deployment surface with Hermes runtime coordination, durable OpenClaw state, storage, GitOps, route, and validation runbooks.
- OpenClaw/Hermes should be considered a higher-level planning/conversation layer above the Agent Platform control APIs, not automatically folded into the dashboard UI story.

## Planning Implications

- The North Star should frame Verdify Skills + Agent Platform + OpenClaw/Hermes + Gravity as a self-hosted software-and-knowledge operating plane.
- `agents.vallery.net` should be planned API/MCP-first, with the UI as inspection, review, recovery, and operator console.
- The owned IP boundary should emphasize the orchestration, evidence, lifecycle, control-plane, and reusable Gravity engine contracts rather than commodity CI, GitOps, database, vector, or Kubernetes primitives.
- Sunshine Club should become the reference implementation and code-mining source for a reusable Gravity core plus organization-specific packs.
- The next plan should prioritize Agent Platform readiness, MCP/control contracts, Skills North Star lock, non-Gravity pilot, and Sunshine-to-Gravity extraction planning before Gravity feature implementation.

## Limitations

- This evidence combines user-reported priorities with local repository and cluster observations from a side-conversation review.
- The observations were non-mutating and sampled high-value surfaces, not a full code audit of every module.
- This is planning evidence only and does not constitute final North Star lock approval.
