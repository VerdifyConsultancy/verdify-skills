# North Star Review Plan

Status: `requested`
Requested at: `2026-06-24T17:21:26Z`
Reviewers: Jason, James

## Review Target

Approve, request changes, or reject the Verdify Skills North Star packet:

- `.agent-workflow/northstar/NORTHSTAR_PRODUCT.md`
- `.agent-workflow/northstar/NORTHSTAR_ARCHITECTURE.md`
- `.agent-workflow/northstar/northstar-artifacts.yaml`
- `.agent-workflow/northstar/northstar-plan.yaml`
- `.agent-workflow/northstar/NORTHSTAR_INTERVIEW.md`
- `.agent-workflow/northstar/AGENTIC_LOOP_SKILL_AUDIT.md`
- `.agent-workflow/northstar/SDLC_SKILL_DESIGN.md`

Approval locks the North Star for the next milestone. Requested changes return
the loop to `northstar-planning` / `artifact-loop`.

## Evidence In Scope

The evidence registry contains 40 registered evidence records. The review should
focus first on these records because they drove the current packet:

- `northstar://evidence/NSE-20260624-agentic-loop-sdlc-best-practices`
- `northstar://evidence/NSE-20260624-agentic-loop-audit-closeout`
- `northstar://evidence/NSE-20260623-repo-controller-bootstrap-self-discovery`
- `northstar://evidence/NSE-20260623-agent-platform-live-state-audit`
- `northstar://evidence/NSE-20260623-agent-platform-sunshine-gravity-ip-priorities`
- `northstar://evidence/NSE-20260623-openclaw-hermes-reuse-interface-security-audit`
- `northstar://evidence/NSE-20260623-openclaw-hermes-local-evidence`
- `northstar://evidence/NSE-20260623-end-to-end-agent-based-sdlc`
- `northstar://evidence/NSE-20260623-long-horizon-agent-compounding-learning`
- `northstar://evidence/NSE-20260623-long-horizon-learning-loop-source-verification`

## Review Checks

1. Confirm the product and architecture North Star consistently model 18
   lifecycle skills plus standalone `issue-triage`, for 19 validating skills in
   the package.
2. Confirm `PRQ-030`, `ARQ-029`, and `IFACE-021` correctly define the shared
   bounded agentic-loop contract for lifecycle skills.
3. Confirm `VerdifyConsultancy/verdify-skills#43` is the skills-side backlog
   anchor for auditing and updating applicable skills against that contract.
4. Confirm platform follow-up issues `jvallery/agents#1995` through `#2000`
   cover the Agent Platform counterparts and should remain outside this
   repository's implementation scope.
5. Confirm the North Star still blocks Gravity implementation until
   `platform-readiness` and `gravity-readiness` pass.
6. Confirm open North Star questions are review inputs, not hidden gates, unless
   reviewers explicitly promote one to a blocking decision.
7. Confirm the final-lock gate is still the only approval that lets downstream
   lifecycle skills treat these artifacts as core planning authority.
8. Confirm the next route should be `northstar-planning` / `human-review` until
   approval, changes-requested feedback, or rejection is recorded.

## Readiness Audit

| Check | Result | Evidence |
| --- | --- | --- |
| Paired North Star artifacts exist | pass | `NORTHSTAR_PRODUCT.md`, `NORTHSTAR_ARCHITECTURE.md` |
| Structured signoff artifact exists | pass | `northstar-artifacts.yaml` |
| Evidence registry is current | pass | 40 `northstar://evidence/...` records |
| Skill-count drift is reconciled | pass | North Star now states 18 lifecycle skills plus standalone `issue-triage` |
| Agentic-loop audit exists | pass | `AGENTIC_LOOP_SKILL_AUDIT.md` |
| Skills-side follow-up exists | pass | `VerdifyConsultancy/verdify-skills#43` |
| Platform follow-ups exist | pass | `jvallery/agents#1995` through `#2000` |
| Approval is intentionally not recorded | pass | `review.status: requested`, `approvals: []` |

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
