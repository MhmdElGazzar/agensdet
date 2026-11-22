# AgenSDET

A Claude plugin that helps manual QA engineers start test automation: from an empty repo to Playwright tests running in Azure Pipelines.

Marks used in these docs: **Confirmed** (said by the product owner), **Draft** (proposed), **TBD** (no answer yet).

## Personas

| Persona | In short |
|---------|----------|
| [Manual QA starting automation](personas/manual-qa.md) | Knows the project, basic coding, no automation in the team |

Problem IDs (P-1, P-2, …) are unique across personas and never reused. A dropped problem stays listed as `Dropped`.

## Features and views

Generated from `registry.json`:

- [Status matrix](status-matrix.md): every feature, its stage, and the problems it solves. Each feature's full story is in `features/<id>-<name>/README.md`.
- [Component map](component-map.md) · [Workflow view](workflows.md) · [Existing work](existing-work.md) (the audited VAS framework)
- [ADRs](adr/README.md): decisions that had alternatives

## Decisions

One decision per line: the decision, then why.

### 2026-11-22

- **Docs site: Docusaurus in `website/`, reading `docs/` directly.** One source for GitHub and the site; it adds a sidebar and one place to read everything. *Confirmed*
- **Diagrams are SVG images generated from `registry.json`, not Mermaid.** Mermaid's look was poor; an SVG shows the same on GitHub, the site and VS Code. *Confirmed*
- **AgenSDET decides what must be the same for everyone, or what a beginner can't judge.** Asking a beginner those questions brings P-1 back. *Draft*
- **Claude detects what it can read from the machine instead of asking.** Fewer questions. *Draft*
- **The tester decides anything that changes their machine, lives outside the project, or is their preference.** It's their machine. *Draft*
- **Milestones (M1, M2, …) mark what the user can do at each point of the journey; M1 is "tools installed and verified".** They show progress inside a release. *Confirmed*
- **Name: AgenSDET in prose, `agensdet` as the identifier.** Repo and plugin names must be lowercase. *Confirmed*
- **P-5's solution: the plugin reviews its own output against a project quality standard (F-004).** Nobody on the team can review yet. *Confirmed*
- **First persona: the manual QA starting automation.** *Confirmed*
- **Problems before solutions, solved one at a time from P-1.** So each solution answers a known problem. *Confirmed*

## Out of scope

- Story-to-tests workflow, debugging and review: not in v0.1. **Confirmed**
- No-code, spec-driven testing (the AgenTeX plugin): separate or merge, TBD.
- Other stacks and other CI in v0.1. **Draft**
