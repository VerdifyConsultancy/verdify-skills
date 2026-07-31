# Sprint plan: Fleet CI/CD E2E

Issue [#234](https://github.com/VerdifyConsultancy/verdify-skills/issues/234)
is the single backlog item for this bounded sprint. The sprint adds the required
Agent Fleet CI/CD guidance, migrates eight directly hosted workflow jobs from the
retired hosted-runner label to `validation-standard`, and proves the local,
broker-authenticated, live ARC, and ten-minute durability loop.

## Lane and ownership

| Lane | Issue | Owner | Reviewer | Branch | Contract |
|---|---:|---|---|---|---|
| `issue-234-fleet-cicd-e2e` | #234 | `root-fleet-cicd-worker` | fresh independent critic, then non-author code owner | `lane/234-fleet-cicd-e2e` | `.agent-workflow/sprints/2026-07-31-fleet-cicd-e2e/lanes/contracts/issue-234-fleet-cicd-e2e.contract.yaml` |

There is one serial lane and no cross-lane overlap. It owns `AGENTS.md`, the six
workflow files with eight runner assignments, `MANIFEST.sha256`, and its closeout.
Package behavior, release version, credentials, container builds, GitOps, and
cluster state are outside scope.

## QA and review

The implementation milestone is a regenerated manifest plus `make test`, runner
inventory, and workflow-only diff at exact head I. The next QA milestone is a
broker-authenticated push and a live pull-request run whose jobs show a nonzero
runner ID and `validation-standard`, followed by the same green-state re-probe
at least ten minutes later.

The closeout-only evidence head E goes to a different critic session. Because
workflow files are protected control-plane paths, final head S also requires a
commit-bound `APPROVED` GitHub review from an allowed repository admin or
maintainer other than the PR author. The review packet path is
`.agent-workflow/sprints/2026-07-31-fleet-cicd-e2e/review/review-inbox-packet.yaml`.

## Approval

Jason Vallery approved this transaction through directive
`fleet-cicd-e2e-2026-07-31` at `2026-07-31T05:36:01Z`, including autonomous
execution, exact acceptance scope, no-workaround constraints, and blocker
recording.
