# North Star Reboot Interview

Status: ready
Generated at: 2026-07-11T17:55:42Z
Routed mode: northstar-interview / review
Target planning iteration: 26
Evidence registry: .agent-workflow/northstar/evidence-registry.yaml
Product pair: .agent-workflow/northstar/NORTHSTAR_PRODUCT.md
Architecture pair: .agent-workflow/northstar/NORTHSTAR_ARCHITECTURE.md
Loop record: .agent-workflow/northstar/northstar-artifacts.yaml

## Review Summary

The owner has explicitly requested reconsideration of the shape, scope,
structure, priorities, sequence, backlog, and refactor strategy of Verdify.
That authorizes a new planning iteration; it does not itself revoke an approved
gate. Iteration 25 remains the current protected authority until an authorized
suspension/revocation or a separately approved iteration-26 lock supersedes it.
Every iteration-25 decision is open to accept, revise, replace, or retire in
planning, while conflicting execution remains unauthorized.

The July 11 state-of-the-art review found a defensible Verdify core but no
proof yet that the entire four-project autonomous platform creates net value.
The strongest current hypothesis is a small portable lifecycle and assurance
profile around replaceable coding agents, GitHub, deterministic verification,
independent exact-head review, deployment verification, and compact durable
receipts. That is a proposed default, not a pre-decision.

This packet is deliberately exhaustive. It is a decision tree, not a demand to
answer every row at once. Answer the root ballot first. Those answers will
retire, rewrite, or default many conditional questions. The remaining modules
then provide complete coverage for the new Product North Star, Architecture
North Star, GitHub backlog, repository refactor, portfolio sequence, and proof
plan.

The inventory contains 360 unique decisions: a 14-decision active root ballot,
304 branch-pruned conditional decisions, all 28 current-skill dispositions, and
all 14 live Skills issue dispositions. A root answer can retire whole
conditional branches; the bank measures coverage, not required ceremony.

No answer in this packet is final-lock approval. Accepted answers must be
preserved as evidence and synthesized through northstar-planning before a
separate explicit lock decision.

## Proposed Priorities

1. Preserve a temporary truth and safety floor: no production mutation, secret
   exposure, destructive migration, release, or protected-design change is
   authorized by this interview alone.
2. Decide product identity, primary user, measurable outcome, and portfolio
   boundary before selecting architecture.
3. Define the smallest owned operational core and explicitly compose, defer, or
   retire everything outside it.
4. Fix known fail-open safety defects before increasing autonomy.
5. Establish executable baselines and prove one single-repository transaction
   through accepted outcome, failure recovery, and durability.
6. Earn expansion in order: runtime-changing lane, narrow cross-project lane,
   four-project slice, then consulting reuse.
7. Rebuild the backlog from accepted outcomes and exit gates; do not preserve
   issues merely because they already exist.

## How To Answer

- Use ID: OPTION, for example RBT-002: A.
- DEFAULT is valid only for choose-one or approve-default rows. It is invalid
  for rank, numeric, matrix, owner, date, or freeform rows.
- Use MODIFY: ... to constrain a choice, DEFER: owner/date/trigger for a P1/P2
  choice, or RESEARCH: question/owner/exit criterion when evidence is
  insufficient.
- For ranks, return IDs or option letters in order.
- You may accept a homogeneous choose/approve range only when every row has the
  same answer type; never use a range for numbers, ranks, matrices, owners, or
  freeform constraints.
- Use N/A only with the exact root ID/option that retires the branch.
- Add a confidence value of high, medium, or low when useful. Low-confidence
  P0 answers become explicit validation hypotheses rather than silent
  requirements.
- If two answers conflict, neither is silently preferred. The planning loop
  must surface the conflict.
- Do not include secret values, private customer/personal content, or
  exploit-ready detail. Cite a protected evidence reference instead.

Recommended order:

1. Answer RBT-001 through RBT-015, excluding reserved RBT-006, only.
2. Let the planning loop validate answers, apply branch rules, consolidate
   aliases, and generate the smaller applicable second-round packet.
3. Answer/delegate product, authority, coupled architecture, proof/sequence,
   and project-specific rows in that generated order.
4. Map accepted sequence to backlog, refactor, and skill/issue dispositions.
5. Review the generated change map, then provide a separate final lock only
   when the rewritten North Star is acceptable.

Each captured answer record must contain ID, answer type, selected
option/value, modifications, rationale, confidence, decision owner, evidence
refs, applicability/root predicate, and reconsideration trigger. An applicable
P0 may not remain deferred at final lock: resolve it, narrow scope so a root
predicate retires it, or keep the North Star unlocked.

## Decision Classes

| Class | Meaning |
| --- | --- |
| must-decide | Required if applicable to establish product identity, authority, safe architecture, or the next milestone. Only the 14 root rows are active P0s in round one; bank P0s are dormant until branch-selected. |
| should-decide | Needed before contracts, platform execution, refactor, or pilot dispatch. |
| can-defer | May remain a named backlog decision with owner and trigger. |
| research-needed | Current evidence cannot support a responsible default; define the research exit criterion. |

## Temporary Non-Waivable Review Safety Floor

These are current authority constraints, not ordinary preference options. They
remain in force while the reboot is designed. Changing one requires its own
authorized protected gate, evidence, compensating controls, scope, expiry, and
rollback; an interview answer cannot waive it.

RBT-006 is intentionally reserved for this safety-floor record and is not an
active interview question. The owner may propose additional temporary
constraints outside the ballot.

- Enforce the currently approved authority matrix and protected gates.
- Never expose raw secrets or treat a credential value as planning evidence.
- Do not let a worker, author, or candidate-supplied validator self-certify the
  same protected result.
- Run policy/review validation from a trusted protected base or exact installed
  package, not solely from candidate code.
- Preserve unmanaged consumer paths during install, upgrade, and uninstall.
- Do not perform unauthorized destructive, production, permission-expanding,
  release, publication, or external-message effects.
- Use least privilege and keep production credentials away from ordinary
  implementation workers.
- Treat model classification as advisory, never the sole security boundary.
- Bind material review/integration evidence to the exact applicable head until
  a separately approved assurance policy replaces that rule.

## Evidence Key

| Key | Evidence |
| --- | --- |
| E01 | July 11 registered report NSE-20260711-agentic-sdlc-state-of-art-kiss, especially sections 5-19 and 22-23. |
| E02 | Approved iteration-25 NORTHSTAR_PRODUCT.md, PRODUCT-001 through PRODUCT-014. |
| E03 | Approved iteration-25 NORTHSTAR_ARCHITECTURE.md, ARCH-001 through ARCH-021. |
| E04 | northstar-artifacts.yaml, northstar-plan.yaml, REVIEW_PLAN.md, and the approved North Star gate. |
| E05 | Prior interview and final-lock evidence NSE-20260709-jason-review-feedback and NSE-20260709-jason-iteration-25-final-lock-approval. |
| E06 | COMMON_OPERATING_CONTRACT.md and config/authority-matrix.yaml. |
| E07 | Live July 11 GitHub inventory: Skills 14, Agent Platform 133, Orbit 62, and Gravity 21 open issues. |
| E08 | v1.3.0 exact-artifact publication evidence and the locally green repository validation suite. |
| E09 | Current local gap evidence: installer host-path loss risk, vacuous critic approval, missing diff-to-contract enforcement, prose-only evals, YAML issue-ID loss, weak handoff semantics, and missing resume-check. |
| E10 | Current platform evidence: disabled dynamic-worktree operation, conflicting Kubernetes readiness, no general crash/recovery or durability proof, and open Agent Platform security P0s. |
| E11 | Current Orbit and Gravity evidence: incomplete connectors/trust separation and incomplete citation hydration/network MCP/readiness. |
| E12 | July 11 owner directive to reboot the entire strategy with nothing off the table. |

## Current Facts, Not Interview Questions

These observations are evidence constraints. They can be challenged with newer
evidence, but they do not need a preference answer.

| Fact | Current proof status | Planning consequence |
| --- | --- | --- |
| Verdify Skills 1.3.0 is published and its exact package transaction was observed. | Local verification plus live publication; not general operational/value proof. | Preserve the working publication substrate while testing rollback, durability, and consumer safety. |
| The repository has broad validators and a green local suite. | Strong level-5 implementation evidence. | Do not equate structure compliance with semantic safety or user value. |
| Installer source/test inspection identified a credible unmanaged-host-path deletion regression. | Locally supported by E01/E09; an exact published-package reproducer and owning issue are still missing. | Reproduce from the packed artifact before filing, then treat preservation as Stage 0. |
| A critic can currently approve with zero criteria/evidence entries. | Demonstrated fail-open defect. | No autonomy expansion until non-vacuous coverage is enforced. |
| Diff-to-contract path enforcement and several semantic/effect checks are absent. | Demonstrated local gap. | Schemas alone cannot be the assurance boundary. |
| Seventy-seven evaluation cases are prose rather than an executed comparative runner. | Demonstrated gap. | Skill benefit and productivity claims remain unproven. |
| Provider dispatch assumes an operation that is currently disabled/unsupported. | Current platform evidence. | Unsupported capability must fail truthfully; dynamic worktree dispatch is not ready. |
| No general live crash/recovery, duplicate-effect, rollback, and later durability transaction is cited. | Operational proof absent. | Level-6 platform reliability is not proven. |
| Orbit's connector, trust-domain, and governed-actuation substrate is incomplete. | Current project evidence. | Orbit cannot yet be a trusted portfolio authority or broad actuator. |
| Gravity has partial live retrieval but incomplete citation hydration/network integration/readiness. | Partial implementation evidence. | Gravity cannot yet serve as generally trusted cross-project evidence. |
| No comparative dataset proves Verdify improves accepted outcomes, human effort, cost, defects, or consulting value. | Value proof absent. | Expansion decisions need an explicit baseline and kill threshold. |

## Iteration-25 Hypotheses Explicitly Reopened

| Prior decision | Reboot questions |
| --- | --- |
| Adopt all July 9 recommendations as defaults. | RBT-001..002, PRD-001..005 |
| Trusted exact-artifact installation/publication. | SEC-015..016, REF-008..012 |
| Proprietary and internal-first. | PRD-013..015, PRD-023, CST-001..004 |
| No backward compatibility. | LCY-025, REF-008..010 |
| Four co-equal pilots and a root planner. | PTF-001..015, ORB-001, GRA-001, SEQ-006..008 |
| Named North Star/release/publication authorities. | RBT-004..005, GOV-007..019 |
| Current Gravity as authority. | GRA-001..006 |
| Gravity HTTP plus consumer MCP. | RUN-005, GRA-002..003 |
| Orbit as personal assistant plus engineering chief of staff. | PTF-006, ORB-001..008 |
| First complete four-project slice, then consulting. | EVL-001..020, SEQ-002..008, CST-001..004 |

## Coverage Map

| Reboot dimension | Question families |
| --- | --- |
| Shape and product identity | RBT, PRD, PTF |
| Scope and non-goals | PRD, PTF, SKL, ORB, GRA, CST |
| User stories and experience | EXP, LCY, GOV, OBS |
| Structural architecture | KRN, RUN, GOV, SEC, INF |
| Platform and infrastructure stories | SEC, INF, OBS, ORB, GRA |
| Priority and proof | EVL, BKL, ISS |
| Refactor and migration | SKL, REF |
| Sequencing, capacity, releases, and stop rules | SEQ |
| Authority, approval, and final lock | RBT, GOV, SEQ |

## Decision Dependency Map

| Stage | Decisions | Unlocks |
| --- | --- | --- |
| 0 | Reboot authority, temporary invariants, time/cost appetite, lock owner | A safe planning boundary |
| 1 | Product category, primary user, job, outcome, business posture | Product requirements and non-goals |
| 2 | Portfolio topology and owned-versus-composed boundary | Project missions and interfaces |
| 3 | User journeys, lifecycle paths, skill disposition | Product surface and operating model |
| 4 | Kernel, controller, worker, governance, security, infrastructure | Architecture contracts and refactor |
| 5 | Proof rubric, metrics, stage exit gates | Prioritized issue backlog and pilot sequence |
| 6 | Migration, release, and lock decisions | Executable sprint and delivery plans |

## Two-Pass Branch Pruning

The exhaustive bank is not administered verbatim. After the 14 root answers,
the planning loop must:

1. validate every root answer against the safety floor and answer shape;
2. record each module as active, delegated-research, deferred, or retired;
3. retain one canonical decision where aliases exist;
4. replace incompatible KISS defaults with defaults appropriate to the chosen
   root shape;
5. assign decision/research owners and evidence deadlines;
6. emit a second-round packet containing only active unresolved rows; and
7. reject any contradictory answer set before North Star synthesis.

| Root predicate | Activate or emphasize | Retire or make N/A | Default consequences |
| --- | --- | --- | --- |
| RBT-002=A profile/kernel | LCY, KRN, GOV, EVL, BKL, REF, SEQ; adapter-level RUN/INF | Hosted/full-platform details unless separately selected | July 11 KISS recommendations remain evidence-backed candidates |
| RBT-002=B integrated platform | All RUN, SEC, INF, OBS and platform blockers | None solely because of product category | Recompute defaults with explicit TCO/owner; do not inherit “compose everything” automatically |
| RBT-002=C consulting OS | PRD, EXP, CST, GOV, EVL; only client-needed runtime/project modules | Unused fleet/product-marketplace details | Client authority, data exit, services economics, and operator UX dominate |
| RBT-002=D library/reference | SKL, install/supply-chain, evaluation, docs, compatibility, backlog/refactor | Controller execution, deploy/runtime, portfolio conductor, and hosted platform branches unless retained as examples | Proof ends at safe useful package behavior, not autonomous outcome claims |
| RBT-004 removes/pauses Orbit | ORB disposition and migration only | ORB-002..008 after disposition | No Orbit assumptions enter Skills or platform contracts |
| RBT-004 removes/pauses Gravity | GRA disposition and migration only | GRA-002..006 after disposition | Choose another narrow dependency or no evidence-service stage |
| RBT-004 selects Skills-only | Skills/product/core questions | Cross-project planner and four-project proof | Backlog and sequence become single-project until reopened |
| RBT-007 advisory/human-every-lane | Review UX, deterministic verification | Autonomous merge/deploy choices | Runtime isolation still protects tools/data; autonomy metrics are not success metrics |
| RBT-009 selects hosted service | Tenancy, SLA, billing/TCO, HA/DR, provider-data, support | None | Hosted operational/security defaults become mandatory questions |
| RBT-009 selects local/customer-controlled only | Portability, install, customer exit | Multi-tenant SaaS/billing/HA questions unless future trigger named | Avoid speculative hosted-control-plane architecture |
| RBT-010 ends before runtime | Package/PR terminal evidence | Deploy/GitOps/rollback stages for current milestone | Do not make runtime-completion claims |
| RBT-010 selects four-project/customer first | All affected platform/project blockers | None | Record explicit risk/cost acceptance; KISS sequence no longer acts as default |

N/A answers must cite the exact root ID/option that retires the row. A later
root change reactivates the affected branch.

### Conditional-Family Manifest

Every bank row inherits its family predicate below unless its own section/row
is narrower. The second-round generator must materialize the exact predicate,
not merely cite this table.

| Family | Root inputs | Active when | Retired/pruned when |
| --- | --- | --- | --- |
| PRD | RBT-002/003/005/008/009/014 | Any Verdify product/method remains | Only if the project itself is ended; retain disposition/exit questions |
| PTF | RBT-004/005/010/013 | More than one project remains or a project needs disposition/migration | Skills-only with all other projects terminally retired after disposition |
| EXP | RBT-002/003/007/008/009 | A user-facing method/product remains | Only rows for surfaces/journeys excluded by root product/market choices |
| LCY | RBT-002/005/007/008/012 | Operational lifecycle/profile/platform remains | Library/method-only except authoring, install, evaluation, and compatibility |
| SKL | RBT-002/005/011/012/014 | Always for current-skill disposition | Never wholesale; individual row may be N/A after verified no consumer |
| KRN | RBT-002/005/007/008/012 | A deterministic kernel/controller remains | Pure content/method choice with no operational policy kernel |
| RUN | RBT-002/005/007/009/010/011 | Coding-agent/session execution remains | Library/method/planning-only product without worker integration |
| GOV | RBT-003/007/008/013 | Always; depth varies by effects and product | Never wholesale; effect-specific rows prune when effect is excluded |
| SEC | RBT-003/005/007/009/013 | Safety floor always; runtime/data rows when corresponding branch exists | Never wholesale; only irrelevant deployment/provider/data rows |
| INF | RBT-002/004/005/007/009/010/011 | Platform, Kubernetes, hosted, or runtime/deploy proof remains | Local library/method/product without platform or deployment |
| PLT | RBT-004/005/007/010/013 | Agent Platform remains or supplies a selected proof | Agent Platform terminally retired and no migration/closure remains |
| OBS | RBT-005/008/009/010/014 | Operational/evidence/value claims remain | Only telemetry implementation rows for a non-operational library |
| ORB | RBT-003/004/007/009/013 | Orbit retained or needs migration/disposition | After terminal retirement/migration; keep disposition evidence |
| GRA | RBT-004/005/008/010/013 | Gravity retained or selected dependency | After terminal retirement/migration; keep disposition evidence |
| CST | RBT-003/008/009/014 | Consulting/services is a selected market/revenue/validation path | Consulting explicitly excluded |
| EVL | RBT-003/008/010/011/014 | Always for claims/value/safety | Never wholesale; select tests appropriate to product terminal boundary |
| SEQ | RBT-008/010/011/014 | Always for the selected scope | Never; a maintenance/stop choice still needs a terminal sequence |
| BKL/ISS | RBT-004/010/011/012/013/014 | Always for in-scope GitHub backlogs | Out-of-scope repositories after explicit disposition only |
| REF | RBT-002/005/011/012/014 | Any retained surface needs change/migration | No-change maintenance choice, except safety fixes and disposition record |

## Canonical Decision Aliases

The first ID in each row owns the decision. The second-round generator must not
emit later IDs as independent choices: render the canonical answer read-only,
then ask only unresolved projection, implementation, or evidence fields. A
derived row cannot override the canonical answer even if its bank priority says
P0; conflict is a validation error.

| Canonical decision | Derived/detail rows |
| --- | --- |
| RBT-008 job, terminal outcome, and primary value rule | PRD-004, PRD-009, LCY-018, GOV-017, OBS-002, EVL-003, EVL-010 |
| RBT-014 horizon, cadence, and stop rule | PRD-025..026, SEQ-013 |
| RBT-011 capacity and opportunity cost | INF-014, SEQ-009..010 |
| RBT-012 compatibility/refactor/backlog posture | BKL-001..003, LCY-025, REF-001, REF-008..009 |
| EXP-001 canonical entry experience | LCY-004 implementation routing |
| GOV-012 review-ready definition | EXP-008 reviewer UX projection |
| GOV-005 lane cardinality | LCY-011 lifecycle detail |
| EVL-014 fault/recovery proof | LCY-020 and INF-026 application details |
| OBS-007 memory authority | RUN-015 and ORB-006 scoped uses |
| OBS-006 evidence authority | KRN-012 and GOV-004 field-level mappings |
| SEC-013 retention/deletion authority | KRN-011 and OBS-003/OBS-010 record mappings |
| RBT-004 portfolio/project roles | PTF-001, PTF-006..007, ORB-001, GRA-001 |

## Coupled Architecture Decisions

These decisions are co-designed; the listed modules must not pretend to form a
safe serial dependency.

| Bundle | Co-decided rows | Required output |
| --- | --- | --- |
| Runtime safety | RUN-002, RUN-007..019; SEC-003..009, SEC-014; INF-002..008 | Worker/controller topology, isolation hardening, identity/credentials, egress/tools, storage, cancellation/recovery, and conformance as one threat-tested design |
| Evidence and health truth | KRN-004, OBS-001..002, OBS-006, OBS-008; INF-020, INF-023 | Canonical identities, capability/health states, receipts, metrics, proof owners, and platform exit evidence before “ready” |
| Sequence and backlog | RBT-010, EVL-014..017, SEQ-002..008; then BKL/ISS/REF/SKL | Accept proof stages first; only then map issues, refactors, and skill dispositions |
| Portfolio trust | RBT-004, SEC-011..013, OBS-006..010, ORB/GRA | Project/data/evidence authority, tenant boundaries, connectors, and cross-project proof |

## Default Provenance And Decision Owners

