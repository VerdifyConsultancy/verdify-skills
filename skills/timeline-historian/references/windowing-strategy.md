# Windowing Strategy

Use this reference when deciding how to split and roll up historical periods.

## Defaults

Start with the smallest window that has enough source density to support a
bounded narrative:

- annual windows for dense modern records;
- decade windows for mixed archival folders;
- 30-year windows for broad institutional eras;
- 50-year or 100-year windows only after smaller summaries exist.

Use overlap when events span a boundary. Record overlap explicitly instead of
duplicating claims silently.

## Window Fields

Each window should have:

- `window_id`;
- `label`;
- `start_year`;
- `end_year`;
- `parent_window_id`;
- `source_count`;
- `claim_count`;
- `coverage_notes`;
- `open_questions`;
- `ready_for_rollup`.

## Rollup Gates

Only roll up when:

- lower windows have summaries;
- accepted claims have source anchors;
- weak or missing source coverage is recorded;
- critical review has no blocking contradiction;
- public/private source constraints are understood.

If a broad period has uneven source density, write the unevenness into the
narrative instead of smoothing it away.
