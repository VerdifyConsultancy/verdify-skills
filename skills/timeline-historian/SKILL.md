---
name: timeline-historian
description: Builds source-backed timeline narratives over document corpora with asset traceability, OCR/span provenance, semantic or hybrid search ledgers, Shepard-style claim treatment, window summaries, and critical-historian review. Use when Codex needs to research or write historical narratives from archives, vaults, OCR exports, semantic-search systems, decade/year folders, or source ledgers, especially when every claim must trace to assets and later evidence can support, qualify, contradict, supersede, or distinguish prior claims.
metadata:
  author: Verdify
  version: "1.2.1"
  category: standalone
---

# Timeline Historian

Build historical narratives as evidence products. Do not write a broad story
until assets, search results, OCR spans, atomic claims, and claim treatment are
recorded.

## Workflow

1. Define the period, audience, corpus boundary, publication constraints, and
   output location. For time slicing, run `scripts/plan_windows.py` or read
   `references/windowing-strategy.md`.
2. Inventory source assets before interpretation. Record stable IDs, hashes,
   source URIs or paths, dates, rights/access status, discovery method, and
   derived artifacts. Read `references/asset-traceability.md` when the corpus
   is new, mixed, or partly untrusted.
3. Build retrieval evidence. Use lexical, semantic, hybrid, OCR, and metadata
   discovery surfaces as available. Record every query, filter, backend,
   model/index version, hit rank, score, chunk ID, asset ID, and source anchor.
   Read `references/search-and-ocr.md` before using OCR or semantic search.
4. Extract atomic claims from retrieved evidence. Each claim needs a time
   interval, source anchors, confidence, and status. Keep raw OCR, corrected
   text, normalized text, and LLM interpretation separate.
5. Shepard claims before synthesis. Search for support, qualification,
   contradiction, supersession, distinction, duplicates, and stale evidence.
   Read `references/shepard-claims.md` before updating claim treatment.
6. Write the smallest accepted window first. Summarize source coverage, events,
   claims, counterevidence, excluded weak evidence, and open questions. Roll up
   broader windows only from accepted lower-window summaries and traceable
   claims.
7. Run a critical-historian review before accepting or publishing. Check for
   unsupported causality, vague chronology, over-weighted documents, OCR
   instability, missing counterevidence, and claim treatment changes.
8. Validate the bundle with `scripts/validate_timeline_bundle.py` when JSONL
   ledgers are present.

## Sunshine Vault

For the Sunshine Club vault, read `references/sunshine-vault.md` first. The
read-only seed command is:

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

Use the seed bundle as evidence scaffolding, then enrich it with Postgres OCR,
Qdrant or full-text search results, source-card links, and critical review.

## Required Artifacts

Produce these artifact families unless the user explicitly asks for a narrower
diagnostic:

- `asset-ledger`: source objects and derived OCR/index artifacts.
- `search-ledger`: lexical, semantic, hybrid, OCR, and discovery queries.
- `claim-ledger`: atomic source-backed historical claims.
- `claim-treatment-ledger`: Shepard-style support and challenge records.
- `window-summary`: bounded time-window narrative evidence.
- `narrative-review`: critical-historian audit before rollup or publication.

Use the templates in `assets/` for YAML-shaped deliverables, or JSONL when a
script is producing rows for deterministic validation.

## Stop Conditions

Stop and record the gap instead of writing unsupported history when source
identity, rights/access status, date evidence, OCR text, search provenance, or
claim anchors cannot be inspected. Stop before exposing restricted or private
source assets in public output.
