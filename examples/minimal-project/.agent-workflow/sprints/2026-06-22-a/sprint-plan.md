# Sprint 2026-06-22-a

Deliver issue #123 as one lane and one PR, bind implementation I to closeout-only E and critic-report-only S, obtain a separate admin or maintainer approval on S, then prove the integrated revision through a staging health probe.

- In: issue #123 health endpoint implementation and verification.
- Deferred: issue #124 revision identity standardization.
- Lane: `issue-123-api`, owned by `api-worker`, reviewed by a distinct `example-critic` agent/session, and approved on final head S by a repository admin or maintainer other than the PR author.
- Next QA: validate implementation I, prove the artifact-only I→E→S suffix, and recheck required checks on S.
- Next human review: atomic packet commit P at `.agent-workflow/sprints/2026-06-22-a/review/review-inbox-packet.yaml` on the evidence-only `controller/2026-06-22-a` branch.
- Integration: merge the lane PR individually; never use the controller evidence branch as the integration candidate.
- Review story: operator verifies service health and running revision before sprint acceptance.
