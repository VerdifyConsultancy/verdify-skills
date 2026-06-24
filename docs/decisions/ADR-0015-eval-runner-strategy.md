# ADR-0015: Treat current evaluation packs as behavioral spec examples

- Status: accepted
- Date: 2026-06-24
- Resolves: #25

## Context

Every skill has an `evaluations/<skill>/evals.json` pack, but the repository
does not have an executable evaluation runner. The current validation surface is
`scripts/validate-repo.rb`, whose `validate_evaluations` check verifies structure:
matching `skill_name`, at least two eval entries, unique eval ids, required
fields, and at least three assertions per eval.

The eval pack content is intentionally descriptive today. Across 19 packs and
46 eval entries, every `files` array is empty, and assertions are prose such as
expected worker, critic, or lifecycle behaviors rather than machine-checkable
predicates. CI runs `make test` through `.github/workflows/validate.yml`; that
target includes the structural validator and local tests, but it does not feed
prompts to a model, invoke a judge, or evaluate assertion semantics.

Issue #25 asks whether Verdify should build an executable eval runner with
fixture-backed, machine-checkable assertions, or re-scope the existing
`evaluations/*` packs so contributors do not mistake them for a quality gate.

## Decision

Re-scope the current `evaluations/*` packs as behavioral spec examples. Do not
wire the existing eval packs into CI as an executable quality gate.

Verdify can add an executable eval runner later, but only after a separate
contract defines the runner semantics and the eval-pack format required to make
results meaningful. At minimum, that future contract needs fixture references,
machine-checkable assertion shapes, deterministic failure rules, model or judge
selection rules when LLM judging is involved, cost and credential boundaries,
and clear CI gating policy.

## Rationale

The current packs are useful as examples of expected skill behavior, but they are
not sufficient test inputs. A runner over the current shape would either ignore
the prose assertions, turning the gate into a false signal, or require an LLM
judge in pull-request CI, adding nondeterminism, cost, and credential handling
to the default validation path.

Keeping `make test` deterministic matters for lane workers, critics, and
integrators. The structural validator is a reasonable repository hygiene check:
it can prove that every skill has a minimum spec pack with stable keys and
enough behavioral assertions for review. It cannot prove that a skill performs
those behaviors.

Choosing the spec-example path now also protects downstream work. Evaluation
uplift can improve the examples without pretending that they are executable
coverage, while a later runner lane can introduce schema and CI changes with an
explicit migration plan instead of retrofitting hidden semantics into prose.

## Affected Surfaces

`evaluations/*`: The 19 packs and 46 entries remain behavioral spec examples
until a future ADR or lane defines an executable eval contract. New or updated
entries should keep describing concrete expected behavior, but should not be
presented as model-executed tests or merge-blocking quality evidence.

`scripts/validate-repo.rb`: `validate_evaluations` remains a structural
validator. It should continue to enforce pack presence, required fields, unique
ids, and assertion count. Any future rename, schema addition, fixture
requirement, assertion DSL, or executable runner hook is a separate scoped
change.

CI: `make test` and `.github/workflows/validate.yml` remain deterministic local
validation surfaces. They should not call an LLM judge or fail a pull request
based on the current free-form eval assertions. If Verdify later adopts an
executable runner, CI should distinguish deterministic structural checks from
model-backed evaluation jobs and record the gating policy explicitly.

Documentation and issue traceability: Repository documentation should describe
the current packs as behavioral spec examples, not executable evals, until the
future runner contract exists. Issue #25 is the decision record for this ADR.

## Rejected Options

Build an LLM-judge runner over the current files now. Rejected because the
assertions are free-form prose, fixture inputs are absent, and pull-request CI
would need model credentials, cost controls, retry semantics, and nondeterminism
policy before it could be trusted as a gate.

Build an assertion-DSL runner now. Deferred because it requires an eval-pack
schema change, fixture population, migration guidance for every pack, and CI
policy changes beyond this decision-only lane.

Rename or rewrite `evaluations/*` in this lane. Rejected for this lane because
the approved scope is the ADR only. Follow-up implementation should happen in
separate issues and lanes.

## Consequences

- Contributors should treat eval packs as reviewed behavioral examples, not as
  executed tests.
- The repository avoids a misleading quality gate while preserving useful skill
  behavior examples.
- Future executable evaluation work needs its own issue, lane contract, schema
  design, and CI policy.
- Downstream eval-uplift work may improve pack coverage within the current
  structural format, but it should not claim executable quality evidence.
