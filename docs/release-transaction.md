# Release transaction

Verdify releases promote one clean `dev` commit through one exact npm tarball.
The tarball is packed once by `scripts/build-release-candidate.sh`; its external
sidecar records the source commit, SHA-256, SHA-512, npm integrity, file set,
archive identity, and the one-pack proof. Tests and `npm publish` receive that
exact tarball path.

## Authority and recovery

`scripts/release-transaction.rb` reconstructs state from the candidate sidecar
and immutable public authorities:

1. npm package version, integrity, and `gitHead`;
2. tag name and peeled source commit;
3. GitHub release tag and asset digests;
4. the clean candidate source, tarball, ZIP, and checksum identities.

The script never requires a previous ledger to resume. Every invocation writes
a fresh ledger validated by `schemas/release-transaction.schema.yaml` and names
one next action: verify, publish npm, push the tag, create or repair release
assets, upload the completed ledger, or stop for manual reconciliation. Partial
ledgers are audit output only. The completed ledger is uploaded to the GitHub
release as `release-transaction-v<version>.json`.

Identity mismatches fail closed. A published npm version is resumable only when
its version, integrity, and `gitHead` match the candidate. Existing tags and
releases are reused only when they identify the same source and exact assets;
the workflow never creates duplicates to repair a partial release.

## Operator commands

Build a clean candidate:

```bash
bash scripts/build-release-candidate.sh dist
```

Reconstruct release state without mutating npm, Git, or GitHub:

```bash
ruby scripts/release-transaction.rb \
  --sidecar dist/<tarball>.release-candidate.json \
  --ledger dist/release-transaction-v<version>.json \
  --repository VerdifyConsultancy/verdify-skills
```

Publication remains restricted to `.github/workflows/publish-npm.yml` after the
reviewed `dev -> main` promotion. Worker and pull-request jobs do not publish,
tag, create releases, or require npm credentials.
