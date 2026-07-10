# Email Workflow

## Drafting

Draft emails with:

- recipient and CRM object context;
- purpose and desired outcome;
- concise subject;
- body with one clear call to action;
- follow-up timing when relevant;
- assumptions and missing CRM fields.

## Review

Before sending, present:

- To/Cc/Bcc;
- subject;
- body;
- CRM contact/account/deal IDs;
- planned send or log endpoint;
- side effects and rollback limitations.

## Sending

Only send when the user explicitly approves the exact recipient and content.
After sending, report the CRM response ID, status, and timestamp. Do not include
the bearer token, raw headers, or unrelated CRM records.

## Logging Without Sending

When the user wants an activity note rather than delivery, log the activity
against the relevant contact/account/deal and preserve the same redaction rules.