Unless a row says otherwise, its proposed default is an evidence-backed machine
recommendation (REC), not an approved requirement. Current Facts are FACT,
the temporary safety floor is CONSTRAINT, iteration-25 choices are PRIOR-LOCK,
and any unmeasured number or architecture forecast is HYPOTHESIS. The
second-round generator must attach one of those labels to every active row.

| Families | Default decision/research owner |
| --- | --- |
| RBT and final PRODUCT/ARCH lock | Authorized portfolio/North Star owner |
| PRD, EXP, CST, value metrics | Product owner with actual user/customer evidence |
| PTF and cross-project sequence | Portfolio owner plus each affected project owner |
| LCY, SKL, KRN, REF | Skills maintainer/architecture owner; protected changes remain human-approved |
| RUN, INF, PLT | Agent Platform/runtime owner plus Skills contract owner |
| GOV | Named authority owner for the affected decision class |
| SEC | Security/privacy owner plus affected data/service owner |
| OBS, EVL | Observability/evaluation owner independent of the implementation result |
| ORB and GRA | Their project/data owners; Skills cannot approve on their behalf |
| BKL, ISS | Owning GitHub repository maintainer |

Every generated second-round row must materialize:

| Field | Requirement |
| --- | --- |
| id / canonical_id | Stable bank ID and canonical alias owner |
| applies_if / retired_by | Exact root answer predicate and any narrower branch rule |
| decision_class / priority | Active blocking status after pruning, not dormant bank priority |
| provenance | FACT, CONSTRAINT, REC, HYPOTHESIS, or PRIOR-LOCK |
| owner | Named accountable decision owner or research owner, not only a role family |
| evidence / freshness | Exact evidence refs, observed/inferred status, and refresh date |
| answer_type / required_fields | Enumerated, rank, numeric, matrix, owner, date, or freeform schema |
| research_deadline / exit | Required for HYPOTHESIS/research-needed rows |
| conflicts / consequences | Canonical aliases, incompatible answers, affected IDs, and branches retired |
| reconsideration | Trigger, owner, and review date |

## Reference Strategy Shapes And Tradeoffs

These are composable reference shapes, not mutually exclusive product choices.
The root ballot separately decides the primary shipped unit, portfolio,
commercial/distribution posture, and deployment model. Select a primary shape
only as a consistency check; secondary shapes do not silently import their
architecture.

| Option | Shape | Advantages | Costs and risks |
| --- | --- | --- | --- |
| A. Lifecycle and assurance profile | Portable skills, schemas, small deterministic validator/CLI, adapters to GitHub and existing agents/platforms | Smallest defensible ownership boundary; provider-neutral; fastest proof; easiest adoption | Less end-to-end control; depends on external runtimes; integration quality becomes critical |
| B. Integrated autonomous delivery platform | Skills plus owned controller, durable scheduler, worker runtime, review plane, deployment loop, and portfolio coordination | Unified UX and stronger control over reliability | Large security/operations burden; duplicates mature systems; current proof and readiness are far behind scope |
| C. Internal consulting operating system | Opinionated private workflow, artifacts, agents, and human services optimized for Verdify engagements | Direct internal value; can tolerate bespoke integrations; learning is close to users | Harder to productize; customer portability and public compatibility become secondary |
| D. Product suite with a thin shared kernel | Skills, Agent Platform, Orbit, and Gravity remain distinct products over a minimal shared identity/evidence/authority kernel | Preserves specialized ownership while avoiding one monolith | Cross-project contracts, releases, and governance remain complex; needs disciplined dependency sequencing |
| E. Skills/reference library only | Publish reusable playbooks and templates; rely on users' existing orchestration | Very low runtime risk and cost | Gives up autonomous assurance claims and much of the differentiation |

## Root Ballot

Answer these first. Each row contains the decision, why it matters, proposed
default, explicit choices, affected artifacts, evidence, and answer shape.

| ID | Priority / class | Decision and context | Proposed default | Options / tradeoffs | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| RBT-001 | P0 / must-decide | What authority status and scope does the reboot have? A request to reconsider a lock is not itself a revocation gate. | Iteration 25 remains current protected authority until an authorized suspension/revocation or iteration-26 lock; this review may reconsider all four projects, contracts, backlogs, and strategy without authorizing conflicting execution. | A default; B seek a separate gate to suspend iteration 25; C reopen only named decisions; D seek a separate gate to revoke/archive it; then name in-scope repositories. | All PRODUCT/ARCH/loop/gate IDs | E02-E06, E12 | choose status + scope |
| RBT-002 | P0 / must-decide | What is the primary product unit Verdify will ship or operate? Commercial model and portfolio topology are separate choices. | A portable lifecycle-and-assurance profile plus a small deterministic kernel. | A default; B integrated autonomous delivery platform; C consulting delivery operating system; D reusable skills/reference library; E another primary unit. Secondary contexts may be named but do not replace the primary. | PRODUCT-001, PRODUCT-003, PRODUCT-013; ARCH-001, ARCH-004 | E01-E03 | choose one primary + non-goal |
| RBT-003 | P0 / must-decide | Who is the primary daily user, economic buyer/sponsor, and outcome beneficiary for vNext? These may be different people. | Daily user: repository/consulting delivery operator; sponsor: Verdify during proof then customer project owner; beneficiary: project/outcome owner. | A accept/edit default; B individual developer-led; C platform/SRE-led; D external engineering team-led; E Orbit/personal-user-led. Name excluded segment. | PRODUCT-001-004 | E01-E02 | role triple + excluded segment |
| RBT-004 | P0 / must-decide | What portfolio topology relates Skills, Agent Platform, Orbit, and Gravity? Sequence is decided separately in RBT-010. | Separately owned products joined only by narrow versioned contracts, with each project disposition stated explicitly. | A default; B one integrated product; C four co-equal products/pilots; D Skills-only with ordinary dependencies; E merge/pause/retire named projects. | PRODUCT-014; ARCH-014, ARCH-017, ARCH-019-021 | E01-E03, E07, E10-E11 | choose topology + dispositions |
| RBT-005 | P0 / must-decide | Which capabilities are proprietary Verdify core versus composed dependencies? | Own intent/risk routing, lifecycle legality, leases/idempotency, exact-head assurance, compact receipts, and deploy/outcome evidence adapters; compose workers, SCM, CI, compute, GitOps, telemetry, identity, signing, and retrieval. | A approve/edit build-reuse-stop matrix; B narrower policy-only core; C broader integrated stack; D method/content only. Every built subsystem needs owner and build-versus-buy evidence. | PRODUCT-003, PRODUCT-013; ARCH-004-006, ARCH-013 | E01-E03 | approve/edit capability matrix |
| RBT-007 | P0 / must-decide | What autonomy and human-governance promise applies by environment and risk? | Bounded unattended implementation/mechanical verification inside isolation; protected decisions/effects remain human-authorized; independent commit-bound review is risk-proportional. | A default; B advisory/human approval every lane; C autonomous low-risk merge; D broader named-domain autonomy; E deterministic automation only. List always-human decisions. | PRODUCT-002, PRODUCT-005; ARCH-007, ARCH-009 | E01, E06 | choose posture + protected list |
| RBT-008 | P0 / must-decide | What job, terminal boundary, outcome owner, North Star metric, and proof floor decide whether Verdify is valuable? These are related fields, not one bundled option. | Candidate matrix: ready issue → accepted outcome; project/customer owner accepts; accepted outcomes per human effort and total cost; no critical unauthorized/duplicate effect; operational/value claims follow the proof ladder. | Supply five fields: start/job; terminal boundary; acceptance owner; metric/formula/unit; mandatory proof/safety floor. Candidate jobs include plan, PR, deployed outcome, cited decision, or consulting outcome. | PRODUCT-001, PRODUCT-004, PRODUCT-009; ARCH-009 | E01, E08-E11 | five-field matrix |
| RBT-009 | P0 / must-decide | What market, license/distribution, revenue, hosting, and support posture applies during proof? Keep these axes independent. | Candidate matrix: internal-first market; proprietary distribution; consulting/service leverage before software pricing; local or customer-controlled hosting; internal targets with no external SLA until evidence/capacity exist. | Supply five fields: internal/external market priority; proprietary/permissive/source-available/open-core distribution; internal leverage/services/license/subscription/usage/outcome revenue; local/customer-hosted/Verdify-hosted; best-effort/business-hours/managed SLA. Add a reconsideration event per field. | PRODUCT-001, PRODUCT-006, PRODUCT-008, PRODUCT-013; ARCH-005 | E01-E03, E12 | five-axis matrix |
| RBT-010 | P0 / must-decide | What is the first proof target and broad sequence? | Safety/truth floor, executable evaluation, one non-runtime repo lane, one runtime lane, one narrow dependency, then four-project/customer expansion only if gates pass. | A default; B customer-first; C Platform-first; D four-project-first; E library/value proof only. Name the exact first task class and terminal evidence. | PRODUCT-006-009, PRODUCT-014; ARCH-009, ARCH-021 | E01, E08-E11 | choose/rank + first task |
| RBT-011 | P0 / must-decide | What people, agent slots, spend, maximum concurrent strategic bets, and opportunity costs constrain the plan? | Supply hard caps or ranges before dates, issue selection, or architecture expansion; name which project pauses when proof-critical safety/platform work needs capacity. | A hard caps; B ranges; C research current costs first; D safety maintenance only. | PRODUCT-002, PRODUCT-006-007; backlog/waves | E01, E07, E12 | capacity/budget table |
| RBT-012 | P0 / must-decide | What independent compatibility, refactor, and backlog-reset policies are authorized? | Candidate matrix: breaking internal simplification before named external adoption; incremental contract-backed refactor with rewrite allowed where justified; preserve issue history but revalidate/merge/close/defer every item. | Supply three fields: compatibility window and definition of external adoption; refactor posture (incremental/rewrite/minimal) with migration/rollback; backlog posture (revalidate/archive/recreate/preserve) with deletion/closure authority. | PRODUCT-013; ARCH-006, ARCH-009; issues #76, #116, #211 | E01, E05, E07-E09 | three-axis matrix |
| RBT-013 | P0 / must-decide | Who owns strategy, product, architecture, security/privacy, release/publication, production effects, project backlog, customer outcome, and deadlock resolution? | Role-local accountable owners; Jason currently locks North Star, release/publication remain separate, repo/customer owners retain their authority, and consensus is exceptional. | A approve/edit current matrix; B one global owner; C standing council/quorum; D supply another RACI. Include delegate, veto, expiry, and appeal. | PRODUCT-002; ARCH-010, ARCH-020; authority matrix | E05-E06 | authority matrix |
| RBT-014 | P0 / must-decide | What horizon, review cadence, and go/narrow/stop rule follow from the resource envelope? | No invented calendar default: derive dates and iteration count from RBT-011, baseline uncertainty, safety work, and opportunity cost; do not bypass exit gates for a deadline. | A provide dates/cadence/stop; B fund one stage then reassess; C research envelope first; D maintenance-only pause. | PRODUCT-006-007, PRODUCT-009 | E01, E12 | dates + stop rule |
| RBT-015 | P0 / must-decide | What completes and locks the reboot? | Applicable decisions resolved or scope-pruned, paired North Stars rewritten, authority/project/contract maps reconciled, GitHub backlog/refactor/migration/proof plan produced, adversarial review passed, then a separate explicit authorized lock. | A default; B North Star only; C strategy plus first sprint; D another acceptance set. Answers never imply lock. | All planning artifacts and gate | E04-E06, E12 | approve/edit acceptance |

### Copy-Paste Round-One Answer Sheet

Include rationale/confidence where a choice is tentative. RBT-009, RBT-011,
RBT-013, and RBT-014 require the requested matrix or numbers; DEFAULT alone is
not valid for them.

~~~text
RBT-001:
RBT-002:
RBT-003:
RBT-004:
RBT-005:
RBT-007:
RBT-008:
RBT-009:
RBT-010:
RBT-011:
RBT-012:
RBT-013:
RBT-014:
RBT-015:
~~~

The root response is valid only when these fields are present:

| ID | Required fields |
| --- | --- |
| RBT-001 | authority status; in-scope repositories/projects; explicitly out-of-scope effects; separate-gate request if suspending/revoking |
| RBT-002 | one primary shipped/operated unit; secondary contexts; one-sentence promise; explicit non-goals |
| RBT-003 | daily user; buyer/sponsor; beneficiary/outcome owner; excluded segment; current evidence for each |
| RBT-004 | topology; disposition of each of four projects; ownership boundary; no sequencing answer |
| RBT-005 | capability-by-capability build/compose/defer/retire; operational owner for built items; alternative considered |
| RBT-007 | autonomy by environment/risk; always-human decisions; reviewer/approver roles; prohibited effects |
| RBT-008 | start/job; terminal boundary; acceptance owner; metric/formula/unit; proof and safety floor |
| RBT-009 | market priority; license/distribution; revenue model; hosting; support/SLA; reconsideration trigger per axis |
| RBT-010 | ordered proof stages; exact first task class; terminal evidence; expansion condition |
| RBT-011 | human roles/capacity; agent slots; model/cloud/infra spend; concurrency; maximum strategic bets; project pause choices |
| RBT-012 | compatibility/adoption rule; refactor/migration/rollback posture; backlog reset/closure authority |
| RBT-013 | decision type; accountable approver; delegate; veto; expiry; appeal/deadlock rule |
| RBT-014 | horizon dates; evidence-review cadence; funded attempts/stages; quantitative or qualitative go/narrow/stop rule |
| RBT-015 | required artifacts/change maps/reviews; unresolved-item policy; final lock owner and exact approval form |

## Exhaustive Decision Bank

The 14 root answers are the only active first-round interview. The rows below
are a reference bank. The planning loop must generate a smaller second-round
packet containing only applicable rows, canonical decisions, delegated
research, and explicit N/A reasons. A conditional P0 is blocking only after its
branch becomes applicable.

| ID | Priority / class | Decision and context | Proposed default | Options / tradeoffs | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| PRD-001 | P1 / should-decide | Given RBT-002, RBT-004, and RBT-009, which reference shape is primary and which are only secondary contexts? This checks consistency; it does not recombine the root axes. | If RBT-002 accepts its default: A is primary; consulting or suite may be secondary only if their separate root choices activate them. | Rank A-E as primary/secondary/N-A, or define a custom shape; list architecture that must not be imported from each secondary shape. | PRODUCT-001, PRODUCT-003, PRODUCT-013 | E01-E03 | rank + exclusions |
| PRD-002 | P1 / should-decide | Project the RBT-008 job into one customer-facing promise and explicit exclusions. It cannot select a different job. | Use the accepted RBT-008 start/terminal fields and describe the assurance receipt without adding scope. | No independent option; confirm wording, edit clarity, or flag a root conflict. | PRODUCT-001, PRODUCT-004-005 | E01-E02 | confirm projection/flag conflict |
| PRD-003 | P0 / must-decide | Who is the first primary user whose success controls vNext? | An engineering/project owner using existing GitHub repositories and coding agents who needs trustworthy end-to-end delivery. | A default; B individual developer; C platform/SRE owner; D consultancy operator; E executive/chief of staff; F external customer team. | PRODUCT-002-005 | E01-E02 | choose one |
| PRD-004 | P1 / should-decide | Project the RBT-008 North Star metric into product requirements; do not choose a new primary metric here. | Preserve the accepted formula/unit/safety floor and name product-level leading indicators separately. | No independent option; confirm mapping, add leading indicators, or flag a root conflict. | PRODUCT-001, PRODUCT-009 | E01 | metric projection |
| PRD-005 | P0 / must-decide | What is explicitly not the product? | Not a coding model/agent, general scheduler, source-control system, CI/CD platform, GitOps engine, secret manager, general memory store, or Kubernetes distribution. | A accept list; B remove named exclusions; C add exclusions; D own the full stack. | PRODUCT-003, PRODUCT-013; ARCH-004 | E01-E03 | approve/modify |
| PTF-001 | P1 / should-decide | Project RBT-004 into explicit product ownership, dependencies, shared contracts, and release relationships. It cannot change topology or sequence. | Translate every retained/paused/retired project disposition without importing the prior four-pilot model. | No independent option; confirm mapping or flag a root conflict. | PRODUCT-014; ARCH-020-021 | E01-E03, E07 | portfolio projection |
| PTF-002 | P1 / should-decide | Given RBT-010, name the exact first project/task and why it satisfies that accepted proof stage. | If the staged default is selected, a bounded Skills task is the evidence-backed candidate; otherwise derive from the chosen sequence. | No independent sequence choice; select only an exact target allowed by RBT-004/RBT-010 or flag conflict. | Milestones/waves | E01, E08-E11 | exact target + rationale |
| PTF-003 | P0 / must-decide | Is a root cross-project planner required now? | Defer it until two-project contracts and a narrow cross-project transaction are proven; use linked GitHub issues meanwhile. | A default; B build now; C never build; D use an existing portfolio tool. | PRODUCT-014; ARCH-021; issue #211 | E01, E07 | choose one |
| EXP-001 | P0 / must-decide | What is the canonical entry experience? | GitHub issue or approved planning artifact enters a deterministic router; chat/CLI/UI are thin adapters. | A default; B conversation first; C CLI first; D web control center first; E API first. | PRODUCT-008; ARCH-013 | E01-E03 | choose one |
| EXP-002 | P0 / must-decide | How much lifecycle should a routine bounded issue see? | A proportional fast path with deterministic denied-risk checks; planning and consensus slow paths run only when current state or risk requires them. | A default; B all lifecycle phases always; C worker plus PR only; D owner-selected path. | PRODUCT-004-005; issues #43, #70, #116 | E01, E07 | choose one |
| LCY-001 | P0 / must-decide | Is the operational product all current skills or a smaller mandatory kernel plus optional library? | Mandatory kernel: route, contract, isolate/execute, verify, criticize, integrate, deploy/outcome verify, handoff; all other skills are optional slow-path/domain modules. | A default; B all 28 mandatory; C library only; D define another kernel. | PRODUCT-003-008; ARCH-004 | E01-E03 | choose/edit set |
| KRN-001 | P0 / must-decide | What state is authoritative for execution and recovery? | Compact versioned repository receipts plus GitHub identities and external telemetry links; chat memory and broad duplicated snapshots are caches. | A default; B repository YAML only; C database/event store; D GitHub only; E hybrid with named authority per field. | ARCH-003-006, ARCH-013 | E01, E03-E04 | choose one |
| RUN-001 | P0 / must-decide | Should Verdify build a coding-agent harness or treat agents as replaceable workers? | Replaceable workers through a provider-neutral semantic contract; evaluate ACP as optional transport and retain thin CLI adapters/fallback. | A default; B own harness; C standardize on Codex; D standardize on OpenCode/OpenHands; E no runtime integration. | ARCH-004, ARCH-006; issue #12 | E01, E10 | choose one |
| RUN-002 | P0 / must-decide | What is the default execution isolation boundary? | One disposable container or VM per lane, scoped short-lived credentials, controlled egress, and no production credentials; worktrees alone are local-development isolation. | A default; B worktree only; C shared per-user container; D fixed long-lived repo agents; E environment-specific. | ARCH-005, ARCH-007, ARCH-017-018 | E01, E10 | choose one |
| GOV-001 | P0 / must-decide | What autonomy target should vNext optimize? | Autonomous bounded implementation and mechanical verification inside isolation; human decisions remain for protected changes and independent review remains commit-bound. | A default; B advisory only; C full PR autonomy; D merge autonomy; E deploy autonomy; F domain-specific matrix. | PRODUCT-005; ARCH-007, ARCH-009 | E01, E06 | choose/modify |
| GOV-002 | P0 / must-decide | Is independent criticism a permanent invariant? | Yes for material delivery, using separate context and exact-head criterion coverage; lightweight changes may use deterministic checks plus policy-approved risk routing. | A default; B every change; C only protected changes; D eliminate LLM critic; E human review only. | PRODUCT-005; ARCH-009; issue #73 | E01, E09 | choose one |
| SEC-001 | P0 / must-decide | What threat model is vNext designed to withstand? | Assume prompt injection, malicious repositories/dependencies, compromised workers, credential exfiltration attempts, cross-tenant leakage, supply-chain tampering, duplicate side effects, and reviewer/model error. | A accept; B internal-trusted threat model; C add regulated threats; D define per deployment. | ARCH-007; platform readiness | E01, E06, E09-E11 | approve/modify |
| SEC-002 | P0 / must-decide | Can security rely on model-classified approvals? | No. Models may advise, but isolation, RBAC, scoped credentials, network policy, trusted validation, and human gates form the boundary. | A default; B model classifier is sufficient internally; C user prompts only; D other controls. | ARCH-007 | E01, E10 | choose one |
| INF-001 | P0 / must-decide | Is Agent Platform a product Verdify must build or an replaceable infrastructure provider behind contracts? | Replaceable provider; build only the missing isolation, identity, credential, supervision, and receipt capabilities proven necessary by conformance tests. | A default; B strategic full platform; C use GitHub Actions only; D use a third-party sandbox service; E hybrid. | PRODUCT-013-014; ARCH-017-018, ARCH-021 | E01, E10 | choose one |
| EVL-001 | P1 / should-decide | Expand the RBT-010 first target into an exact end-to-end proof transaction and evidence checklist; do not select a different stage. | Include applicable isolation, deterministic checks, exact review, authorized effects, failure/recovery, terminal outcome, and delayed proof. | No independent stage option; tailor evidence to the accepted target or flag conflict. | PRODUCT-006-009; ARCH-009 | E01, E08-E10 | transaction projection |
| EVL-002 | P0 / must-decide | What baseline must Verdify beat? | Same representative tasks with the same worker/model and repository, comparing normal current workflow versus Verdify on accepted outcomes, human minutes, time, cost, defects, and policy events. | A default; B historical baseline; C no comparison; D competitor benchmark; E consulting margin baseline. | PRODUCT-009; issues #74-75 | E01, E07 | choose one |
| BKL-001 | P1 / should-decide | Project the RBT-012 backlog-reset policy onto every in-scope repository and preserve issue history/reasons. | Produce repository-by-repository mechanics and closure authority consistent with the accepted backlog axis. | No independent reset option; confirm mapping or flag root conflict. | All issue recommendations | E01, E07, E12 | backlog projection |
| REF-001 | P1 / should-decide | Project the RBT-012 refactor axis into code/package/repository constraints and migration/rollback rules. | Derive the implementation posture from the accepted root matrix; do not choose rewrite versus incremental again. | No independent posture option; add constraints or flag root conflict. | All source/artifacts; issue #76 | E01, E09 | refactor projection |
| SEQ-001 | P1 / should-decide | Project RBT-010 into named stages and dependencies; it cannot reorder the accepted strategy. | Translate the accepted broad sequence into stage labels and prerequisites without importing deferred stages as commitments. | No independent sequence option; confirm stage map or flag root conflict. | PRODUCT-006-007; backlog | E01 | sequence projection |

