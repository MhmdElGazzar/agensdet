# F-005 project-create

> Creates the Playwright project, explains its files, and ends the setup stage with a sample test (milestone M1).

<!-- registry:start (generated from registry.json; do not edit) -->
| Type | Release | Solves | Stage |
|------|---------|--------|-------|
| command | v0.1 | P-1, P-4 | Problem: not-started ([board](../../status-matrix.md)) |
<!-- registry:end -->

## Problem and users

### Users

_Not started._

### Problems

_Not started._

### Workflow today

_Not started._

### What success looks like

_Not started._

## Solution

_Not started._

## Behavior

_Not started._

## Quality

_Not started._

## Decisions

One decision per line: the decision, then why.

### 2026-11-22

- **F-005 covers steps 2–4: create the project, explain its files, run a sample test.** Together they end the setup stage. *Confirmed*
- **AgenSDET answers the `npm init playwright` questions: TypeScript, `tests`, no GitHub Actions.** A beginner can't judge them, and we use Azure Pipelines. *Confirmed*
- **Chromium only at first.** One download, and one place to look when something fails. *Confirmed*
- **Chromium, not Chrome.** It ships with Playwright at a matching version; installed Chrome updates by itself and can stop matching. *Confirmed*
- **Chromium, not Firefox.** It's the engine inside Chrome and Edge, which most people use. *Confirmed*
- **Add other browsers later, based on the real users of the tester's product.** It's one line in `projects`. *Confirmed*
- **Remove `tests-examples/`.** It tests another site and confuses beginners. *Confirmed*
- **Explain four config settings: `baseURL`, `projects`, `reporter`, and trace and screenshot on failure.** The rest can wait. *Confirmed*
- **The tester confirms the project folder's location and name; Claude suggests one.** It's their file. *Confirmed*
- **End with a sample test on the demo site, inside the new project; passing it is M1.** It proves every tool works together. *Confirmed*
- **Sample test: Test Case 7 "Verify Test Cases Page".** It changes no data, so it passes on every run. *Confirmed*
- **Run it headed.** The tester sees the browser move. *Confirmed*
- **Check in two steps: a local page, then the demo site.** A failure then says whether the machine or the site is the problem. *Confirmed*

## Changelog

_Not started._
