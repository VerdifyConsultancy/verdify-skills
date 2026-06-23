# Controller, Ledger, And Agent Platform Control Primary Sources

Date: 2026-06-23
Evidence status: observed

## Scope

This note follows primary documentation for durable agent orchestration,
human-in-the-loop multi-agent coordination, MCP/API control surfaces, catalog
modeling, and lightweight-to-scaled ledger storage options.

## Followed Sources

- LangGraph project README:
  https://github.com/langchain-ai/langgraph
- AutoGen multi-agent conversation framework:
  https://microsoft.github.io/autogen/0.2/docs/Use-Cases/agent_chat/
- AutoGen human-in-the-loop:
  https://microsoft.github.io/autogen/0.2/docs/tutorial/human-in-the-loop/
- Microsoft Research AutoGen project:
  https://www.microsoft.com/en-us/research/project/autogen/
- Model Context Protocol specification:
  https://modelcontextprotocol.io/specification/2025-06-18
- MCP tools:
  https://modelcontextprotocol.io/specification/2025-06-18/server/tools
- Backstage system model:
  https://backstage.io/docs/features/software-catalog/system-model/
- Backstage descriptor format:
  https://backstage.io/docs/features/software-catalog/descriptor-format/
- Backstage catalog:
  https://backstage.io/docs/features/software-catalog/
- SQLite JSON functions:
  https://sqlite.org/json1.html
- JSON Lines format:
  https://jsonlines.org/
- pgvector:
  https://github.com/pgvector/pgvector
- Qdrant filtering:
  https://qdrant.tech/documentation/search/filtering/

## Observed Findings

- LangGraph describes itself as a low-level orchestration framework for
  building, managing, and deploying long-running, stateful agents.
- AutoGen frames multi-agent applications as conversations among capable,
  customizable agents that can integrate LLMs, tools, humans, and code.
- AutoGen's human-in-the-loop support can intercept messages before auto-reply
  behavior and provide human feedback or termination behavior.
- MCP is an open protocol for connecting LLM applications with external data
  sources and tools through standardized protocol requirements.
- MCP tools allow servers to expose named operations with schemas for language
  models to invoke external systems.
- Backstage's catalog model uses Components, APIs, and Resources as core
  entities; APIs are first-class boundaries and should be machine-readable.
- Backstage descriptor formats model Systems as collections of resources,
  components, and APIs, providing a reference for Agent Platform project,
  application, and environment catalog shapes.
- SQLite includes JSON functions and table-valued JSON functions that can
  support a local pilot ledger with queryable JSON event payloads.
- JSON Lines is a simple newline-delimited format for one structured JSON value
  per record and works well for logs, shell pipelines, and cooperating
  processes.
- pgvector stores vectors with the rest of Postgres data and supports exact and
  approximate nearest-neighbor search plus normal Postgres operational features.
- Qdrant supports payload and ID filters for vector search, including must,
  should, must-not, nested object filters, and ID filters.

## North Star Implications

- `controller-loop` should remain framework-neutral but can use LangGraph and
  AutoGen as reference evidence for durable stateful agents, multi-agent
  coordination, and human intervention points.
- `session-ledger` should become a separately testable contract if multiple
  skills need to write parent/child sessions, tool calls, PRs, deployments,
  review decisions, and learning-capture events.
- The pilot ledger can start with SQLite plus JSONL for low operational
  overhead, then graduate to Postgres plus pgvector if semantic search becomes
  a product requirement.
- Qdrant remains relevant for Gravity-style evidence retrieval when filtered
  vector search over payload metadata is central to the product.
- `agent-platform-control` should use MCP/API-first contracts with explicit
  operation schemas, authorization, policy verdicts, and traceability IDs.
- Agent Platform's application/catalog model should borrow Backstage-style
  concepts for components, APIs, resources, systems, ownership, and
  machine-readable descriptors without committing to Backstage as a dependency
  before platform-readiness research.

## Limitations

- This note does not choose LangGraph, AutoGen, or a custom workflow engine.
- This note does not inspect local Agent Platform APIs or MCP servers.
- This note does not benchmark SQLite, Postgres, pgvector, or Qdrant for local
  workload volume.