## Branch-Pruned Conditional Modules

Questions below become authoritative inputs only after their dependencies are
answered and branch predicates select them. P1 questions normally precede
contracts or implementation. P2 questions can become named backlog decisions.
Do not administer this bank without first generating the applicable subset.

### Product, Value, Market, And Business Model

Applies after the root ballot (RBT-001..015 excluding reserved RBT-006).
PRD-001..005 are product-shape projections of the root choices, not a second
independent root ballot.

| ID | Priority / class | Decision and context | Proposed default | Options / tradeoffs | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| PRD-006 | P0 / must-decide | Which painful current problem is urgent enough to justify adoption? | Delivery evidence and authority are fragmented, so a PR can exist without trustworthy scope, review, deployment, durability, or outcome proof. | A default; B planning fragmentation; C agent reliability; D platform operations; E consulting coordination; F name another pain with frequency/cost. | PRODUCT-001, PRODUCT-003-005 | E01-E02 | choose plus example |
| PRD-007 | P0 / must-decide | Rank the first three user segments; serving all personas equally prevents a coherent vNext. | 1 repository owner, 2 platform/release owner, 3 consultancy delivery lead. | Rank: developer, maintainer, engineering manager, product owner, platform/SRE, security, consultant, executive, customer reviewer. | PRODUCT-002, PRODUCT-004 | E01-E02 | rank three |
| PRD-008 | P1 / should-decide | Who buys, sponsors, administers, operates, reviews, and benefits, and are these different people? | Internal sponsor and repository owner initially; document distinct operator, reviewer, security, and outcome-owner roles. | A accept role split; B one-person workflow; C enterprise buyer/admin/user split; D consulting sponsor/client split. | PRODUCT-002; ARCH-020 | E02-E03 | role map |
| PRD-009 | P1 / should-decide | Project the RBT-008 terminal boundary across work classes (plan/package/runtime/data/consulting); do not select a new terminal promise. | Apply the root terminal rule and state only legitimate class-specific evidence differences. | No independent option; produce class matrix or flag root conflict. | PRODUCT-001, PRODUCT-004; ARCH-009 | E01-E03 | terminal projection |
| PRD-010 | P1 / should-decide | What do target users do today instead? | GitHub plus a coding agent plus CI plus human coordination, with evidence assembled manually. | A default; B internal platform; C project management suite; D consulting process; E name actual alternatives. | PRODUCT-003, PRODUCT-009 | E01 | rank alternatives |
| PRD-011 | P0 / must-decide | Which differentiation is valuable enough to defend? | Risk-proportional deterministic lifecycle, exact-head independent assurance, distinct deploy/durability/outcome proof, and portable receipts. | A default bundle; B planning quality; C multi-agent orchestration; D personal assistant; E evidence retrieval; F other. | PRODUCT-001, PRODUCT-003, PRODUCT-005 | E01-E03 | choose top two |
| PRD-012 | P1 / should-decide | What user promise must work without Agent Platform, Orbit, or Gravity? | A local/GitHub single-repository assurance lane works independently; integrations enhance it. | A default; B platform required; C suite required; D documentation library only. | PRODUCT-013-014; ARCH-004-006 | E01, E08-E11 | choose one |
| PRD-013 | P0 / must-decide | What distribution posture applies through the first operational proof? | Proprietary/internal-first; publish only if public artifacts create measured leverage. | A default; B open core; C fully open source; D source available; E customer-private packages. | PRODUCT-003, PRODUCT-008; current locked default 3 | E02, E05, E12 | choose plus trigger |
| PRD-014 | P1 / should-decide | What licensing and IP policy applies to skills, schemas, CLI, adapters, research, and generated artifacts? | Keep current ownership for now and decide each distributable layer explicitly before external use. | A one license; B open specs/closed runtime; C open skills/closed platform; D proprietary; E dual license. | PRODUCT-013; release plan | E01-E02 | matrix by layer |
| PRD-015 | P1 / should-decide | What business model should architecture preserve, if any? | Internal productivity and consulting leverage first; do not build SaaS billing/tenancy before a paying demand signal. | A internal cost center; B consulting accelerator; C licensed package; D hosted SaaS; E support/services; F no commercial objective. | PRODUCT-001, PRODUCT-006; ARCH-005 | E01, E12 | rank and trigger |
| PRD-016 | P1 / research-needed | What adoption event demonstrates real pull? | HYPOTHESIS: independent repeat use by the selected target segment is stronger than installation/activity, but the sample and threshold must come from RBT-003/RBT-009 and observed demand. | A repeat use; B paying design partner; C retained active use; D internal mandate only; E custom event. | PRODUCT-006, PRODUCT-009 | E01 | event/sample/threshold |
| PRD-017 | P1 / research-needed | What time-to-first-value is acceptable? | Measure current setup and first-lane baselines with the selected user, then set an evidence-backed target and maximum acceptable variance. | A baseline-relative improvement; B hard user-supplied target; C service-level target after proof; D no promise yet. | PRODUCT-008-009; repo-bootstrap | E01, E08 | baseline + target + owner |
| PRD-018 | P1 / should-decide | What setup may a user reasonably be asked to perform? | Install package, authenticate GitHub/worker, approve generated repo policy, run readiness check; no cluster required for local mode. | A default; B zero-config hosted; C Kubernetes operator setup; D bespoke consulting setup. | PRODUCT-008; ARCH-005, ARCH-017 | E01, E08-E10 | choose/edit steps |
| PRD-019 | P1 / should-decide | Which repositories are supported first? | Git repositories on GitHub with deterministic build/test commands and one accountable maintainer; language-neutral but prove this Ruby/npm repo first. | A default; B JavaScript only; C Kubernetes services; D monorepos; E any repository. | PRODUCT-003-005; ARCH-005 | E01, E08 | choose scope |
| PRD-020 | P2 / can-defer | Does Verdify target only software delivery or any governed knowledge-work lifecycle? | Software delivery first; keep contracts general only where that costs nothing and a domain skill has a real consumer. | A default; B all professional workflows; C consulting only; D software plus named domains. | PRODUCT-001, PRODUCT-013 | E01-E02 | choose/trigger |
| PRD-021 | P0 / must-decide | What product qualities outrank feature breadth? | Truthfulness, safety, recoverability, usability, interoperability, then autonomy and scale. | Rank truth, safety, reliability, simplicity, speed, cost, portability, autonomy, extensibility, scale. | PRODUCT-003, PRODUCT-005; ARCH-001 | E01, E09-E11 | rank top six |
| PRD-022 | P1 / should-decide | What must users never need to understand? | Internal mode names, schema topology, provider session details, and cross-project bookkeeping. | A default; B expose everything to operators; C hide only from non-admins; D CLI is expert-only. | PRODUCT-008; ARCH-013 | E01-E03 | approve/modify |
| PRD-023 | P1 / should-decide | Which claims may be made publicly or internally at each proof level? | Claims name exact scope and proof level; no autonomy, reliability, security, productivity, or ROI claim beyond measured evidence. | A default; B marketing discretion; C third-party audit required; D no public claims. | PRODUCT-009; release records | E01, E08-E11 | approve/modify |
| PRD-024 | P2 / can-defer | What names should users see for the product, kernel, package, workflow, run, lane, and receipt? | Verdify for the lifecycle/assurance profile; descriptive technical names; do not expose 101 modes. | A default; B rename entire product; C suite brand plus products; D defer until proof. | PRODUCT-008; ARCH-013 | E01-E03 | naming map |
| PRD-025 | P1 / should-decide | Project the RBT-014 go/narrow/stop rule into product-hypothesis evidence and fallback language. | Preserve the accepted threshold, funded attempts, variance basis, opportunity cost, and safety floor. | No independent stop choice; define product evidence/communications or flag root conflict. | PRODUCT-006, PRODUCT-009 | E01 | stop-rule projection |
| PRD-026 | P1 / should-decide | Project the RBT-014 horizon into one measurable product outcome consistent with RBT-008/RBT-011. | Translate the accepted dates/capacity/metric without choosing a new horizon or strategic outcome. | No independent horizon choice; define measurable product result or flag root conflict. | PRODUCT-001, PRODUCT-006-009 | E01, E12 | horizon projection |
| PRD-027 | P1 / research-needed | What user research is required before treating owner preferences as product demand? | HYPOTHESIS: observe the root-selected user/buyer segments, capture current workflow/cost/failures, and test the proposed journey; determine sample by segment diversity and evidence saturation, not an invented count. | A segment research; B internal dogfood only; C paid design partner; D no research; E another evidence bar. | PRODUCT-002-004, PRODUCT-009 | E01 | method/sample rule/exit |
| PRD-028 | P1 / should-decide | What scale must vNext support before optimization: users, repositories, concurrent lanes, run duration, and artifact/evidence volume? | Supply the smallest capacity needed by RBT-003/RBT-010/RBT-011 and test only the next declared threshold; no unsupported user-count default. | A individual; B small team; C enterprise; D fleet; E custom numeric envelope. | PRODUCT-003, PRODUCT-006; ARCH-005, ARCH-008 | E01, E10 | numeric envelope + source |
| PRD-029 | P2 / can-defer | Which acquisition/adoption channel is strategic after proof? | Existing consulting/internal relationships and one design partner first; defer marketplace, content-led, partner, or enterprise sales investment until pull is measured. | A default; B open-source community; C agent marketplace; D direct enterprise sales; E channel partners. | PRODUCT-006, PRODUCT-008, PRODUCT-013 | E01 | rank/revisit trigger |
| PRD-030 | P1 / should-decide | What support, maintenance, and SLA promise is affordable? | Internal operating targets during proof; no external uptime/support SLA until operational evidence, owner/on-call capacity, and pricing justify it. | A default; B best effort external; C business-hours support; D managed enterprise SLA; E package-only no support. | PRODUCT-002-003, PRODUCT-013; ARCH-008 | E01, E10 | phase/owner/SLA |
| PRD-031 | P2 / can-defer | Is a third-party/community skill ecosystem strategically important? | No during proof; consider a curated provenance-tested ecosystem only after install safety, behavior evals, permissions, ownership, update, and revocation work. | A default; B curated partners now; C open marketplace; D never third-party. | PRODUCT-008, PRODUCT-013; ARCH-006-007 | E01, E09 | choose/entry gate |

### Portfolio Shape And Project Ownership

Applies if RBT-004 retains more than a Skills-only product or if project
disposition/migration must be decided. Depends on applicable PRD answers.

| ID | Priority / class | Decision and context | Proposed default | Options / tradeoffs | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| PTF-004 | P0 / must-decide | What one-sentence mission belongs to Verdify Skills? | Own portable lifecycle intent, deterministic policy/validation, human-facing skills, and exact assurance receipts. | A default; B content library only; C full controller; D merge into Agent Platform. | PRODUCT-013; ARCH-004, ARCH-013 | E01-E03 | edit sentence |
| PTF-005 | P0 / must-decide | What one-sentence mission belongs to Agent Platform? | Provide replaceable isolated compute, runtime identity, credential/network envelopes, and session/process supervision behind contracts. | A default; B full lifecycle controller; C Kubernetes facade only; D replace with third party. | PRODUCT-013-014; ARCH-017-018 | E01, E03, E10 | edit sentence |
| PTF-006 | P1 / should-decide | Project RBT-004's Orbit disposition into a one-sentence mission, owner, dependencies, and non-authorities. | Use the accepted portfolio role; do not independently promote, narrow, or retire Orbit here. | No independent role option; confirm mission or flag root conflict. | PRODUCT-014; ARCH-019, ARCH-021 | E02-E03, E11 | role projection |
| PTF-007 | P1 / should-decide | Project RBT-004's Gravity disposition into a one-sentence mission, owner, dependencies, and non-authorities. | Use the accepted portfolio role; do not independently promote, replace, or retire Gravity here. | No independent role option; confirm mission or flag root conflict. | PRODUCT-014; ARCH-014 | E02-E03, E11 | role projection |
| PTF-008 | P0 / must-decide | Which projects should merge, split, rename, pause, or end? | Keep four repositories temporarily, pause cross-project expansion, and use proof to decide future topology. | A default; B merge Skills+Platform; C merge Orbit+Gravity; D one monorepo; E list dispositions. | PRODUCT-014; ARCH-020-021 | E01, E07-E11 | disposition map |
| PTF-009 | P0 / must-decide | What is the dependency order among the projects? | Skills can run locally; Agent Platform is an optional execution provider; Gravity and Orbit are downstream consumers; cross-project planning links but does not own. | A default; B circular co-equality; C Platform foundation; D Orbit conductor; E custom DAG. | PRODUCT-014; ARCH-021 | E01, E10-E11 | draw/rank DAG |
| PTF-010 | P1 / should-decide | Which contracts are truly shared? | Repository/run identity, authority decision, capability negotiation, evidence reference, effect receipt, deployment/outcome reference, and typed stop. | A default; B current broad PilotProject schema; C no shared model; D event bus. | ARCH-006, ARCH-021 | E01, E03 | approve/edit set |
| PTF-011 | P1 / should-decide | Where do shared contracts live and who versions them? | Skills owns semantic lifecycle contracts; provider-specific transport contracts stay with providers; consumers pin exact versions and run conformance tests. | A default; B Agent Platform SDK; C separate contracts repo; D duplicate per project. | ARCH-006; authority matrix | E01, E03, E06 | choose/owner |
| PTF-012 | P1 / should-decide | Is there one portfolio backlog authority? Current fleet language and repo-local practice can be read differently. | Each repository's GitHub Issues own implementation; one GitHub portfolio issue/project links outcomes and dependencies without duplicating backlog state. | A default; B jvallery/agents owns all work; C Skills owns suite backlog; D external project tracker. | PRODUCT-014; ARCH-021 | E06-E07 | choose authority |
| PTF-013 | P1 / should-decide | How are cross-project releases versioned and accepted? | Independent releases; an integration manifest pins compatible versions; a wave records correlated evidence but does not force one version. | A default; B synchronized suite release; C continuous unpinned compatibility; D monorepo release. | PRODUCT-007; ARCH-009, ARCH-021 | E01, E03 | choose one |
| PTF-014 | P1 / should-decide | Who resolves a cross-project dependency when local priorities conflict? | Named portfolio outcome owner may rank and request; each repo owner retains authority and records an explicit accept/defer/escalate response. | A default; B root planner overrides; C steering council; D first-ready wins. | PRODUCT-002, PRODUCT-014; ARCH-020-021 | E02-E03, E06 | choose rule |
| PTF-015 | P2 / can-defer | When does consulting become a first-class project or product surface? | After the internal lane demonstrates comparative value and one engagement needs reusable intake, authority, evidence, and outcome contracts. | A default; B immediately; C never; D separate consultancy tooling. | PRODUCT-006-008, PRODUCT-014 | E01, E12 | choose trigger |

### User Journeys And Product Surfaces

Applies to the user/product selected by RBT-002..004 and RBT-008..009. Depends
on the applicable PRD/PTF answers.

| ID | Priority / class | Decision and context | Proposed default | Options / tradeoffs | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| EXP-003 | P0 / must-decide | Which triggers may start a run? | An approved GitHub issue, an approved planning artifact that creates/updates issues, or an authorized operator command; chat can propose but not bypass intake. | A default; B any chat request; C scheduled work; D API events; E selected set. | PRODUCT-004, PRODUCT-008; ARCH-013 | E01-E03, E06 | select triggers |
| EXP-004 | P1 / should-decide | What happens when a user arrives with only a transcript or idea? | Ingest it as evidence, identify affected projects/decisions, propose requirements/issues, and obtain protected approval where needed. | A default; B create issues directly; C begin implementation; D require manual PRD. | PRODUCT-004; transcript-replan | E02, E06 | choose flow |
| EXP-005 | P1 / should-decide | What happens when a bounded ready issue arrives? | Route risk/prerequisites, acquire one lease, execute in isolation, verify, open/update one PR, criticize, integrate, and prove the applicable terminal boundary. | A default; B require sprint plan; C worker-to-PR only; D operator-defined. | PRODUCT-004-005; ARCH-009 | E01-E03 | approve/modify |
| EXP-006 | P1 / should-decide | What happens for a multi-repository outcome? | Decompose into project-owned issues/contracts, order dependencies, prove each independently, and correlate evidence in a wave. | A default; B one shared lane; C one root-agent session; D manual coordination. | PRODUCT-014; ARCH-021 | E01-E03 | choose flow |
| EXP-007 | P1 / should-decide | What status must a returning user see in under a minute? | Outcome, current state, blocker/decision, owner, last verified head/effect, next action, risks, cost/time, and links to authoritative evidence. | A default; B raw session feed; C project dashboard; D PR status only. | PRODUCT-008; ARCH-008, ARCH-013 | E01-E03 | approve fields |
| EXP-008 | P1 / should-decide | Project GOV-012's review-ready fields into the reviewer experience and selected RBT-009 surfaces. | Present every required field and exact decision with minimum burden; do not weaken review readiness. | No independent evidence-field option; choose presentation only or flag canonical conflict. | PRODUCT-008-009; ARCH-009, ARCH-013 | E01, E03, E09 | UX projection |
| EXP-009 | P1 / should-decide | How may a human interrupt, redirect, cancel, or resume work? | Typed commands update durable state; cancellation is idempotent; resume reconstructs from Git/GitHub/receipts, never hidden chat alone. | A default; B chat instruction; C provider-native control; D UI controls only. | PRODUCT-004-005; ARCH-013 | E01, E09-E10 | choose controls |
| EXP-010 | P1 / should-decide | What does failure look like to the user? | One typed terminal or decision-required status with cause, completed effects, untrusted/unknown state, safe next choices, owner, and evidence. | A default; B retry silently; C generic error; D raw logs. | PRODUCT-008; ARCH-008 | E01, E09-E10 | approve fields |
| EXP-011 | P1 / should-decide | What installation surfaces are supported? | Exact npm package plus host links and a repository-local CLI; add OCI/hosted distribution only after demand. | A default; B standalone binary; C container only; D marketplace/plugin install; E hosted. | PRODUCT-008; ARCH-004 | E08-E09 | choose set |
| EXP-012 | P1 / should-decide | How is repository policy configured? | Generated, human-reviewed, versioned repo policy with secure global invariants and validated repo-specific branch/check/environment adapters. | A default; B hardcoded Verdify conventions; C interactive wizard; D remote admin console. | PRODUCT-008; ARCH-006-007 | E03, E06 | choose/fields |
| EXP-013 | P2 / can-defer | Which primary surface should non-expert users use? | GitHub-native first; thin web status/review only if trials show GitHub cannot communicate the decision. | A default; B web control center; C chat; D CLI; E IDE. | PRODUCT-008; ARCH-013 | E01-E03 | rank surfaces |
| EXP-014 | P2 / can-defer | Which operator surface is required? | CLI plus GitHub and inspectable durable files; browser/tmux visibility is diagnostic, not authority. | A default; B web console; C terminal only; D API only. | PRODUCT-008; ARCH-013, ARCH-017 | E01, E10 | choose one |
| EXP-015 | P2 / can-defer | What notifications are valuable and through which channels? | Notify only on decisions, failures, review readiness, deployment regression, and accepted completion; link to authority. | A default; B all progress; C daily digest; D user-configurable; channels GitHub/email/Slack/Orbit. | PRODUCT-008; ARCH-008 | E01-E03 | event/channel matrix |
| EXP-016 | P1 / should-decide | How are learned improvements presented? | Proposal-only change with source, measured failure, blast radius, test, approver, expiry/reconsideration trigger, and rollback. | A default; B auto-update skills/prompts; C manual notes; D no learning loop. | PRODUCT-012; ARCH-015 | E01-E03 | choose flow |
| EXP-017 | P2 / can-defer | Is an executive portfolio digest a core Verdify story? | Optional projection over authoritative project records, likely an Orbit experience; it must not create or approve work. | A default; B core Skills surface; C root-planner output; D remove. | PRODUCT-008, PRODUCT-014; ARCH-019-021 | E02-E03, E11 | choose owner |
| EXP-018 | P1 / should-decide | How does a reviewer inspect a cited claim or receipt? | Follow a stable evidence reference to source metadata and, when authorized, the exact source span/artifact and generation/visibility context. | A default; B summarized prose; C raw telemetry; D Gravity-only. | PRODUCT-004, PRODUCT-008; ARCH-014 | E01, E11 | approve journey |
| EXP-019 | P2 / can-defer | What accessibility, localization, and device constraints apply? | Keyboard-accessible, screen-reader-compatible web/Markdown; English first; no mobile-first build before demand. | A default; B CLI-only; C mobile required; D regulated accessibility target. | PRODUCT-008 | E02 | constraints |
| EXP-020 | P2 / can-defer | What support and diagnostic bundle may users safely share? | Redacted version/config/check/state/correlation metadata plus explicit opt-in logs; never secrets, private prompts, or customer content. | A default; B full trace export; C no telemetry; D managed support access. | PRODUCT-008; ARCH-007-008 | E03, E06 | approve/modify |

