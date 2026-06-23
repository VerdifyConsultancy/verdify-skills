# OpenGitOps Session Shortlist

Date: 2026-06-23
Discovery method: Brave Search API, followed by source URL checks where available.
Status: researched for North Star evidence ingest.

## Scope

This supplements `2026-06-23-opengitops-events-session-specificity.md` with a
concrete shortlist of session/event references. It does not claim that any talk
has been watched, transcribed, or used as architecture evidence yet.

## Brave Search Coverage

- `site:events.linuxfoundation.org OpenGitOps EU recordings`
- `GitOpsCon North America 2024 YouTube Argo CD ApplicationSet`
- `GitOpsCon North America 2024 YouTube Flux multi tenancy`
- `GitOpsCon Europe 2023 YouTube Argo CD progressive delivery`
- `GitOpsCon Europe 2023 YouTube Flux Argo`
- `site:events.linuxfoundation.org/kubecon-cloudnativecon-europe/program/ GitOpsCon Europe 2024 schedule`

## Event And Recording Anchors

- GitOpsCon North America 2024 YouTube playlist: https://www.youtube.com/playlist?list=PLj6h78yzYM2OyAZIMbJPOsamT2aLKZX6b
- GitOpsCon North America 2024 Schedule & Directory: https://gitopsconna2024.sched.com/
- GitOpsCon North America LF event page: https://events.linuxfoundation.org/gitopscon-north-america/
- GitOpsCon North America 2024 CNCF report: https://www.cncf.io/reports/gitopscon-north-america-2024/
- GitOpsCon Europe 2023 Schedule & Directory: https://gitopsconeu2023.sched.com/
- GitOpsCon Europe LF event page: https://events.linuxfoundation.org/gitopscon-europe/
- cdCon+GitOpsCon 2023 Schedule & Directory: https://cdcongitopscon2023.sched.com/
- GitOpsCon Europe 2022 schedule archive: https://events.linuxfoundation.org/archive/2022/gitopscon-europe/program/schedule/
- Flux at GitOpsCon/KubeCon EU 2022 YouTube playlist: https://www.youtube.com/playlist?list=PLwjBY07V76p53FP85y03psCnb95u095Do

## Candidate Session Topics Found

- `Extending Argo CD with Health Checks and Resource Actions` - Gerald Nunn, Red Hat. Discovered on the GitOpsCon North America 2024 schedule.
- `What's New with Flux?` - discovered on the GitOpsCon North America 2024 schedule.
- `Kubernetes as a Platform Framework: Journey from IaC Pipelines to K8s APIs` - Christina Andonov, AWS. Discovered on the GitOpsCon North America 2024 schedule.
- `GitOps at Production Scale with Flux` - discovered on the KubeCon + CloudNativeCon North America 2024 Sched result.
- `Dynamic 5G Core Infrastructure with FluxCD Terraform Controller` - David Blaisonneau, Orange. Discovered on the GitOpsCon Europe 2023 schedule.
- `Empowering Developer Productivity: A Deep Dive Into ArgoCD and Botkube Integration` - discovered on the GitOpsCon Europe 2023 schedule.
- `Two GitOps Titans, One Powerful Solution` - Flux/Argo CD combination discussed in CNCF coverage of GitOpsCon Europe 2023.
- `GitOps: Unlocking the Power of Kubernetes Cluster Management` - Praseeda Sathaye and Valentin Widmer, AWS. Discovered on the GitOpsCon Europe 2023 schedule.
- `Terraforming ArgoCD: The GitOps Bridge` - discovered on the cdCon+GitOpsCon 2023 schedule.
- `A Quantitative Study on Argo Scalability` - Andrew Anderson and Jun Duan, IBM. Discovered on the cdCon+GitOpsCon 2023 schedule.
- `Adopting CDEvents and Embracing Interoperability` - Andrea Frittoli, IBM. Discovered on the cdCon+GitOpsCon 2023 schedule.
- `GitOps and Progressive Delivery with Flagger, Istio and Flux` - Marco Amador, Anova. Discovered on the GitOpsCon Europe 2022 schedule archive.

## Source-Backed Findings

- Official LF/OpenGitOps/CNCF/Sched pages and YouTube playlists can anchor a session-level research queue for GitOps operations, Argo CD, Flux, progressive delivery, platform APIs, and interoperability.
- The shortlisted sessions are candidates for future claim extraction; they should not be cited as proof of a specific architecture requirement until a later pass watches or reads the talk material and records exact claims.
- For the current North Star, stronger non-video primary documentation already exists for concrete requirements: Argo CD ApplicationSet, Argo sync waves, Argo Rollouts, Flux repository structure, OpenGitOps principles, GitHub deployment reviews, and Kubernetes RBAC/multi-tenancy.

## Planning Relevance

- Resolves the research-queue gap from "official event hubs only" to a concrete session shortlist.
- Supports future deeper research for `wave-release-planning`, `platform-readiness`, `review-inbox`, and `environment-gitops` without treating videos as already-verified architecture evidence.

## Limitations

- This pass did not watch videos or extract timestamped claims.
- Some Sched pages are dynamic and may change; session titles should be rechecked before use in an approval packet.
