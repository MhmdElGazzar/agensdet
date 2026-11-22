# ADR-0003 — One doc per feature, kept separate from the workflow state

- Status: Accepted (user, 2026-11-22)
- Date: 2026-11-22
- Components: all features
- Replaces: the plugin-wide phase files (`planning/01-problem-and-users.md`, `02-workflows.md`, `03-component-map.md`, `features/_TEMPLATE.md`) and the task-based stage of ADR-0001

## Context

The first layout had one file per workflow phase for the whole plugin. After two or three features those files would mix several features' users, problems and designs, and nobody could read one feature's story from start to end. It also mixed two things: the **doc** (what a feature is and why) and the **workflow** (how far we are with it).

## Decision

- **Doc:** each feature has one file, `docs/features/<id>-<name>/README.md`, organized by topic for the reader: Problem and users, Solution, Behavior, Quality, Decisions, Changelog. GitHub shows it when the folder is opened. The plugin-wide overview lives in `docs/README.md`. Each persona has its own doc in `docs/personas/` with its problems (P-1, P-2, …) and a generated table of the features that solve them (added 2026-11-22).
- **Workflow:** stages problem → workflow → design → spec → evals → build → release. Each stage is a skill in `.claude/skills/` that writes its section of the doc. The state of each stage (not-started, draft, approved with a date) is in `registry.json`. The board is generated.
- A feature does not move between folders. Its doc grows in place; the stage is derived from the registry.
- Evals live outside the doc (`evals/<id>-<name>/`); the doc's Quality section keeps a summary.

## Alternatives considered

- **One folder per stage, the feature moves or is copied between them:** moving breaks links from the registry, ADRs and other docs; copying leaves two versions that drift; and the story is split again.
- **One folder per feature with one file per stage:** clean for the workflow, but the reader has to open seven files to understand one feature.
- **Stage status inside the doc (front matter):** mixes workflow into the doc. A small generated status block is shown instead, so the doc stays accurate without being edited by hand.

## Consequences

- `scripts/registry.mjs check` enforces that a stage marked started has content in its doc section, and that a stage starts only after the previous one is approved.
- The existing VAS components move under `existing` in the registry with V-xx ids; they are reference material, not Playwright SDET features.
- Skills for the later stages (`feature-workflow`, `feature-design`, …) are written when the first feature reaches them.