### Lifecycle Shape And Skill System

Applies if RBT-002 retains an operational lifecycle/profile/platform. A
library-only choice keeps only authoring, install, evaluation, and
compatibility rows.

| ID | Priority / class | Decision and context | Proposed default | Options / tradeoffs | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| LCY-002 | P0 / must-decide | Is there one canonical SDLC or a catalog of independent workflows? | One small canonical delivery transaction with proportional entry paths; slow-path planning and domain skills compose around it. | A default; B 28 independent skills; C repository-defined workflows; D one full universal lifecycle. | PRODUCT-003-005; ARCH-004; issue #116 | E01-E03, E07 | choose one |
| LCY-003 | P1 / should-decide | Which lifecycle phases should humans see? | Discover/decide, define, contract, deliver, assure, release, verify outcome, learn; internal states remain implementation detail. | A default; B current 25-skill sequence; C plan/build/review only; D custom names. | PRODUCT-004, PRODUCT-008 | E01-E02 | edit phase list |
| LCY-004 | P1 / should-decide | Project EXP-001's selected entry experience into router implementation and emitted reasons/prerequisites. | Preserve the accepted entry surface; make adapters thin and routing deterministic where the root architecture requires it. | No independent entry choice; define implementation mapping or flag conflict. | ARCH-004, ARCH-013 | E01, E03 | entry projection |
| LCY-005 | P0 / must-decide | How many operational delivery paths exist? | Lightweight, standard, protected; lightweight stays disabled until denied-risk classification tests pass and policy is approved. | A default; B one path; C two paths; D unlimited profiles. | PRODUCT-005; ARCH-009; issue #70 | E01, E07 | choose plus criteria |
| LCY-006 | P1 / should-decide | What makes a planning or architecture artifact current enough to skip slow paths? | Exact approved version, no material contradictory evidence, no changed protected requirement/interface, and age/trigger policy satisfied. | A default; B time-based expiry; C owner assertion; D always rerun. | PRODUCT-005; ARCH-003; state-of-union | E01, E04 | approve/edit |
| LCY-007 | P1 / should-decide | When does project definition run? | Only for a new/poorly understood project or material product-direction change; it must not duplicate a locked North Star. | A default; B every project cycle; C eliminate and expand North Star; D repository opt-in. | PRODUCT-003-005; project-definition | E01-E02 | choose one |
| LCY-008 | P1 / should-decide | When do architecture contracts run? | When owned module boundaries or protected interfaces are new/stale, before parallel lanes depend on them. | A default; B every sprint; C eliminate; D only services. | ARCH-001-006; architecture-contracts | E01-E03 | approve/modify |
| LCY-009 | P1 / should-decide | When does state-of-union run? | On changed foundations, stale strategy, sprint/outcome closure, major health drift, or explicit full triage—not as a routine gate for every issue. | A default; B scheduled always; C eliminate; D owner request only. | PRODUCT-006-007; state-of-union | E01, E04 | choose triggers |
| LCY-010 | P1 / should-decide | Must all work be sprint-planned? | No; bounded dependency-ready issues may run through the standard lane, while sprints/waves coordinate multiple lanes and release/outcome evidence. | A default; B sprint required; C no sprints; D per-repo policy. | PRODUCT-006-007; ARCH-009 | E01-E03 | choose one |
| LCY-011 | P1 / should-decide | Project GOV-005's lane cardinality into lifecycle identities, exceptions, and traceability. | Preserve the canonical cardinality/exception policy; define only artifact and transition consequences. | No independent cardinality option; implementation detail or conflict flag. | PRODUCT-004-005; ARCH-009 | E01, E06 | lane projection |
| LCY-012 | P1 / should-decide | What is a wave? | A set of independently integrated lanes sharing deployment, review, rollback, durability, or accepted-outcome coordination—not a shared implementation branch. | A default; B sprint synonym; C release train; D remove term. | PRODUCT-007; ARCH-009, ARCH-021 | E01-E03 | choose/edit |
| LCY-013 | P1 / should-decide | What creates or updates GitHub Issues from planning? | Planning proposes issue-template-complete changes with evidence and dependencies; an authorized human/automation applies them idempotently after the applicable gate. | A default; B direct automatic creation; C humans transcribe; D external backlog sync. | PRODUCT-005; issue-triage | E06-E07 | choose flow |
| LCY-014 | P0 / must-decide | Which actions are deterministic versus agentic? | Routing, validation, identity, leases, transitions, checks, retry limits, effects, gate eligibility, and exact-head binding are deterministic; synthesis, implementation, and semantic criticism are bounded agentic steps. | A default; B controller fully agentic; C workflow entirely deterministic; D repository-specific. | ARCH-003-006, ARCH-013 | E01, E03 | approve/edit |
| LCY-015 | P1 / should-decide | How are prerequisites represented? | Machine-checkable predicates linked to authoritative facts, with typed missing/stale/unsafe reasons; not prose claims. | A default; B checklist Markdown; C agent judgment; D CI checks only. | PRODUCT-005; ARCH-003 | E01, E09 | choose one |
| LCY-016 | P1 / should-decide | What role purity is required? | Worker, critic, integrator, runtime verifier, and protected approver remain distinct authorities; low-risk co-location requires explicit policy but never self-certification. | A default; B worker may merge; C critic may fix; D one agent end to end. | PRODUCT-002, PRODUCT-005; ARCH-020 | E01, E06 | approve/exceptions |
| LCY-017 | P1 / research-needed | What repair budget applies? | Bound every repair class; use the external one-local/one-CI pattern as a test hypothesis, then set limits from local success, cost, and defect data. | A zero; B externally suggested one/one hypothesis; C risk-based measured budget; D human-controlled. | PRODUCT-005; issue #43 | E01, E07 | operation budget + evidence |
| LCY-018 | P1 / should-decide | Project RBT-008's terminal boundary into documentation, package, runtime, data, and consulting work classes. | Preserve the accepted outcome/owner/metric; define only class-specific evidence needed to reach it. | No independent completion option; class projection or root-conflict flag. | PRODUCT-004-005, PRODUCT-009; ARCH-009 | E01, E08 | completion projection |
| LCY-019 | P1 / should-decide | Which terminal and waiting states are required? | Complete, failed, cancelled, blocked, and decision-required plus typed reason and safe next action; derived detail should not multiply top-level states. | A default; B retain all 22 states; C one generic stopped; D event-derived state. | ARCH-003-004 | E01, E03 | choose state set |
| LCY-020 | P1 / should-decide | Apply EVL-014's accepted fault/recovery matrix to lifecycle transitions and external-effect boundaries. | Map each canonical state/effect to the required fault fixture and terminal evidence. | No independent proof option; lifecycle coverage detail or conflict flag. | ARCH-003, ARCH-008-009; issue #43 | E01, E10 | fault-coverage projection |
| LCY-021 | P1 / should-decide | How does learning enter the lifecycle? | Measured failure or outcome evidence produces a proposal; tests and named approval precede policy/skill changes; no active rule mutates itself. | A default; B automatic memory/skill updates; C retrospective only; D remove learning. | PRODUCT-012; ARCH-015 | E01-E03 | choose flow |
| LCY-022 | P2 / can-defer | Should scheduled planning, hygiene, or fleet sweeps exist? | Only after the same operation is safe, useful, idempotent, and observable on demand; schedules emit ordinary issue-backed work. | A default; B daily all skills; C controller cron; D no schedules. | PRODUCT-006; ARCH-017 | E01, E10 | choose/trigger |
| LCY-023 | P1 / should-decide | How should skill dependencies and composition be expressed? | One canonical lifecycle graph with explicit required/optional/conditional edges and machine-validated input/output contracts. | A default; B prose links; C free agent selection; D workflow DSL. | ARCH-004, ARCH-006 | E01, E03 | choose representation |
| LCY-024 | P2 / can-defer | How should users discover the right skill? | Router intent and lifecycle phase first; skill names remain operator/debug detail with concise examples. | A default; B marketplace search; C expose all modes; D chat chooses silently. | PRODUCT-008; ARCH-013 | E01-E03 | choose UX |
| LCY-025 | P1 / should-decide | Apply RBT-012's compatibility/adoption rule to skill and artifact versions. | Define skill/artifact-specific version and migration mechanics without changing the root compatibility policy. | No independent compatibility option; implementation projection or conflict flag. | PRODUCT-013; ARCH-006; locked default 4 | E01-E03, E05 | compatibility projection |

### Existing Skill Disposition Ballot

For each skill choose K keep as a distinct skill, M merge into the named
neighbor, R refactor into kernel/adapter, X retire, or D defer pending measured
use. The default structural answer for every non-safety row is D pending the
Stage-1 behavior evaluation and a real-consumer inventory. The proposed
disposition column is a target hypothesis, not permission to refactor.
Demonstrated safety/correctness work—especially vacuous criticism, unsafe
installation, identity loss, unsupported dispatch, and exact-head
eligibility—may be fixed in place without pre-deciding a later merge. A keep
decision still requires an owned user story, input/output contract, executable
behavior test, maintainer, and reconsideration trigger.

| ID | Skill | Priority | Proposed disposition and rationale | Choices / likely merge target | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| SKL-001 | project-router | P0 | R: keep the entry surface but make routing a small deterministic kernel operation. | K; R kernel; M CLI; X; D | ARCH-004, ARCH-013 | E01-E03 | K/M/R/X/D + note |
| SKL-002 | repo-bootstrap | P1 | M: one repository readiness/bootstrap experience with repo-hygiene and provider readiness adapters. | K; M repo-hygiene; R readiness adapter; X; D | PRODUCT-004; ARCH-017 | E01, E10 | disposition |
| SKL-003 | transcript-replan | P1 | K optional slow-path evidence intake because conversational intent can materially change protected plans. | K; M northstar-planning; D; X | PRODUCT-004; ARCH-015 | E02, E06 | disposition |
| SKL-004 | northstar-research-ingest | P1 | M into a generic evidence-intake command while preserving registry/provenance behavior. | K; M northstar-planning; R CLI; X; D | PRODUCT-012; ARCH-014-015 | E01-E03 | disposition |
| SKL-005 | northstar-planning | P0 | K as protected slow path, narrowed to evidence synthesis, paired artifacts, review feedback, and lock handoff. | K; R; M project-definition; X; D | PRODUCT-001-014; ARCH-001-021 | E02-E05 | disposition |
| SKL-006 | northstar-interview | P1 | M as a planning question-pack mode unless repeated independent use proves a separate skill improves outcomes. | K; M northstar-planning; D; X | PRODUCT-010; ARCH-011 | E01-E05 | disposition |
| SKL-007 | northstar-question-resolution | P1 | M into planning/research intake with a scalable question-ledger mode. | K; M northstar-planning; D; X | PRODUCT-010; ARCH-011 | E01-E05 | disposition |
| SKL-008 | project-definition | P1 | M or K only for genuinely undefined projects; remove duplication with the approved North Star. | K; M northstar-planning; R conditional module; X; D | PRODUCT-003-005 | E01-E02 | disposition |
| SKL-009 | architecture-contracts | P1 | K as conditional contract compiler after architecture intent is approved; require black-box executable checks. | K; M northstar-planning; R kernel compiler; X; D | ARCH-001-006 | E01-E03 | disposition |
| SKL-010 | state-of-union | P1 | K as evidence-backed strategy reconciliation at explicit drift/closure triggers, not routine delivery. | K; M router/planning; D; X | PRODUCT-006-007; ARCH-011 | E01, E04 | disposition |
| SKL-011 | repo-hygiene | P1 | M with repo-bootstrap into one readiness/gap facade; retain deterministic validators. | K; M repo-bootstrap; R validator; X; D | PRODUCT-004; ARCH-005 | E01, E08-E10 | disposition |
| SKL-012 | sprint-planning | P1 | K but simplify to issue selection, lane contracts, dependencies, review/release evidence, and approval. | K; M state-of-union; R; X; D | PRODUCT-006-007; ARCH-009 | E01-E03 | disposition |
| SKL-013 | sprint-replan | P1 | M into sprint-planning as review-feedback/replan mode; avoid parallel handoff formats. | K; M sprint-planning; D; X | PRODUCT-006-007 | E01-E03 | disposition |
| SKL-014 | sprint-orchestrator | P0 | R into the deterministic controller facade over provider adapters; do not embed unsupported transport assumptions. | K; R kernel; M controller-loop; X; D | ARCH-003-006, ARCH-013 | E01, E10 | disposition |
| SKL-015 | controller-loop | P0 | R to the minimal transition/reconciliation kernel and compact run receipt; defer broad portfolio/session duplication. | K; R kernel; M sprint-orchestrator; X; D | ARCH-003-004, ARCH-021 | E01, E10 | disposition |
| SKL-016 | subagent-worktree | P1 | R as one local worker provider adapter with lease/conformance behavior, not a lifecycle stage. | K; R adapter; M lane-delivery; X; D | ARCH-006, ARCH-013 | E01, E10 | disposition |
| SKL-017 | platform-readiness | P1 | M common readiness predicates into bootstrap, retaining a platform-specific adapter/report only while Agent Platform is a supported provider. | K; M repo-bootstrap; R adapter; X; D | ARCH-017-018 | E01, E10 | disposition |
| SKL-018 | gravity-readiness | P2 | R as a Gravity-owned readiness profile rather than mandatory Skills lifecycle. | K; R domain adapter; move repo; X; D | ARCH-014 | E01, E11 | disposition |
| SKL-019 | lane-delivery | P0 | K as the bounded worker-facing implementation contract; prohibit it from self-review, merge, or deploy authority. | K; R worker contract; M orchestrator; X; D | PRODUCT-004-005; ARCH-006 | E01, E06 | disposition |
| SKL-020 | independent-critic | P0 | K and fix criterion coverage/exact-head fail-closed semantics; allow risk policy to decide when it runs. | K; R assurance module; M review; X; D | PRODUCT-005; ARCH-009; issue #73 | E01, E09 | disposition |
| SKL-021 | controller-merge | P0 | R into a deterministic integration eligibility/reconciliation operation with separate authorized GitHub effect. | K; R kernel; M release-verification; X; D | ARCH-009, ARCH-013 | E01, E06 | disposition |
| SKL-022 | release-verification | P0 | K or split adapters; preserve distinct publish/deploy/health/durability/outcome receipts without owning CI/GitOps. | K; R adapters; M controller; X; D | PRODUCT-009; ARCH-009 | E01, E08 | disposition |
| SKL-023 | sprint-handoff | P1 | M terminal/continuation receipt into controller and sprint-planning; fix weak terminal semantics before reuse. | K; M controller-loop; R receipt; X; D | PRODUCT-007-008; ARCH-003 | E01, E09 | disposition |
| SKL-024 | adversarial-audit | P1 | K as optional protected-plan review with explicit human authority; do not make it routine for bounded lanes. | K; M planning/critic; D; X | PRODUCT-009-010; ARCH-011 | E01-E03 | disposition |
| SKL-025 | consensus-audit-workflow | P2 | D or M into protected planning; require measured marginal value before multi-party consensus becomes a default. | K; M adversarial-audit; D; X | PRODUCT-009-010 | E01 | disposition |
| SKL-026 | issue-triage | P1 | K standalone for evidence-backed backlog hygiene and duplicate-safe issue creation. | K; M router/bootstrap; R GitHub adapter; X; D | PRODUCT-005-007 | E06-E07 | disposition |
| SKL-027 | crm-email | P2 | Keep outside the core only with a real authorized CRM user story, connector contract, effect gate, and owner; otherwise move/retire. | K domain; move plugin/repo; D; X | PRODUCT-013; ARCH-006-007 | E01 | disposition |
| SKL-028 | timeline-historian | P2 | Keep outside the core as a proven domain skill or move to a domain package; do not affect lifecycle complexity metrics. | K domain; move plugin/repo; D; X | PRODUCT-013; ARCH-014 | E01, E07 | disposition |

### Deterministic Kernel, State, Artifacts, And Schemas

Applies if RBT-002 retains a deterministic operational kernel/controller.

