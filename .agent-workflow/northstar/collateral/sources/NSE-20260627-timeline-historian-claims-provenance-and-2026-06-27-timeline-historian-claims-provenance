# Timeline Historian Skill: Claims, Provenance, OCR, and Discovery Research

Date: 2026-06-27
Method: Brave Search API using the configured local `brave_search_key.txt`
credential reference. Raw credential values were not printed, copied, logged, or
stored.

## Scope

This note supports the design of a reusable historian and critical-historian
skill that builds layered time-window narratives over a document corpus. The
research focused on asset traceability, semantic search, OCR provenance,
discovery metadata, and a Shepard-style claims pattern for tracking whether
new evidence supports, qualifies, contradicts, supersedes, or distinguishes
previous narrative claims.

## Brave Queries

- `digital humanities historical narrative corpus OCR provenance source citation best practices`
- `W3C provenance data model source traceability evidence entities activities agents`
- `Web Annotation Data Model selector source text fragment provenance`
- `IIIF Presentation API OCR annotations canvas text source traceability`
- `ALTO XML OCR layout coordinates text provenance standard`
- `retrieval augmented generation source attribution citation provenance best practices`
- `legal Shepardizing citator treatment history overruled questioned distinguished pattern`
- `semantic search hybrid search metadata filtering provenance vector database best practices`
- `archival discovery metadata provenance Dublin Core source identifier date relation standard`
- `Qdrant filtering payload vector search official documentation hybrid search`
- `OpenSearch hybrid search neural lexical search official documentation`
- `RAG evaluation faithfulness context precision source citation official docs`
- `TEI Guidelines source description certainty responsibility evidence historical documents`
- `METS metadata encoding transmission standard structural map provenance official`
- `IIIF Content Search API OCR annotations search hits before after official`
- `OAI-PMH protocol metadata harvesting repository discovery official`
- `FAIR data principles metadata provenance reusable findable accessible interoperable reusable official`

## Sources Found

| Source | Type | URL | Relevance |
| --- | --- | --- | --- |
| W3C PROV-DM | primary standard | https://www.w3.org/TR/prov-dm/ | Provides the core model for provenance as entities, activities, and agents involved in producing data, which maps directly to asset, OCR, correction, embedding, search, and narrative generation lineage. |
| W3C Web Annotation Data Model | primary standard | https://www.w3.org/TR/annotation-model/ | Provides selectors such as text quote and position selectors for anchoring claims and notes to exact source spans. |
| IIIF Presentation API 3.0 | primary standard | https://iiif.io/api/presentation/3.0/ | Supports associating transcriptions, commentary, tags, and other annotations with canvases in a distributed, standards-based way. |
| IIIF Content Search API 2.0 | primary standard | https://iiif.io/api/search/2.0/ | Supports searching annotation content within IIIF resources such as manifests, canvases, ranges, and collections. |
| Library of Congress ALTO schema | primary standard | https://www.loc.gov/standards/alto/alto.xsd | Defines layout-aware OCR output that stores recognized text and physical page layout information. |
| Library of Congress METS | primary standard | https://www.loc.gov/standards/mets/ | Provides descriptive, administrative, and structural metadata packaging for digital library objects. |
| Dublin Core Metadata Basics | primary standard/community guidance | https://www.dublincore.org/resources/metadata-basics/ | Provides a compact discovery metadata vocabulary including creator, date, identifier, relation, source, coverage, and rights. |
| OAI-PMH 2.0 | primary protocol | https://www.openarchives.org/OAI/openarchivesprotocol.html | Supports repository discovery and harvesting with stable item identifiers and multiple metadata formats. |
| GO FAIR Principles | primary/community guidance | https://www.go-fair.org/fair-principles/ | Emphasizes machine-actionable findability, accessibility, interoperability, and reuse of digital assets. |
| TEI responsibility attributes | primary standard | https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-att.global.responsibility.html | Supports encoding responsibility and certainty for textual assertions and editorial interventions. |
| Qdrant filtering and hybrid queries | vendor technical docs | https://qdrant.tech/documentation/search/filtering/ and https://qdrant.tech/documentation/search/hybrid-queries/ | Supports metadata-filtered vector search and dense/sparse hybrid retrieval. |
| OpenSearch vector search concepts | vendor technical docs | https://docs.opensearch.org/latest/vector-search/getting-started/concepts/ | Defines hybrid search as combining lexical keyword search with semantic vector search to improve relevance. |
| Ragas context precision | evaluation framework docs | https://docs.ragas.io/en/stable/concepts/metrics/available_metrics/context_precision/ | Provides a retrieval evaluation metric for whether retrieved contexts are useful for answering a question. |
| USC Gould Law Library Shepard guide | legal research guidance | https://lawlibguides.usc.edu/c.php?g=542695&p=3718771 | Shows the citator pattern of positive and negative treatment categories such as followed, overruled, questioned, criticized, and distinguished. |
| Northwestern Pritzker Legal Research Center case updating guide | legal research guidance | https://library.law.northwestern.edu/cases/updating | Shows treatment categories such as overruled, abrogated, superseded, and questioned. |
| arXiv: From OCR to Analysis | emerging research paper | https://arxiv.org/abs/2603.00884 | Found by Brave as an emerging example of span-level OCR correction provenance; useful as a design signal, not as a governing standard. |

