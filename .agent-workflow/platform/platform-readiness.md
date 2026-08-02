# Platform readiness — VerdifyConsultancy/verdify-skills CI/CD convergence

Assessed at `2026-08-02T18:30:10Z` under the `jvallery/agents#3088` estate directive.

## Verdict

`BLOCKED_PLATFORM` / canonical status `blocked`.

The repository is an active npm-delivery project, but its self-managed validation
path is not usable. Exact-head jobs request `validation-standard` and remain
unclaimed with runner ID zero and no steps. The standard repo service account also
cannot create `repo-validate` Workflows in `agent-fleet-ci`, and no `fleet-ci`
status exists.

The repository has no image or GitOps runtime. No Zot digest, Argo CD Application,
runtime user path, or deployment rollback is applicable or should be manufactured.

## Repository-owned follow-up

The central validation helper supports a checks-only `.agent-fleet/ci.yaml`, but
the current dispatched contract explicitly prohibits `.agent-fleet/**`. Issue
`#234` therefore needs a replacement approved transaction after platform readiness;
PR `#235` must not silently absorb that material scope change.

## Platform-owned gates

- Restore a claimable `validation-standard` runner and a read-only runner-profile
  status surface for exact-repo App identities.
- Reconcile the declared `ci-workflows` capability for service account name
  `repo-verdifyconsultancy-verdify-skills-sa` through the fleet registry/GitOps path.
- Provide `gitleaks` in the standard runtime or approve an equivalent contract.
- Correct rendered auth/worktree/RBAC prose and provide an audited parent-issue relay.

The complete timestamped commands, workflow inventory, credential-reference names,
cleanup record, and proposed standard fixes are recorded in repository issue `#234`
and PR `#235`. No Secret value or annotation, production mutation, image build,
registry push, Argo refresh, deployment, merge, or release occurred.
