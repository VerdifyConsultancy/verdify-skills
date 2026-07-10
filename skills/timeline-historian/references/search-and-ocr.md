# Search And OCR

Use this reference before retrieving evidence from semantic search, full-text
search, OCR tables, or exported document folders.

## Retrieval Ledger

Record every query that influences the narrative:

- query text;
- purpose: discovery, corroboration, contradiction, rollup, or review;
- backend: file manifest, SQL, full text, semantic, hybrid, Qdrant, OpenSearch,
  IIIF search, OAI-PMH, or external search;
- filters: date range, category, collection, access, OCR confidence, rights,
  source IDs, and excluded classes;
- model/index version: embedding model, collection name, index version, or
  manifest hash;
- results: rank, score, asset ID, chunk/page/span, snippet, and timestamp.

Do not cite a retrieval result as evidence until the underlying source or OCR
span has been inspected.

## OCR Separation

Keep these layers separate:

- source image or document;
- raw OCR;
- page OCR;
- corrected OCR;
- normalized text;
- extracted fields;
- LLM interpretation.

When OCR is weak, quote cautiously and label confidence. For dense pages,
prefer page, crop, or region retries over whole-document generalization.

## Semantic Search

Use semantic search for thematic discovery and adjacent evidence. Use lexical or
full-text search for names, dates, exact phrases, amounts, and source IDs. Use
hybrid search when both recall and exactness matter.

Semantic search results should be filtered by metadata whenever possible:

- date or period;
- category or tag;
- collection;
- access and rights;
- OCR confidence or extraction quality;
- source visibility.

## Critical Search

Run separate searches for:

- direct support;
- counterevidence;
- earlier or later treatment;
- duplicates;
- source gaps;
- adjacent people, places, and institutions;
- OCR variants and spelling variants.

Record negative searches when they materially affect confidence.