| ID | Priority / class | Decision and context | Proposed default | Options / tradeoffs | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| KRN-002 | P0 / must-decide | What exact operations belong in the deterministic kernel? | Route, validate, classify risk, lease, compare-and-swap transition, bind exact heads, enforce idempotency/effects, evaluate gates, and emit terminal receipt. | A default; B validator only; C add scheduler/provider supervision; D full workflow engine. | ARCH-003-006, ARCH-013 | E01, E03 | approve/edit list |
| KRN-003 | P1 / research-needed | What is the smallest canonical operational state model? | Derive states from executable legal transitions, recovery/effect boundaries, and user-visible stops; richer labels should be views. No target count is assumed. | A derive/minimize; B retain 22 pending evidence; C event-derived only; D per-path machines. | ARCH-003-004 | E01, E03 | state/transition table |
| KRN-004 | P0 / must-decide | What belongs in one canonical run projection? | Run/idempotency ID, repo/issue/lane/PR identities, heads, adapters/sessions, state/version, checks, risk/gate, effects, deploy/outcome refs, retry/stop, evidence links. | A default; B current many-artifact composition; C event history; D GitHub fields only. | ARCH-003-006, ARCH-021 | E01, E03-E04 | approve fields |
| KRN-005 | P0 / must-decide | What admission test must a new durable artifact pass? | It crosses an actor/restart/authority/security/release boundary, has a deterministic consumer, cannot live in a native authority, and has owner/version/retention plus observed need. | A default; B schema anticipated needs; C freeze all new artifacts; D owner judgment. | PRODUCT-005; ARCH-003-006 | E01, E09 | approve/modify |
| KRN-006 | P0 / must-decide | When does an artifact deserve its own schema? | Only when machine-consumed across a trust/restart boundary; human packets remain Markdown and links. | A default; B schema every durable artifact; C one generic envelope; D database model. | ARCH-004, ARCH-006 | E01, E03 | choose rule |
| KRN-007 | P0 / must-decide | What universal idempotency and effect identity prevents duplicate side effects? | Repository + issue + lane + operation + exact input/head identity, with provider effect ID linked after check-before-act. | A default; B caller UUID; C provider ID; D run ID only. | ARCH-003, ARCH-006, ARCH-021 | E01, E10 | approve fields |
| KRN-008 | P1 / should-decide | How do concurrent controllers resolve transitions? | Refresh authoritative facts and use optimistic compare-and-swap on expected state/version; stale writers fail and reconcile. | A default; B filesystem/Git lock; C database lock; D single controller. | ARCH-003, ARCH-017 | E01, E10 | choose primitive |
| KRN-009 | P0 / must-decide | What stop/failure taxonomy is canonical? | Blocked, decision-required, failed, cancelled, and rolled-back-incomplete with typed reason, completed/unknown effects, owner, expiry, and next action. | A default; B five separate state artifacts; C one generic error; D preserve all current structures. | ARCH-003-004 | E01, E09 | approve vocabulary |
| KRN-010 | P1 / should-decide | Do we need a current projection, append-only ledger, or replayable event history? | Compact projection plus immutable external receipts; adopt an event log only after replay/reconciliation failures prove need. | A default; B projection+ledger; C full event sourcing; D workflow engine history. | ARCH-003, ARCH-008 | E01, E10 | choose plus trigger |
| KRN-011 | P1 / should-decide | Apply SEC-013's retention/deletion policy to kernel state, leases, workspaces, receipts, and diagnostics. | Define record-class implementation without changing the canonical data policy. | No independent retention option; record mapping or conflict flag. | ARCH-007-008, ARCH-015 | E01, E03 | retention projection |
| KRN-012 | P1 / should-decide | Apply OBS-006's evidence-authority decision to GitHub, repository artifacts, provider state, telemetry, and refresh order. | Define field-level source and contradiction handling without selecting a new authority. | No independent authority option; field mapping or conflict flag. | ARCH-003, ARCH-006, ARCH-008 | E01, E06 | authority projection |
| KRN-013 | P1 / should-decide | How are schema and semantic versions negotiated? | Exact supported version ranges plus capability flags; omitted capability fails closed; migrations are explicit and atomic. | A default; B latest wins; C backward-compatible forever; D repository pins everything manually. | ARCH-006; issue #12 | E01, E07 | choose policy |
| KRN-014 | P1 / should-decide | What language/package boundary should implement the kernel? | Preserve dependency-light Ruby CLI while evidence supports it; expose stable JSON/YAML contracts and consider a standalone binary only for distribution/runtime needs. | A default; B TypeScript; C Go/Rust binary; D service API; E generated multi-language SDK. | ARCH-004, ARCH-006 | E01, E08 | choose/trigger |
| KRN-015 | P1 / should-decide | How is trusted validation kept independent of candidate changes? | Run protected-base or atomically installed validator/policy against candidate inputs; bind validator and policy version in evidence. | A default; B candidate branch validator; C CI version only; D signed remote service. | ARCH-007, ARCH-009 | E06, E08-E09 | approve/modify |
| KRN-016 | P1 / should-decide | How should issue IDs, refs, empty fields, unknown keys, and semantic invariants fail? | Lossless round-trip for identities; explicit nullable semantics; reject unknown/ambiguous protected fields; semantic effect tests supplement schemas. | A default; B permissive parsing; C warnings; D per-schema choice. | ARCH-003-006; issue #74 | E09 | approve policy |
| KRN-017 | P0 / must-decide | What exact diff-to-contract algorithm prevents a lane from changing unauthorized scope? | Trusted-base comparison against the declared merge base and allowed/prohibited ownership rules, covering add/modify/delete/rename/copy, generated files, symlinks, submodules, case normalization, path traversal, shared files, and base drift; ambiguity fails closed. | A default; B changed paths only; C critic judgment; D repository hook. Define exception authority and fixtures. | ARCH-006-007, ARCH-009 | E01, E09 | algorithm + edge-case matrix |

### Controller, Worker, Protocol, Context, And Durability

Applies if worker/runtime integration remains in scope. RUN-002, RUN-007..019,
SEC-003..009/014, and INF-002..008 are one Runtime Safety co-decision, not a
serial dependency.

| ID | Priority / class | Decision and context | Proposed default | Options / tradeoffs | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| RUN-003 | P0 / must-decide | What is the semantic worker-session contract? | Capability/auth negotiation, create/resume/cancel/close, workspace roots, bounded tool envelope, progress, exact Git refs, result, effects, and typed failure; provider state is never authority. | A default; B provider-specific prompt/terminal only; C ACP contract directly; D no session integration. | ARCH-006, ARCH-013 | E01, E10; issue #12 | approve fields |
| RUN-004 | P0 / research-needed | Should ACP be required, optional, deferred, or rejected? | Run a two-worker conformance/security/maintenance/fallback spike; adopt as optional transport only if it reduces adapters without weakening controls. | A default spike; B require ACP now; C defer; D reject/custom. | ARCH-006, ARCH-013 | E01 | choose plus workers |
| RUN-005 | P0 / must-decide | What may MCP represent? | Tool/resource boundary only; server-side identity, authorization, idempotency, policy, and effect receipts remain explicit. | A default; B task/control protocol; C universal bus; D no MCP. | ARCH-006, ARCH-014 | E01, E11 | choose allowed roles |
| RUN-006 | P2 / can-defer | Is A2A needed? | No hot-path use; consider vocabulary/adapter only for a demonstrated long-lived cross-service agent task with deduplication and authority. | A default; B vocabulary only; C cross-project now; D platform-wide. | ARCH-021 | E01 | choose/use case |
| RUN-007 | P0 / must-decide | Which worker topologies must work first? | Local leased worktree and one fixed worker first; disposable isolated Job second; dynamic worktree only after the platform truthfully supports it. | A default; B Kubernetes Job first; C dynamic worktree; D hosted agent; E rank matrix. | ARCH-005, ARCH-013, ARCH-017 | E01, E10 | rank mandatory/fallback |
| RUN-008 | P1 / should-decide | How is worker/model/provider selection made? | Capability, security envelope, cost, reliability, task fit, and measured outcomes; never provider identity as architecture. | A default; B fixed provider; C operator choice; D policy router; E competitive parallel runs. | ARCH-006, ARCH-013 | E01 | rank factors |
| RUN-009 | P1 / should-decide | What happens when a worker/provider fails? | Reconcile effects, preserve valid Git state, and resume/restart from the compact authoritative envelope with same or compatible worker; do not replay untrusted transcript. | A default; B same-session resume only; C restart from scratch; D immediate human. | ARCH-003, ARCH-013, ARCH-017 | E01, E10 | failure matrix |
| RUN-010 | P0 / must-decide | When is multi-agent execution allowed? | One accountable lane owner; parallel agents only for separable research/inventory or independent review with disjoint write scope. | A default; B routine subagents; C planner-worker teams; D no subagents. | PRODUCT-005; ARCH-020 | E01, E06 | choose/exceptions |
| RUN-011 | P0 / research-needed | What evidence would justify a durable workflow engine? | None now; require measured multi-day waits/replay volume or recurrent reconciliation failures beyond GitHub/Kubernetes/compact state, then compare DBOS and Temporal. | A default; B DBOS now; C Temporal now; D Restate/Dapr; E never. | ARCH-003, ARCH-017; issue #43 | E01, E10 | threshold/candidate |
| RUN-012 | P1 / research-needed | What retry, wait, and recovery policy applies per operation? | Bound deterministic transient/agent/CI retries from observed failure, cost, and risk; durable waits expire and external effects reconcile before replay. | A zero; B one/one external hypothesis; C measured risk-based; D human-controlled. | ARCH-003, ARCH-013 | E01 | operation matrix + basis |
| RUN-013 | P1 / should-decide | What context envelope does a worker receive? | Issue, lane contract, nearest agent instructions, relevant code, exact checks, risk/tool policy, and just-in-time references; no full lifecycle corpus by default. | A default; B entire repo/docs; C model-selected context; D generated repository map. | PRODUCT-008; ARCH-006 | E01 | approve/edit |
| RUN-014 | P1 / should-decide | What tools does a worker receive? | Curated read/edit/test/restricted Git plus task-specific tools; high-impact effects stay outside the worker. | A default; B all MCP tools; C shell only; D provider defaults. | ARCH-006-007, ARCH-013 | E01, E10 | tool policy |
| RUN-015 | P1 / should-decide | Apply OBS-007's memory-authority decision to execution sessions, compaction, resume, and cache lifetime. | Define scoped runtime use without granting memory new authority. | No independent memory option; runtime projection or conflict flag. | ARCH-015, ARCH-019 | E01 | memory projection |
| RUN-016 | P1 / should-decide | How is context compacted across long work? | Persist verified state, decisions, open risks, exact refs, and next action in compact receipts; summaries identify sources and uncertainty. | A default; B provider transcript; C full event log; D manual handoff. | ARCH-003, ARCH-008, ARCH-015 | E01, E09 | approve fields |
| RUN-017 | P1 / should-decide | How are leases acquired, renewed, expired, and stolen? | Atomic issue/lane lease with owner/session/worktree, TTL/heartbeat, expected version, safe expiry, and explicit administrative recovery; never two active writers. | A default; B Git branch implies lease; C provider session; D database lock. | ARCH-003, ARCH-013 | E01, E06 | lease contract |
| RUN-018 | P1 / should-decide | What cancellation semantics apply? | Cancellation stops new effects, attempts bounded worker stop, reconciles completed/unknown effects, preserves valid commits, releases lease only when safe, and emits receipt. | A default; B kill process; C revert all; D human-only. | ARCH-003, ARCH-013 | E01, E10 | approve flow |
| RUN-019 | P1 / should-decide | How is provider conformance proven? | Executable fixtures cover capabilities, unsupported-operation failure, session lifecycle, exact refs, cancellation, timeout, effect reconciliation, crash/resume, and redaction. | A default; B documentation review; C one happy path; D certification program. | ARCH-006, ARCH-013; issue #12 | E01, E10 | approve test set |

### Human Governance, Authority, Review, And Exceptions

Applies to every shape. Depends on the safety floor, RBT-007..008, and RBT-013;
details vary by the chosen lifecycle paths.

| ID | Priority / class | Decision and context | Proposed default | Options / tradeoffs | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| GOV-003 | P0 / must-decide | Does GitHub remain backlog and delivery authority? | Yes for issues, PRs, checks, reviews, deployments, and releases; support another forge only after a real consumer requires an adapter. | A default; B SCM-neutral now; C Verdify authority; D another forge. | PRODUCT-005; ARCH-006, ARCH-009 | E01, E06-E07 | choose one |
| GOV-004 | P1 / should-decide | Apply OBS-006's evidence-authority decision to repository-local governance records and the authority matrix. | Define which approved intents/gates/policies/receipts are local and link all native authorities; do not choose a new source. | No independent authority option; governance projection or conflict flag. | ARCH-003-006, ARCH-008 | E01, E03-E04, E06 | authority projection |
| GOV-005 | P0 / must-decide | Does one issue/lane/branch/workspace/session/PR remain the default? | Yes; coupled exceptions must name why independent integration is impossible and who approves. | A default; B multi-issue lane; C epic branch; D one wave branch. | PRODUCT-004-005; ARCH-009 | E01, E06 | approve/exceptions |
| GOV-006 | P1 / should-decide | Is dev-to-main a Verdify invariant or this repository's policy? | Repository-specific validated branch policy; keep dev-to-main here while main tracks the published release. | A default; B global dev-to-main; C trunk main; D release branches. | ARCH-006, ARCH-009 | E06, E08 | choose one |
| GOV-007 | P0 / must-decide | Which decisions always require a human? | Unresolved product intent, protected architecture, permission expansion, legal/privacy commitment, destructive/irreversible action, public interface break, material spend, and production outside a preauthorized rollback envelope. | A default; B human every lane; C risk score decides all; D edit list. | PRODUCT-002, PRODUCT-005; ARCH-007, ARCH-009 | E03, E06 | approve/edit classes |
| GOV-008 | P0 / must-decide | What review applies by risk class? | Mechanical checks always; fresh exact-head semantic critic for standard/material work; human approval for configured/protected classes; consensus only for rare protected decisions. | A default; B critic every change; C human every PR; D deterministic only; E multi-model consensus. | PRODUCT-005, PRODUCT-009; ARCH-009 | E01, E06, E09 | risk-review matrix |
| GOV-009 | P0 / must-decide | What makes critic approval non-vacuous? | Every applicable contract/acceptance criterion has an explicit verdict and evidence; zero applicable criteria cannot approve without a validated reason. | A default; B overall prose judgment; C human judgment only; D LLM score threshold. | ARCH-009; issue #73 | E01, E09 | approve rule |
| GOV-010 | P1 / should-decide | Must critic model/provider differ from the worker? | Different session/context and no write authority are mandatory; different model/provider is preferred for high-risk work and measured for marginal value. | A default; B always cross-model; C same worker self-review; D human only. | PRODUCT-005; ARCH-009 | E01, E06 | choose by risk |
| GOV-011 | P0 / must-decide | What exact identity binds implementation, evidence, criticism, human review, and integration? | Last substantive implementation head, closeout-only evidence head, final current PR head, critic target, and human review commit all match explicit 40-character SHAs under defined allowed changes. | A default; B final head only; C PR number; D signed attestation. | ARCH-009; PR template | E06, E08-E09 | approve/modify |
| GOV-012 | P1 / should-decide | What qualifies as review-ready? | Exact head, declared mechanical checks, changed-path/contract scope, risk/security disposition, preview/probe if applicable, rollback, gaps, and precise reviewer decision. | A default; B CI green; C current large packet; D risk-proportional fields. | PRODUCT-008-009; ARCH-009 | E01, E03, E09 | field matrix |
| GOV-013 | P1 / should-decide | How are policy exceptions granted? | Typed request naming rule, scope, owner, rationale, evidence, expiry, compensating controls, rollback, and after-review; no permanent chat exception. | A default; B no exceptions; C approver comment; D admin override. | PRODUCT-005; ARCH-007 | E06 | approve fields |
| GOV-014 | P1 / should-decide | What emergency/break-glass path exists? | Separately authorized incident gate with narrow scope, expiry, audit, rollback, and mandatory post-incident review; it never silently changes the North Star. | A default; B no bypass; C operator discretion; D automated incident agent. | ARCH-007-009 | E06 | choose/owner |
| GOV-015 | P1 / should-decide | Who may update active policy, skills, prompts, schemas, and authority mappings? | Named maintainers through PR, trusted validation, affected-consumer tests, applicable critic/human review, atomic release, and rollback. | A default; B self-modifying controller; C repo owners locally; D central board. | PRODUCT-012-013; ARCH-006-007 | E01, E06 | authority matrix |
| GOV-016 | P1 / should-decide | When is multi-party consensus justified? | Only material protected product/architecture/security decisions with unresolved cross-domain risk; measure delay and reversal prevented. | A default; B every plan; C never; D owner selects ad hoc. | PRODUCT-009-010; adversarial/consensus skills | E01 | choose triggers |
| GOV-017 | P1 / should-decide | Project RBT-008's acceptance owner across projects and work classes. | Bind the named project/customer owner and delegation; technical checks cannot silently replace the accepted root owner. | No independent owner option; owner mapping or root-conflict flag. | PRODUCT-002, PRODUCT-009, PRODUCT-014 | E01-E02, E06 | acceptance-owner projection |
| GOV-018 | P1 / should-decide | Who may merge and release? | Repository maintainer/integrator distinct from worker, after exact-head eligibility; release/publish authority follows repository policy and remains separate from North Star lock. | A default; B worker auto-merge; C controller merge; D GitHub auto-merge. | PRODUCT-002; ARCH-009, ARCH-020 | E05-E06 | authority matrix |
| GOV-019 | P2 / can-defer | How are dissent, uncertainty, and minority risk preserved? | Record material counterevidence, rejected options, decision owner, confidence, review trigger, and responsible human approval; do not erase dissent after lock. | A default; B final decision only; C append full transcripts; D external audit. | PRODUCT-009-010; ARCH-010-011 | E01, E04-E06 | approve fields |

### Security, Privacy, Tenancy, Supply Chain, And Incident Response

Applies to every shape at the temporary floor. Runtime/data-specific rows join
the Runtime Safety and Portfolio Trust co-decision bundles; they do not wait
for a topology chosen without security input.

