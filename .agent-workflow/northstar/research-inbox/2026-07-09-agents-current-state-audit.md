# Agents Current-State Audit — 2026-07-09

Evidence status: verified or observed where stated. This is a point-in-time read-only audit of `jvallery/agents` repository, GitHub, and safe live-state surfaces.

## Current truth

- Canonical `main`: `7bc69090126e7cc6c244c4c0b499b55a2cd96c0d`.
- GitHub had 122 open issues and two open draft pull requests at the audit time.
- Runtime had 38 of 38 repo StatefulSets Ready and the dashboard Ready, but Argo was only 42 of 56 Synced and 48 of 56 Healthy.
- The Agents pod was Running and Ready, but its checkout was 119 commits behind its already stale in-pod `origin/main` and reported Verdify `1.0.0`.
- Agents, Orbit, and Gravity loops had fresh heartbeats but six consecutive failed headless iterations. Agents and Gravity were blocked on weekly model quota; Orbit had invalidated Codex authentication.
- The live Agents MCP surface exposed `add_worktree_agent`, `list_agents`, `remove_worktree_agent`, `request_argocd_refresh`, `scoped_kubectl`, and `probe_secret`. It did not expose the proposed `task_worker` or a root-planner capability and task contract.

## North Star conflict

- The locked Agents North Star names Orbit as the outer-loop conductor and treats Gravity as the pilot cell rather than one of four co-equal pilots.
- The accepted July 9 direction assigns cross-project outer-loop planning to the root planner, keeps Verdify Skills as the shared method and agent layer, and gives each of Skills, Agents, Orbit, and Gravity its own product authority and pilot outcome.
- This conflict is architecture-significant and requires an Agents North Star review-feedback iteration and Jason re-lock rather than a correction-ledger-only change.

## Existing issue coverage

- One SDLC: agents #2803 and Verdify Skills #116.
- Root-planner control and fixed-worker task dispatch: agents #655 and #2497.
- Callback-token completeness: agents #1762.
- Repository checkout and Verdify runtime freshness: agents #2817 and #2819.
- Executor authentication and quota: agents #2491, #2859, and #2802.
- Health, loop, Argo, and session truth: agents #2840, #2886, #2888, and #2598.
- Validation and merge enforcement: agents #2693, #2720, #2026, #2885, and #2889.
- Security floor: agents #2884, #2887, #2601, and #2605.
- Gravity search ownership: agents #2336.

## New issue

- `jvallery/agents#2890`: reframe Agents as a co-equal pilot under the root-planner outer loop.

## Planning implications

- Define a common `PilotProject` contract with revision, lifecycle state, capabilities, supported operation versions, authorized task submission, gates, result/evidence references, runtime/deployment health, tenancy, identity, idempotency, audit, and failure state.
- Agent Platform may provide shared runtime, CI, GitOps, observability, and session capabilities, but it must not own the product North Stars of the other pilots.
- Current Agents planning artifacts cannot authorize a new sprint until its North Star, project definition, architecture, contracts, state-of-union, and router are reconciled.

## Limitations

- Unsafe security probes were not repeated.
- Live facts can drift and must be reverified at implementation or release gates.
- This audit did not edit Agents source or runtime state.
