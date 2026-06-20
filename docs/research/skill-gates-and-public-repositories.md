# Skill Gates And Public Repository Research

Date: 2026-06-20

## Sources Reviewed

- OpenAI Codex Agent Skills: https://developers.openai.com/codex/skills
- Agent Skills open specification: https://agentskills.io/specification
- Agent Skills script guidance: https://agentskills.io/skill-creation/using-scripts
- Agent Skills eval guidance: https://agentskills.io/skill-creation/evaluating-skills
- OpenAI skills catalog: https://github.com/openai/skills
- Anthropic skills examples: https://github.com/anthropics/skills
- Addy Osmani engineering skills: https://github.com/addyosmani/agent-skills
- GitHub `gh skill` preview: https://github.blog/changelog/2026-04-16-manage-agent-skills-with-github-cli/

## Finding

Best-in-class skill repositories do not usually make human gates mechanically binding inside `SKILL.md` alone. The common pattern is layered:

1. `SKILL.md` defines the workflow, required pauses, evidence, and outputs.
2. Bundled scripts handle deterministic, repeatable checks.
3. Host features handle permissions, approval prompts, sandboxing, MCP access, and app metadata.
4. CI or local validators check package shape, references, schemas, and examples.
5. A workflow engine or managing agent turns procedural pauses into durable interrupts when orchestration is needed.

That means a skill can define a gate contract, but a plain agent session cannot guarantee the gate is obeyed. Mechanical control needs a surrounding runtime, hook, policy, CI job, or workflow engine.

## Patterns Worth Matching

OpenAI curated skills:

- concise `SKILL.md` files with strong trigger descriptions;
- optional `agents/openai.yaml` for Codex app metadata and tool dependencies;
- scripts for brittle operations such as CI log inspection or browser automation;
- eval folders for skills with repeatable output quality checks.

Anthropic examples:

- one self-contained folder per skill;
- minimal required frontmatter;
- references and scripts loaded only when needed;
- production document skills use deterministic tools for fragile file operations.

Agent Skills specification:

- `name` and `description` are required;
- skill directory name should match `name`;
- `scripts/`, `references/`, and `assets/` are optional;
- progressive disclosure is the intended scaling pattern;
- validation of skill metadata and structure is expected.

Addy Osmani engineering skills:

- lifecycle skills are split by phase rather than one monolith;
- gates are expressed as checklists and explicit review/approval points;
- a repository validator enforces frontmatter, naming, required sections, and cross-skill references;
- install paths are documented for multiple agent hosts.

GitHub `gh skill` preview:

- skills are treated as portable packages across hosts;
- publication should validate skills;
- version pinning and provenance matter because skills can contain executable instructions and scripts.

## Implication For Verdify

Verdify should be stricter than a prompt pack but should not pretend that a skill alone is a workflow engine.

The repository should provide:

- procedural gate instructions in `SKILL.md`;
- structured gate artifacts under `.verdify/sprints/<id>/gates/`;
- a schema for gate artifacts;
- templates for human-facing gate review;
- repository validation scripts;
- eval cases covering gate routing;
- later orchestration that consumes `verdify.workflow.yaml` and gate artifacts as mechanical interrupts.

## Decision

For v0.1, gates are contract-driven procedural stops with machine-readable artifacts.

For v0.2, scripts should validate sprint state, gate artifacts, lane contracts, evidence manifests, and workflow references.

For v0.3+, a managing agent or durable workflow engine should enforce interrupts, resume events, timeout policy, and allowed resolvers.