| ID | Priority / class | Decision and context | Proposed default | Options / tradeoffs | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| SEC-003 | P0 / must-decide | What isolation level maps to each risk class? | Worktree for attended low-risk local work; disposable container/Job for unattended standard work; VM/dedicated boundary for untrusted or high-risk code/data. | A default; B worktree only; C container always; D VM always; E per-repo. | ARCH-005, ARCH-007, ARCH-017 | E01, E10 | risk-isolation table |
| SEC-004 | P0 / must-decide | What network egress may workers use? | Deny by default or destination allowlist with task-specific brokered tools; no unrestricted egress for effect-capable/untrusted workers. | A default; B unrestricted monitored; C allowlist; D broker only. | ARCH-005, ARCH-007, ARCH-018 | E01, E10 | by environment/risk |
| SEC-005 | P0 / must-decide | How are credentials issued? | Short-lived, audience-bound, minimum-scope workload identity or brokered tokens injected from references; never raw values in prompts/logs/Git. | A default; B static Secrets; C operator forwarding; D provider vault. | ARCH-007, ARCH-018 | E01, E06, E10 | service matrix |
| SEC-006 | P0 / must-decide | What is the RBAC identity/cardinality? | Repository controller principal plus lane/task and environment scope; privileged infrastructure-domain principals remain separate explicit grants. | A default; B namespace service account; C per-lane account; D central platform account; E capability tokens. | ARCH-007, ARCH-017-020 | E03, E06, E10 | choose topology |
| SEC-007 | P0 / must-decide | May an autonomous worker mutate production? | No; a separate authorized deployment/effect executor may act only inside a preapproved scoped rollback envelope. | A default; B never any automation; C low-risk production; D broad production agent. | PRODUCT-005; ARCH-007, ARCH-009 | E01, E06, E10 | choose/exceptions |
| SEC-008 | P0 / must-decide | Which consequential effects require separation from analysis/implementation? | Issue/PR changes, merge/release/deploy, messages/calendar/docs, connector writes, secrets, permissions, and destructive actions use typed buffered output and narrow executor. | A default; B high-risk only; C same session with approvals; D no separation. | ARCH-006-007, ARCH-019 | E01, E11 | effect matrix |
| SEC-009 | P0 / must-decide | How is untrusted content prevented from becoming authority/instruction? | Web, source, issue, PR, log, email, document, and retrieved content are data; deterministic policy independently authorizes tools/effects and sanitizes context. | A default; B prompt warning; C model classifier; D isolated sandbox only. | PRODUCT-005; ARCH-007, ARCH-014, ARCH-019 | E01, E11 | approve controls |
| SEC-010 | P1 / should-decide | How are third-party skills, MCP servers, models, dependencies, and runner images admitted? | Allowlisted provenance/version/digest, source/permission/egress review, behavior tests, owner, update policy, and rapid revocation. | A default; B trusted marketplace; C operator choice; D unrestricted. | PRODUCT-013; ARCH-006-007, ARCH-009 | E01, E08-E09 | admission checklist |
| SEC-011 | P0 / must-decide | What tenant boundary applies? | Repository/project and customer are distinct authority, data, credential, telemetry, evidence, and deployment domains; private/personal context never crosses implicitly. | A default; B single internal tenant; C namespace tenancy; D hard customer account tenancy. | ARCH-007, ARCH-014, ARCH-018-021 | E03, E11 | define tenant |
| SEC-012 | P0 / must-decide | Where may personal, enterprise, customer, and source data live? | ACL-preserving encrypted source systems/private stores; Git holds sanitized fixtures, schemas, policy, receipts, and pointers only. | A default; B private Git; C Gravity universal store; D source-only retrieval. | ARCH-007, ARCH-014, ARCH-019 | E03, E11 | data/storage matrix |
| SEC-013 | P1 / should-decide | What retention, correction, export, and deletion rules apply? | Purpose/risk-bound metadata retention, source ACL/deletion propagation, customer export, verified deletion, and no indefinite raw prompt/content retention by default. | A default; B permanent audit; C repository-defined; D regulated schedule. | ARCH-007-008, ARCH-014-015, ARCH-019 | E01, E11 | record-class matrix |
| SEC-014 | P1 / should-decide | Who may use pod exec, browser terminals, secret probes, production logs, and diagnostics? | Named operator/domain roles; read-only by default; commands/targets audited; autonomous delivery workers have none. | A default; B repo controllers; C all workers with approval; D capability-scoped. | ARCH-007-008, ARCH-017-018 | E06, E10 | role-capability matrix |
| SEC-015 | P0 / must-decide | What provenance must be verified at each boundary? | Source SHA, package/tarball, policy bundle, skill origin, worker image, dependency/SBOM, deployed image digest, and GitOps revision using existing signing/attestation primitives. | A default; B release only; C deploy only; D full chain. | ARCH-007, ARCH-009 | E01, E08-E09 | risk-provenance matrix |
| SEC-016 | P0 / must-decide | What install/upgrade/uninstall safety promise is binding? | Atomic, conflict-safe, reversible, exact-artifact, and unmanaged-path preserving; uninstall removes only managed state and reports retained user data. | A default; B container-only avoids host install; C manual migration; D best effort. | PRODUCT-008; ARCH-009 | E08-E09 | approve/modify |
| SEC-017 | P1 / should-decide | What vulnerability response and revocation path exists? | Named security owner can freeze distribution/dispatch, revoke package/image/skill/provider versions, publish advisory, rotate affected references, and require revalidation. | A default; B normal release only; C platform owner; D external service. | PRODUCT-002; ARCH-007, ARCH-009 | E06, E09-E10 | owner/SLA |
| SEC-018 | P0 / must-decide | What incident kill switches are required? | Disable new dispatch, external effects, provider/connector, package/version, deployment path, or tenant independently while preserving evidence and recovery access. | A default; B global off only; C human stop messages; D none. | ARCH-007-009, ARCH-013-019 | E01, E10-E11 | select switches |
| SEC-019 | P1 / should-decide | Which adversarial security fixtures must pass before autonomy expands? | Prompt injection, malicious repo hooks, secret/log exfiltration, egress denial, cross-tenant access, stale head, duplicate effects, dependency tamper, privilege request, and cancellation races. | A default; B static scan only; C penetration test; D production observation. | PRODUCT-009; ARCH-007-009 | E01, E09-E11 | approve/add cases |
| SEC-020 | P1 / should-decide | What actual legal, compliance, residency, and audit obligations exist? | Do not invent certifications; inventory real jurisdictions, contracts, data classes, retention/locality duties, and approvers before designing enterprise controls. | A default; B internal baseline; C privacy-focused; D regulated customers/certifications. | PRODUCT-003, PRODUCT-013; ARCH-007 | E01-E03 | inventory/choice |
| SEC-021 | P0 / must-decide | What hardening profile accompanies each container/VM isolation choice? | Rootless/non-root, dropped capabilities, read-only root filesystem, seccomp/AppArmor, no privileged mode/hostPath/Docker socket/devices, explicit service-account token, isolated processes, bounded writable mounts, and verified cleanup unless a separately gated exception exists. | A default profile; B runtime-native sandbox; C stronger VM; D named exception with threat evidence. | ARCH-005, ARCH-007, ARCH-017-018 | E01, E10 | control matrix by risk |
| SEC-022 | P0 / must-decide | What code, prompts, customer/personal data, and telemetry may leave the trust domain for external model/provider processing? | Data-minimized task content only under approved provider terms; explicitly decide retention/training, subprocessors, abuse logs, regionality, DPA, deletion, incident notice, and opt-out. | A provider matrix; B no sensitive external processing; C self-hosted models; D named exceptions. | PRODUCT-013; ARCH-007, ARCH-019 | E01, E10-E11 | provider/data-class matrix |
| SEC-023 | P0 / must-decide | How are callbacks, webhooks, platform API results, MCP/ACP messages, and any future A2A task updates authenticated and replay-protected? | Validate issuer/audience/signature, bind request/run/result/tenant, use nonce/expiry, reject duplicate or out-of-order delivery safely, prohibit bearer-token forwarding, and test confused-deputy/callback desynchronization. | A default; B network trust; C provider callback ID only; D polling-only. | ARCH-006-007, ARCH-013, ARCH-021 | E10; Agents #1762/#2884 | approve protocol controls |
| SEC-024 | P0 / must-decide | May provider sessions share Unix identity, credential/OAuth home, PVC, SSH material, browser state, or copied authentication? | No cross-provider/tenant sharing by default; inventory current shared state, isolate homes/identities, migrate safely, and advertise unavailable auth honestly. | A default isolation; B shared internal identity; C brokered credentials only; D fixed-agent exception. | ARCH-007, ARCH-017-018 | E10; Agents #2491 | identity/storage matrix |
| SEC-025 | P1 / should-decide | Who owns encryption keys and how are they rotated, recovered, audited, and destroyed? | Named security/data owner, managed KMS or approved age workflow, separate backup keys, least-privilege decrypt, rotation/compromise drill, access audit, and deletion semantics. | A default; B platform-managed; C customer-managed; D source-system encryption only. | ARCH-007, ARCH-014, ARCH-018-019 | E06, E10-E11 | key authority matrix |
| SEC-026 | P0 / must-decide | What secret-validity probes are permitted? | Fixed allowlisted destination and protocol per secret type, metadata-only result, no returned value/body, strict timeout/rate limit/audit, tenant binding, and kill switch. | A default; B operator manual; C arbitrary read-only probe; D disable probes. | ARCH-007, ARCH-017-018 | E10; Agents #2906 | probe contract |

### Agent Platform, Kubernetes, CI/CD, GitOps, And Operations

Applies only if RBT-002/004/009 retain Agent Platform, Kubernetes, hosted
runtime, or deployment proof. Runtime topology, security, and INF-002..008 are
co-decided.

| ID | Priority / class | Decision and context | Proposed default | Options / tradeoffs | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| INF-002 | P0 / must-decide | What is the canonical runtime topology? | Durable repo controller only where recurrence/recovery needs it; disposable task workers for implementation; GitHub and compact receipts hold durable work authority. | A default hybrid; B pod per repo; C Job per task; D shared pool; E hosted agents. | ARCH-005, ARCH-017-018 | E01, E10 | controller/worker choice |
| INF-003 | P0 / must-decide | Is Kubernetes required for every Verdify user? | No; local/worktree mode is viable, while Kubernetes is the current production fleet isolation/reconciliation provider. | A default; B Kubernetes required; C hosted platform required; D pluggable runtime with conformance. | PRODUCT-008, PRODUCT-013; ARCH-005 | E01, E10 | choose minimum |
| INF-004 | P0 / must-decide | Are fixed repo agents, ephemeral workers, or dynamic worktrees the supported primary strategy? | One truthful fixed/local strategy now; ephemeral isolated Job next; dynamic worktree remains unsupported until its API works and passes conformance. | A default; B fixed agents only; C dynamic worktrees first; D remote hosted. | ARCH-013, ARCH-017; issue #12 | E10 | rank/support status |
| INF-005 | P1 / should-decide | What durable control-plane service, if any, does Agent Platform own? | Capability discovery, task environment provisioning, identity/credential/network policy, process/session supervision, cancellation, health, and provider receipts—not Verdify lifecycle authority. | A default; B compute only; C full controller; D no owned platform. | PRODUCT-013-014; ARCH-017-018 | E01, E10 | approve/edit |
| INF-006 | P1 / should-decide | How are tasks queued and scheduled? | GitHub-ready work plus a small bounded dispatcher; no proprietary general scheduler until concurrency/priority/SLA evidence requires it. | A default; B Kubernetes Jobs directly; C workflow engine; D central priority queue; E manual dispatch. | ARCH-013, ARCH-017 | E01, E10 | choose/trigger |
| INF-007 | P1 / should-decide | What namespace cardinality and naming rule applies? | Collision-safe owner/repository identity with explicit environment suffix; previews/tasks have TTL, labels, quotas, and owner. | A default; B namespace per repo; C per environment; D per lane; E shared fleet. | ARCH-005, ARCH-018 | E03, E10 | template/cardinality |
| INF-008 | P1 / should-decide | What storage is durable versus disposable? | Bounded controller PVC only if needed; task worktrees/caches disposable; source/evidence native; no shared active worktree between coding sessions. | A default; B PVC per task; C shared NFS; D object store; E no persistent workspace. | ARCH-005, ARCH-017-018 | E03, E06, E10 | storage map/SLA |
| INF-009 | P0 / must-decide | What role does GitHub Actions play? | Trusted validation and control signal; it builds without production push under current fleet policy; effects use separately governed publication/deploy paths. | A default; B build/publish; C full deploy; D replace CI. | ARCH-009 | E06, E08, E10 | responsibility matrix |
| INF-010 | P0 / must-decide | What image build and registry path is strategic? | Current fleet: in-cluster Kaniko to durable zot origin, pull by sha256 digest, GitHub validates buildability; revisit builder only on measured pain. | A default; B BuildKit; C GitHub build/push; D managed registry. | ARCH-009, ARCH-018 | E06, E10 | choose + migration trigger |
| INF-011 | P0 / must-decide | Is Argo CD the committed GitOps reconciler and how are deletions handled? | Argo CD; prune remains false until a governed cleanup flow exists; removed resources require explicit change-gated deletion and verification. | A default; B Flux; C direct deploy; D selective prune; E full prune. | ARCH-009, ARCH-018 | E06, E10 | controller/prune policy |
| INF-012 | P1 / should-decide | Which environments are required? | Local/dev plus ephemeral preview where it produces evidence; staging only for distinct risk; production protected separately. | A default; B dev only; C dev/stage/prod; D preview per PR; E project-specific. | ARCH-005, ARCH-009 | E03, E10 | project/risk matrix |
| INF-013 | P1 / should-decide | How are DNS, ingress, routes, and certificates requested? | PR-reviewed desired state or typed platform request; named network owner approves; repo workers never mutate shared routing directly. | A default; B self-service template; C operator ticket; D direct kubectl. | ARCH-018; deferred NSQ-013 | E03, E06, E10 | choose flow |
| INF-014 | P1 / should-decide | Allocate RBT-011's accepted capacity/spend envelope across CPU, memory, time, concurrency, tokens, and infrastructure. | Preserve root caps and override authority; define quota-blocked behavior and attribution only. | No independent budget option; allocation table or root-conflict flag. | ARCH-005, ARCH-008, ARCH-017 | E01, E10 | budget projection |
| INF-015 | P2 / can-defer | How granular are base images and how are they maintained? | Small role/language-family images, digest pinning, scheduled rebuild/vulnerability checks, and rollback; repo agents recommend but do not mutate fleet images. | A default; B one universal image; C per repo; D install at runtime. | ARCH-018 | E06, E10 | granularity/cadence |
| INF-016 | P1 / should-decide | What availability, RTO, and RPO are justified? | Prove single-cluster restart and backup/restore first; Git/GitHub remain recoverable authority; defer multi-region HA. | A default; B best effort; C single-cluster HA; D warm standby; E multi-region. | ARCH-005, ARCH-008, ARCH-017 | E01, E10 | targets/failure domains |
| INF-017 | P1 / should-decide | How are previews provisioned, expired, and attributed? | One isolated preview only when review/outcome needs runtime evidence; exact source/image/GitOps refs, TTL, quota, URL/access, cleanup owner, and orphan detection. | A default; B preview every PR; C shared staging; D no previews. | ARCH-005, ARCH-009 | E01, E10 | approve contract |
| INF-018 | P0 / must-decide | Who performs deployment and what does Verdify own? | Existing CI/registry/GitOps/Kubernetes perform effects; Verdify validates eligibility, invokes authorized adapter, correlates refs, and verifies evidence. | A default; B Verdify deploy engine; C human only; D Agent Platform full ownership. | ARCH-009, ARCH-013, ARCH-017 | E01, E10 | choose boundary |
| INF-019 | P0 / must-decide | Who may trigger rollback and under what envelope? | Deterministic health signal may execute only a preapproved bounded rollback; otherwise named human/operator authorization. | A default; B human always; C preview auto; D production auto; E self-healing agent. | ARCH-007, ARCH-009 | E01, E06 | authority matrix |
| INF-020 | P1 / should-decide | What delayed re-probe proves durability? | Predeclare workload-specific stabilization window and at least one later probe after initial health; package/service/data changes have distinct probes. | A default; B fixed 5/15/60 minutes; C SLO-driven; D no delay. | PRODUCT-009; ARCH-008-009 | E01, E08 | rules/examples |
| INF-021 | P1 / should-decide | How are orphaned resources and failed cleanup detected and resolved? | Inventory desired versus observed resources, alert on TTL/ownership mismatch, and route destructive cleanup through change gate with post-verification. | A default; B enable prune; C manual sweep; D ignore until cost incident. | ARCH-008-009, ARCH-018 | E06, E10 | choose flow |
| INF-022 | P1 / should-decide | What operator visibility is required? | GitHub/status/receipts first; correlated logs/metrics/traces and optional terminal view for diagnostics; no tmux transcript as authoritative state. | A default; B browser control center; C terminal-only; D platform API only. | PRODUCT-008; ARCH-008, ARCH-013, ARCH-017 | E01, E10 | rank surfaces |
| INF-023 | P0 / must-decide | What objective transaction makes Agent Platform complete enough? | One supported dispatch with correct capability failure, isolation, scoped identity/RBAC/egress, cancel/crash/resume, no duplicate effect, correlated PR/deploy/outcome, and no path-relevant open P0. | A default; B four Ready pods; C API feature checklist; D full backlog closed. | ARCH-017-018; platform readiness | E10 | approve exit gate |
| INF-024 | P1 / should-decide | Must the platform support customer-hosted, Verdify-hosted, or both? | Internal/customer-controlled local or Kubernetes deployment first; defer multi-tenant hosted control plane until business demand and tenancy proof. | A default; B Verdify SaaS; C customer only; D both immediately. | PRODUCT-013; ARCH-005, ARCH-017-018 | E01, E10 | choose/trigger |
| INF-025 | P1 / should-decide | How is infrastructure portability tested? | One local provider and one Kubernetes provider implement the same semantic lane contract and failure fixtures; provider-specific features stay optional. | A default; B current fleet only; C cloud abstraction; D no portability goal. | ARCH-006, ARCH-013, ARCH-017 | E01, E10 | approve tests |
| INF-026 | P1 / should-decide | Apply EVL-014's fault/recovery proof to backup/restore and the RTO/RPO selected in INF-016. | Define restore/reconcile/no-duplicate evidence; disposable work remains non-authoritative unless the canonical state decision says otherwise. | No independent proof model; backup/restore projection or conflict flag. | ARCH-008, ARCH-017-018 | E01, E10 | recovery projection |
| INF-027 | P2 / can-defer | When does the platform need a service catalog or golden-path portal? | Only after multiple teams cannot discover/support repositories through GitHub and bootstrap; integrate an existing catalog before building one. | A default; B Backstage now; C custom portal; D never. | PRODUCT-008, PRODUCT-013; ARCH-017 | E01 | trigger/choice |
| INF-028 | P1 / should-decide | Which host OS, shell, offline/air-gapped, proxy, and self-hosted environments must install and run vNext? | Support only environments named by RBT-003/RBT-009; prove Linux/current fleet first and make unsupported hosts fail explicitly. Do not promise air-gap support without dependency/model/update design. | A Linux only; B macOS+Linux; C Windows/WSL; D air-gapped; E custom support matrix. | PRODUCT-008, PRODUCT-013; ARCH-005 | E01, E08-E10 | support matrix + tests |
| INF-029 | P0 / must-decide | What cluster-change gate governs new resource kinds, CRDs, AppProject permissions, cluster-scoped resources, mutation, and deletion? | Snapshot observed state, render/validate desired diff, require named authorized apply, enforce dead-man timeout/rollback, post-verify and delayed re-probe; whitelist new kinds explicitly and route orphan cleanup separately. | A default; B GitOps approval only; C bounded self-service; D operator manual. | ARCH-007, ARCH-009, ARCH-018 | E06, E10 | change-class/authority matrix |

### Live Agent Platform Blocker Decisions

Applies whenever RBT-004 retains Agent Platform or RBT-010 requires a runtime
or platform-backed proof. These point-in-time blockers must be refreshed before
the second-round packet.

| ID | Priority / class | Decision and context | Proposed default | Options / tradeoffs | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| PLT-001 | P0 / must-decide | What convergence invariant binds runtime checkout, source branch/revision, installed Verdify package, policy, and worker image? | Dispatch only when declared source/policy/package/image identities are compatible and fresh; stale or pre-loop clones become typed unavailable/degraded, never silently armed. | A default; B origin/main always; C baked package floor; D checkout package only; E compatibility matrix. | ARCH-006, ARCH-017 | E10; Agents #2817/#2819 | invariant + stale behavior |
| PLT-002 | P0 / must-decide | What does healthy mean across Pod, Argo, controller process, outer loop, active task, deployment, durability, and accepted outcome? | Separate state/evidence owner for each layer; Pod Ready is never controller/work/deploy/outcome success; contradictory layers produce degraded/blocked truth. | A default; B aggregate green; C Argo only; D SLO only. | ARCH-008-009, ARCH-017 | E10; Agents #2598/#2840/#2886/#2888 | health-state matrix |
| PLT-003 | P0 / must-decide | How do provider authentication expiry, unavailable login, quota exhaustion, rate limits, cooldown, and model/runtime mismatch affect capability and fallback? | Advertise only currently usable capability; typed degraded/denied state, bounded backoff, no credential copying, compatible-provider fallback after reconciliation, and human notice when work cannot progress. | A default; B retry indefinitely; C fixed-provider block; D operator-only. | ARCH-006, ARCH-008, ARCH-013, ARCH-017 | E10; Agents #2491/#2497/#2859 | failure/fallback matrix |
| PLT-004 | P0 / must-decide | What happens to invalid, legacy, duplicate, or mutually active lifecycle transactions before new dispatch? | Validate current artifacts with trusted policy; designate one authority; terminalize, migrate, or archive the rest with evidence; fail closed while ambiguity remains. | A default; B newest wins; C ignore legacy; D root planner reconciles. | ARCH-003, ARCH-017, ARCH-021 | E10; Agents #2889 | reconciliation rule |
| PLT-005 | P0 / must-decide | What current platform evidence closes callback/request integrity risk? | SEC-023 controls plus regression fixtures for HTTP desynchronization, callback-token mounting/rotation, request-result binding, duplicate/replay delivery, restart, and denial; no effect path opens until fixed. | A default; B disable callbacks; C poll-only temporary path; D risk accept is not available inside this interview. | ARCH-006-007, ARCH-013, ARCH-017 | E10; Agents #1762/#2884 | closure evidence |
| PLT-006 | P0 / must-decide | Which execution paths are blocked by the named Agent Platform security P0s and what exact evidence closes each? | #2884 blocks affected HTTP effect paths; #2887 requires quarantine/rotation/history treatment before affected credentials; #2906 blocks unrestricted probes. No generic risk-accept shortcut. | A default mapping; B freeze all platform work; C disable affected features; D separate protected exception gate. | ARCH-007, ARCH-017-018 | E10; Agents #2884/#2887/#2906 | issue-path-evidence matrix |
| PLT-007 | P0 / must-decide | What kubeconfig source, service-account RBAC, namespace scope, and denial behavior does Platform promise? | Durable in-cluster kubeconfig targets the real API; own-namespace reads match declared contract; extra access requires registry grant; localhost fallback or unexpected Forbidden is typed not-ready; conformance probe prints no sensitive data. | A default; B no Kubernetes access; C operator proxy; D expanded named grants. | ARCH-005, ARCH-007, ARCH-017-018 | E10, current kube audit | contract + probe |
| PLT-008 | P0 / must-decide | What capability-state ladder prevents implemented code from being called platform-ready? | Define implemented, deployed, exposed, authenticated, integrated, release-verified, degraded, disabled, stale, and denied; each transition has evidence owner, timestamp, literal probe, and re-probe where applicable. | A default; B ready/not-ready; C provider status only; D custom ladder. | PRODUCT-009; ARCH-008-009, ARCH-017, ARCH-021 | E01, E10; ARQ-033 | state/evidence table |
| PLT-009 | P1 / should-decide | Does Agents #2890 remain a four-pilot/root-planner strategy issue after RBT-004? | Reframe/close/defer it to match the chosen portfolio topology; Agent Platform cannot self-authorize co-equal portfolio status. | A reframe; B retain; C close; D defer. | PRODUCT-014; ARCH-021 | E10; Agents #2890 | disposition |
| PLT-010 | P1 / should-decide | Which controller cadence, heartbeat, budget, missed-tick, unattended-streak, and recovery controls are required? | Expose configured executor/cadence/budget, emit heartbeat and missed-tick alert, prove restart-safe streak only after effect reconciliation; do not equate elapsed uptime with successful work. | A default; B manual controller; C provider-native loop; D no unattended target. | ARCH-008, ARCH-017 | E10; Agents #2802/#2859 | control/metric matrix |
| PLT-011 | P0 / must-decide | How are undeclared sessions, namespace/Argo co-ownership, hung clones, and other observed drift reconciled? | Compare desired ownership to pods/tmux/namespaces/Argo/transactions, quarantine ambiguity, repair non-destructively where authorized, and route deletion through INF-029. | A default; B controller observed state wins; C GitOps desired wins; D operator manual. | ARCH-008-009, ARCH-017-018 | E10; Agents #2598/#2840/#2886/#2888 | reconciliation/authority |

