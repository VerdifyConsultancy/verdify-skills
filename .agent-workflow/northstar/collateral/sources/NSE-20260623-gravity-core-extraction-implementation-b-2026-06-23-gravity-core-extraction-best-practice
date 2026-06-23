# Gravity Core Extraction Implementation Best Practices

Date: 2026-06-23

Scope: Define the first stable `gravity-core-extraction` planning contract for
extracting reusable Gravity evidence-ingestion capabilities from Sunshine Club
while preserving provenance, source-object identity, and pack boundaries.

Discovery method: Brave Search API using Jason's local Brave Search credential.
Queries targeted official W3C, IETF/RFC Editor, Frictionless Data, OCI, SLSA,
RO-Crate, and GitHub documentation for provenance, manifests, checksums,
resource metadata, content descriptors, build/source provenance, research-object
packaging, and repository source refs.

## Primary Sources

- W3C PROV Data Model:
  https://www.w3.org/TR/prov-dm/
- W3C PROV Overview:
  https://www.w3.org/TR/prov-overview/
- RFC 8493 BagIt File Packaging Format:
  https://www.rfc-editor.org/rfc/rfc8493.html
- Frictionless Data Package specification:
  https://specs.frictionlessdata.io/data-package/
- OCI image-spec descriptor:
  https://github.com/opencontainers/image-spec/blob/main/descriptor.md
- SLSA build provenance:
  https://slsa.dev/spec/draft/build-provenance
- RO-Crate metadata specification:
  https://www.researchobject.org/ro-crate/specification/1.1/metadata.html
- GitHub repository contents API:
  https://docs.github.com/en/rest/repos/contents
- GitHub REST search API:
  https://docs.github.com/en/rest/search/search

## Findings

- Gravity extraction should treat each reusable file, package, schema, prompt,
  test, migration, or Kubernetes object as a source object with identity,
  provenance, source path, checksum strategy, and a reuse classification.
- W3C PROV supports modeling source objects as entities related to activities
  and agents, which maps cleanly to extraction decisions, transformations,
  ownership, and review evidence.
- BagIt-style manifests support file-package preservation by pairing paths with
  checksums. This fits a Gravity source-object inventory where local filesystem
  evidence must be preserved before transformation.
- Frictionless Data Package and RO-Crate both emphasize explicit resource
  metadata. Gravity extraction should require resource purpose, source, license
  or visibility assumptions when known, and contextual links rather than only
  copying file paths.
- OCI descriptors separate media type, digest, size, and annotations for
  addressed content. Gravity extraction can use the same pattern for source
  objects and later managed objects without coupling to container images.
- SLSA provenance records subjects, builder/process identity, dependencies, and
  materials. Gravity extraction should record which source materials produced a
  core contract, adapter, pack artifact, or discarded item.
- GitHub repository content/search APIs expose path and SHA-style source refs,
  which are useful for recording exact repository material without treating a
  mutable branch path as sufficient provenance.

## Verdify Contract Implications

- Add `gravity-core-extraction-plan.schema.yaml` as the first
  `gravity-core-extraction` mode artifact owned by `gravity-readiness`.
- Require source-system identity, target core and pack boundaries, source-object
  inventory, reuse matrix, pack assumptions, contracts, migration risks, pilot
  criteria, readiness updates, handoff, and approval.
- Require every source object to name content identity and checksum strategy
  even when the first inventory is path-only or pending hash calculation.
- Keep organization-specific schemas, prompts, personas, vault rules, taxonomy,
  paths, environment variables, and business stories out of generic core unless
  explicitly reclassified through the reuse matrix.
- Keep the first Gravity pilot scoped to local filesystem evidence ingestion and
  block feature implementation until the extraction plan and readiness gates are
  approved.

## Limitations

- This evidence defines extraction artifact shape and stop conditions. It does
  not prove Sunshine code quality, grant Gravity implementation approval, or
  replace a fresh source/test/security inventory of the Sunshine and Gravity
  repositories.
- Exact content hashes and migration tasks must be collected during a repository
  inventory run; this research only defines the contract for capturing them.
