# Terminal receipt

Run this only after the controller evidence branch has immutable P/R/O and every
lane PR is merged into `dev` at exact S with trusted checks.

## Normal transaction

1. Fetch `origin/dev` and create
   `receipt/<sprint-id>/<first-12-base-sha>` at that exact SHA.
2. Generate the five canonical files:

   ```bash
   bin/verdify sprint receipt \
     --repo <receipt-worktree> \
     --sprint <sprint-id> \
     --controller-ref controller/<sprint-id> \
     --base <exact-dev-sha>
   ```

3. Commit all five files together. The receipt commit must have the recorded
   base as its only parent.
4. Open a same-repository PR to `dev`. Its first content is:

   ```text
   <!-- verdify-terminal-receipt:<sprint-id>:<exact-dev-sha> -->
   ```

5. Enable auto-merge. Do not request another critic or routine human review.
6. After merge, fetch `origin/dev`, run global `bin/verdify route --write`, and
   record the route evidence.

## Bounded recovery

`issue-135-recovery-v1` is the only multi-sprint mode. Its branch and marker
use that bundle ID, its base must equal PR #213's merge commit, and its diff must
contain the exact five canonical paths for all six sprint IDs compiled into
`SprintTerminalReceipt::RECOVERY_SPRINT_IDS`. Any missing or extra sprint/path
fails closed. Do not add a generic historical bypass.

## Typed stops

Stop the same receipt transaction on a P/R/O digest or scope mismatch, invalid
D/I/E/S, unmerged or stale PR, newer failing/untrusted required check, wrong
base/branch/marker, mixed path, or ancestry failure. Fix forward on the receipt
branch. Escalate to a human only when the evidence exposes a protected decision
outside the recorded authority or rollback envelope.