## Findings

1. The historian skill should be an evidence pipeline, not a narrative-only
   writing prompt. W3C PROV supports modeling every derived object as lineage:
   original asset, OCR artifact, corrected text, normalized text, chunk,
   embedding, retrieved result, extracted event, claim, summary, critique, and
   final narrative.
2. Asset traceability should be immutable at the source-object level. Each asset
   needs a stable `asset_id`, source path or URI, repository identifier,
   collection/accession context, content hash, rights or access status,
   discovery method, ingestion timestamp, and derived-artifact hashes.
3. OCR provenance should be span-level when possible. ALTO gives page layout and
   recognized text coordinates; IIIF and Web Annotation provide a way to anchor
   transcriptions, commentary, and claims to canvases, regions, and text spans.
   Raw OCR, corrected text, normalized text, and LLM interpretation should stay
   separate artifacts.
4. Discovery is not evidence by itself. OAI-PMH, Dublin Core, METS, and FAIR
   principles support the discovery catalog: what exists, where it came from,
   when it was found, what metadata was harvested, and whether it has been
   ingested, OCRed, indexed, reviewed, or cited.
5. Semantic search should be hybrid and metadata-filtered. Vector search is
   useful for thematic retrieval, but historical work also needs exact names,
   dates, collection IDs, document types, locations, rights status, OCR
   confidence, and time-window filters. OpenSearch and Qdrant both support the
   product pattern of lexical plus semantic retrieval.
6. Every retrieval result used by a narrative should store the query text,
   filters, retrieval backend, embedding model/version, index version, score,
   rank, chunk ID, asset ID, page/span anchor, and retrieved timestamp. This is
   necessary for reproducibility and for later criticism.
7. The Shepard claims pattern is a strong fit. Legal citators do not simply cite
   an authority; they track later treatment. A historian claim ledger should do
   the same: each claim receives treatment records from later evidence or higher
   review passes, with states such as `supports`, `qualifies`, `contradicts`,
   `supersedes`, `distinguishes`, `duplicates`, `needs-review`, and
   `not-evaluated`.
8. Time-window rollups must be claim-traceable. A decade, 30-year, 50-year, or
   century narrative should not invent a new unsupported generalization. It
   should derive from lower-window claims and source anchors, and each rollup
   claim should retain links to the lower claims it compresses.
9. The critical-historian pass should search against the narrative, not only
   against the original user prompt. It should look for missing counter-evidence,
   OCR instability, unsupported causal language, vague chronology, thin source
   coverage, over-weighted documents, date conflicts, and claims whose treatment
   has changed since the narrative was written.
10. Retrieval quality needs explicit evaluation. Context precision-style metrics
   can measure whether retrieved chunks are useful for a target question, while
   historian-specific evaluation should add source coverage, quote-anchor
   validity, OCR confidence, time-window coverage, and claim-treatment stability.

## Recommended Default

Implement the historian skill as a layered research workflow with six durable
artifact families:

1. `asset-ledger`: one immutable row per discovered source object, plus derived
   OCR/correction/normalization/index artifacts.
2. `search-ledger`: one row per semantic, lexical, hybrid, or metadata-filtered
   query, including query text, filters, backend, model/index version, result
   ranks, and source anchors.
3. `claim-ledger`: one row per atomic claim, with time interval, assertion text,
   source anchors, confidence, authoring step, and status.
