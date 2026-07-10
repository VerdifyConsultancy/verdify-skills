# Sunshine Vault Adapter

Use this reference when testing the timeline historian against the Sunshine Club
vault.

## Read-Only Inputs

Primary read-only surfaces:

- `/Volumes/sunshine/decades/_manifest/decade-export-manifest.jsonl`
- `/Volumes/sunshine/decades/<period>/`
- `/Volumes/sunshine/decades/SUNSHINE_CLUB_HISTORY_1900_2026.md`
- `/Users/jason/repos/sunshine_club/site/docs/sources/`
- `/Users/jason/repos/sunshine_club/site/docs/ocr/`
- Sunshine Postgres tables when available: `file_extractions`,
  `file_extraction_pages`, `structured_field_values`, `managed_source_objects`,
  and `file_object_state`.
- Search surfaces when available: MCP `gravity.search`,
  `/admin/search/fulltext`, `/admin/search/semantic`,
  `/admin/search/hybrid`, and Qdrant-backed semantic retrieval.

Do not reorganize, move, delete, or overwrite vault files during a historian
test.

## Smoke Test

From `/Users/jason/repos/verdify-skills`:

```bash
python3 skills/timeline-historian/scripts/sunshine_manifest_seed.py \
  --manifest /Volumes/sunshine/decades/_manifest/decade-export-manifest.jsonl \
  --decade 1960s \
  --category meeting-minutes \
  --limit 25 \
  --output /tmp/timeline-historian-sunshine-1960s

python3 skills/timeline-historian/scripts/validate_timeline_bundle.py \
  /tmp/timeline-historian-sunshine-1960s
```

The seed bundle contains manifest-backed asset, search, claim, treatment,
window, and review scaffolds. It is not a finished historical narrative.

## Stronger Test Loop

1. Generate a seed bundle for one decade.
2. Inspect the selected `content_sha256` values in Sunshine Postgres and source
   cards.
3. Add OCR/page spans to the claim anchors.
4. Run hybrid searches for the same decade and topic.
5. Add support, qualification, contradiction, and distinction treatment rows.
6. Write a `window-summary` with explicit source coverage and caveats.
7. Write a `narrative-review` before public publication.

## Sunshine-Specific Evidence Rules

- Treat `content_sha256` as the durable asset identity.
- Treat exported `target_path` as a review copy, not the canonical source.
- Use `sha256_verified`, `source_object_uri`, `object_key`, and
  `file_object_state` to reason about object availability.
- Treat path-derived dates and weak fallback dates as lower confidence.
- Use source cards and OCR pages for public links only when public-export rules
  make them safe.
