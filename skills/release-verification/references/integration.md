# Integration

Use only final critic-report heads S with a matching latest effective `APPROVED`
review from a distinct repository admin/maintainer, live `SUCCESS` for every
configured required check, and a complete packet-only commit P on the controller
evidence branch. Revalidate the implementation/evidence/report chain and
approvals after any new commit or later review-state change. Merge or queue each
lane PR individually against its approved base; never merge the controller
evidence branch. Prefer the merge queue for concurrent lanes so checks run
against the prospective target state.

Integration evidence should include merge order, conflicts and resolutions, system-test results, migration checks, package/image identity, release notes, known issues, and rollback constraints.
