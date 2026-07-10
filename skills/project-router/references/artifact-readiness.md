# Artifact readiness

A phase is ready only when:

- the canonical structured artifact exists and validates;
- validation used the schema selected by the consumer, not an artifact-selected
  substitute;
- its status is approved or otherwise satisfies policy;
- referenced issues, decisions, and baselines resolve;
- no blocking gate remains open;
- derived Markdown views do not contradict the canonical artifact;
- the next role has enough evidence to proceed without hidden chat context.

Presence alone is not readiness. A draft, stale, partially populated, malformed,
semantically invalid, or unapproved file is incomplete. The router emits only a
typed failure category, expected schema, and bounded error count; raw invalid
artifact values and parser messages do not become route evidence.
