# Playwright SDET

A Claude plugin, planned and built in small sessions. Its purpose is described in `docs/README.md`; its users in `docs/personas/`.

## How every session starts and ends

1. Read `planning/STATUS.md` first. It says what we are working on and what the next step is.
2. Work only on that step unless the user says otherwise. Sessions are short; one step is enough.
3. Before stopping, update `planning/STATUS.md` (what was done, next step, open questions), run `node scripts/registry.mjs generate` and `node scripts/registry.mjs check`.

Do not guess answers the user has not given. Unanswered items stay as `TBD` and are listed under "Open questions" in `planning/STATUS.md`.

## Doc vs workflow

Two things are kept apart ([ADR-0003](docs/adr/0003-feature-doc-separate-from-workflow.md)):

- **Doc** — what a feature is and why, written for a reader a year from now. `docs/README.md` is the plugin overview and the decisions log. Each persona has one doc, `docs/personas/<name>.md`: who they are, their problems (P-1, P-2, …, unique across personas), what success looks like, and a generated table of the features that solve each problem. Each feature has one doc, `docs/features/<id>-<name>/README.md`, organized by topic: Problem and users, Solution, Behavior, Quality, Decisions, Changelog.
- **Workflow** — how far we are. Stage skills in `.claude/skills/`, stage state in `registry.json`, plugin-wide planning in `planning/` (`STATUS.md`, `roadmap.md`, `00-existing-work.md`).

`docs/` is what we publish; `planning/`, `registry.json` and `.claude/skills/` are how we work.

### Writing docs

- Say each thing once. If it is already written elsewhere, link to it (persona details live only in the persona doc; features link to them).
- No intro sentence that restates the table or list below it.
- No column where every row has the same value; state it once above the table.
- One table with more columns beats two tables about the same rows.
- Decisions: one per line, grouped under a date heading: **the decision.** Why, in one sentence. *Confirmed* or *Draft*.
- Every stage skill follows these rules.

## Feature workflow (per feature)

| # | Stage | Skill | Writes in the feature doc |
|---|-------|-------|---------------------------|
| 1 | Problem: who the user is, what hurts, what success looks like | `feature-problem` | Problem and users → Users, Problems, What success looks like |
| 2 | Workflow: what the user does today, step by step | `feature-workflow` (TBD) | Problem and users → Workflow today |
| 3 | Design: component type, flow, alternatives (ADR when needed) | `feature-design` (TBD) | Solution, Decisions |
| 4 | Spec: trigger, inputs, outputs, tools, failure behavior | `feature-spec` (TBD) | Behavior |
| 5 | Evals: test cases written from the spec | `feature-evals` (TBD) | Quality (summary; cases in `evals/<id>-<name>/`) |
| 6 | Build: the code, until its evals pass | — | Behavior, if something changed while building |
| 7 | Release: docs, CHANGELOG, tried on a real project | `feature-release` (TBD) | Changelog |

- A stage is `not-started`, `draft`, or `approved YYYY-MM-DD`. Only the user approves. A stage starts only after the previous one is approved; `check` enforces this and that every started stage has content in its doc section.
- A feature never moves between folders. Its doc grows in place; its stage is derived from `registry.json`.
- Skills for later stages are written when the first feature reaches that stage. New features start from `planning/templates/feature-doc.md` (the `feature-problem` skill copies it).

Prioritizing between features is plugin-wide, not per feature: releases live in `planning/roadmap.md`.

### Existing work

Work that already exists is not restarted. It enters through an audit in `planning/00-existing-work.md` and sits under `existing` in `registry.json` with V-xx ids (view: `docs/existing-work.md`). It is reference material that features are `built_from`.

WIP limit: no new feature is started until every feature in progress is ready or explicitly deferred. The features of one journey stage (the steps up to its milestone) count as one item and move through the stages together.

### Component types (design stage)

- **Skill**: knowledge or a method Claude pulls in on its own when it needs it.
- **Command**: an action the user starts themselves (e.g. `/run-tests`).
- **Agent**: a large, isolated task with its own context.
- **Hook**: something that runs automatically before or after a given tool.
- **MCP server**: access to an external system (ADO, Playwright, an API).

## Registry and generated views

`registry.json` is the single source for features (type, release, problems, stages, path, depends_on, built_from), the plugin's main user journeys (`workflows`), and the audited existing work (`existing`). Generated from it, never edited by hand:

- `docs/status-matrix.md` (the board), `docs/component-map.md`, `docs/workflows.md`, `docs/existing-work.md`, `docs/adr/README.md`
- the status block between `registry:start` and `registry:end` in each feature doc
- the solutions table between `solutions:start` and `solutions:end` in each persona doc
- the journey diagram between `journey:start` and `journey:end` in the root `README.md` (Getting started), from the first workflow that has `stages`

Commands: `node scripts/registry.mjs generate` after any change; `check` before finishing a session or merging; `snapshot <version>` at each release (copy in `docs/snapshots/<version>/`).

Docs site: `website/` is Docusaurus and reads `docs/` directly (nothing is copied). Diagrams are SVG images the script generates into `docs/assets/`, not Mermaid. Preview with `cd website && npm run build && npm run serve`. Plain `.md` files are parsed as CommonMark, so HTML comments in generated blocks are fine; don't rename them to `.mdx`.

A design decision that a diagram cannot explain gets a short ADR in `docs/adr/` (copy `0000-template.md`) and a dated line under "Decisions" in the feature doc.

## Releases

Every feature belongs to exactly one release (v0.1 MVP, v0.2, v1.0). Each release bumps `version` in `plugin.json` and adds a `CHANGELOG.md` entry. The board may move to GitHub Projects or Azure DevOps later; that decision is open.

### Definition of Done

A feature is `Ready` only when all seven stages are approved, which means:

- [ ] Its spec has been reviewed by the user (spec approved)
- [ ] Its evals pass (build approved)
- [ ] It has been tried on a real project (release approved)
- [ ] Its doc, the plugin `README.md` and `CHANGELOG.md` are updated (release approved)

## Secrets

`.env` holds tokens and is git-ignored. Never print its values or commit it. `.env.example` lists the keys only.
