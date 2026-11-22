# F-001 automation-init

> Turns an empty repo into a working Playwright + TypeScript automation project, ready to run in Azure Pipelines.

<!-- registry:start (generated from registry.json; do not edit) -->
| Type | Release | Solves | Stage |
|------|---------|--------|-------|
| command | v0.1 | P-1, P-3 | Problem: draft ([board](../../status-matrix.md)) |
<!-- registry:end -->

## Problem and users

### Users

- QA engineers starting test automation on a new project. **Confirmed** (2026-11-22)
- They know the product and how to test it manually, but have not built an automation framework before. **Draft**
- They use Playwright + TypeScript and Azure Pipelines. **Confirmed** (2026-11-22)
- Background (manual QA, new to the company) and where they work (VS Code, terminal): TBD

### Problems

- **P-1 — Starting from an empty repo.** There is no structure, no page objects, no data strategy, no runner and no CI. Each project rebuilds these differently, so tests from one project don't carry over to the next, and a newcomer can't tell which parts are essential. **Draft**
- **P-3 — Test data missing or shared between tests.** Without a place and a rule for test data, tests reuse the same records or assume data exists. Failures then look random and take long to explain. **Draft**
- What this costs today: TBD
- How users cope today: TBD

### Workflow today

_Not started._

### What success looks like

- In an empty repo, one command produces a project the user understands: where page objects go, where tests go, where test data comes from, and how CI runs it. **Draft**
- The first test the user writes runs locally and in Azure Pipelines without extra setup. **Draft**
- How we measure it: TBD

## Solution

_Not started._

## Behavior

_Not started._

## Quality

_Not started._

## Decisions

- **2026-11-22** — Stack is Playwright + TypeScript with Azure Pipelines ([ADR-0002](../../adr/0002-stack-playwright-typescript-azure-pipelines.md)).
- **2026-11-22** — Built from the VAS framework's structure, page objects, fixtures, data helper (`vas-hook-data`, V-14) and pipeline; see [existing work](../../existing-work.md).

## Changelog

_Not started._
