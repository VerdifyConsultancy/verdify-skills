# Code Batch 7 Critic Review - PR #64

Verdict: APPROVE

PR: VerdifyConsultancy/verdify-skills#64 (`lane/secret-scanning`)
Issue: #16
Head reviewed: `1562683a2a989ad1803a137138431578f8b318f8`
Base: `6af623a01e0ff64025332ad14d17472495f24778`

## Scope Reviewed

Commands requested by the lane owner were run:

- `gh pr view 64 --repo VerdifyConsultancy/verdify-skills`
- `gh pr diff 64 --repo VerdifyConsultancy/verdify-skills`
- `gh pr checks 64 --repo VerdifyConsultancy/verdify-skills`

The PR changes are limited to:

- `.agent-workflow/sprints/2026-06-24-skills-hardening/lanes/closeout/lane-secret-scanning.closeout.yaml`
- `lib/verdify/cli.rb`
- `skills/northstar-research-ingest/SKILL.md`
- `tests/test_cli.sh`

That is within the lane-owned research-ingest skill, the coordinated CLI ingest/init path, and expected test/closeout evidence. I did not find cross-lane source edits.

## Findings

No blocking findings.

The fix is real and fail-closed. `lib/verdify/cli.rb` calls `scan_research_source_for_secrets!(source)` immediately after proving the source file exists and before `.agent-workflow/northstar/collateral/sources/` is created, before `FileUtils.cp`, before item YAML writes, and before registry writes. On detection it raises `UsageError`; this is not a warning-only scan.

The scanner is deterministic and covers private-key blocks, AWS access key IDs, Google API keys, GitHub tokens, GitHub fine-grained tokens, OpenAI keys, Slack tokens, JWT bearer tokens, SSNs, Luhn-valid payment card numbers, and high-entropy credential assignment values. Entropy is applied in credential-assignment context rather than as a blanket standalone entropy sweep; that matches the approved lane contract's common key/token/credential-shape target and avoids claiming comprehensive secret discovery.

The regression coverage is present in `tests/test_cli.sh`. It creates a credential-shaped fixture, runs `northstar ingest-research`, asserts the command fails with `research source failed secret scan`, and asserts both the copied source and normalized evidence item are absent while the registry is not updated.

The generated `verdify init` `.agent-workflow/.gitignore` now includes `northstar/collateral/sources/`, and the test verifies copied source paths are ignored in newly initialized repos. Existing tracked source files are not purged, which is explicitly outside this lane's scope.

## Validation

- GitHub checks: `pull-request-policy` pass, `validate` pass.
- Local `ruby scripts/validate-repo.rb`: pass (`21 skills, 45 schemas`).
- Local `make test`: pass.
- Additional critic probe: pass. A high-entropy credential assignment and an AWS-shaped key were both rejected before source copy in a temporary repo.

## Residual Risk

This is a pragmatic deterministic gate for common credential/PII shapes, not a replacement for dedicated enterprise secret-scanning history audits. The skill documentation correctly keeps human/agent judgment as mandatory and does not present the scan as exhaustive.
