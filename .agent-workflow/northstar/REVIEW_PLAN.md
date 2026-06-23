# North Star Review Plan

Status: `requested`
Requested at: `2026-06-23T04:30:38Z`
Reviewers: Jason, James

## Review Target

Approve or request changes for the Verdify Skills repository North Star:

- `.agent-workflow/northstar/NORTHSTAR_PRODUCT.md`
- `.agent-workflow/northstar/NORTHSTAR_ARCHITECTURE.md`
- `.agent-workflow/northstar/northstar-artifacts.yaml`
- `.agent-workflow/northstar/northstar-plan.yaml`
- `.agent-workflow/northstar/NORTHSTAR_INTERVIEW.md`

Approval locks the North Star for the next milestone. Feedback returns the
loop to `northstar-planning` / `artifact-loop`.

## Evidence In Scope

- `northstar://evidence/NSE-20260623-walk-transcript-agent-platform-gravity-skills`
- `northstar://evidence/NSE-20260623-cicd-sdlc-agent-orchestration-human-governed-delivery`
- `northstar://evidence/NSE-20260623-kubernetes-gitops-cicd-cardinality`
- `northstar://evidence/NSE-20260623-end-to-end-agent-based-sdlc`
- `COMMON_OPERATING_CONTRACT.md`
- `README.md`
- `verdify.workflow.yaml`
- `docs/decisions/ADR-0001-github-control-plane.md`
- `docs/decisions/ADR-0002-cohesive-skills.md`
- `docs/decisions/ADR-0003-worktree-leases.md`
- `docs/decisions/ADR-0004-readiness-loop-skills.md`
- `docs/decisions/ADR-0005-northstar-planning-loop.md`
- `docs/decisions/ADR-0006-northstar-evidence-registry.md`
- `docs/decisions/ADR-0007-product-architecture-northstar-artifacts.md`
- `docs/decisions/ADR-0008-northstar-interview-skill.md`

## Review Checks

1. Confirm the product North Star covers the intended scope of this repository:
   lifecycle skills, CLI, schemas, host discovery, durable artifacts, GitHub
   authority, lane/worktree execution, review, release verification, readiness,
   and CI/CD wave deployment.
2. Confirm the architecture North Star gives each product requirement a
   corresponding architecture requirement, interface, control, or traceability
   entry.
3. Confirm the only North Star planning gate is final approval to lock the
   North Star for the next milestone.
4. Confirm deferred questions are correctly routed:
   - `NSQ-002` branch/session/worktree/wave naming goes to release architecture.
   - `NSQ-003` Gravity/Onyx dependency goes to `gravity-readiness`.
5. Confirm Gravity feature implementation remains blocked until platform and
   Gravity readiness approvals pass.
6. Confirm CI/CD based wave deployment remains a core plan requirement.
7. Confirm repo/application/environment/namespace cardinality is sufficient for
   planning: repository/application is the product boundary; dev, staging,
   production, and preview use environment-scoped namespaces or namespace sets
   with quota, RBAC, NetworkPolicy, secret references, endpoints, deployment
   path, and observability.
8. Confirm the next route should remain `northstar-planning` / `human-review`
   until approval or changes-requested feedback is recorded.
9. Confirm the `NORTHSTAR_INTERVIEW.md` P0 questions are accepted, modified, or
   rejected before final lock approval.

## Agent Readiness Audit

| Check | Result | Evidence |
| --- | --- | --- |
| Paired North Star artifacts exist | pass | `.agent-workflow/northstar/NORTHSTAR_PRODUCT.md`, `.agent-workflow/northstar/NORTHSTAR_ARCHITECTURE.md` |
| Product artifact covers required sections | pass | Purpose, personas, PRD, stories, requirements, milestones, waves, surfaces, review script, questions, traceability |
| Architecture artifact covers required sections | pass | Intent, stories, requirements, high-level design, environments, interfaces, RBAC/secrets, observability, release/rollback, ADRs, questions, traceability |
| Every product requirement has architecture or artifact traceability | pass | `PRQ-001` through `PRQ-015` all appear in architecture links, `northstar-artifacts.yaml`, or the traceability indexes |
| Every architecture requirement links back to product value | pass | `ARQ-001` through `ARQ-014` cite product requirements, stories, waves, or surfaces |
| Evidence registry is referenceable | pass | Four `northstar://evidence/...` records are present in `.agent-workflow/northstar/evidence-registry.yaml` |
| North Star interview packet exists | pass | `.agent-workflow/northstar/NORTHSTAR_INTERVIEW.md` contains prioritized P0/P1/P2 questions, proposed defaults, tradeoffs, affected IDs, evidence, and answer-capture rules |
| Ordinary planning questions are not gates | pass | `NSQ-002` and `NSQ-003` are deferred, nonblocking, and routed to release architecture or `gravity-readiness` |
| Final-lock gate is durable and open | pass | `.agent-workflow/gates/northstar.yaml` has `status: open` and `resume_state: northstar-planning/human-review` |
| Router points to human review | pass | `.agent-workflow/router/route-decision.yaml` reports `OPEN_GATE`, `northstar-planning`, `human-review` |
| Deterministic validation has passed | pass | `bin/verdify artifact validate`, `ruby scripts/validate-repo.rb`, `make test`, and `git diff --check` passed on this review packet |
| Approval is intentionally not recorded | pass | `northstar-artifacts.yaml` keeps `review.status: requested` and `approvals: []` |

Remaining final decision: Jason and James either approve the lock, request
changes, or reject this review packet. Requested changes return the loop to
`artifact-loop`; approval allows downstream skills to treat the paired North
Star artifacts as authority for the next milestone.

## Approval Decision

Allowed decisions:

- `approved`: lock the North Star and route downstream to the next milestone.
- `changes_requested`: preserve feedback and restart `artifact-loop`.
- `rejected`: keep the North Star unapproved and require a new planning pass.

Recommended approval record if approved:

```yaml
review:
  status: approved
  approvals:
    - reviewer: Jason
      decision: approved
      decided_at: "<UTC timestamp>"
      notes: "Approved as the Verdify Skills North Star for the next milestone."
```

Do not mark `northstar-artifacts.yaml` approved until the actual human decision
is provided.
