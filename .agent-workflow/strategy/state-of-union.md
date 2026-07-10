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

The approved execution order is:

1. Fix committed state-of-union baseline routing in issue #143.
2. Fix reproducible shipped-file selection in issue #130.
3. Selectively recover timeline-historian, registered evidence, and the final
   ref-disposition ledger in issue #126.
4. Implement exact packed-artifact and resumable publication safety in issue
   #120.
5. Enforce protected dev integration and release-only main promotion in issue
   #121.
6. Promote one genuinely new version and verify main, npm, GitHub release,
   provenance, and final ref cleanup.

After the narrow #143 control-plane fix, the next handoff is
`sprint-planning / issue-readiness` for separate #130 and #126 lanes, with #126
dependent on #130. Agent Platform, Orbit, Gravity, route quality, eval, and
simplification issues remain durable backlog but are outside this
repository-recovery release.
