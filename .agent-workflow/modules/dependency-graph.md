# Module Dependency Graph

Hard dependencies form an acyclic graph:

```text
governance-routing
  -> evidence-northstar
    -> definition-architecture-strategy
      -> planning-hygiene
        -> execution-control
          -> lane-assurance
            -> release-package
      -> readiness-integration
        -> execution-control

governance-routing -> quality-enablement
```

`quality-enablement` has soft review dependencies on all modules but no module may require documentation generation to execute its runtime behavior. Shared CLI additions coordinate through `governance-routing`; shared repository validation and documentation changes coordinate through `quality-enablement`.
