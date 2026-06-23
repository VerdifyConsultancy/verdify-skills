# Repo-bootstrap lifecycle skill: self-discovery packet, AGENTS update, and gap PR loop

## What

Define a reusable repo-bootstrap lifecycle skill in `verdify-skills`. The skill should be a facade over the existing lifecycle skills rather than a large new parallel methodology.

The bootstrap run must let a repo controller:

- inventory repository contents, git history, docs, issues, PRs, CI, and existing planning artifacts;
- inventory associated Kubernetes namespaces, pods, logs, metrics, routes, storage, and safe credential references where the platform grants access;
- update or propose updates to `AGENTS.md` so the controller knows its project responsibility and available lifecycle skills;
- produce a standard bootstrap packet covering project purpose, access, gaps, risks, KPIs, and recommended next lifecycle route;
- open a gap backlog or PR using the GitHub control plane.

## Why

The 2026-06-23 walk made bootstrap self-discovery the first fleet-scale action after repo controllers exist. This belongs in `verdify-skills` as the reusable prompt/schema/template contract, while `jvallery/agents` supplies the runtime data and controller pod APIs.

## Acceptance

- A `repo-bootstrap` skill or documented facade exists and explicitly composes `project-router`, `repo-hygiene`, `platform-readiness`, `northstar-planning`, and `controller-loop` where appropriate.
- The output schema includes repo inventory, runtime inventory, credential-reference inventory, AGENTS.md delta, KPI proposal, gap backlog, and route recommendation.
- Secret handling is explicit: report credential location/auth mode/validation status only; never print raw values.
- The packet template is durable and suitable for dispatching across many repo controllers.
- The skill records open questions for namespace naming, domain-agent authority, route/DNS ownership, storage mounts, and runtime-image package recommendations.
- A validation fixture demonstrates bootstrap output without requiring live cluster or secret access.

## Related

- Evidence: `NSE-20260623-repo-controller-bootstrap-self-discovery`
- Runtime counterpart: `jvallery/agents` repo-bootstrap controller issue
