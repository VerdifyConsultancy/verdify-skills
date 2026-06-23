# Learning Capture Implementation Best Practices

Date: 2026-06-23

Scope: Harden Verdify `learning-capture` as a proposal-only North Star planning
mode that can mine explicit evidence, session summaries, validation failures,
review feedback, and tool friction without silently mutating skills or
scheduling recurring loops prematurely.

Discovery method: Brave Search API using Jason's local Brave Search credential.
Queries targeted official OpenAI, LangGraph/LangChain, NIST, and OWASP sources
for evaluation design, durable agent state, privacy/data minimization, and LLM
prompt-injection or sensitive-information disclosure risks.

## Primary Sources

- OpenAI Evals repository:
  https://github.com/openai/evals
- OpenAI Evals guide:
  https://developers.openai.com/api/docs/guides/evals
- OpenAI Cookbook MCP evaluation example:
  https://developers.openai.com/cookbook/examples/evaluation/use-cases/mcp_eval_notebook
- LangGraph persistence documentation:
  https://docs.langchain.com/oss/python/langgraph/persistence
- LangGraph repository:
  https://github.com/langchain-ai/langgraph
- NIST Privacy Framework:
  https://www.nist.gov/privacy-framework
- NIST SP 800-122, Guide to Protecting the Confidentiality of Personally
  Identifiable Information:
  https://nvlpubs.nist.gov/nistpubs/legacy/sp/nistspecialpublication800-122.pdf
- OWASP LLM01 Prompt Injection:
  https://genai.owasp.org/llmrisk/llm01-prompt-injection/
- OWASP Top 10 for LLM Applications archive:
  https://genai.owasp.org/llm-top-10/

## Findings

- Learning capture should evaluate proposals against a stable verifier rather
  than accepting agent self-report. OpenAI Evals emphasizes explicit task
  definitions, datasets, graders, and comparable runs.
- MCP or tool-using evaluation needs consistent datasets and tool constraints
  before comparing behavior. This maps to Verdify's requirement that proposal
  scans name source scope, verifier, permissions, and objective done criteria.
- Durable learning loops need explicit persisted state. LangGraph distinguishes
  checkpointers for current-thread state from stores for long-term memory,
  which maps to Verdify's packet storage and future registry needs.
- Privacy guidance supports data minimization and retention limits. Learning
  capture should retain references, hashes, paths, distilled findings, and
  verifier results instead of raw session logs unless explicitly approved.
- OWASP LLM guidance treats prompt injection and sensitive-information
  disclosure as core risks. Learning capture must treat session logs, web
  content, issue text, and tool output as untrusted input and must reject
  proposals that contain raw secrets or unverified instructions.
- Recurring learning capture should stay unscheduled until at least one manual
  run proves redaction, deduplication, verifier behavior, state persistence,
  stop condition, budget, and review routing.

## Verdify Contract Implications

- Keep `learning-capture` under `northstar-planning` until redaction,
  retention, verifier, and manual-run evidence are accepted.
- Add an operator reference for learning-capture procedure, source eligibility,
  completeness rules, and stop conditions.
- Add a template and minimal-project example for
  `northstar-learning-proposals.schema.yaml` so proposal packets are repeatable.
- Continue validating proposal packets with
  `schemas/northstar-learning-proposals.schema.yaml`; do not schedule recurring
  session mining from a single manual pass.

## Limitations

- This evidence hardens the learning-capture operating contract. It does not
  authorize reading private session stores, retaining raw logs, applying
  proposed changes, or scheduling a recurring scan.
- Source-specific retention and redaction windows remain a planning question
  (`NSQ-009`) until Jason, James, or the configured security owner approves
  them.
