# Sunshine Gravity Reuse Local Evidence

Date: 2026-06-23
Evidence status: observed local repository evidence
Repository: `/Users/jason/repos/sunshine_club`
Observed local HEAD: `960b491ba351b3f91fc35ffe6e002959cb9c94ba`

## Scope

This note captures local evidence from Sunshine Club for the Verdify Skills
North Star loop, specifically the reusable Gravity substrate and the
Sunshine-specific pack boundary. It contains architecture, implementation, and
test-surface evidence only. No raw secrets, private keys, tokens, credential
values, production records, or customer content were copied.

## Source Files Inspected

- `/Users/jason/repos/sunshine_club/README.md`
- `/Users/jason/repos/sunshine_club/AGENTS.md`
- `/Users/jason/repos/sunshine_club/docs/technical-architecture.md`
- `/Users/jason/repos/sunshine_club/docs/data-model.md`
- `/Users/jason/repos/sunshine_club/docs/gravity/README.md`
- `/Users/jason/repos/sunshine_club/docs/design/sunshine_gravity_file_centric_replan_2026-06-16.md`
- `/Users/jason/repos/sunshine_club/apps/api/src/sunshine_api/services/source_bytes.py`
- `/Users/jason/repos/sunshine_club/apps/api/src/sunshine_api/services/gravity_artifacts.py`
- `/Users/jason/repos/sunshine_club/apps/api/src/sunshine_api/services/vault_projection.py`
- `/Users/jason/repos/sunshine_club/apps/api/src/sunshine_api/review_store.py`
- `/Users/jason/repos/sunshine_club/apps/api/src/sunshine_api/mcp_server.py`
- `/Users/jason/repos/sunshine_club/apps/api/src/sunshine_api/services/root_of_trust.py`
- `/Users/jason/repos/sunshine_club/tests/`
- `/Users/jason/repos/sunshine_club/scripts/`

## Observed Claims

- Sunshine Club is a NAS-first document intelligence, review, routing, search,
  and agent system for the Sunshine corpus.
- The current production model keeps original NAS/source paths as provenance,
  copies SHA-256-identified bytes into uniquely named Sunshine-managed S3 source
  objects, and requires downstream pipeline work to use the managed S3 source
  object after ingest.
- Postgres is documented as the source of truth for inventory, extraction,
  structured data, tags, route candidates, review state, runs, model usage, and
  file-processing health.
- Qdrant stores embedding vectors for retrieval; S3-compatible object storage
  stores managed source objects, artifacts, pipeline mirrors, and backups.
- The 2026-06-16 Gravity replan makes `content_sha256` the durable unit of
  progress and demotes runs to audit/provenance rather than ownership of file
  intelligence.
- Sunshine's technical architecture separates generic Gravity file enrichment
  from Sunshine-specific prompt/schema pack enrichment, which directly supports
  extracting a reusable Gravity core plus organization-specific packs.
- The NAS/filesystem connector pattern records original path, source
  collection, size, mtime, extension, MIME type, checksum evidence, and
  source-location map while preserving source identity.
- The S3/object storage connector stores managed source objects under
  deterministic SHA-256 keys, records managed objects, links storage rows by
  `content_sha256`, and uses secret values from Kubernetes secrets rather than
  Git.
- `source_bytes.py` is an implemented downstream byte-acquisition seam that
  resolves bytes by `content_sha256`, prefers managed S3 objects, then legacy
  S3 blobs, and uses NFS only as transitional fallback.
- `gravity_artifacts.py` implements Gravity recipe preview, execution planning,
  artifact registration, run/object/artifact/review listing, and projection
  event/review item operations over recipe, evidence, persistence, and vault
  rendering services.
- `vault_projection.py` projects canonical file extraction into shared,
  schema-validated markdown/frontmatter vault notes and reports manifest
  eligibility via visibility and production-readiness state.
- `review_store.py` owns SQLite-backed local review queues, file browser
  indexes, pipeline run metadata, run events, model usage records, and review
  import/update methods.
- `mcp_server.py` exposes governed Gravity MCP tools for search, governed file
  URL resolution, business stories, and structured views while excluding
  restricted and soft-deleted records.
- `root_of_trust.py` verifies managed S3 vault objects against the Postgres
  ledger, classifies missing/mismatched/orphaned objects, and supports snapshot
  reporting.
- The repository contains many tests and scripts around Gravity readiness,
  vault files, projection approval queues, root-of-trust, S3 storage,
  reconciliation, production audits, Kubernetes/NAS smoke, and pipeline health.

## Planning Relevance

- Strongly supports the North Star's Sunshine-to-Gravity extraction path:
  reuse the generic file-to-knowledge substrate, but separate the Sunshine
  prompt/schema/taxonomy/business-story pack from generic Gravity core.
- Supports Gravity readiness requirements for inventory, managed source-object
  proof, review queues, vault projection, search/MCP, root-of-trust checks,
  and evidence-backed CI/CD validation.
- Supports treating local filesystem evidence ingestion as the first Gravity
  pilot story after platform readiness, because Sunshine has already exercised
  the core pattern over NAS/source bytes to S3/Postgres/Qdrant/vault/MCP.
- Supports the North Star requirement that downstream processing read managed
  content-addressed bytes rather than crawling or mutating original source paths.
- Supports review-inbox and observability-diagnostics planning because
  Sunshine already has review queues, health buckets, root-of-trust snapshots,
  and readiness/audit scripts.

## Limitations

- This is local repository evidence, not a live Sunshine production audit.
- The Sunshine system is organization-specific and contains domain assumptions,
  naming, taxonomy, dashboards, and business stories that should not be copied
  directly into generic Gravity.
- Live GitHub project state, Argo CD state, Kubernetes state, object-store
  state, and model gateway health were not validated in this note.
- Source files and docs show implemented surfaces, but extraction into generic
  Gravity packages still needs a dedicated architecture and migration plan.
