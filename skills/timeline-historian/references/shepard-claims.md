# Shepard Claims

Use this reference before extracting claims or reviewing an existing narrative.

## Claim Ledger

Make claims atomic. A claim should be small enough that later evidence can
support, qualify, contradict, supersede, or distinguish it.

Required fields:

- `claim_id`;
- `window_id`;
- `assertion`;
- `time_interval`;
- `claim_type`: event, person, organization, finance, place, publication,
  policy, interpretation, or rollup;
- `source_anchors`;
- `confidence`;
- `status`: draft, accepted, needs-review, rejected, or superseded;
- `created_from`: extraction, search result, OCR quote, lower-window rollup, or
  human note.

## Treatment Ledger

Use a separate row for each later treatment of a claim:

- `supports`: later evidence directly supports the claim.
- `qualifies`: evidence narrows, conditions, or weakens the claim.
- `contradicts`: evidence conflicts with the claim.
- `supersedes`: later review or stronger evidence replaces the claim.
- `distinguishes`: evidence looks similar but applies to a different time,
  person, place, source, or meaning.
- `duplicates`: another claim states the same thing.
- `needs-review`: treatment cannot be resolved without human or deeper source
  review.
- `not-evaluated`: placeholder for new claims before review.

Keep legal citator terms as design inspiration, but use historian wording in
public reports unless the user asks for legal-style labels.

## Rollup Rule

A rollup claim must cite the lower claims it compresses and the strongest source
anchors behind those lower claims. Do not create a broad decade or century
claim from a single unreviewed source.

## Critical-Historian Checks

Before accepting a narrative, check:

- unsupported causal language;
- vague chronology;
- single-source overreach;
- source-path-only date evidence;
- OCR instability;
- missing counterevidence;
- private or restricted sources;
- stale claim treatment;
- rollup claims without lower-window support.
