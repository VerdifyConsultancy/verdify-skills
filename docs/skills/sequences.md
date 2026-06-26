# End-to-end sequences

Mermaid sequence diagrams for the main flows. Each participant is a skill (or
GitHub / Agent Platform / human). For per-skill detail see [`per-skill/`](per-skill/).

## 1. Intake → North Star lock

How conversational and research input becomes locked planning authority. Ordinary
questions restart the loop; only the final lock is a human gate.

```mermaid
sequenceDiagram
    participant H as Human
    participant TR as transcript-replan
    participant RI as northstar-research-ingest
    participant NP as northstar-planning
    participant NI as northstar-interview
    participant NQ as northstar-question-resolution
    H->>TR: walk transcript / meeting notes
    TR->>TR: route proposals + flag conflicts (proposed-only)
    TR->>RI: source evidence to register
    RI->>RI: hash + copy + register (evidence registry)
    RI->>NP: queryable evidence
    NP->>NP: synthesize product + architecture drafts
    NP->>NQ: large question corpus
    NQ-->>NP: delegated answers + escalation pack
    NP->>NI: review-ready drafts
    NI-->>H: prioritized Q&A (no approval)
    H-->>NP: answers / feedback
    NP->>H: request final lock approval
    H-->>NP: lock NORTHSTAR_PRODUCT + ARCHITECTURE
```

## 2. Plan → execute → verify → review (the delivery heart)

From approved strategy to a verified, accepted wave. CI green is necessary but not
sufficient: a fresh critic and review evidence gate integration.

```mermaid
sequenceDiagram
    participant SU as state-of-union
    participant SP as sprint-planning
    participant H as Human
    participant SO as sprint-orchestrator
    participant CL as controller-loop
    participant AP as Agent Platform
    participant LD as lane-delivery
    participant IC as independent-critic
    participant RV as release-verification
    SU->>SP: candidate issues + strategy
    SP->>SP: lanes, contracts, wave release plan
    SP->>H: plan-approval gate
    H-->>SP: approve
    SP->>SO: approved sprint
    SO->>CL: register sprint + sessions
    loop each ready lane
        SO->>AP: dispatch one worker (add_worktree_agent)
        AP-->>LD: worker session
        LD->>LD: implement owned paths, validate, open PR
        LD->>IC: closeout (ready_for_critic)
        IC-->>SO: approve / request fixes
    end
    SO->>RV: all lanes approved
    RV->>RV: review packet + deploy verification
    RV-->>H: review-ready evidence + outcome
    H-->>RV: accept outcome
    RV->>SU: cycle continues
```

## 3. Fix-forward after critic findings

A rejected lane re-enters delivery under a new sequential lease — never the same
active worker session.

```mermaid
sequenceDiagram
    participant IC as independent-critic
    participant SO as sprint-orchestrator
    participant CL as controller-loop
    participant LD as lane-delivery (new lease)
    IC-->>SO: request_fixes (cited findings)
    SO->>CL: record changes-requested
    SO->>LD: release prior lease (--keep-worktree), new session-id
    LD->>LD: address only cited findings + rerun validation
    LD->>IC: updated closeout for fresh review
```

## 4. Controller recovery

A controller pod/session restart reconstructs from durable artifacts, not chat history.

```mermaid
sequenceDiagram
    participant New as new controller session
    participant Art as .agent-workflow (controller-state + session-ledger)
    participant GH as GitHub
    New->>Art: read controller-state + session-ledger
    New->>GH: reconcile issue/PR/check/deployment state
    New->>New: rebuild active leases, open gates, pending PRs
    New->>New: resume from generated prompt (trusted refs)
```

## 5. Router cycle

`project-router` is the entrypoint and the return point after every handoff.

```mermaid
flowchart LR
    R[project-router] --> N["next skill + mode<br/>(route-decision)"]
    N --> W[skill does its bounded work]
    W --> A["durable .agent-workflow artifact"]
    A --> R
```
