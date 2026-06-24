# Question Resolution Workflow Research

Date: 2026-06-24
Method: Brave Search API using the configured local `BRAVE_API_KEY` credential
reference. Raw credential values were not printed or copied.

## Scope

This note supports `northstar-question-resolution`, a workflow for reducing large
sets of open planning questions into clustered evidence-backed decisions,
delegated defaults, and short human escalation packs.

## Brave queries

- `software architecture decision records open questions decision log evidence documentation workflow`
- `docs as code generated documentation status manifest CI best practices`
- `Architecture Decision Record ADR template rationale consequences official`

## Sources Found

| Source | Type | URL | Relevance |
| --- | --- | --- | --- |
| Microsoft Learn, "Maintain an architecture decision record (ADR)" | vendor architecture guidance | https://learn.microsoft.com/en-us/azure/well-architected/architect-role/architecture-decision-record | Supports using durable ADRs with context, decision, consequences, ownership, and regular review for material architecture choices. |
| Martin Fowler, "Architecture Decision Record" | architecture practice reference | https://martinfowler.com/bliki/ArchitectureDecisionRecord.html | Supports lightweight text records for architecturally significant decisions and preserving the rationale behind them. |
| Kong, "What is Docs as Code?" | vendor docs-as-code guidance | https://konghq.com/blog/learning-center/what-is-docs-as-code | Supports version-controlled documentation workflows that use review and automation similarly to code changes. |
| TechTarget, "Docs-as-Code explained" | secondary practice overview | https://www.techtarget.com/searchapparchitecture/tip/Docs-as-Code-explained-Benefits-tools-and-best-practices | Supports docs-as-code as a reviewable, source-controlled workflow, but it is secondary evidence. |

## Findings

1. ADR-style decision records are a good fit for material architecture and
   product choices because they preserve context, selected decision, options,
   consequences, and future review hooks.
2. Large question corpora should not be converted directly into human gates.
   They should be clustered into shared decisions, with evidence and rationale
   attached once per thematic decision.
3. Docs-as-code guidance supports keeping question inventories and resolution
   registers in version control, with CI validation and review before downstream
   implementation consumes them.
4. The safest workflow shape is: inventory questions, cluster by decision,
   research missing evidence, record delegated default answers with confidence,
   escalate protected or low-confidence decisions, then hand off to the planning
   artifact owner.

## Recommended Default

Verdify should treat question resolution as a North Star support workflow rather
than as final approval. The workflow should create a stable inventory and
resolution register, ingest source-backed research through the North Star
evidence registry, and return to `northstar-planning` for artifact updates.

## Limitations

- Brave result ordering is not itself evidence of authority.
- Some returned sources are secondary practice summaries and should be used only
  to frame options or discover primary sources.
- This note validates the workflow pattern, not the answer to every Gravity
  question. Gravity-specific decisions still need batch-by-batch evidence.
