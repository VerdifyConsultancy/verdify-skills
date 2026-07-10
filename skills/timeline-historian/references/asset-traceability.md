# Asset Traceability

Use this reference when a corpus has mixed file sources, derived OCR, exported
copies, object storage, or public/private access rules.

## Asset Ledger

Record one immutable row per source object:

- `asset_id`: stable local ID, preferably `sha256:<content_sha256>` or a
  repository-native object ID.
- `content_sha256`: full content hash when available.
- `sha12`: short display ID, never the durable identity.
- `source_uri`: original URI, object storage URI, IIIF manifest/canvas URI, or
  local path.
- `source_paths`: observed historical paths or aliases.
- `collection`: collection, accession, folder, or vault name.
- `category`: document, meeting minutes, scrapbook, photograph, clipping,
  publication, financial record, or another controlled value.
- `date_evidence`: selected date plus candidates, source, support, and
  confidence.
- `rights`: public, internal, restricted, unknown, or mixed.
- `access`: exported, authenticated, private, missing, or unknown.
- `derived_artifacts`: OCR, corrected text, normalized text, chunks,
  embeddings, source cards, thumbnails, and review files.

## Derived Artifacts

Treat derived files as separate assets linked to their source asset:

- raw OCR;
- page OCR;
- ALTO or layout output;
- corrected text;
- normalized text;
- extracted structured fields;
- chunks and embeddings;
- query result snippets;
- public source cards and OCR pages.

Do not overwrite raw OCR with corrected text. Record a new derived artifact with
its own hash, producer, timestamp, method, and confidence.

## Anchor Rules

Prefer the strongest available anchor:

1. Asset hash plus page/canvas plus OCR span or region.
2. Asset hash plus page/canvas plus quoted text.
3. Asset hash plus target path and source path.
4. Source path only.

Source-path-only evidence is a lead, not a strong claim anchor.

## Public Output

Before exposing a source in public output, confirm:

- rights/access status permits exposure;
- the exported file exists or an authenticated link is intentional;
- OCR transcript exposure is allowed;
- the citation points to a stable source card or asset ID.