Cross-project blockers that branch pruning must retain when the corresponding
project remains active:

| Project | Live issues | Decision coverage |
| --- | --- | --- |
| Orbit | #193 trust split, #194 private-material removal, #195 source/audit contract, #196 ACL-preserving connector, #197 portfolio role, #198 workflow authority | ORB-001..008, SEC-011..026, PLT-008, SEQ-006..007 |
| Gravity | #184 Gate-B integration evidence, #406 portfolio role, #407 cited API/MCP parity | GRA-001..006, OBS-006/009, SEC-011..013, SEQ-006..007 |

### Observability, Correlation, Evidence, Memory, And Provenance

OBS-001..002/006/008 are foundational inputs to INF-023 and precede the
platform exit gate. Remaining observability details apply after the selected
runtime/data topology is known.

| ID | Priority / class | Decision and context | Proposed default | Options / tradeoffs | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| OBS-001 | P0 / must-decide | What is the minimum cross-system correlation identity? | Run ID plus repo, issue, lane, session/provider, PR, implementation/evidence/current heads, policy, deployment, and outcome IDs propagated as links. | A default; B W3C trace only; C provider IDs; D GitHub IDs only. | ARCH-003, ARCH-008, ARCH-021 | E01, E03 | approve ID set |
| OBS-002 | P1 / should-decide | Project RBT-008's North Star metric and hard safety floor into operational funnel/diagnostic metrics. | Keep the canonical metric primary; define leading indicators, dimensions, attribution, thresholds, and owners without substituting activity metrics. | No independent primary-metric option; observability projection or conflict flag. | PRODUCT-009; ARCH-008 | E01 | metric projection |
| OBS-003 | P1 / should-decide | Apply SEC-013's retention/deletion policy to logs, metrics, traces, prompts, content, and correlation metadata. | Define sampling/redaction/retention mechanics per signal without changing canonical data policy. | No independent retention option; signal mapping or conflict flag. | ARCH-007-008, ARCH-019 | E01, E11 | retention projection |
| OBS-004 | P1 / should-decide | May alerts restart or re-dispatch agents? | Restart process health only when state is safely reconstructable; never replay external/business effects without reconciliation. | A default; B alert only; C restart controller; D resume worker; E full remediation. | ARCH-008, ARCH-017 | E01, E10 | alert-action matrix |
| OBS-005 | P2 / can-defer | Which OpenTelemetry GenAI conventions are supported? | Pin one explicit experimental version behind a mapping adapter for diagnostics, not authority. | A default; B generic spans; C provider-specific; D no GenAI schema. | ARCH-008 | E01 | choose/version |
| OBS-006 | P0 / must-decide | What is the authority split among Git receipts, evidence registry, Gravity, and telemetry? | Git for approved intent/receipts; registry for cited planning evidence; Gravity for tenant-scoped read evidence; telemetry for diagnostics. | A default; B Gravity universal; C Git only; D central event/evidence store. | ARCH-008, ARCH-014-015 | E01, E03, E11 | authority table |
| OBS-007 | P1 / should-decide | What is agent memory allowed to remember? | User-approved preferences and proposed lessons with source, confidence, retention, correction/deletion; never authority, approval, secret, or sole task state. | A default; B session only; C organization memory; D personal persistent memory; E none. | ARCH-015, ARCH-019 | E01, E11 | class/rules |
| OBS-008 | P1 / should-decide | What evidence must every terminal receipt contain? | Intent/contract refs, exact identities/heads, validator/policy versions, checks, reviewer/authority, effects, deploy/durability/outcome refs, gaps, cost/time, and final disposition. | A default; B PR link only; C full transcript; D signed attestation only. | PRODUCT-009; ARCH-008-009 | E01, E08-E09 | approve fields |
| OBS-009 | P1 / should-decide | How do evidence links prove freshness, access, and deletion? | Include source/generation/version, tenant/visibility, retrieved-at/validity, resolvable span/artifact, processing/deletion state, and typed denial. | A default; B URL only; C snapshot copies; D best effort. | ARCH-014, ARCH-019 | E01, E11 | approve contract |
| OBS-010 | P1 / should-decide | Apply SEC-013 and OBS-006 to evidence immutability, correction, supersession, tombstones, and prohibited-content deletion. | Define mechanics that preserve canonical authority/retention without selecting a conflicting policy. | No independent correction/retention option; evidence projection or conflict flag. | ARCH-008, ARCH-014-015 | E01, E11 | correction projection |
| OBS-011 | P2 / can-defer | What dashboard views are actually required? | Lane funnel, failure/repair, cost/intervention, policy/security events, deploy/durability/outcome, and stale/orphan state; build only views with owners/actions. | A default; B raw fleet dashboard; C executive only; D none. | PRODUCT-008-009; ARCH-008 | E01, E10 | rank views |
| OBS-012 | P1 / should-decide | How are observability and evidence quality themselves tested? | Fixture spans/metrics/receipts with correlation/redaction assertions, missing-signal failure, alert delivery, and source-link resolution; live failure drill validates operations. | A default; B dashboard inspection; C unit tests; D third-party audit. | ARCH-008-009 | E01, E10-E11 | approve tests |

### Orbit, Gravity, And Consulting Boundaries

Applies only to projects retained by RBT-004. Disposition/migration rows remain
active even when a project is paused or retired.

| ID | Priority / class | Decision and context | Proposed default | Options / tradeoffs | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| ORB-001 | P1 / should-decide | Project RBT-004's Orbit disposition and PTF-006 mission into core/optional experience boundaries and non-authorities. | Do not independently change portfolio topology; state the exact retained user surface and prohibited authority. | No independent role option; Orbit projection or root-conflict flag. | PRODUCT-014; ARCH-019-021 | E02-E03, E11 | role projection |
| ORB-002 | P0 / must-decide | Does Orbit combine personal assistant and engineering chief-of-staff roles? | Keep both only as distinct trust domains and user journeys; otherwise split scope or product. | A default split domains; B personal only; C engineering only; D one shared broad agent. | PRODUCT-014; ARCH-019 | E02-E03, E11 | choose one |
| ORB-003 | P1 / should-decide | Which connector is first and in what sequence do others earn admission? | One minimal-scope read-only connector with citations, ACL/freshness, audit, revocation, correction/deletion proof; expand source by source. | Rank email, calendar, GitHub, enterprise docs, meetings/transcripts, CRM, fleet status. | ARCH-019 | E11 | rank + exit gates |
| ORB-004 | P0 / must-decide | Must personal context and engineering/fleet actuation use separate principals and storage? | Yes: separate runtime identities/trust domains or a strictly brokered capability boundary. | A default; B separate service accounts; C separate namespaces; D shared principal with approval. | ARCH-007, ARCH-019-021 | E03, E11 | choose topology |
| ORB-005 | P0 / must-decide | What writes may Orbit ever perform? | Read/propose first; messaging, calendar, documents, GitHub, platform, and production writes require separate scoped executor and policy/human authorization. | A read-only; B proposed writes default; C low-risk autonomous; D broad actuation. | PRODUCT-005; ARCH-019 | E01, E11 | source-capability matrix |
| ORB-006 | P1 / should-decide | Apply OBS-007's memory authority and SEC-013's data policy to Orbit personalization. | Define Orbit-specific classes, user controls, provenance, retention, correction/deletion, and trust separation without granting new authority. | No independent memory option; Orbit projection or conflict flag. | ARCH-015, ARCH-019 | E01, E11 | memory projection |
| ORB-007 | P1 / should-decide | Is a morning digest/status brief a core outcome? | Optional Orbit experience that cites authoritative sources, reports degraded/stale connectors, and proposes rather than authorizes actions. | A default; B Skills core; C platform control screen; D remove. | PRODUCT-008, PRODUCT-014; ARCH-019-021 | E11 | choose owner/acceptance |
| ORB-008 | P1 / should-decide | What proves Orbit ready? | One connector passes identity/ACL/citation/freshness/audit/revocation/deletion, injection resistance, separate actuation, and useful-user evaluation before another connector. | A default; B connector works; C all connectors; D personal dogfood. | PRODUCT-006-009; ARCH-019 | E11 | approve exit gate |
| GRA-001 | P1 / should-decide | Project RBT-004's Gravity disposition and PTF-007 mission onto the current versus historical repository migration. | If Gravity is retained, name its authoritative implementation and migration; if retired/replaced, record terminal treatment. Do not change portfolio role here. | No independent role option; authority/migration projection or root-conflict flag. | ARCH-014; locked default 7 | E03, E05, E11 | repository projection |
| GRA-002 | P0 / must-decide | What transport boundary does Gravity own first? | Versioned tenant-scoped read-only HTTP API plus consumer-side MCP mapping; network MCP only after a concrete need. | A default; B HTTP only; C network MCP; D direct DB/library. | ARCH-006, ARCH-014; locked default 8 | E03, E05, E11 | choose/version |
| GRA-003 | P0 / must-decide | What makes a result trusted? | Same-context resolvable citations, source ACL, tenant/visibility/generation/deletion identity, typed denials, processing state, durability, freshness, and API/MCP parity. | A default; B best-effort citations; C document-level; D span-level mandatory. | PRODUCT-005, PRODUCT-009; ARCH-014 | E01, E11 | approve invariant |
| GRA-004 | P1 / should-decide | Which sources and evidence types does Gravity support first? | One bounded corpus needed by a real planning/dependency proof; no universal ingestion claim. | A repo docs/issues; B North Star collateral; C transcripts; D enterprise docs; E web research. | ARCH-014 | E11 | rank/source owner |
| GRA-005 | P1 / should-decide | What ingestion, update, deletion, and re-index semantics apply? | Idempotent source/version ingestion, observable processing state, ACL/deletion propagation, correction/tombstone, and bounded recovery. | A default; B append-only; C periodic rebuild; D source-specific. | ARCH-014 | E11 | approve state model |
| GRA-006 | P1 / should-decide | What proves Gravity ready for cross-project use? | Live tenant-scoped query with correct citations/denials across restart, consumer MCP parity, freshness/deletion test, latency/SLO, audit, and recovery evidence. | A default; B HTTP 200; C local tests; D production usage. | PRODUCT-006-009; ARCH-014 | E11 | approve exit gate |
| CST-001 | P1 / should-decide | Is consulting the first business model, a validation channel, or a later vertical? | Business use and validation channel after internal proof; reusable kernel stays client-neutral and bespoke engagement work is explicitly separated. | A default; B primary product; C bespoke service only; D defer. | PRODUCT-001, PRODUCT-006, PRODUCT-013 | E01, E12 | choose one |
| CST-002 | P1 / should-decide | Which consulting journey should be proved first? | Client intent/transcript to approved issue-backed plan, then one delivery lane to accepted outcome and handoff, with client-owned authority and evidence. | A default; B planning advisory; C platform implementation; D ongoing managed operations. | PRODUCT-004, PRODUCT-008 | E01-E02 | choose journey |
| CST-003 | P1 / should-decide | What client data and authority may Verdify retain? | Client owns backlog, code, decisions, and outcomes; Verdify retains only contractually allowed redacted receipts/lessons, with no cross-client memory transfer. | A default; B full engagement archive; C client environment only; D reusable anonymized data. | PRODUCT-013; ARCH-007, ARCH-015 | E01, E06 | authority/retention |
| CST-004 | P2 / can-defer | What commercial unit should eventually be priced? | Do not choose until measured: compare engagement/outcome, managed repository, seat, and platform subscription against value/cost evidence. | A engagement; B outcome; C repo/month; D seat; E usage; F no software price. | PRODUCT-001, PRODUCT-006 | E01 | rank/revisit trigger |

### Evaluation, Proof, Economics, And Claims

Applies to every product shape. RBT-008 owns the primary job/value rule; these
rows define its measurement and proof.

| ID | Priority / class | Decision and context | Proposed default | Options / tradeoffs | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| EVL-003 | P1 / should-decide | Operationalize the RBT-008 primary metric with formula, unit, attribution window, denominator, uncertainty, and safety-gate handling; do not choose another metric. | Use the accepted root metric and distinguish leading/funnel diagnostics from the North Star measure. | No independent option; define measurement or flag root conflict. | PRODUCT-001, PRODUCT-009 | E01 | metric implementation |
| EVL-004 | P0 / must-decide | Which safety/quality metrics are hard gates rather than optimization metrics? | Unauthorized/duplicate effect, stale-head acceptance, critical escaped defect, privacy/security breach, failed recovery, failed rollback, and false completion are hard failures. | A default; B security only; C reliability only; D advisory. | PRODUCT-005, PRODUCT-009; ARCH-007-009 | E01, E09-E11 | classify metrics |
| EVL-005 | P0 / must-decide | What executable evaluation runner replaces prose cases? | Versioned fixtures invoke skill/router/validator/worker adapters, capture artifacts/effects, run deterministic graders, support with/without treatments, and emit comparable results. | A default; B unit tests only; C LLM judge; D production telemetry. | PRODUCT-009; issues #74-75 | E01, E07, E09 | approve capabilities |
| EVL-006 | P1 / should-decide | Which tasks populate the first representative suite? | 2-3 real cases per critical behavior plus negative routing/safety fixtures: install, route, lane, critic, effect, resume, package/runtime proof. | A default; B all 77 prose cases; C synthetic benchmark; D external customer cases. | PRODUCT-004-009 | E01, E09 | choose corpus |
| EVL-007 | P1 / should-decide | What with/without comparison isolates skill value? | Same task/repo/worker/model/context budget: baseline agent+GitHub versus Verdify; human-only or external platform added where feasible. | A default; B historical baseline; C no control; D provider benchmark. | PRODUCT-009 | E01 | comparator set |
| EVL-008 | P1 / research-needed | How many repetitions handle model variance? | Estimate variance in a pilot and use a declared sequential/sample-size rule tied to claim risk and decision threshold; no arbitrary fixed count. | A sequential rule; B owner-supplied fixed count; C one diagnostic run only; D external statistical review. | PRODUCT-009 | E01 | rule/confidence |
| EVL-009 | P1 / should-decide | What graders are trusted? | Deterministic tests/effects/heads first; human blind rubric for semantic outcome; LLM judge only supplemental and calibrated against humans. | A default; B LLM judge; C human only; D CI only. | PRODUCT-009; ARCH-009 | E01 | grader matrix |
| EVL-010 | P1 / should-decide | Operationalize RBT-008's terminal boundary and acceptance owner with predeclared observable criteria by work class. | Separate technical success, satisfaction, and business effect without changing the root outcome/owner. | No independent terminal/owner option; acceptance projection or root-conflict flag. | PRODUCT-004, PRODUCT-009 | E01-E02 | acceptance projection |
| EVL-011 | P1 / should-decide | How are human effort and intervention captured? | Active review/decision/fix minutes plus intervention count/reason; exclude passive wait and distinguish required governance from avoidable repair. | A default; B self-report; C screen time; D number of messages. | PRODUCT-009; ARCH-008 | E01 | method |
| EVL-012 | P1 / should-decide | What cost is counted? | Model/tool compute, task environment, CI, storage/egress, human time, failed attempts, and maintenance amortization; report per attempted/accepted/deployed outcome. | A default; B model tokens only; C cloud bill; D labor only. | PRODUCT-009; ARCH-008 | E01 | cost model |
| EVL-013 | P1 / should-decide | How are defects, rework, and escape measured? | Critic/human change requests, CI repairs, rollback, post-merge defect severity, duplicate/unauthorized effect, and outcome rejection linked to exact run. | A default; B bug count; C PR comments; D SLO only. | PRODUCT-009; ARCH-008-009 | E01 | taxonomy/window |
| EVL-014 | P0 / must-decide | What operational fault-injection suite proves level 6? | Kill worker/controller before/after every external effect; stale/duplicate events; provider loss; CI failure; deploy regression; rollback; API/connector outage; delayed re-probe. | A default; B one restart demo; C chaos platform; D no injection. | PRODUCT-009; ARCH-008-009, ARCH-017 | E01, E10-E11 | approve matrix |
| EVL-015 | P1 / should-decide | What proof is required per claim? | Map each claim to proof ladder: design, adoption, empirical, implemented, local verified, operational, value; publish exact scope and exclusions. | A default; B one global maturity label; C tests mean proven; D customer reference. | PRODUCT-009; release claims | E01, E08-E11 | claim-proof table |
| EVL-016 | P0 / must-decide | What threshold unlocks the next stage? | Representative gate passes repeatedly, no critical safety failure, recovery/durability evidence exists where relevant, and metric movement is promising within budget. | A default; B deadline; C owner judgment; D backlog completion. | PRODUCT-006-007, PRODUCT-009 | E01 | numeric/qual gates |
| EVL-017 | P0 / must-decide | What result stops or narrows investment? | Derive the threshold and number of funded attempts from RBT-011/RBT-014, observed variance, safety evidence, and opportunity cost; if it is crossed, stop expansion and retain only the proven useful scope. | A quantitative stop; B funded-stage review; C pivot trigger; D no expansion until proof. | PRODUCT-006-007 | E01 | threshold/basis/fallback |
| EVL-018 | P1 / should-decide | How are eval results protected from test leakage and candidate tampering? | Trusted-base runner, immutable fixtures/graders, held-out cases, exact versions/seeds, separated candidate workspace, and raw result retention with redaction. | A default; B candidate tests; C public fixtures only; D external service. | ARCH-007, ARCH-009 | E06, E09 | approve controls |
| EVL-019 | P2 / can-defer | Which external benchmarks matter? | Use SWE-bench/agent benchmarks only for worker selection context; local lifecycle, safety, deployment, and value evaluations decide Verdify. | A default; B optimize benchmark; C no external comparison; D build public benchmark. | PRODUCT-009 | E01 | choose role |
| EVL-020 | P1 / should-decide | Who owns the evaluation program and may approve metric changes? | Independent product/evaluation owner with repository maintainers; metric/fixture changes are versioned, reviewed, and cannot rewrite prior results. | A default; B implementer; C controller; D external auditor. | PRODUCT-002, PRODUCT-009 | E06 | owner/change policy |

### Backlog Authority, Taxonomy, And Issue Disposition

Applies after RBT-010, EVL-014..017, and SEQ-002..008 define the accepted proof
sequence. Then map issues to stages; do not let the inherited backlog choose
the strategy.

