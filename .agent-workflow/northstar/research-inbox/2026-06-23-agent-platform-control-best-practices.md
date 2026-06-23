# Agent Platform Control Best Practices

Date: 2026-06-23
Search method: Brave Search API, followed by primary-source documentation review.
Scope: Define the first stable `agent-platform-control` request contract for
Verdify Skills as a platform-readiness artifact before any broad control-plane
execution.

## Brave Search Queries

- `Model Context Protocol authorization tools specification official docs`
- `site:modelcontextprotocol.io specification authorization tools resources official`
- `OpenAPI specification operationId security responses official docs`
- `Kubernetes SubjectAccessReview RBAC authorization official docs`
- `GitHub REST API deployments workflow runs checks official docs`
- `Open Policy Agent decision logs REST API official docs`
- `OAuth 2.0 authorization framework RFC 6749 scopes official`
- `Kubernetes audit logging official docs requestResponse metadata`

## Primary Sources Reviewed

- Model Context Protocol tools:
  https://modelcontextprotocol.io/specification/2025-11-25/server/tools
- Model Context Protocol authorization:
  https://modelcontextprotocol.io/specification/2025-11-25/basic/authorization
- OpenAPI Specification:
  https://spec.openapis.org/oas/latest.html
- Kubernetes authorization:
  https://kubernetes.io/docs/reference/access-authn-authz/authorization/
- Kubernetes SubjectAccessReview:
  https://kubernetes.io/docs/reference/kubernetes-api/authorization-resources/subject-access-review-v1/
- Kubernetes RBAC good practices:
  https://kubernetes.io/docs/concepts/security/rbac-good-practices/
- Kubernetes audit logging:
  https://kubernetes.io/docs/tasks/debug/debug-cluster/audit/
- GitHub REST API:
  https://docs.github.com/en/rest?apiVersion=2026-03-10
- GitHub workflow runs API:
  https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2026-03-10
- GitHub check runs API:
  https://docs.github.com/en/rest/checks/runs?apiVersion=2026-03-10
- GitHub deployments API:
  https://docs.github.com/en/rest/deployments/deployments?apiVersion=2026-03-10
- OAuth 2.0 RFC 6749:
  https://www.rfc-editor.org/rfc/rfc6749
- Open Policy Agent policy reference:
  https://www.openpolicyagent.org/docs/latest/policy-reference/
- Open Policy Agent decision logs:
  https://www.openpolicyagent.org/docs/latest/management-decision-logs/

## Source-Backed Findings

- MCP tools expose model-callable actions with names, descriptions, input
  schemas, and results. Agent Platform control requests should identify the
  MCP tool or API operation, summarize inputs, and separate proposed execution
  from authorization.
- MCP authorization, OAuth 2.0, and scoped credentials reinforce that control
  actions need explicit subject, scopes, token/audience mode, and protected
  resource boundaries. Verdify should record authorization context without
  copying raw tokens.
- OpenAPI operation descriptions provide operation IDs, parameters, security
  requirements, responses, and error shapes. Verdify should record operation ID,
  method/tool name, API reference, expected result, and error handling.
- Kubernetes authorization and SubjectAccessReview provide a pattern for
  asking whether a subject can perform a verb on a resource in a namespace.
  Verdify should preserve policy verdict and subject/access-review evidence
  before allowing Kubernetes, GitOps, terminal, or production-affecting actions.
- Kubernetes RBAC good practices and audit logging show that privileged actions
  should be least-privilege, namespace-scoped where possible, and auditable.
  Verdify control requests should classify mutation level and require review
  for protected or production writes.
- GitHub REST APIs for workflows, checks, deployments, and repository state
  provide authoritative external refs for control-plane operations. Verdify
  should link external refs and observed results rather than copying remote
  payloads.
- OPA decision logs show a pattern for recording policy decisions separately
  from application execution. Verdify should record policy decision ID, verdict,
  constraints, and reason.

## Implementation Implications

- Keep `agent-platform-control` as a platform-readiness artifact contract first,
  not a top-level canonical skill, until concrete Agent Platform MCP/API
  operations have one reliable manual run.
- Add `agent-platform-control-request.schema.yaml`.
- Required artifact groups should cover requester, operation, target,
  authorization, policy decision, inputs, expected effects, evidence refs,
  execution result, review gate, and handoff.
- Mutation levels should distinguish read-only, dev write, protected write, and
  production write.
- Execution should remain blocked unless authorization, policy verdict, target
  identity, rollback or recovery path, and evidence capture are explicit.
- `platform-readiness` should own the first contract and use it to assess or
  block Agent Platform API/MCP readiness.

## Limitations

- This contract does not call Agent Platform APIs or MCP tools. It only defines
  the durable request, policy, and evidence shape that must exist before safe
  execution.
- Production mutation remains gated by protected environment and human approval
  rules outside this first schema.
