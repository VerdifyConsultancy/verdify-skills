# Supply Chain, Policy, And Knowledge Store Primary Sources

Date: 2026-06-23
Evidence status: observed

## Scope

This note follows primary documentation for supply-chain provenance, SBOM and
component provenance, policy-as-code, Kubernetes access boundaries, and
knowledge-store/storage primitives relevant to production readiness.

## Followed Sources

- SLSA build provenance:
  https://slsa.dev/spec/v1.2/build-provenance
- Tekton Chains signed provenance tutorial:
  https://tekton.dev/docs/chains/signed-provenance-tutorial/
- Tekton Chains SLSA provenance:
  https://tekton.dev/docs/chains/slsa-provenance/
- CycloneDX provenance use case:
  https://cyclonedx.org/use-cases/provenance/
- Open Policy Agent docs:
  https://www.openpolicyagent.org/docs
- Kubernetes RBAC good practices:
  https://kubernetes.io/docs/concepts/security/rbac-good-practices/
- Kubernetes multi-tenancy:
  https://kubernetes.io/docs/concepts/security/multi-tenancy/
- Qdrant filtering:
  https://qdrant.tech/documentation/search/filtering/
- pgvector:
  https://github.com/pgvector/pgvector

## Observed Findings

- SLSA build provenance is verifiable information about where, when, and how
  artifacts were produced, and it is intended to let consumers verify that
  artifacts were built according to expectations or rebuild them if desired.
- SLSA provenance uses an in-toto attestation predicate type and includes
  build definition and run details as required fields at SLSA Build L1.
- Tekton Chains can automatically generate and sign in-toto attestations for
  images built in Tekton, store attestations in a transparency log, and query
  those attestations.
- CycloneDX provenance guidance describes tracking origin, development,
  ownership, location, and modifications of software components for a complete
  auditable chronology.
- OPA is a general-purpose policy engine for policy-as-code and can externalize
  policy decisions across microservices, Kubernetes, CI/CD pipelines, API
  gateways, and other systems.
- Kubernetes RBAC good practices emphasize least privilege and minimizing
  distribution of privileged service-account tokens.
- Kubernetes RBAC guidance treats namespace boundaries as weak and warns that
  resources with different trust or tenancy should be separated while still
  applying minimum necessary permissions.
- Kubernetes multi-tenancy guidance requires RBAC for tenant namespace access
  and notes that ResourceQuota can prevent tenants from monopolizing cluster
  resources or overwhelming the control plane.
- pgvector and Qdrant support different stages of a knowledge store: pgvector
  keeps embeddings with relational data in Postgres; Qdrant provides payload
  filtering for vector search.

## North Star Implications

- Production-ready release evidence should eventually include provenance,
  signatures or attestations, and SBOM/component evidence, but review-ready
  pilot work can phase this after immutable artifact identity, CI/test evidence,
  preview deployment, rollback notes, and traceability.
- `release-verification` should distinguish review-ready evidence from
  production-ready supply-chain evidence.
- `wave-release-planning` should define when SLSA/Tekton Chains/CycloneDX/OPA
  proof is mandatory versus backlog.
- `platform-readiness` and `agent-platform-control` should include policy-as-code
  hooks rather than relying only on prompt instructions for privileged actions.
- Kubernetes access for agents should be namespace-scoped, least-privilege,
  quota-bound, and audited; direct production mutation remains out of scope for
  worker agents.
- Gravity knowledge storage should treat pgvector and Qdrant as different
  tradeoff points rather than assuming one permanent store.

## Limitations

- This note does not inspect the local CI substrate, Tekton availability, or
  existing SBOM tooling.
- This note does not define the final OPA policy package.
- This note does not decide whether Gravity's first reusable store is Postgres,
  pgvector, Qdrant, or a hybrid.
