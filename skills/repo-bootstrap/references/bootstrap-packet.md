# Bootstrap Packet Reference

Use this reference when creating or reviewing a repo-bootstrap packet.

## Composition Rules

- `project-router` remains the entrypoint. Bootstrap may recommend a route but
  must not silently perform the recommended next lifecycle skill.
- `repo-hygiene` owns repository safety, source-of-truth drift, CI/test
  readiness, GitHub state observations, and repo-agent scope inputs.
- `platform-readiness` owns platform, namespace, RBAC, route, storage,
  observability, runtime-image package, and credential-reference readiness.
- `northstar-planning` owns unresolved product, architecture, KPI, milestone,
  and research-backed planning synthesis before downstream lock.
- `controller-loop` owns durable controller state, session-ledger events, and
  handoff evidence when a repo controller is initialized.

## Required Sections

1. Inputs: repository path, GitHub repository, baseline SHA, issue refs, and
   live-runtime access level.
2. Repo inventory: purpose, languages, important paths, docs, Git, GitHub,
   CI/CD, planning artifacts, and risks.
3. Runtime inventory: namespaces, pods, routes, storage mounts, observability,
   runtime-image packages, and missing access.
4. Credential-reference inventory: locations, auth modes, scopes, owners,
   validation status, and failure modes only.
5. `AGENTS.md` delta: no-op, proposed, applied, or blocked status with patch
   reference when a local change exists.
6. KPI proposal: target, measurement source, cadence, and owner for each KPI.
7. Gap backlog: issue-ready gaps with severity, source, owner, and GitHub refs.
8. Route recommendation: exactly one next skill and mode with evidence.
9. Open questions: namespace naming, domain-agent authority, route/DNS
   ownership, storage mounts, and runtime-image packages.
10. GitHub outputs and limitations.

## Secret Handling

The packet schema intentionally has no credential value field. If a source
contains secret material, summarize the safe credential reference and record the
source as redacted or blocked. Do not paste, transform, checksum, or partially
quote raw secret values in the packet, issue, PR, log, or closeout.

