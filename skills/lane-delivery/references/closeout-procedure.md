# Closeout procedure

A complete closeout includes:

- baseline, separate approved dispatch commit, last substantive implementation
  SHA, and validated SHA;
- issue and PR references;
- changed paths grouped by contract ownership;
- validation command, exit status, timestamp, and artifact/log location;
- criterion-to-evidence mapping;
- clean/dirty worktree status;
- lease-backed worker agent and worker session identities;
- discovered issues and residual risk;
- worker assertion and explicit limitations.

Statuses are `ready_for_critic`, `blocked`, `failed`, or `decision_required`. Worker closeout never uses `approved`.

For `ready_for_critic`, `implementation_head_sha` and `validated_head_sha` are
the same last substantive commit. Commit the closeout afterward as the only
changed path. Do not try to place that containing commit's SHA inside the
closeout; the critic records it as `evidence_head_sha`. Any substantive change
after the implementation head requires new validation, a rewritten closeout,
and a new evidence head.

Before accepting the closeout, validate that the first commit after the
contract baseline is dispatch-only, contains the canonical contract, changes no
implementation path, and that no dispatch artifact changes between D and I.
