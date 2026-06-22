---
name: project-definition
description: Converts raw project knowledge into an approved discovery, requirements, product, and design-surface definition with traceability. Use for new or poorly understood projects, after major product changes, or when requirements, users, scope, flows, interfaces, or human approval points are missing or contradictory.
compatibility: Requires access to supplied project sources and permission to write .verdify project artifacts. Human input may be required for material ambiguity.
metadata:
  author: Verdify
  version: "1.0.0"
  lifecycle-order: "2"
---

# Project Definition

Build one traceable project definition through four ordered modes. Do not jump from raw notes to architecture.

## Canonical artifacts

- `.verdify/project/project-definition.yaml` — authoritative structured definition
- `.verdify/project/discovery.md` — generated human view
- `.verdify/project/requirements.md` — generated human view
- `.verdify/project/product.md` — generated human view
- `.verdify/project/design-surface.md` — generated human view

The YAML is canonical. Markdown views summarize it and must not introduce new decisions.

## Select a mode

Run the earliest incomplete mode unless the router names one:

1. `discovery`
2. `requirements`
3. `product`
4. `design-surface`

## Discovery mode

1. Inventory every supplied source: repository docs, transcripts, notes, research, prior outputs, screenshots, spreadsheets, issues, and existing specifications.
2. Summarize what each source actually supports.
3. Record known decisions, stated goals, constraints, assumptions, undefined terms, contradictions, and missing evidence.
4. Ask evidence-based questions only after intake. Do not ask generic questions already answered by sources.
5. Record human answers and mark affected decisions.

Read `references/discovery-mode.md` when source material is large or contradictory.

## Requirements mode

1. Convert approved discovery into uniquely identified functional and non-functional requirements.
2. Record constraints, security, performance, integration, deployment, observability, data, and human-in-loop requirements when relevant.
3. Give each requirement measurable acceptance criteria and source/decision links.
4. Keep open questions explicit. Do not disguise assumptions as requirements.

Read `references/requirements-mode.md` for quality rules.

## Product mode

Define primary users, problem statement, jobs, workflows, minimum useful scope, non-goals, success metrics, product risks, and user-visible completion. Resolve conflicts between desired features and stated constraints through a decision gate.

Read `references/product-mode.md` for scope and metric guidance.

## Design-surface mode

Define every intentional interaction surface: UI, CLI, API, event, MCP/tool, agent workflow, configuration, review queue, admin surface, and human approval flow. For each surface, define inputs, outputs, states, errors, permissions, and acceptance behavior.

Read `references/design-surface-mode.md` when the product is API-, agent-, or workflow-first rather than UI-first.

## Traceability

Use stable IDs such as `SRC-001`, `DEC-001`, `FR-001`, `NFR-001`, `AC-001`, `USR-001`, and `FLOW-001`. Every requirement must trace to evidence or an approved decision; every product/design element must trace to requirements. Read `references/traceability.md` before final approval.

## Approval and handoff

Validate against `../../schemas/project-definition.schema.yaml`. A human or delegated policy owner approves material product intent. After all four modes are approved, hand off to `architecture-contracts` with the canonical YAML and views.

## Stop conditions

Open a durable gate instead of proceeding when primary users, problem, scope, public behavior, data handling, security expectations, or success criteria remain materially unresolved.
