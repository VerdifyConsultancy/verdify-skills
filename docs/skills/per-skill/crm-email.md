# crm-email

**Registry skill:** CRM-backed email drafting, review, send/log workflows, and
safe `crm.verdify.ai` API access.

## Use

Use when an agent needs to draft a CRM-context email, prepare follow-up,
retrieve CRM contact/account context, send approved email, or log an email
activity through Verdify CRM.

## Inputs

| Input | Authority |
|---|---|
| CRM API key | Environment variable `VERDIFY_CRM_API_KEY` |
| CRM base URL | `VERDIFY_CRM_BASE_URL`, default `https://crm.verdify.ai` |
| Contact/account/deal IDs | User or CRM API |
| Approved message content | User review |

## Outputs

| Output | Consumer |
|---|---|
| Draft email | User/reviewer |
| Redacted CRM request metadata | Audit/handoff |
| CRM response status/object IDs | User/reviewer |

## Safety

- Never store raw CRM API keys in the repo or generated artifacts.
- Require explicit approval before send/log write operations.
- Use `skills/crm-email/scripts/crm_request.rb` for low-level calls and keep
  tokens in environment variables only.
- Validate request fixtures with `--dry-run`; it emits redacted metadata and a
  body digest without credentials or network access.

## References

- `skills/crm-email/SKILL.md`
- `skills/crm-email/references/crm-api.md`
- `skills/crm-email/references/email-workflow.md`
- `packs/crm-email/pack.yaml`
