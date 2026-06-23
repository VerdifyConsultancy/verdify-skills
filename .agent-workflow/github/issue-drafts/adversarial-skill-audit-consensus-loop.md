# Adversarial skill architecture audit and consensus review loop

## What

Add a documented skill-audit and consensus-review workflow for `verdify-skills`.

The workflow should:

- review the skill set against evidence and external research;
- score evidence and record why skill boundaries exist;
- check tag/schema/internal consistency;
- run Codex and Claude adversarial reviews until both return no required changes;
- give lane owners and stakeholder lenses a vote on plan artifacts;
- persist objections, decisions, votes, and final unresolved issues.

## Why

The walk explicitly asked for a defendable North Star evidence vault explaining why the skill architecture exists, which skills should exist, how they flow together, and how loops, KPIs, and alerts tie into execution.

## Acceptance

- A durable review packet format exists for skill architecture audits.
- Evidence references are registered in the North Star evidence registry or a linked collateral registry.
- The workflow distinguishes accepted decisions, proposed changes, conflicts, and rejected suggestions.
- It supports stakeholder lenses: product, manager, finance, infrastructure, SRE, and security.
- It records machine reviewers separately from human/lane owner votes.
- It never marks protected North Star or skill decisions approved without human approval.

## Related

- Evidence: `NSE-20260623-repo-controller-bootstrap-self-discovery`
