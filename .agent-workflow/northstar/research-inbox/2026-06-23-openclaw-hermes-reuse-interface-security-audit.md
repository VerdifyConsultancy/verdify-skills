# OpenClaw And Hermes Reuse Interface/Security Audit

Date: 2026-06-23
Evidence status: observed local repository evidence.
Source repos: `/Users/jason/repos/openclaw`, `/Users/jason/repos/verdify-platform/hermes`.

## Scope

This note closes the research-queue gap for the OpenClaw/Hermes reuse decision.
It focuses on interface and security patterns that Verdify Skills and Agent
Platform can reuse or adapt. It does not propose a runtime dependency. No raw
secrets, tokens, private keys, or runtime state files were read.

## Source Files Inspected

OpenClaw:

- `docs/cli/mcp.md`
- `docs/cli/approvals.md`
- `docs/concepts/session.md`
- `docs/concepts/queue.md`
- `docs/agent-runtime-architecture.md`
- `docs/logging.md`

Hermes:

- `hermes/iris/config.yaml`
- `hermes/iris/README.md`

## Observed Claims

- OpenClaw has several MCP surfaces: it can run as an MCP server exposing Gateway-backed conversations, manage outbound MCP server definitions, and project scoped MCP configuration into supported runtimes.
- OpenClaw's MCP server bridge exposes conversation/session tools such as list/get/read, event polling/waiting, message sending, and approval handling over stdio while the Gateway owns routed session state.
- OpenClaw approvals separate requested exec policy from enforceable host approvals; host approvals files are the effective source of truth, and approvals can target local, gateway, or node hosts.
- OpenClaw session management explicitly warns that shared direct-message sessions can leak private messages between users unless DM isolation is enabled; recommended scopes include per-channel-peer and per-account-channel-peer.
- OpenClaw's queue model serializes runs per session key and supports `steer`, `followup`, `collect`, and `interrupt` modes with bounded caps/drop behavior. This is useful precedent for lane-aware controller/session handling.
- OpenClaw logging is JSONL-based with structured fields such as host, agent, session, and channel, and supports redaction configuration and log tailing through CLI/control UI.
- OpenClaw runtime architecture separates built-in runtime, session persistence, tool definitions/policies, hooks, provider registry, plugin SDK boundaries, and additional runtime adapters.
- Hermes Iris is deliberately narrower than OpenClaw for the Verdify production planner: memory, web, terminal, filesystem, and browser toolsets are disabled; dashboard is disabled; API server is the only interface; and only a fixed Verdify MCP allowlist is enabled.
- Hermes Iris excludes the raw `query` tool and requires writes to pass through named MCP tools that carry audit identifiers.
- Hermes runtime secrets live outside Git and are injected through local environment files; the versioned config records locations and handling mode without raw secret values.

## Reuse Decision

- Reuse OpenClaw as an architecture reference for session isolation, queue modes, MCP bridging, approvals, runtime adapter boundaries, JSONL logs, and trace correlation.
- Do not make OpenClaw the deterministic Verdify SDLC controller or GitHub/GitOps authority.
- Treat Hermes/OpenClaw as the higher-level conversation/planning layer above Agent Platform MCP/API control, where all consequential operations still pass through Verdify policies, GitHub authority, readiness checks, and human review gates.
- Prefer the Hermes Iris security posture for production planning agents: MCP-only tools, no raw shell/web/filesystem/browser access, explicit allowlists, disabled raw query escape hatches, API-only interface, and external secret injection.

## Planning Relevance

- Supports `PRQ-018`, `SURF-012`, `IFACE-012`, `ARCH-013`, and `ARCH-007`.
- Supports future `agent-platform-control`, `session-ledger`, `review-inbox`, and `controller-loop` contracts with concrete queue/session/log/approval patterns.
- Supports keeping powerful planner agents constrained by API/MCP contracts and review gates rather than granting broad terminal or Kubernetes powers.

## Limitations

- This was not a live runtime audit of OpenClaw Gateway or Hermes Iris.
- This pass did not inspect OpenClaw source implementation beyond docs.
- This pass did not test MCP calls, approval propagation, or Hermes deployment health.
