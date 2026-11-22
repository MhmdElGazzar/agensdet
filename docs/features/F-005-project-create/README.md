# F-005 project-create

> Creates the Playwright project, explains its files, and ends the setup stage with a sample test (milestone M1).

<!-- registry:start (generated from registry.json; do not edit) -->
| Type | Release | Solves | Stage |
|------|---------|--------|-------|
| command | v0.1 | P-1 | Workflow: draft ([board](../../status-matrix.md)) |
<!-- registry:end -->

## Problem and users

### Users

[Manual QA starting automation](../../personas/manual-qa.md), right after [F-001](../F-001-tool-setup/README.md) has installed and checked their tools.

### Problems

- **P-1** Doesn't know where to start. Here: how to create a Playwright project, what its files are for, and how to know it runs.

Details are in the [persona doc](../../personas/manual-qa.md#problems).

### Workflow today

After installing the tools ([F-001](../F-001-tool-setup/README.md#workflow-today)), the tester follows Playwright's installation page. What the commands do is **Confirmed** from `create-playwright` 1.17.139; where it hurts is **Draft**.

| # | What they do | Where it hurts (P-1) |
|---|--------------|----------------------|
| 1 | Make a folder and run `npm init playwright@latest`. | It asks five questions they can't judge: TypeScript or JavaScript, where to put the tests, add a GitHub Actions workflow, install browsers, install OS dependencies (needs admin rights). |
| 2 | Wait for the browsers to download. | It downloads three browsers (Chromium, Firefox, WebKit) when one is enough to start. |
| 3 | Open the files it created: `playwright.config.ts`, `tests/example.spec.ts`, `package.json`. | Doesn't know which file matters, or what the config settings do. |
| 4 | Run `npx playwright test`. | It runs without showing a browser, in all three browsers, against playwright.dev, not a site they know. The result is a report they have to open. |

### What success looks like

- The sample test passes, headed, inside the tester's new project: milestone M1, the end of the setup stage (see the [persona doc](../../personas/manual-qa.md#what-success-looks-like)). **Confirmed** (2026-11-22)
- The tester can say what the project's main files and the four explained config settings are for. **Confirmed** (2026-11-22)

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
- **Playwright SDET answers the `npm init playwright` questions: TypeScript, `tests`, no GitHub Actions.** A beginner can't judge them, and we use Azure Pipelines. *Confirmed*
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
- **F-005 solves P-1 only; P-4 was removed.** Problems are solved one at a time, and P-4 hasn't been worked on yet. *Confirmed*

## Changelog

_Not started._
