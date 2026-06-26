# Contributing

Changes should begin with a GitHub issue that states the problem and desired outcome. Implementation pull requests target `dev` and must link that issue with a supported closing keyword; discovered maintenance work belongs in the backlog rather than an undocumented exception.

`dev` is the long-running development integration branch. `main` is the protected release branch and should only be updated by the generated `dev -> main` release PR. Every push to `dev` opens or updates that release PR; merging it to `main` triggers the npm publish workflow.

Before opening a pull request:

```bash
make test
```

Skill changes must keep `SKILL.md` below 500 lines, use progressive disclosure, preserve one canonical schema location, and add or update evaluation scenarios. Workflow changes must update `verdify.workflow.yaml`, relevant documentation, and examples.

Do not add a dependency without explaining why Ruby, Git, Bash, and GitHub CLI are insufficient.
