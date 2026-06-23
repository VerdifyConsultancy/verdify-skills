# Agent Loop And Learning Capture Patterns

Source review date: 2026-06-23

## Source Links

- X post: https://x.com/0xCodez/status/2065089060104720776
- Mirror/extraction: https://readcopilot.ionichina.com/articles/16791
- Anthropic launch announcement: https://www.anthropic.com/news/claude-fable-5-mythos-5
- Anthropic API notes: https://platform.claude.com/docs/en/about-claude/models/introducing-claude-fable-5-and-claude-mythos-5
- Anthropic access suspension statement: https://www.anthropic.com/news/fable-mythos-access
- Anatoli Kopadze X post: https://x.com/AnatoliKopadze/status/2068328135611822149
- Indexed/mirrored Anatoli article: https://mer.vin/2026/06/ai-agent-loops-explained-claude-goal-gpt-self-check-and-mira-telegram-skills/
- Cathryn Lavery X post: https://x.com/cathrynlavery/status/2069193102586474781
- Cathryn Lavery article: https://www.littlemight.com/your-first-ai-loop-should-be-for-yourself/

## Evidence Summary

The X posts could not be fully read directly from X in the browser session, but
search snippets, indexed copies, and associated article pages preserve the core
arguments.

The 0xCodez post argues that frontier agent models are underused when treated
like one-off chat prompts. The useful pattern is a compounding system with
primitives, orchestration, durable memory, and self-improvement. The post
specifically emphasizes state files, skills that improve from validated
lessons, fan-out/synthesis, adversarial verification, loop-until-done workflows,
independent verifier agents, safe worktree parallelism, visual self-checks,
task-complexity-based model routing, and long-running routines.

The Anatoli Kopadze post/article argues that useful agent loops are not better
prompts; they are goals with a verification gate, state, and stop condition.
The canonical cycle is discover, plan, execute, verify, and iterate. The article
also warns that loops are only worth building when the task repeats, bad output
can be automatically rejected, the agent can complete the work end-to-end, and
done is objective. It recommends proving one manual run, then turning it into a
skill, then wrapping the skill in a loop, and only then scheduling it. It also
emphasizes cost per accepted change, iteration caps, token budgets, and
monitoring.

The Cathryn Lavery post/article argues that the first useful AI loop may be a
self-improvement loop for the human and their setup. The article recommends
mining Claude Code, Codex, and terminal sessions as evidence, then asking what
should be created from the work and what reusable improvement would make the
next session shorter, safer, cheaper, more correct, or less annoying. Lessons
should be routed to content ideas, context files, slash commands, skills, hooks,
tools/CLI fixes, config changes, or nothing. The safe automation pattern is to
schedule only the scan/proposal step; changes remain human-approved.

Anthropic's launch and API documentation support the general long-horizon
agentic framing. The docs describe Fable/Mythos as long-context and
long-horizon models, mention persistent file-based memory improving performance,
and describe integration behaviors that matter for robust orchestration:
classifier refusals can be successful HTTP responses, fallback may be needed,
and model availability can change. The later Anthropic suspension statement is
evidence that model availability and policy constraints must be treated as
normal lifecycle states rather than rare exceptional events.

## Planning Interpretation

This evidence supports an explicit learning-capture loop in Verdify North Star
planning:

1. Record the evidence or observed failure/opportunity.
2. Investigate and verify what can be supported by source or runtime evidence.
3. Distill the lesson into a proposed skill, artifact, schema, or review change.
4. Route the proposed change through the appropriate review level.
5. Keep durable state in `.agent-workflow`, not hidden conversation history.

It also supports an explicit loop-readiness test before automating a skill or
controller loop:

1. Is the work recurring enough to justify the loop?
2. Can bad output be rejected by a verifier, test, rubric, runtime check, or
   human review packet?
3. Can the agent complete the loop end-to-end inside its permissions?
4. Is done objective enough to avoid subjective self-certification?
5. Is there a hard stop condition, budget, and handoff summary?

The key North Star implication is that "self-improving skills" should not mean
agents freely rewriting their instructions from intuition. It should mean
evidence-backed, traceable, reviewable improvement proposals that become skill
updates only after validation and the configured approval path.

## Candidate Learning Capture Records

| ID | Learning | Proposed impact |
| --- | --- | --- |
| LRN-001 | State files and durable artifacts are the memory layer; chat history is not sufficient. | Reinforce `.agent-workflow` as the authority for North Star planning, evidence, questions, review state, and handoff. |
| LRN-002 | Independent verifier agents are safer than self-critique. | Require North Star drafts and implementation output to have fresh verifier/critic review before final lock or integration. |
| LRN-003 | Useful agent systems use repeatable loop patterns: fan-out/synthesis, adversarial review, and iterate-until-evidence. | Name these patterns in `northstar-planning` and produce research/review packets from them. |
| LRN-004 | Skills should compound through validated lessons, not unreviewed prompt drift. | Add a learning-capture section to planning output with source, verification, proposed change, risk class, and approval requirement. |
| LRN-005 | Model refusal, fallback, downgrade, and availability loss are normal orchestration states. | Add fallback and model-abstraction requirements to controller/API planning. |
| LRN-006 | Visual or runtime verification is stronger than textual self-report for UI/control-plane features. | Require screenshot/browser/runtime evidence where the North Star includes UI, review inbox, Gravity, or control-plane behavior. |
| LRN-007 | A loop requires a goal, verifier, state, stop condition, budget, and objective done criteria. | Add loop-readiness checks before scheduling or delegating recurring North Star/controller tasks. |
| LRN-008 | Prove one manual run before converting it to a skill, loop, or schedule. | Add a readiness sequence to planning and controller skills: manual proof, skill extraction, loop wrapping, then schedule. |
| LRN-009 | Session mining should stage proposals and preserve human judgment for applying changes. | Add proposal-only learning capture for Codex/Claude/terminal sessions, with routing to context files, commands, skills, hooks, tool/CLI fixes, config, content, or backlog. |
| LRN-010 | Cost per accepted change is a better loop metric than token spend or loop count. | Add cost/acceptance telemetry to future controller and session-ledger planning. |

## Limitations

- The X posts themselves were not fully accessible through the browser session.
- Mirrors, indexed copies, and article pages may include translation,
  summarization, or editorial interpretation.
- Fable/Mythos product details were volatile in June 2026 due access suspension;
  use the architectural pattern, not the specific model name, as the durable
  planning input.
- This evidence should not be treated as final approval for skill changes; it
  supports proposed changes to the planning loop.
