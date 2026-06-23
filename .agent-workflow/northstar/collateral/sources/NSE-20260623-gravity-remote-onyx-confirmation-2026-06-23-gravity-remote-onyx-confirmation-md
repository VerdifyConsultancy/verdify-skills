# Gravity Remote And Onyx Confirmation

Date: 2026-06-23
Evidence status: observed read-only Git, GitHub, Kubernetes, and Argo CD state.

## Scope

This note closes the research-queue gap for Gravity remote state and the Onyx
dependency question. It records read-only checks only. No raw secrets, pod exec,
or production mutation were used.

## Commands And Sources Inspected

- `git -C /Users/jason/repos/gravity fetch origin --prune`
- `git -C /Users/jason/repos/verdify-gravity fetch origin --prune`
- `git -C /Users/jason/repos/gravity grep -n -i onyx origin/main origin/planning`
- `git -C /Users/jason/repos/verdify-gravity grep -n -i onyx origin/main`
- `gh issue list --repo VerdifyConsultancy/gravity --state all --search onyx`
- `gh pr list --repo VerdifyConsultancy/gravity --state all --search onyx`
- `gh issue list --repo VerdifyConsultancy/verdify-gravity --state all --search onyx`
- `gh pr list --repo VerdifyConsultancy/verdify-gravity --state all --search onyx`
- `gh issue view 487 --repo jvallery/agents`
- `gh pr view 554 --repo jvallery/agents`
- `kubectl get applications.argoproj.io -n argocd`

## Observed Claims

- `/Users/jason/repos/gravity` is behind remote: local `HEAD` is `563446c`, while `origin/main` is `744b813`; the local branch reports `main...origin/main [behind 4]`.
- `/Users/jason/repos/verdify-gravity` is behind remote: local `HEAD` is `3f834d5`, while `origin/main` is `a0675d8`; the local branch reports `main...origin/main [behind 3]`.
- `VerdifyConsultancy/gravity` `origin/main` and `origin/planning` only show an `Onyx` match in a raw pasted transcript; no direct active dependency was observed in the searched remote code/docs.
- `VerdifyConsultancy/verdify-gravity` `origin/main` contains explicit Onyx boundary material. `docs/operations/PRODUCT_OWNERSHIP_DECISION.md` states that Gravity is a document-pipeline proof point, is not the memory compiler, does not depend on Onyx ingestion, and has no Onyx ingestion enabled.
- `docs/system-updates/onyx-vault-boundary-2026-06-08.md` says `gravity.onyx.vallery.net` is a planned/gated Onyx project vault, not an activated Gravity deployment or Gravity source of truth.
- Current GitHub searches returned 0 Onyx-matching issues and 0 Onyx-matching PRs in both `VerdifyConsultancy/gravity` and `VerdifyConsultancy/verdify-gravity`.
- The historical `jvallery/agents#487` Onyx epic is closed and marked deferred/post-MVP/archived pre-MVP replan. PR `jvallery/agents#554` merged Onyx replan documentation on 2026-06-08.
- Current Argo CD state shows Onyx Applications (`onyx-local-staging`, `onyx-jason-local-staging`, prerequisites, and secrets) exist and are mostly `Synced/Healthy`, with `onyx-jason-prereqs-local-staging` `Synced/Progressing` and `onyx-jason-secrets-local-staging` `OutOfSync/Healthy`.
- The prior doc reference to `VerdifyConsultancy/verdify_gravity#2` is stale as a current issue pointer: current `VerdifyConsultancy/verdify-gravity#2` is `[Epic E2] File discovery and metadata`, not the old ownership/Onyx decision.

## Planning Relevance

- Supports resolving the North Star Onyx question as: Gravity does not currently depend on Onyx ingestion for the MVP; Onyx remains a separate planned/gated vault/search front door and post-MVP/control-plane concern.
- Supports keeping Gravity implementation blocked on `platform-readiness` and `gravity-readiness`, not on an unresolved direct Onyx dependency.
- Adds a follow-up hygiene item: update stale Onyx/Gravity issue references in `verdify-gravity` docs before using them as authoritative handoff links.

## Limitations

- This was not a full Gravity readiness audit.
- No Gravity app runtime endpoints, database state, S3 state, pod logs, or Onyx connector settings were inspected.
- GitHub search validates current issue/PR text only through GitHub search behavior; it does not prove no archived discussion mentions Onyx elsewhere.
