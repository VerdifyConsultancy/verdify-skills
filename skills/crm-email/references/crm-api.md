# CRM API Reference

## Current Known Boundary

- Base URL: `https://crm.verdify.ai`
- Credential env var: `VERDIFY_CRM_API_KEY`
- Auth header: `Authorization: Bearer <token>`
- Public probes of common OpenAPI paths returned the web app shell rather than
  a machine-readable API spec as of 2026-07-08.

## Discovery Procedure

1. Prefer official CRM API docs or an exported OpenAPI spec when available.
2. If docs are unavailable, inspect browser network calls in an authenticated
   session or ask the CRM owner for endpoint contracts.
3. Record discovered endpoints here with method, path, required fields, response
   shape, and side effects.
4. Treat endpoints that send email, mutate contacts, or create public activity
   as write operations requiring explicit user approval.

## Endpoint Contract Template

```text
Method:
Path:
Purpose:
Required fields:
Optional fields:
Response fields:
Side effects:
Approval required:
Notes:
```

## Safety Rules

- Do not send exploratory write requests.
- Do not print or persist bearer tokens.
- Do not assume a SPA route returning HTTP 200 is an API endpoint.
- Log only redacted request metadata: method, path, status, object IDs, and
  timestamps.
