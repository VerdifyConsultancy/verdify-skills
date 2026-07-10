# Orbit Current-State Audit — 2026-07-09

Evidence status: verified or observed where stated. This is a point-in-time read-only audit of committed `jvallery/orbit`, GitHub, the repo pod, and safe connector state.

## Current truth

- Canonical `main`: `3819f1d72a90e09ea902a622a10bd89f2ec4b9d5`.
- The supported workload is the Ready `repo-jvallery-orbit-0` repo pod. The retired standalone OpenClaw namespace and Argo applications are absent.
- Codex, Claude, OpenClaw, and Hermes are runtime adapters in the same pod, Unix identity, PVC, and credential home; they are not four isolated assistant services.
- The loop is enabled, but its last six recorded headless iterations failed on Codex authentication. Interactive login now reports authenticated, but recovery is unproved until a headless iteration succeeds.
- GOG `0.33.0` and OAuth bootstrap material exist, but live `auth list` contains zero accounts. Orbit currently has no working Gmail, Calendar, Drive, Docs, Tasks, contacts, Meet, or enterprise-document access.
- No verified live Slack identity, transcript/meeting capture connector, or enterprise document connector exists in the current repo pod.

## Security and privacy

- Personal context and engineering actuation currently share one trust domain: runtime identity, filesystem, GitHub identity, Kubernetes service account, and future connector credentials.
- The current service account can read Secrets in the Orbit namespace and has named exec into sibling engineering pods.
- Broad connector plans exceed minimum read-only scope and lack a normalized personal-source contract, connector read ledger, source ACL propagation, retention, correction, deletion, and cross-account controls.
- Raw personal, contact, biometric, health, location, email, meeting, and workspace material remains tracked in the source repository pending the planned private-data split.

## Existing issue coverage

- Orbit North Star and stale runtime cleanup: #170 and #188.
- Loop auth/readiness: Orbit #182; Agents #2491, #2553, #2645, #2660, and #2859.
- Fleet MCP regression: Orbit #168 and closed Agents #2337.
- Google and personal connectors: Orbit #10, #21, #30, #116, #125, and #162.
- Transcript and meeting intake: Orbit #141, #159, and #167.
- Memory, correction, deletion, and vault policy: Orbit #118, #119, #120, and #165.
- Personal assistant skill facades: Verdify Skills #98.

## New issues

- Orbit #193: split personal-context and fleet-actuation trust domains.
- Orbit #194: execute the private-material split and remove raw personal data from source Git.
- Orbit #195: define the personal-source data contract and connector read-audit ledger.
- Orbit #196: add enterprise-document connectors with tenant policy and source-ACL preservation.

## Planning implications

- Authorized personal and enterprise information is core Orbit product scope, not a deferred appendix.
- Connector breadth must be implemented through a separate, policy-enforced connector plane with normalized source identity, tenant, classification, ACL, cursor/freshness, provenance, retention, and capability rules.
- OpenClaw, Hermes, Codex, and Claude are replaceable runtime adapters rather than product identities or separate deployments.
- The first safe connector milestone is minimal-scope read-only access with citations and read auditing; write actions follow principal separation, policy enforcement, and human-control proof.
- Verdify Skills #98 should use thin orchestration facades over existing lifecycle and connector contracts. Raw transcripts and audio belong in approved encrypted evidence storage, not an automatic repo-root vault.

## Limitations

- Connector authorization and headless-loop recovery can change and must be reverified.
- No raw personal data, credentials, tokens, or secret values were copied into this audit.
- This audit did not mutate Orbit source or runtime state.
