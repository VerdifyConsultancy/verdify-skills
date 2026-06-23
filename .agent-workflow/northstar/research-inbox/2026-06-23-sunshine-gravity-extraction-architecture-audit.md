# Sunshine Gravity Extraction Architecture Audit

Date: 2026-06-23
Evidence status: observed local repository and remote-branch evidence.
Source repos: `/Users/jason/repos/sunshine_club`, `/Users/jason/repos/verdify-gravity`.

## Scope

This note closes the research-queue gap for Sunshine Club extraction
architecture. It records source-boundary and migration-plan evidence only. No
customer corpus files, production records, raw secrets, tokens, or secret values
were read or copied.

## Source Files Inspected

Sunshine Club:

- `packages/gravity/src/sunshine_gravity/config.py`
- `packages/gravity/src/sunshine_gravity/**`
- `apps/gravity-worker/src/sunshine_gravity_worker/__main__.py`
- `apps/api/src/sunshine_api/mcp_server.py`
- `apps/api/src/sunshine_api/services/gravity_artifacts.py`
- `apps/api/src/sunshine_api/services/source_bytes.py`
- `apps/api/src/sunshine_api/services/vault_projection.py`
- `apps/api/src/sunshine_api/review_store.py`
- `docs/technical-stack.md`

Verdify Gravity:

- `clients/sunshine/README.md`
- `clients/sunshine/nfs_mount_handoff.md`
- `docs/mvp/README.md`
- `docs/mvp/cicd_and_runtime.md`
- `packages/gravity/src/verdify_gravity/scanner/contracts.py`
- `packages/gravity/src/verdify_gravity/staging/contracts.py`
- `packages/gravity/src/verdify_gravity/mcp/contracts.py`
- `packages/gravity/src/verdify_gravity/**`

## Observed Claims

- Sunshine Club has a substantial implemented Gravity-like substrate: `sunshine_gravity` package modules for recipes, execution, review queues, schema readiness, vault rendering/schema, synthesis, timeline, artifact freshness, image sidecars, and evidence bundles.
- Sunshine Club's current package and worker are still Sunshine-named (`sunshine_gravity`, `sunshine_gravity_worker`) and configured through `SUNSHINE_*` environment variables such as `SUNSHINE_GRAVITY_ENABLED`, `SUNSHINE_GRAVITY_*`, and `SUNSHINE_DATABASE_URL`.
- Sunshine Club's Gravity config still defaults to Sunshine paths such as `/mnt/sunshine_vault` and `/mnt/sunshine_vault/_sidecars`.
- Sunshine Club's MCP server exposes generic-looking Gravity tools (`gravity.search`, `gravity.get_file`) but also embeds Sunshine-specific instructions, business stories, dashboard paths, and corpus assumptions.
- Sunshine Club's MCP search/get-file logic uses governed citation-first access, `content_sha256` provenance, visibility checks, and short-lived governed blob URLs, which are strong candidates for generic Gravity core contracts.
- Verdify Gravity already has a cleaner package namespace (`verdify_gravity`) with modules for scanner, files, staging, extraction, pipeline, search, knowledge, MCP, worker, readiness, API, and auth.
- Verdify Gravity's MVP package narrows scope to local/NFS folder input, Postgres file tracking and row leasing, S3-compatible immutable object staging keyed by SHA-256, Markdown extraction, Postgres search/pgvector, Cortex-only model calls, OIDC-protected UI, FastAPI API, and read-only MCP tools.
- Verdify Gravity has a `clients/sunshine` pack that explicitly keeps Sunshine-specific source-corpus notes outside generic Gravity MVP docs while binding the Sunshine source to the standard pod mount `/mnt/gravity/source`.
- Verdify Gravity's `clients/sunshine/nfs_mount_handoff.md` documents dev/stage source-PVC overlays, validation scripts, and bounded sample-path guidance for Sunshine corpus mounting.
- The extraction target should therefore be a generic Gravity core plus client pack boundary, not a direct code copy from Sunshine Club.

## Proposed Extraction Boundary

Generic Gravity core candidates:

- Source discovery contracts for local/NFS files.
- SHA-256 content identity, immutable object staging, and source occurrence tracking.
- Postgres file, pipeline, step, review, and leasing primitives.
- Read-only MCP contracts for file search, semantic search, file status, and stats.
- Governed blob URL pattern with visibility and object-existence checks.
- Extraction, staging, validation, readiness, and release evidence workflows.

Sunshine/client-pack candidates:

- Sunshine corpus source path and NFS export details.
- Sunshine-specific taxonomy, business stories, dashboards, schemas, prompts, personas, and vault templates.
- Sunshine env-var compatibility shims.
- Sunshine-specific Google Drive/NAS assumptions, historical records, and production review vocabulary.

## Migration Plan Implications

- Use `verdify_gravity` as the package namespace and keep `sunshine_gravity` as source evidence or a compatibility shim only when needed.
- Move corpus-specific setup into `clients/sunshine` and keep generic runtime paths mounted as `/mnt/gravity/source`.
- Port generic interfaces first: scanner contracts, SHA-256/object staging, Postgres pipeline row leasing, readiness checks, read-only MCP tools, and validation scripts.
- Port Sunshine-specific behavior as a client pack after the generic contracts are stable and tests prove the same source-object and review invariants.
- Keep Gravity feature implementation blocked until platform and Gravity readiness approve source mounts, secrets, S3, Postgres, Cortex, OIDC, review, and rollback evidence.

## Limitations

- This was not a full code migration plan with file-by-file ownership.
- No live Sunshine production database, object store, Qdrant, or corpus files were inspected.
- The Sunshine checkout is on branch `codex/gravity-replan-proposal-2026-06-20` with unmerged planning changes relative to `origin/main`.
