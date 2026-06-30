---
name: sprint-handoff
description: Produces the sprint-boundary handoff packet — an executive status report of the sprint that just closed, a summary of the plan for the next sprint, the agent-to-agent handoff state, and an explicit human-attention list (approvals, credential rotations, decisions, confirm-first deploy/change-gate windows). Use at the boundary between sprint-orchestrator (a sprint closes) and sprint-planning/dispatch (the next sprint is planned but not yet approved), when a human returns and asks "where are we / what's the status", when handing the workstream to another agent or operator, or whenever banked work must be made legible before anyone acts on it.
compatibility: Requires repository read access and GitHub issue/PR access or a current snapshot. The previous sprint's closeout artifacts and the next sprint's plan artifacts should already exist. Writing GitHub updates, closing gates, or dispatching work requires explicit authority from repository policy or the user — this skill reports and hands off; it does not approve, deploy, or close gates on its own.
metadata:
  author: Verdify
  version: "0.1.0"
---

# Sprint Handoff

Make banked work legible at the sprint boundary. A sprint that did the work but never produced a clean status + handoff is *banked-but-unreported* — the next human or agent cannot see what shipped, what is gated, or what is theirs to decide. This skill turns that state into one executive packet.

It sits between [`sprint-orchestrator`](../sprint-orchestrator/SKILL.md) (which closes a sprint) and [`sprint-planning`](../sprint-planning/SKILL.md) (which plans the next one). It is narrower than [`state-of-union`](../state-of-union/SKILL.md): state-of-union reconciles durable intent against delivery reality to produce a *strategy*; sprint-handoff reports *what just happened and what is waiting on whom* in human-executive form. Run state-of-union when direction is unclear; run sprint-handoff when direction is clear and the work needs a clean status + handoff.

## Canonical artifacts

- `.agent-workflow/sprints/<sprint-id>/handoff/sprint-handoff.yaml` — the authoritative handoff record (structured; the source of truth).
- `.agent-workflow/sprints/<sprint-id>/handoff/sprint-handoff.md` — the generated human/executive view. Summarizes the YAML; introduces no new decisions.

The YAML is canonical. The Markdown is a rendering of it for humans (Slack/email/terminal) and must not contain a claim that is not in the YAML.

## The four sections (always all four)

1. **Previous sprint — status of record.** What the closing sprint set out to do and what actually landed: lanes merged, issues closed, board delta (before → after), CI/deploy state, and the quality record (defects caught before merge, fix-forwards). Distinguish **shipped** (code in main, CI green) from **deployed** (the running process executes the new code) from **gated/banked** (done but waiting on a human gate). Every "green/done" claim carries a snapshot timestamp + the literal probe and, for flap-prone state, a re-probe (the durability discipline) — never a bare "✅".
2. **Next sprint — plan summary.** The shape of the planned-but-not-yet-dispatched next sprint: goal, wave/lane topology, coverage proof (every open issue placed), the deploy vs build vs change-gate split, and the top risks. Link the plan artifacts; do not restate every lane contract.
3. **Agent handoff.** What the next agent (or a resumed session) needs to continue without re-deriving context: the baseline SHA, the open PRs and their state, the in-flight branches/worktrees, the gates that are open, the gotchas already learned, and the single "start here" pointer. Written so a cold agent can pick up the workstream.
4. **Human eyes on.** The explicit, ordered list of what only a human can or must do — and nothing else buried with it: plan approval, credential rotations, `[DECISION]` gates, cross-operator confirms, and confirm-first deploy/change-gate windows. Each item names the owner, the artifact, and the consequence of inaction. This is the part a returning human reads first.

## Procedure

1. **Locate the boundary.** Identify the sprint that just closed (its `sprint-id`, closeout/review artifacts) and the next sprint that is planned (its `sprint-plan.yaml`, lane-map, gates, plan-approval). If either is missing, say so explicitly rather than inferring.
2. **Reconcile against ground truth, not narrative.** Read the live board (open/closed issue counts, the actual delta), PR states, CI status, and — where the platform deploys — the live runtime/deploy state. GitHub is authoritative for backlog and delivery; the closeout doc is a claim to be verified, not trusted. Record the literal probes used.
3. **Classify every "done" claim** into shipped / deployed / gated-banked, and flag any bare green claim that has no timestamp or re-probe.
4. **Assemble the four sections** into `sprint-handoff.yaml` (canonical), then render `sprint-handoff.md`.
5. **Pull the human-attention list to the top** of the Markdown view, ordered by urgency and with each item's owner + artifact + consequence. Optionally split product talking points from architecture talking points when the report has an executive/business audience.
6. **Hand off, do not act.** Present the packet. Do not approve the plan, rotate credentials, close gates, dispatch lanes, or deploy — those route through their own gates/owners. Naming them here is the deliverable; doing them is not.

## Guardrails

- **Report and hand off; do not execute.** This skill never approves, deploys, closes a gate, or dispatches. It makes the next action legible to whoever owns it.
- **No bare green.** Every status claim is timestamped and, for control-plane/flap-prone state, re-probed. A claim with no probe is not a claim.
- **Ship the human list clean.** The "human eyes on" section is not a place to also park nice-to-knows — only what genuinely needs a human, each with owner + consequence.
- **Markdown adds no decisions.** The `.md` view only renders the canonical `.yaml`.
- **Shared-clone discipline.** When the workstream is worked by multiple agents/worktrees, report in-flight branches and open PRs accurately; never imply a lane is done when it is merely staged-and-flagged.

## Handoffs

- Previous sprint closed + next planned → run this skill, then route the human-attention list to the named owners.
- Plan approved → `sprint-orchestrator` (dispatch the next sprint).
- Direction unclear / intent vs reality drifting → `state-of-union` (strategy) before re-planning.
