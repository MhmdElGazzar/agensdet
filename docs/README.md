# Playwright SDET

A Claude plugin that helps QA engineers with their test automation work in Playwright and Azure Pipelines, starting from a manual tester's first test.

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

- **The plugin ships from `plugin/`; the rest of the repo is how we build it.** Users install only the plugin, not our docs, site and scripts. *Confirmed*
- **Repos live under the `agentic-testers` GitHub organization, not a personal account.** The name describes who the plugins are for, and others can be given access without sharing a personal account. *Confirmed*
- **The marketplace is its own repo, `agentic-testers/marketplace`, named `agentic-testers`.** Later testing and quality plugins join the same catalog, so testers add it once and the add command never changes. *Confirmed*
- **From the VAS framework we reuse skills only: no code, no data, nothing from its projects.** It's company work; the method is what we need. *Confirmed*
- **The language Claude uses with the tester is a setting, saved in `~/.playwright-sdet/settings.json`.** It's the tester's preference; Claude asks once and remembers. *Confirmed*
- **Whether to merge with AgenTeX is deferred.** Not needed for the current stage. *Confirmed*
- **Docs site: Docusaurus in `website/`, reading `docs/` directly.** One source for GitHub and the site; it adds a sidebar and one place to read everything. *Confirmed*
- **Diagrams are SVG images generated from `registry.json`, not Mermaid.** Mermaid's look was poor; an SVG shows the same on GitHub, the site and VS Code. *Confirmed*
- **Playwright SDET decides what must be the same for everyone, or what a beginner can't judge.** Asking a beginner those questions brings P-1 back. *Confirmed*
- **Claude detects what it can read from the machine instead of asking.** Fewer questions. *Confirmed*
- **The tester decides anything that changes their machine, lives outside the project, or is their preference.** It's their machine. *Confirmed*
- **Milestones (M1, M2, …) mark what the user can do at each point of the journey; M1 is "tools installed and verified".** They show progress inside a release. *Confirmed*
- **Name: Playwright SDET in prose, `playwright-sdet` as the identifier (was AgenSDET).** It names the tool and the role, covers all automation work rather than just the start, and doesn't repeat "agentic" from the organization's name. *Confirmed*
- **P-5's solution: the plugin reviews its own output against a project quality standard (F-004).** Nobody on the team can review yet. *Confirmed*
- **First persona: the manual QA starting automation.** *Confirmed*
- **Problems before solutions, solved one at a time from P-1.** So each solution answers a known problem. *Confirmed*

## Out of scope

- Story-to-tests workflow, debugging and review: not in v0.1. **Confirmed**
- No-code, spec-driven testing (the AgenTeX plugin). Merging is deferred.
- Other stacks and other CI in v0.1. **Draft**
