# Secrets And Credential Injection Patterns

Date: 2026-06-23
Discovery method: Brave Search API, followed by direct URL reachability checks.
Status: researched for North Star evidence ingest.

## Brave Search Coverage

- Query: `External Secrets Operator Vault Agent Injector Kubernetes Secrets encryption at rest GitHub Actions OIDC secret injection`
- Follow-up query: `site:external-secrets.io External Secrets Operator Kubernetes Secret OR site:developer.hashicorp.com Vault Agent Injector Kubernetes OR site:kubernetes.io secrets encryption at rest OR site:docs.github.com OIDC cloud providers actions`
- Selection rule: prefer official operator, HashiCorp, Kubernetes, and GitHub documentation.

## Primary Sources Followed

- External Secrets Operator overview: https://external-secrets.io/latest/introduction/overview/
- External Secrets Operator security best practices: https://external-secrets.io/latest/guides/security-best-practices/
- External Secrets Operator threat model: https://external-secrets.io/latest/guides/threat-model/
- HashiCorp Vault Agent Injector for Kubernetes: https://developer.hashicorp.com/vault/docs/deploy/kubernetes/injector
- Kubernetes Secrets: https://kubernetes.io/docs/concepts/configuration/secret/
- Kubernetes encrypting confidential data at rest: https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/
- GitHub Actions OIDC cloud provider hardening: https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-cloud-providers

## Source-Backed Findings

- External Secrets Operator synchronizes secret material from external secret providers into Kubernetes by using custom resources and a controller, so it improves source-of-truth handling but can still result in Kubernetes Secret objects that require Kubernetes RBAC, namespace, and datastore controls.
- External Secrets Operator's own threat model and security guidance make the operator, its service account, SecretStore/ClusterSecretStore scope, and namespace boundaries part of the security boundary rather than neutral plumbing.
- Vault Agent Injector uses Kubernetes admission/mutation behavior to add Vault Agent sidecars or init containers that can retrieve and render secrets for pods at runtime.
- Kubernetes documents Secrets as Kubernetes API objects and provides a separate task for encrypting secret data at rest, which means a cluster without encryption-at-rest and tight RBAC leaves secret data exposed through etcd backups, API access, or overly broad service accounts.
- GitHub Actions OIDC lets workflows request short-lived tokens from cloud providers instead of storing long-lived cloud credentials as GitHub secrets, which fits the North Star requirement for CI credentials to be scoped and ephemeral.

## Planning Relevance

- Supports `ARQ-003` and `ARCH-007`: prefer runtime secret injection, short-lived credentials, and scoped identities over reusable secrets in prompts or committed artifacts.
- Supports platform-readiness checks for Kubernetes Secrets encryption at rest, namespace-scoped SecretStores, least-privilege operator service accounts, and explicit approval before ClusterSecretStore or production secret access.
- Supports CI/CD planning that uses GitHub OIDC or equivalent workload identity for cloud and registry access where possible.
- Supports the local Brave Search credential handling used by this research loop: store a project reference to the local secret path, not the raw token.

## Limitations

- This pass did not inspect the local cluster's EncryptionConfiguration, External Secrets Operator installation, Vault deployment, or GitHub OIDC trust policies.
- This pass does not choose between External Secrets Operator and Vault Agent Injector; it records the tradeoff surface for platform-readiness evaluation.
