# Fleet vendoring and version standard

Status: adopted 2026-07-07 as the rule for all consuming repositories.
Pattern of record: the jvallery/orbit vendoring implemented in orbit#176.

This document defines how a consuming repository ("vendor") installs, records,
verifies, and updates the Verdify skills package. It exists because the fleet
currently runs a mix of unpinned dev snapshots, mislabeled versions, and
side-by-side copies, and because there is no fleet-wide update mechanism —
each repo updates itself (today via `npx @verdify-cli/cli@latest init` or a
manual re-vendor). The fan-out execution plan for bringing every consumer onto
this standard is tracked in jvallery/orbit#183.

## The standard

Every consuming repository MUST satisfy all five rules:

1. **Exactly one pinned version directory.** The installed package lives at
   `.agent-skills/verdify-skills/<version>/` and there is exactly one
   `<version>` directory at a time. No `latest/`, no moving refs, no
   side-by-side versions left over from previous updates.

2. **A provenance record.** `.agent-skills/verdify-skills/UPSTREAM.yaml`
   records where the vendored tree came from and who verified it:

   ```yaml
   upstream: https://github.com/VerdifyConsultancy/verdify-skills
   version: "1.2.0"
   source_tag: v1.2.0
   source_commit: <40-char commit SHA of the tag>
   retrieval_method: <release archive | git archive | npx installer>
   retrieved_at: "2026-07-07"
   verified_by: <operator or agent identity>
   verification: <manifest check performed and its result>
   ```

   The exact field set may grow, but tag, commit SHA, retrieval method, date,
   and verifier are the minimum. jvallery/orbit's record (orbit#176) is the
   reference implementation.

3. **A manifest verification step, per vendor.** Release archives ship
   `MANIFEST.sha256`, and `scripts/verify-package.sh` checks an archive
   against it. **Known issue:** the upstream manifest fails verification in
   released tags (#109 — 95/296 entries fail on v1.2.0; fix in flight as
   PR #111). Until a release ships with a verifiable manifest, vendors
   generate their own manifest over the vendored tree at vendor time (as
   orbit did) and record that in `UPSTREAM.yaml`; re-verification then proves
   the local tree has not drifted since vendoring, even though it cannot yet
   prove provenance against upstream.

4. **Host symlinks are set by the host repository.** The consuming repo wires
   `.claude/skills/` and `.agents/skills/` symlinks into the single pinned
   version directory. Skill discovery never points at a moving ref or at more
   than one package version.

5. **Update = re-vendor, not mutate.** To update, vendor the newer pinned
   version directory, update `UPSTREAM.yaml`, re-point the host symlinks,
   and remove the old version directory in the same change. Never edit
   vendored skill files in place; upstream changes go through
   VerdifyConsultancy/verdify-skills.

## Canonical shipped file boundary

Release archives and `MANIFEST.sha256` use the same Git-index-derived file set,
implemented by `scripts/package-file-list.rb`. The selector includes tracked
regular files and tracked discovery symlinks, excludes controller state and
generated install/build roots, and rejects unsupported Git modes. Repository
staging reads regular bytes and symlink targets from the blob object IDs captured
with each Git-index entry; it never reads those values through mutable worktree
paths. Ignored, untracked, and locally modified host files are never package
inputs, even when they are present inside a normally shipped directory such as
`.claude/`. Explicit exported-tree manifest generation remains available when
Git metadata is intentionally absent and reads only that supplied tree boundary.

The archive stores tracked discovery symlinks as symlinks. Manifest hashing
covers the selected regular files without following those links, so a host-local
target can neither enter an archive nor influence an integrity digest. Staged
regular-file permissions come from the Git index: `100644` becomes `0644` and
`100755` becomes `0755`, independent of mutable worktree content, type, symlink
targets, or permission bits.

## Current consumer census (2026-07-07)

| Consumer | Vendored state | Verdict |
| --- | --- | --- |
| jvallery/agents + ~12 fleet repos | Unpinned `dev` snapshot mislabeled "1.0.0" (dev@fa8fb8a5, 2026-06-24, 18 skills) | Non-compliant — needs re-vendor at 1.2.0 with `UPSTREAM.yaml` |
| jvallery/orbit | 1.1.2 pinned, `UPSTREAM.yaml` provenance record plus own generated manifest (orbit#176) | Exemplary — the pattern this standard promotes; update to 1.2.0 when convenient |
| VerdifyConsultancy/gravity | 1.2.0 vendored, but three version directories side by side | Partially compliant — needs prune to exactly one pinned version dir |

## Known gaps this standard depends on

- **#109 / PR #111** — upstream `MANIFEST.sha256` integrity in released tags;
  until fixed, rule 3 uses vendor-generated manifests.
- **#106** — npm `@verdify-cli/cli` lags the repository (1.1.4 was never
  released; 1.2.0 shipped on GitHub); prefer the release tag/archive as the
  vendoring source until npm catches up.
- **jvallery/agents#2642** — the fleet runtime image ships a broken 0-byte
  `/usr/local/bin/verdify` stub; runtime consumers must call the vendored
  `bin/verdify` from the pinned version directory, not the image stub.
- **jvallery/orbit#183** — the fleet-wide fan-out plan that applies this
  standard to every consumer; there is no automatic update mechanism today.

## See also

- [`architecture.md`](architecture.md) — package layers and boundaries
- `docs/decisions/ADR-0016-package-platform-skill-reconciliation.md` — the
  package-vs-platform contract boundary that makes pinned vendoring safe
- `README.md` — installer (`npx @verdify-cli/cli init`) and bootstrap flows
