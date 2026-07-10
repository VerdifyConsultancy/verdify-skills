---
name: crm-email
description: Draft, review, search context for, and send CRM-backed email through Verdify CRM. Use when Codex needs to work with crm.verdify.ai email workflows, contact/account context, follow-up drafting, campaign or one-to-one email preparation, CRM activity logging, or API-backed email operations using credential references only.
metadata:
  author: Verdify
  version: "1.3.0"
  category: registry
---

# CRM Email

Use Verdify CRM as the source of contact/account context and the delivery or
logging system for email work. Never store raw API keys in repo files, prompt
artifacts, logs, examples, or package manifests.

## Credential Boundary

- Read credentials from `VERDIFY_CRM_API_KEY`.
- Default base URL is `https://crm.verdify.ai`.
- Do not echo bearer tokens or write them into `.agent-workflow`.
- If a request fails, report status, endpoint, and redacted response context.
- Use dry-run drafts unless the user explicitly asks to send or log.

## Workflow

1. Clarify intent: draft, revise, search CRM context, send, or log activity.
2. Identify target contact/account/deal identifiers and missing recipient data.
3. Pull CRM context only when needed. Read `references/crm-api.md` before making
   API calls.
4. Draft with a clear subject, recipient, purpose, CTA, and follow-up timing.
5. Ask for review before any external send unless the request already includes
   explicit send approval and recipient identity.
6. Send or log through the CRM only after approval. Record the CRM object IDs,
   endpoint used, status, and timestamp, but not the API key.

## API Helper

Use `scripts/crm_request.rb` for low-level CRM calls:

```bash
VERDIFY_CRM_API_KEY="$TOKEN" \
  ruby skills/crm-email/scripts/crm_request.rb \
  --method GET \
  --path /api/contacts
```

For request bodies, pass a JSON file:

```bash
ruby skills/crm-email/scripts/crm_request.rb \
  --method POST \
  --path /api/email/drafts \
  --body draft.json \
  --dry-run
```

`--dry-run` validates the request and emits only redacted metadata and a body
digest. It does not require credentials or open a network connection. Remove it
only after the user has approved the target and external write.

Read `references/email-workflow.md` before send/log operations or when choosing
between draft, activity log, campaign, and one-to-one email behavior.
