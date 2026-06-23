# OpenGitOps Event And Session Specificity

Date: 2026-06-23
Discovery method: Brave Search API, followed by direct URL reachability checks.
Status: researched for North Star evidence ingest.

## Brave Search Coverage

- Query: `OpenGitOps events conference talks GitOps sessions Argo Flux progressive delivery`
- Follow-up query: `OpenGitOps events GitOpsCon ArgoCon official`.
- Selection rule: prefer OpenGitOps event pages and Linux Foundation or project event references when discoverable.

## Primary Sources Followed

- OpenGitOps events index: https://opengitops.dev/events/
- OpenGitOps home page with events links: https://opengitops.dev/
- GitOpsCon North America 2021 OpenGitOps blog: http://opengitops.dev/blog/gitopscon-na-2021/
- GitOpsCon Europe 2023 OpenGitOps blog: http://opengitops.dev/blog/gitopscon-eu-2023/
- GitOps Days 2022 OpenGitOps blog: http://opengitops.dev/blog/gitops-days-2022/

## Source-Backed Findings

- OpenGitOps maintains an events index that links to GitOpsCon, ArgoCon, OpenGitOps, and related recordings, making it the right primary starting point for talk-level GitOps evidence.
- The OpenGitOps event history includes GitOpsCon and ArgoCon entries that are directly relevant to reconciled delivery, GitOps operating models, Argo CD, Flux, and progressive delivery planning.
- The OpenGitOps event pages provide better provenance for talk discovery than generic search snippets, but they do not by themselves prove that a specific talk supports a specific Verdify architecture claim.
- North Star evidence should cite individual talk recordings only after a follow-up pass verifies the session title, speaker/source, recording URL, and the exact claim being used.

## Planning Relevance

- Supports keeping OpenGitOps event/session specificity as a research sub-queue rather than treating broad GitOps event pages as final architecture evidence.
- Supports future platform-readiness and wave-release-planning evidence that can cite specific ArgoCon/GitOpsCon sessions about ApplicationSet, progressive delivery, multi-tenancy, or production GitOps operations.

## Limitations

- This pass did not watch or transcribe individual recordings.
- This pass found event indexes and blog posts, not a fully verified shortlist of session-level claims.
