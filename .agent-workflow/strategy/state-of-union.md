# State of union

Iteration 25 product, project, and architecture foundations are approved on
`dev@45150ee76b770c2e97345dfdfa9196b4acebcc3b`. All historical sprint
transactions are terminal, and global routing no longer needs a sprint selector.

The repository is not release-ready. `main`, npm latest, and GitHub latest
release agree on `1.2.1`, while repeated generated `1.2.1` promotions from
`dev` fail the required new-version gate. Package selection is also
host-dependent because ignored files can enter the manifest and archive, and
two recovery refs still contain authoritative unpublished skill and evidence
work. Live `dev` is unprotected; `main` requires checks but no review.

The committed-strategy routing prerequisite in issue #143 is complete at
`dev@ce912de11605879188d32675293fb1a49a25a56d`. The remaining approved
execution order is:

1. Fix reproducible shipped-file selection in issue #130.
2. Selectively recover timeline-historian, registered evidence, and the final
   ref-disposition ledger in issue #126.
3. Implement exact packed-artifact and resumable publication safety in issue
   #120.
4. Enforce protected dev integration and release-only main promotion in issue
   #121.
5. Promote one genuinely new version and verify main, npm, GitHub release,
   provenance, and final ref cleanup.

The next handoff is `sprint-planning / issue-readiness` for separate #130 and
#126 lanes, with #126 dependent on #130. Repo hygiene remains the mandatory
router gate before that handoff. Agent Platform, Orbit, Gravity, route quality,
eval, and simplification issues remain durable backlog but are outside this
repository-recovery release.