4. `claim-treatment-ledger`: Shepard-style later treatment records for each
   claim: supports, qualifies, contradicts, supersedes, distinguishes,
   duplicates, needs-review, or not-evaluated.
5. `window-summary`: bottom-up summaries for each configured time window,
   including source coverage, events, claims, unresolved questions, and
   excluded/weak evidence.
6. `narrative-review`: critical-historian reports that assess the current
   narrative before a broader rollup is accepted.

The skill should decompose into these internal modes:

- `discover-assets`: harvest metadata and candidate sources through file,
  repository, OAI-PMH, IIIF, or other collection discovery surfaces.
- `prepare-text`: OCR, parse existing OCR, preserve raw/corrected/normalized
  text, and store layout/span anchors.
- `index-corpus`: create lexical, semantic, and metadata indexes with explicit
  index versioning.
- `search-window`: run hybrid retrieval for a time window and area of interest.
- `extract-claims`: produce atomic claims, event candidates, and quote anchors.
- `shepard-claims`: update treatment records by searching for support,
  contradiction, supersession, distinction, and missing evidence.
- `write-window`: write a bounded narrative for the current window.
- `critic-review`: audit the narrative and claim ledger before rollup.
- `roll-up`: synthesize broader windows only from accepted lower-window
  summaries and source-backed claims.

## Suggested Skill Resources

- `references/asset-traceability.md`: required IDs, hashes, source URIs,
  rights/access fields, OCR lineage, and derived artifact relationships.
- `references/shepard-claims.md`: claim schema, treatment vocabulary, review
  states, and re-synthesis triggers.
- `references/search-and-ocr.md`: hybrid retrieval, metadata filters, OCR
  confidence, ALTO/IIIF/Web Annotation anchors, and query ledger rules.
- `references/windowing-strategy.md`: time-window planning, overlap rules,
  rollup thresholds, and coverage checks.
- `scripts/plan_windows.py`: deterministic calendar/time-window generator.
- `scripts/validate_claim_ledger.py`: checks that claims have source anchors and
  treatment status.
- `scripts/validate_asset_traceability.py`: checks source hashes, derived
  artifact lineage, and anchor resolvability.
- `assets/window-summary.template.yaml`: bounded summary contract.
- `assets/claim-ledger.template.yaml`: atomic claim and treatment contract.

## Open Design Questions

1. Should claim treatment status be limited to historian semantics, or should it
   intentionally mirror legal citator terms such as overruled, questioned, and
   distinguished?
2. Should semantic search be an external service contract only, or should the
   skill include concrete adapters for Qdrant/OpenSearch/Postgres pgvector?
3. Should OCR correction be in scope for the skill, or should the historian only
   consume OCR/correction artifacts produced by a separate document-intelligence
   pipeline?
4. What level of source access should be allowed in public narratives: source
   card only, OCR transcript, image region, full asset, or authenticated link?

## Claims Ready For Ingest

- W3C PROV supports modeling historian output as lineage across source assets,
  OCR/correction steps, search/index activities, generated claims, reviews, and
  narratives.
- IIIF, Web Annotation, and ALTO support source anchors at canvas, region, text
  span, and OCR layout levels, so historian claims should retain page/image/span
  traceability rather than only document-level citations.
- OAI-PMH, Dublin Core, METS, and FAIR principles support separating discovery
  metadata from evidentiary support, so the historian should distinguish found,
  harvested, ingested, indexed, reviewed, and cited source states.
- OpenSearch and Qdrant documentation support hybrid lexical plus semantic
  retrieval with metadata filtering, so historian semantic search should combine
  vector similarity with exact names, dates, source collections, OCR confidence,
  and access filters.
- Legal Shepardizing/citator guidance supports tracking later treatment of an
  authority, so the historian should maintain a claim-treatment ledger for
  support, contradiction, qualification, supersession, distinction, and stale
  or contested claims.

## Limitations

- Brave Search result order was used for discovery only; source authority comes
  from the linked standards, protocol docs, vendor docs, and legal research
  guides.
- This pass did not inspect a live target corpus, existing OCR quality, or
  available semantic-search backends.
- The arXiv OCR provenance paper is an emerging research signal and should not
  override the standards-based design.
- The skill design still needs a follow-up North Star synthesis pass before it
  becomes an implementation issue, lane contract, or lifecycle skill.
