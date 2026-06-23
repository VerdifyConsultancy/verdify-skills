# OpenClaw And Hermes Local Evidence

Date: 2026-06-23
Evidence status: observed local repository evidence
OpenClaw repository: `/Users/jason/repos/openclaw`
OpenClaw observed local HEAD: `9bd6ff4c146b259ee869c358b2278977a5e6c914`
Hermes repository: `/Users/jason/repos/verdify-platform/hermes`
Hermes observed local HEAD: `eb38f1975e1b42c287e20b8a5f05d373fc09dedb`

## Scope

This note captures local evidence from OpenClaw and Hermes for the Verdify
Skills North Star loop. It records planning, architecture, runtime, session,
MCP, approval, observability, and governance evidence only. No raw secrets,
private keys, tokens, or credential values were copied.

## Source Files Inspected

OpenClaw:

- `/Users/jason/repos/openclaw/README.md`
- `/Users/jason/repos/openclaw/VISION.md`
- `/Users/jason/repos/openclaw/AGENTS.md`
- `/Users/jason/repos/openclaw/docs/agent-runtime-architecture.md`
- `/Users/jason/repos/openclaw/docs/concepts/agent-loop.md`
- `/Users/jason/repos/openclaw/docs/concepts/session.md`
- `/Users/jason/repos/openclaw/docs/concepts/multi-agent.md`
- `/Users/jason/repos/openclaw/docs/concepts/agent-runtimes.md`
- `/Users/jason/repos/openclaw/docs/concepts/queue.md`
- `/Users/jason/repos/openclaw/docs/cli/approvals.md`
- `/Users/jason/repos/openclaw/docs/cli/mcp.md`
- `/Users/jason/repos/openclaw/docs/logging.md`

Hermes:

- `/Users/jason/repos/verdify-platform/hermes/iris/README.md`
- `/Users/jason/repos/verdify-platform/hermes/iris/SOUL.md`
- `/Users/jason/repos/verdify-platform/hermes/iris/config.yaml`

## Observed Claims

- OpenClaw is a local-first personal AI assistant with a Gateway control plane
  for sessions, channels, tools, events, multi-agent routing, skills, and MCP.
- OpenClaw has a documented agent loop: intake, context assembly, model
  inference, tool execution, streaming replies, persistence, session locks,
  lifecycle events, and wait semantics.
- OpenClaw sessions are routed by source, stored under per-agent state, and
  can be isolated by agent, channel, peer, account, or session key.
- OpenClaw multi-agent routing treats an agent as a scoped workspace, state
  directory, auth profile set, and session store, with deterministic bindings
  from channels/accounts/peers to agents.
- OpenClaw distinguishes provider, model, agent runtime, and channel layers.
  Runtime ownership can belong to the OpenClaw embedded runner, Codex app-server,
  ACP/acpx, Claude CLI, or other harnesses, while OpenClaw still owns channel
  delivery and session projection.
- OpenClaw serializes runs per session key and supports queue modes such as
  steer, followup, collect, and interrupt, providing a concrete precedent for
  lane-aware session execution and turn steering.
- OpenClaw exposes approval management for exec policies and allowlists, with
  host approvals files as enforceable source of truth.
- OpenClaw can act as an MCP server exposing conversations, transcript history,
  event polling/waiting, message sending, and approval response tools; it can
  also manage outbound MCP server definitions.
- OpenClaw logging uses JSONL file logs, control UI log tailing, structured
  log fields, and trace correlation fields when diagnostic trace context exists.
- OpenClaw intentionally routes optional integrations, providers, channels,
  skill bundles, and MCP surfaces through plugin, SDK, or bundle boundaries
  rather than adding every capability to core.
- Hermes local evidence is a narrow production planner profile for `hermes-iris`.
  It says OpenClaw was decommissioned for Verdify Iris planning cycles and that
  Hermes is the production route for that planner.
- Hermes Iris is configured as a single high-reasoning OpenAI-compatible profile
  with an MCP-only tool surface, disabled memory/web/terminal/filesystem/browser
  toolsets, disabled dashboard, and API-server-only interface.
- Hermes Iris excludes the raw `query` tool, requires audit identifiers on
  write tools, and frames the agent as a planner that writes hypotheses,
  outcomes, and lessons through governed MCP tools rather than direct relay or
  shell control.

## Planning Relevance

- Supports keeping Verdify Skills framework-neutral while borrowing concepts
  from OpenClaw: per-agent workspace/state/session isolation, runtime adapters,
  session queues, steering, approval tools, MCP exposure, JSONL logs, and trace
  correlation.
- Supports treating Hermes/OpenClaw as evidence for a higher-level
  conversation/planning layer above Agent Platform control APIs, not as a
  replacement for the deterministic SDLC controller or GitHub/GitOps authority.
- Supports the North Star decision that powerful autonomous planning agents
  should be constrained through MCP/API tool surfaces, disabled raw shell/web
  access where inappropriate, explicit tool allowlists, audit identifiers, and
  structured write contracts.
- Supports future `agent-platform-control`, `session-ledger`,
  `transcript-replan`, and `northstar-interview` design work.

## Limitations

- This is local repository evidence, not a live OpenClaw or Hermes runtime audit.
- OpenClaw evidence is broad and should be mined further before any component
  reuse or architecture dependency is proposed.
- Hermes local repository content is limited to the Iris profile package; it
  does not provide a complete Hermes platform implementation in this checkout.
- Runtime secret locations were observed as configuration facts, but no secret
  values were read or copied.
