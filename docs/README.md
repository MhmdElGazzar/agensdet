# agensdet

A Claude plugin that helps QA engineers who are starting test automation build a working foundation, from an empty repo to tests running in Azure Pipelines with a readable report.

> Status: draft. **Confirmed** = said by the product owner; **Draft** = proposed, waiting for confirmation; **TBD** = no answer yet.

## Users

- **Role:** QA engineers starting test automation on a new project. **Confirmed** (2026-11-22)
  - Coming from manual testing, new to automation, or new to the company: TBD
  - Developers too, or QA only: TBD
- **Skill level:** knows the product and how to test it manually; little or no experience building an automation framework. **Draft**
- **Tools:** Playwright + TypeScript for tests, Azure Pipelines for CI, Azure DevOps for stories. **Confirmed** (2026-11-22, [ADR-0002](adr/0002-stack-playwright-typescript-azure-pipelines.md))
- **Where they work:** TBD (VS Code with Claude Code, terminal, or both)

## Problems

The problems agensdet exists to remove. Each feature doc explains in detail the problems it solves; the [status matrix](status-matrix.md) shows which feature solves which problem.

IDs are stable: never reused or renumbered. A dropped problem stays in the table as `Dropped` with the reason. A new problem gets the next free ID.

| ID | Problem | Status |
|----|---------|--------|
| P-1 | Starting from an empty repo: no structure, no page objects, no data strategy, no runner or CI, so every project rebuilds these differently. | Draft |
| P-2 | First tests click through the UI but do not prove the result (no check on the item, quantity or stored state). | Draft |
| P-3 | Test data missing or shared between tests, so failures look random and are hard to explain. | Draft |
| P-4 | A failed run gives no short answer: which tests ran, which passed only on retry, which never ran. | Draft |

- What these problems cost today (time, defects, rework): TBD
- How users cope today: TBD (copy an older project? tutorials? ask a senior?)

## What success looks like

- In a fresh repo, the user runs `/automation-init`, writes one test with help from the `test-design-basics` skill, runs it with `/automation-run`, pushes, and Azure Pipelines runs it and publishes a readable report. **Draft**
- How we measure it: TBD (time from empty repo to first green CI run? share of tests that assert a business result?)

## Features

The [status matrix](status-matrix.md) lists every feature with its stage and links to its doc. Each feature doc lives in `features/<id>-<name>/README.md` and tells the feature's whole story: problem, solution, behavior, quality, decisions, changelog.

## Out of scope

- The full story-to-tests workflow, debug and review: later releases (v0.2, v1.0). **Confirmed** (2026-11-22)
- Spec-driven, no-code testing: covered by the AgenTeX plugin. Keep separate or merge: TBD
- Other stacks (Cypress, Selenium, Java) and other CI (GitHub Actions) in v0.1. **Draft**

## Design views

Generated from `registry.json`; never edited by hand.

- [Component map](component-map.md): features and who uses whom
- [Workflow view](workflows.md): the plugin's main user journeys
- [Status matrix](status-matrix.md): the feature board
- [Existing work](existing-work.md): the audited VAS framework that features are built from
- [Decisions (ADRs)](adr/)
