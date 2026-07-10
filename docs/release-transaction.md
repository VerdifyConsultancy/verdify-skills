# Release transaction

Verdify releases promote one clean `dev` commit through one exact npm tarball.
The tarball is packed once by `scripts/build-release-candidate.sh`; its external
sidecar records the source commit, SHA-256, SHA-512, npm integrity, file set,
archive identity, and the one-pack proof. Tests and `npm publish` receive that
exact tarball path.

The publish workflow separates candidate construction from privileged
publication. An unprivileged job builds the candidate at the final `main` SHA,
runs the complete installed-consumer matrix, and retains the bundle for 90 days
under `verdify-release-candidate-v<version>-<source-sha>`. Bundle provenance
binds the artifact to this repository, the publish workflow, its originating
run, `main` source SHA, artifact name, sidecar digest, and all candidate file
digests. The npm environment job downloads that exact artifact by run and
artifact ID; it never invokes the packer.

On a later workflow attempt, a retained bundle is accepted only from a publish
workflow run for the same repository and `main` source SHA. It is reverified and
retested before publication continues. If npm, the version tag, or the GitHub
release already exists and that exact retained bundle is unavailable, recovery
stops for manual reconciliation instead of rebuilding candidate bytes.

## Authority and recovery

`scripts/release-transaction.rb` reconstructs state from the candidate sidecar
and immutable public authorities:

1. npm package version, integrity, and `gitHead`;
2. tag name and peeled source commit;
3. GitHub release tag and asset digests;
4. the clean candidate source, tarball, ZIP, and checksum identities.

Local verification always precedes npm, Git, or GitHub authority queries. It
recomputes archive size and SHA-256, the checksum filename, content, and digest,
tarball SHA-1/SHA-256/SHA-512/integrity, package identity, source commit,
package-file-list blob, and every npm member path, size, mode, and content
digest. Any mismatch writes a failed ledger with no publish action.

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

The ZIP builder normalizes member timestamps and directory modes, removes ZIP
extra fields, and supplies an explicitly sorted member list. Rebuilding the
same source commit therefore produces byte-identical ZIP and checksum assets.

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