| ID | Priority / class | Decision and context | Proposed default | Options / tradeoffs | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| BKL-002 | P1 / should-decide | Apply RBT-004/RBT-012/RBT-013 to implementation and portfolio backlog authority. | Name the exact repository/project authority and link strategy without changing root topology, reset policy, or approver. | No independent authority option; backlog mapping or root-conflict flag. | PRODUCT-014; ARCH-021 | E06-E07 | authority projection |
| BKL-003 | P1 / should-decide | Apply RBT-012's backlog-reset axis to the current issue set without losing history. | Define mechanics for classification, updates, closure, successor links, and freeze/cutover consistent with the root policy. | No independent reset option; process projection or root-conflict flag. | All issue recommendations | E07, E12 | reset projection |
| BKL-004 | P1 / should-decide | What issue hierarchy is allowed? | Outcome/epic issue links independently deliverable one-issue lanes; no private parallel backlog or giant implementation issue. | A default; B flat issues; C sub-issues; D project board only. | PRODUCT-006-007; ARCH-021 | E06-E07 | choose hierarchy |
| BKL-005 | P1 / should-decide | Which labels/fields are required for routing and strategy? | Project, type, risk/change class, lifecycle/readiness, stage, owner, dependency/blocker, evidence/proof target, and disposition; minimize labels with no machine/user consumer. | A default; B current ad hoc labels; C project fields; D generated metadata. | PRODUCT-005-007 | E07 | field set |
| BKL-006 | P1 / should-decide | What milestones or waves should exist? | One reboot/Stage-0 milestone, then one milestone per proof stage with explicit entry/exit gates; do not calendar future stages as commitments. | A default; B quarterly roadmap; C four-project milestone; D no milestones. | PRODUCT-006-007 | E01, E07 | choose structure |
| BKL-007 | P1 / should-decide | How are dependencies represented and validated? | Typed blocking/consuming links plus contract/version and evidence prerequisite; router fails closed on missing or stale dependency proof. | A default; B issue text; C project board order; D root planner state. | PRODUCT-005-007; ARCH-021 | E01, E07 | approve contract |
| BKL-008 | P1 / should-decide | What must every issue contain before selection? | User/outcome problem, scope/non-goals, acceptance tests, affected contracts/paths, risk/change class, dependencies, evidence/proof target, owner, review/deploy/rollback needs. | A default; B current template; C brief issue plus lane contract; D agent expands later. | PRODUCT-004-007 | E06-E07 | approve template |
| BKL-009 | P1 / should-decide | What closes an issue? | Its accepted outcome/terminal class is proven and PR/deployment/evidence links are exact; superseded/duplicate/no-longer-wanted issues close with reason and successor. | A default; B merged PR; C maintainer choice; D automated state. | PRODUCT-005, PRODUCT-009 | E01, E06 | closure matrix |
| BKL-010 | P1 / should-decide | How are newly discovered gaps handled during a lane? | Create/update owning-repo issue with evidence, relate it, and continue only if current contract/safety is unaffected; no hidden scope expansion. | A default; B fix opportunistically; C lane blocks always; D private notes. | PRODUCT-005-007 | E06 | approve flow |
| BKL-011 | P2 / can-defer | How often is strategy/backlog reconciled? | Reconcile at stage/outcome closure and material evidence change; derive any calendar backstop from RBT-014 and observed drift, not an unsupported monthly default. | A event-driven; B owner-supplied calendar; C every sprint; D on request. | PRODUCT-006-007 | E01, E07 | cadence/triggers + basis |

The following ballot covers every open Verdify Skills issue as of 2026-07-11.
The decision is about problem disposition; accepted changes must still be
applied in GitHub with current evidence and issue-template discipline.

| ID | Live issue | Priority | Proposed disposition | Choices and consequence | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- |
| ISS-012 | #12 capability negotiation/dispatch | P0 | KEEP/REFRAME as Stage-0 truthful provider capability, unsupported-operation, and conformance work; do not promise dynamic worktrees. | K current; R default; M platform issue; C close; D defer | E01, E07, E10 | K/R/M/C/D + scope |
| ISS-043 | #43 bounded agentic-loop contract | P0 | REFRAME into the minimal kernel retry/wait/cancel/idempotency/crash-resume contract and executable fault matrix. | K broad; R default; M controller refactor; C; D | E01, E07, E10 | disposition |
| ISS-054 | #54 deferred hardening coordination | P1 | AUDIT every deferred item, move surviving problems to precise issues, then close the umbrella; do not preserve an unbounded coordination bucket. | A default; K umbrella; M Stage 0; C now; D | E07 | disposition/items |
| ISS-070 | #70 change class/fast path | P0 | KEEP/REFRAME as deterministic lightweight/standard/protected risk policy with denied-risk tests and approval before activation. | K current; R default; M router; C; D | E01, E07 | disposition |
| ISS-073 | #73 vacuous critic approval | P0 | KEEP as immediate fail-closed safety defect; require criterion coverage and negative tests before autonomous lanes. | K default; M critic refactor; C; D | E01, E07, E09 | disposition |
| ISS-074 | #74 semantic/eval consumer CI | P0 | KEEP; split trusted semantic/effect validator and consumer CI contract only if ownership differs. | K default; S split; M #75; C; D | E01, E07, E09 | disposition |
| ISS-075 | #75 executable eval runner | P0 | KEEP and align to the comparative program in EVL-005..020; avoid building an unmeasured framework. | K default; M #74; R smaller runner; C; D | E01, E07, E09 | disposition |
| ISS-076 | #76 simplify/park surface | P0 | REFRAME from arbitrary counts to evidence-led freeze/disposition using user story, consumer, test, co-invocation, cost, and proof criteria. | K count target; R default; C after matrix; D | E01, E07 | disposition |
| ISS-098 | #98 five chief-of-staff skills | P0 | MOVE/REFRAME as Orbit-owned optional experience or one thin facade; do not add five mandatory lifecycle nodes now. | K in Skills; M one facade; move Orbit; C; D | E01-E03, E07, E11 | disposition |
| ISS-116 | #116 one SDLC/fleet rollout | P0 | REFRAME around the accepted small canonical transaction and staged proof; remove four-project/fleet rollout assumptions until gates pass. | K current; R default; split kernel/rollout; C; D | E01, E07 | disposition |
| ISS-117 | #117 delegation/lock authority | P0 | KEEP/REFRAME to role-based owner-local authority, delegation limits, vetoes, expiry, evidence, and separate lock/release/effect powers. | K default; M governance; C; D | E05-E07 | disposition |
| ISS-174 | #174 timeline historian digest/asset IDs | P1 | KEEP as bounded domain-skill correctness defect if the skill has an active consumer; otherwise move with the domain skill before fixing. | K; move; M domain backlog; C; D | E07, E09 | disposition + consumer |
| ISS-211 | #211 four-project strategy | P0 | REFRAME as iteration-26 reboot strategy and proof sequence; four-project autonomy becomes a gated hypothesis, not the assumed first plan. | K current; R default; replace issue; C; D | E01, E07, E12 | disposition |
| ISS-225 | #225 lifecycle phases in criteria | P1 | DEFER implementation until KRN-005..006 and critic reproducer decide whether a simpler owner/coverage field works; preserve the observed problem. | K schema now; R smaller fix; D default; C | E01, E07, E09 | disposition |

### Repository And Architecture Refactor

Applies after the product/architecture shape and proof sequence are accepted.
Skill/issue dispositions and refactor rows are reconciled together.

| ID | Priority / class | Decision and context | Proposed default | Options / tradeoffs | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| REF-002 | P0 / must-decide | Freeze new skills, modes, schemas, and platform surfaces during the reboot? | Yes except mandatory security/consumer work or an observed failure that passes the admission test. | A hard freeze; B default review gate; C normal work; D immediate broad deletion. | PRODUCT-006-007; ARCH-004 | E01, E07 | choose/exception owner |
| REF-003 | P0 / must-decide | Should Skills, kernel/CLI, schemas, adapters, and domain skills remain one repo/package? | Keep one repository during proof with explicit internal module contracts; split domain packages/plugins first if independent owners/releases/consumers exist. | A default; B core+skills packages; C contracts SDK+content; D services; E monorepo suite. | PRODUCT-013; ARCH-004-006 | E01-E03 | topology/trigger |
| REF-004 | P0 / must-decide | What is the target module boundary? | Policy/kernel, lifecycle skill content, schemas/contracts, provider adapters, evaluation fixtures/runner, and domain extensions with one-way dependencies. | A default; B current folders; C service architecture; D one CLI monolith. | ARCH-004-006 | E01, E03 | approve dependency graph |
| REF-005 | P0 / must-decide | How are 101 modes reduced or hidden? | Expose human intents; retain internal modes only with unique machine behavior/contract/test; merge aliases and delete orphan modes after consumer scan. | A default; B arbitrary target count; C keep all; D one command. | PRODUCT-008; ARCH-004; issue #76 | E01 | approve rule |
| REF-006 | P0 / must-decide | How are 49 schemas reduced or retained? | Inventory machine consumers/boundaries, merge envelopes where semantics align, remove human-only/orphan schemas, and add effect/semantic tests before deleting. | A default; B keep all; C one generic schema; D rewrite database. | ARCH-004, ARCH-006; issue #76 | E01, E09 | approve audit |
| REF-007 | P1 / should-decide | What is the migration order inside the repository? | Lock behavior/eval fixtures, fix fail-open defects, introduce compact kernel/contracts, migrate one canary path, compare outputs, remove replaced surfaces, then update docs/links. | A default; B clean rewrite; C docs first; D delete first. | All source/artifacts | E01, E09 | approve/order |
| REF-008 | P1 / should-decide | Implement RBT-012's refactor/migration axis as a strategy cutover with consumer map, canary, rollback, convergence, and history preservation. | Use the accepted cutover/compatibility posture; do not choose flag-day versus dual-run again. | No independent cutover option; migration projection or root-conflict flag. | PRODUCT-013; ARCH-006, ARCH-009 | E01, E05, E08 | cutover projection |
| REF-009 | P1 / should-decide | Apply RBT-012's compatibility/adoption rule to consumer classes and versions. | Define deprecation/support mechanics from the root matrix without selecting another promise. | No independent compatibility option; consumer projection or root-conflict flag. | PRODUCT-013; ARCH-006; locked default 4 | E01, E05 | compatibility projection |
| REF-010 | P1 / should-decide | Keep npm packaging and Ruby CLI? | Yes until measured distribution/runtime needs justify standalone binary, OCI, SDK, or service; first fix host-path safety. | A default; B binary; C OCI; D TypeScript; E hosted API. | PRODUCT-008, PRODUCT-013; ARCH-004 | E01, E08-E09 | choice/trigger |
| REF-011 | P1 / should-decide | How is generated documentation/config kept synchronized? | One canonical machine source generates host links/catalog/reference tables; validation detects drift, while user narrative remains hand-owned. | A default; B hand-maintained; C generate everything; D external docs. | PRODUCT-008; ARCH-004 | E08-E09 | choose sources |
| REF-012 | P1 / should-decide | How is dead code/artifact removal proven safe? | Search declared and observed consumers, run exact package/install and repo fixtures, canary migration/uninstall, publish deprecation evidence if required, and retain rollback artifact. | A default; B tests green; C owner judgment; D never delete. | PRODUCT-013; ARCH-009 | E01, E08-E09 | approve checklist |
| REF-013 | P1 / should-decide | What architecture build-versus-buy record is mandatory? | For each subsystem record mature alternatives, missing Verdify semantics, operational owner, security/cost burden, exit cost, and adoption/rejection evidence. | A default; B informal ADR; C architecture board; D no register. | ARCH-010, ARCH-013 | E01 | approve fields |
| REF-014 | P1 / should-decide | Which current surfaces should be removed first if defaults hold? | Unsupported dynamic dispatch, vacuous review, duplicated broad projections, user-facing mode sprawl, unexercised consensus/platform facades, and unsafe installer behavior—after exact consumer/failure audit. | A default; B no deletion; C rank custom; D rewrite all. | PRODUCT-008; ARCH-004, ARCH-013, ARCH-021 | E01, E09-E10 | rank candidates |
| REF-015 | P1 / should-decide | How is refactor success measured? | Smaller mandatory surface and operator burden with equal/better representative outcomes, safety, recovery, install compatibility, and maintainability; line/schema counts alone do not decide. | A default; B code reduction; C test pass; D delivery speed. | PRODUCT-009; ARCH-001 | E01 | metrics/thresholds |

### Priority, Sequencing, Capacity, Release, And Lock

Applies after RBT-010, RBT-011, RBT-014, and EVL-014..017. These stage gates
precede and constrain BKL/ISS/REF/SKL mapping.

| ID | Priority / class | Decision and context | Proposed default | Options / tradeoffs | Affected IDs | Evidence | Answer shape |
| --- | --- | --- | --- | --- | --- | --- | --- |
| SEQ-002 | P0 / must-decide | What exactly is Stage 0, the truth/security floor? | Installer preservation; non-vacuous critic; lossless identities; diff-to-contract scope; truthful provider capabilities; terminal handoff/resume/idempotency; Platform security/RBAC/kube truth. | A default; B Skills subset if Platform is out of scope; C platform first; D a typed exception may only disable/narrow the affected path or use a separate protected gate with owner, compensating controls, expiry, rollback, and evidence—it cannot waive the safety floor or named security P0s. | PRODUCT-006-007; ARCH-007-009 | E01, E09-E10 | blocker/parallel/defer |
| SEQ-003 | P0 / must-decide | What is Stage 1, measurable behavior? | Executable trusted runner, with/without baseline, routing negatives, semantic/effect checks, and versioned results for the critical hot path. | A default; B full 77 cases; C production telemetry; D defer until implementation. | PRODUCT-009; issues #74-75 | E01, E09 | approve exit gate |
| SEQ-004 | P0 / must-decide | What is Stage 2, single-repository proof? | One real non-runtime Skills issue through complete lane, crash/effect fault injection, exact review, release/consumer probe if applicable, accepted outcome, and later re-probe. | A default; B synthetic only; C customer issue; D multiple lanes. | PRODUCT-006-009; ARCH-009 | E01, E08-E10 | name task/exit |
| SEQ-005 | P0 / must-decide | What is Stage 3, runtime-changing proof? | One disposable environment and GitOps lane with build/digest, preview/probe, authorized deploy, regression, rollback, restart, delayed durability, and outcome acceptance. | A default; B platform dispatch only; C production first; D skip runtime. | PRODUCT-006-009; ARCH-005, ARCH-009 | E01, E10 | choose repo/task |
| SEQ-006 | P0 / must-decide | What is Stage 4, narrow cross-project proof? | One consumer-provider transaction, preferably cited Gravity read or Platform dispatch, proving identity/version/capability/denial/idempotency/recovery without root state duplication. | A default; B Orbit connector; C Platform only; D skip to four. | PRODUCT-014; ARCH-014, ARCH-017, ARCH-021 | E01, E10-E11 | choose dependency |
| SEQ-007 | P0 / must-decide | When is Stage 5, the four-project slice, allowed? | Only after Stages 0-4 pass, relevant security/readiness P0s close, each project owns an accepted issue/contract, and one bounded portfolio outcome has rollback/stop authority. | A default; B first milestone; C never needed; D replace with customer. | PRODUCT-014; ARCH-021; issue #211 | E01, E07, E10-E11 | approve entry gate |
| SEQ-008 | P1 / should-decide | What is Stage 6, consulting/customer reuse? | One design partner uses the proven profile on customer-owned authority, with tenancy/data/exit contract and comparative outcome evidence; bespoke gaps stay explicit. | A default; B before four-project; C internal only; D public rollout. | PRODUCT-006-009, PRODUCT-013 | E01 | choose entry gate |
| SEQ-009 | P1 / should-decide | Apply RBT-011's maximum concurrency/strategic-bet envelope to the accepted RBT-010 stages. | Allocate parallel research, fixes, implementation, and review only within root caps/dependencies. | No independent concurrency option; stage allocation or root-conflict flag. | PRODUCT-006-007; ARCH-020-021 | E01, E06 | concurrency projection |
| SEQ-010 | P1 / should-decide | Allocate RBT-011's named owners, agent slots, and spend to each accepted stage. | Preserve root capacity/opportunity-cost choices and identify unstaffed gates. | No independent budget option; stage allocation or root-conflict flag. | PRODUCT-002, PRODUCT-006-007 | E01, E12 | capacity projection |
| SEQ-011 | P1 / should-decide | What release cadence applies during refactor? | Release only coherent exact-artifact safety/value increments; no calendar pressure bypasses gates; canary consumers precede broad fleet convergence. | A default; B weekly; C one big v2; D continuous. | PRODUCT-006-007; ARCH-009 | E08-E09 | choose cadence |
| SEQ-012 | P1 / should-decide | How are stage failures handled? | Fix within bounded iteration, narrow the hypothesis, change provider/design with recorded evidence, or stop; never declare the next stage while exit evidence is missing. | A default; B timebox then proceed; C owner exception; D restart full plan. | PRODUCT-006-009 | E01 | choose decision tree |
| SEQ-013 | P1 / should-decide | Project RBT-014's horizon/review/stop rule onto each accepted stage and dependency. | Preserve root dates/cadence/funded attempts and show only stage-specific checkpoints. | No independent horizon option; schedule projection or root-conflict flag. | PRODUCT-006-007 | E01, E12 | horizon projection |
| SEQ-014 | P0 / must-decide | What locks the rewritten North Star? | Root/conditional answers captured as evidence, contradictions resolved, paired artifacts and backlog change map reviewed adversarially, then one explicit authorized final-lock statement. | A default; B answers imply lock; C consensus vote; D immediate owner edit. | All North Star artifacts/gate | E04-E06 | approve process |
| SEQ-015 | P0 / must-decide | What must be in the lock packet? | Product/architecture diffs, accepted/rejected/deferred decision ledger, proof/metric plan, project/authority map, risk/security disposition, issue/refactor/migration sequence, owners/budget, and remaining human gates. | A default; B paired docs only; C summary deck; D GitHub roadmap. | All North Star artifacts | E04-E06 | approve fields |
| SEQ-016 | P0 / must-decide | What is the fallback if the platform thesis fails? | Preserve a portable validated skills/assurance library and consulting method; retire unproven runtime/portfolio machinery while keeping evidence/history. | A default; B continue platform; C OSS library; D services only; E shut down. | PRODUCT-001, PRODUCT-013-014 | E01 | choose fallback |

## Decisions Ready For Human Review

Only the 14 root rows (RBT-001..015 excluding reserved RBT-006) are ready for
the human first round. After those answers, the planning loop must emit a
branch-pruned second-round packet. Conditional P0s
become blocking only if selected; P1 items become contract/backlog or delegated
research inputs; P2 items may be deferred with owner, trigger, and review date.

The highest-leverage answers are:

1. RBT-001..005: current authority, product, customer, portfolio, and owned
   boundary.
2. The safety floor plus RBT-007..009: autonomy/governance, value/proof, and
   business posture.
3. RBT-010..015: proof sequence, capacity/opportunity cost, refactor/backlog
   posture, authority, horizon/stop, and final lock.
4. The generated conditional packet—not this full bank.
5. Only after the sequence is accepted: the skill and issue disposition
   ballots.

## Expected Change Map After Answers

The planning loop should produce a traceable row for every accepted answer:

| Field | Required content |
| --- | --- |
| Decision ID | Interview ID and exact answer/evidence item |
| Current authority | Product/architecture/plan/gate/issue/contract IDs being superseded or retained |
| New requirement | Canonical product or architecture statement |
| Non-goal | Explicit excluded behavior or ownership |
| Project owner | Repository and accountable human/role |
| Contract/artifact action | Keep, add, modify, merge, migrate, or delete |
| Backlog action | Existing issue update/close/merge or new issue after duplicate search |
| Proof | Test, metric, operational drill, and required proof level |
| Sequence | Stage, dependencies, entry/exit gate |
| Migration/rollback | Consumer inventory, cutover, compatibility, and rollback |
| Reconsideration | Trigger, owner, and review date for assumptions/deferred choices |

## Answer Capture Rules

- Preserve the owner's answers verbatim as registered review-feedback evidence.
- Route accepted answers through northstar-planning / review-feedback or
  artifact-loop; do not edit protected paired North Stars directly from this
  packet.
- Apply backlog changes in GitHub, never as a private Markdown substitute.
- Preserve iteration 25 and all prior evidence as history. Iteration 26 must
  explicitly name what it supersedes, retains, defers, and rejects.
- Do not infer an answer from a proposed default, silence, prior approval, or
  an apparently compatible answer to another question.
- An applicable P0 may not remain deferred at final lock. Resolve it, complete
  its research exit criterion, or narrow the root scope so the branch is
  explicitly retired. P1/P2 deferrals require owner, evidence, trigger, and
  review date.
- Protected product, architecture, security, privacy, production, destructive,
  public-interface, material-cost, and exception decisions follow the authority
  matrix and remain human-gated.
- Answers authorize planning changes only. They do not authorize code,
  infrastructure, release, deployment, external messaging, issue mutation, or
  destructive migration unless separately requested and gated.
- Never store raw secrets, private customer/personal content, or exploit-ready
  detail in answer evidence; use protected references and sanitized summaries.
- Final lock approval is separate and explicit; interview completion is never
  treated as approval.
- After synthesis, rerun routing. Architecture contracts, state-of-union,
  backlog reconciliation, repo hygiene/readiness, and sprint planning must
  consume the new approved authority in that order only where their
  prerequisites apply.
