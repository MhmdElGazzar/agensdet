# Manual QA starting automation

A manual QA engineer who knows their project well and starts test automation in a team where nobody automates yet. **Confirmed** (2026-11-22) unless marked otherwise.

## Who they are

- Knows the project's screens, business rules and the scenarios worth testing.
- Coding: basics only (variables, functions), never built a project. Will grow over time.
- Team: nobody does automation yet.
- Tools: Playwright + TypeScript, Azure Pipelines, stories in Azure DevOps. Has a paid Claude account (required).
- Where they work (VS Code, terminal): TBD, needed at the design stage.

## Problems

All five happen to them. Solved one at a time, in ID order.

| ID | Problem | Real example | Cost today |
|----|---------|--------------|------------|
| P-1 | **Doesn't know where to start:** what to install, how to organize the project, how to run a test. | Not needed: measured on a demo site instead | — |
| P-2 | **Doesn't know what to check:** the test clicks through screens but proves nothing. | TBD | TBD |
| P-3 | **No reliable test data:** the data may not exist, or tests share it and break each other. | TBD | TBD |
| P-4 | **Can't tell why a test fails:** broken locator, timing, missing data, or a real bug. | TBD | TBD |
| P-5 | **Nobody to ask or to review:** mistakes go unnoticed, and each teammate does it differently. | TBD | TBD |

How they cope today: TBD.

## What success looks like

- **P-1:** starting from an empty folder, they run a test on a demo website such as [automationexercise.com](https://www.automationexercise.com/test_cases) by themselves. **Confirmed** (2026-11-22)
  - Milestones on the way:
    - **M1, tools installed and verified:** end of the setup stage (F-001, F-005). A sample test on the demo site runs and passes inside their new project. **Confirmed** (2026-11-22)
    - Next milestones: TBD
- P-2 to P-5: TBD

## Solutions

Generated from `registry.json`.

<!-- solutions:start (generated from registry.json; do not edit) -->
| Problem | Solved by | Stage |
|---------|-----------|-------|
| P-1 | [F-001 tool-setup](../features/F-001-tool-setup/README.md) | Workflow: not-started |
| P-1 | [F-005 project-create](../features/F-005-project-create/README.md) | Workflow: not-started |
| P-1 | F-006 project-structure | Problem: not-started |
| P-1 | F-007 ci-pipeline | Problem: not-started |
| P-2 | F-003 test-design-basics | Problem: not-started |
| P-3 | F-003 test-design-basics | Problem: not-started |
| P-3 | F-006 project-structure | Problem: not-started |
| P-4 | F-002 automation-run | Problem: not-started |
| P-5 | F-004 quality-review | Problem: not-started |
| P-5 | F-006 project-structure | Problem: not-started |
<!-- solutions:end -->
