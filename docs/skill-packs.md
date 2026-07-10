# Skill Packs

Verdify stores atomic skills in `skills/<skill>/SKILL.md` and composes them
into installable packs under `packs/<pack>/pack.yaml`.

A skill answers what an agent can do. A pack answers which skills belong
together for a job. Workflows still define sequencing, gates, and handoffs.

## Registry Layout

```text
skills/
  project-router/
  northstar-planning/
  issue-triage/

packs/
  sdlc-core/
    pack.yaml
  northstar-strategy/
    pack.yaml
  research-analysis/
    pack.yaml
  crm-email/
    pack.yaml

schemas/
  skill-pack.schema.yaml
```

`skills/` stays flat for Codex and Claude host compatibility. Packs are the
packaging layer over those skills.

## Pack Manifest

Each `pack.yaml` validates against `schemas/skill-pack.schema.yaml` and records:

- required and optional skills;
- capabilities the pack provides;
- pack and tool dependencies;
- conflicting packs;
- default host and profile metadata.

## Commands

List available packs:

```bash
verdify pack list
```

Install one pack into a target repository:

```bash
verdify pack install --repo /path/to/repo --pack research-analysis --host codex
```

Pack installation is transactional. Verdify preflights every selected host
link and the installed-pack manifest before changing the repository. A conflict
without `--force` leaves zero new links or manifest state. A later write failure
rolls back every newly created target and restores any operator-owned target
temporarily replaced by `--force`. Before the first mutation, every operator
target is copied to a verified backup set. Created paths, replaced paths,
operator targets, and backups are tracked separately, and rollback retains the
verified backups if an individual restoration cannot finish.

Download and install one pack through npm:

```bash
npx @verdify-cli/cli dl research-analysis --repo /path/to/repo --host codex
npx @verdify-cli/cli dl crm-email --repo /path/to/repo --host codex
```

Install optional skills as well:

```bash
npx @verdify-cli/cli dl sdlc-core --include-optional
```

Full lifecycle installation remains available:

```bash
npx @verdify-cli/cli init --repo /path/to/repo
```

To initialize workflow artifacts while selecting a narrower pack:

```bash
npx @verdify-cli/cli init --repo /path/to/repo --pack sdlc-core
```
