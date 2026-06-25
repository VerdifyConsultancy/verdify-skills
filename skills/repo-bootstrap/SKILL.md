---
name: repo-bootstrap
description: Runs a repository bootstrap and self-discovery facade over existing Verdify lifecycle skills to produce a safe bootstrap packet, AGENTS.md delta, gap backlog, KPI proposal, and route recommendation. Use when a newly connected or newly assigned repo controller must inventory repository, GitHub, runtime, credential-reference, and planning gaps before normal lifecycle execution.
compatibility: Requires repository read access, Git, Verdify CLI, GitHub CLI or current GitHub snapshots, and only authorized runtime or credential-reference snapshots. Live cluster or secret access is optional and must be separately authorized.
metadata:
  author: Verdify
  version: "1.1.0"
---

# Repo Bootstrap

Bootstrap a repository controller without creating a parallel lifecycle. This
skill composes `project-router`, `repo-hygiene`, `platform-readiness`,
`northstar-planning`, and `controller-loop` as a facade, then emits one
schema-backed packet that can be reviewed, validated, and routed.

## Canonical Artifacts

- `.agent-workflow/bootstrap/repo-bootstrap.yaml` - bootstrap packet
- `.agent-workflow/bootstrap/repo-bootstrap.md` - optional human-readable view
- Proposed `AGENTS.md` delta, gap issues, and one optional pull request through
  the GitHub control plane

Validate the packet against `../../schemas/repo-bootstrap.schema.yaml`. Use
`assets/repo-bootstrap.template.yaml` as the durable packet template and
`assets/repo-bootstrap.fixture.yaml` as the offline validation fixture.

## Procedure

1. Read `../../COMMON_OPERATING_CONTRACT.md`, `../../config/authority-matrix.yaml`,
   repository `AGENTS.md`, and `references/bootstrap-packet.md`.
2. Run or consume `project-router` output first so bootstrap does not hide a
   more urgent gate, unrouted transcript, or stale approved artifact.
3. Use `repo-hygiene` evidence for repository contents, documentation, Git
   state, GitHub state, CI/CD, source-of-truth drift, and repo-agent scope.
4. Use `platform-readiness` evidence for Kubernetes namespaces, pods, routes,
   storage, observability, runtime-image package needs, and credential-reference
   validation status. Record only references, auth modes, owners, scopes,
   validation status, and failure modes. Never record raw tokens, passwords,
   refresh tokens, API keys, client secrets, private keys, or secret payloads.
5. Use `northstar-planning` when bootstrap finds planning intent, product,
   architecture, KPI, milestone, or question gaps that need synthesis before
   downstream definition, architecture, strategy, or implementation.
6. Use `controller-loop` to record the controller/session handoff and durable
   next action when this bootstrap initializes a long-lived repo controller.
7. Write the bootstrap packet, validate it, and open gap issues or a PR only
   for changes already within authority. Link GitHub refs in the packet.
8. Hand off to exactly one next skill and mode. Do not start implementation
   work from the bootstrap session.

## Required Packet Coverage

The packet must include repo inventory, runtime inventory, credential-reference
inventory, `AGENTS.md` delta, KPI proposal, gap backlog, route recommendation,
GitHub output refs, limitations, and named open questions. The open questions
must cover namespace naming, domain-agent authority, route/DNS ownership,
storage mounts, and runtime-image packages.

## Stop Conditions

Stop and open a gate before raw secret exposure, production or protected
runtime writes, broad RBAC grants, namespace or route ownership changes,
storage mount changes, destructive cleanup, or any public lifecycle contract
change not already authorized.

