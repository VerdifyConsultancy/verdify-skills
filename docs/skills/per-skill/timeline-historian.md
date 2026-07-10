# timeline-historian

**Standalone skill:** Source-backed timeline narratives with asset, search,
OCR, claim, treatment, window, and review provenance.

## Use

Use when an agent needs to research or write historical narratives from an
archive, vault, OCR export, semantic-search index, or source ledger. It is not a
lifecycle route target and does not modify the source corpus.

## Inputs

| Input | Authority |
|---|---|
| Corpus boundary and period | User or approved research scope |
| Assets, metadata, OCR, and search results | Source repository or read-only index |
| Claim treatment decisions | Evidence-backed historian review |

## Outputs

| Output | Consumer |
|---|---|
| Asset and search ledgers | Researcher and reviewer |
| Atomic claim and treatment ledgers | Timeline synthesis |
| Window summaries and narrative review | Human reviewer or publisher |

## Safety

- Preserve asset, page, region, span, query, and hash provenance where available.
- Keep OCR text, corrected text, normalized text, and interpretation distinct.
- Treat later evidence as support, qualification, contradiction, supersession,
  distinction, duplication, or review-required state.
- Seed Sunshine bundles into a local output directory; never mutate the vault.

## References

- `skills/timeline-historian/SKILL.md`
- `skills/timeline-historian/references/asset-traceability.md`
- `skills/timeline-historian/references/search-and-ocr.md`
- `skills/timeline-historian/references/shepard-claims.md`
- `skills/timeline-historian/references/sunshine-vault.md`
