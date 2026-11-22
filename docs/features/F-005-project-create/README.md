# F-005 project-create

> Creates the Playwright project, explains its files, and ends the setup stage with a sample test (milestone M1).

<!-- registry:start (generated from registry.json; do not edit) -->
| Type | Release | Solves | Stage |
|------|---------|--------|-------|
| skill | v0.1 | P-1 | Design: draft ([board](../../status-matrix.md)) |
<!-- registry:end -->

## Problem and users

### Users

[Manual QA starting automation](../../personas/manual-qa.md), right after [F-001](../F-001-tool-setup/README.md) has installed and checked their tools.

### Problems

- **P-1** Doesn't know where to start. Here: how to create a Playwright project, what its files are for, and how to know it runs.

Details are in the [persona doc](../../personas/manual-qa.md#problems).

### Workflow today

After installing the tools ([F-001](../F-001-tool-setup/README.md#workflow-today)), the tester follows Playwright's installation page. What the commands do is from `create-playwright` 1.17.139. **Confirmed** (2026-11-22)

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

**Component:** a skill, `create-project`. The tester runs `/playwright-sdet:create-project`, or accepts Claude's offer at the end of [F-001](../F-001-tool-setup/README.md). See [Decisions](#decisions).

**Flow** (numbers in brackets are the [Workflow today](#workflow-today) rows each step answers):

1. Claude suggests a folder location and name; **the tester confirms or changes it.**
2. Claude writes `.nvmrc` with the Node LTS version.
3. Claude runs `npm init playwright@latest -- --quiet --lang=TypeScript --browser=chromium --no-examples`: no questions, one browser, no example tests, no GitHub Actions. [1, 2]
4. Claude sets `baseURL` to the demo site and turns on trace and screenshot on failure in `playwright.config.ts`.
5. Claude explains the main files and the four config settings, briefly. [3]
6. Claude writes the sample test (Test Case 7) with its two checks: a local page, then the demo site.
7. Claude runs it headed; the tester watches the browser. [4]
8. When it passes, Claude says milestone M1 is reached. If it fails, Claude says which of the two checks failed.

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
- **Create the project with `--no-examples` (was: remove `tests-examples/`).** `create-playwright` 1.17.139 no longer makes `tests-examples/`; its remaining example tests playwright.dev, which confuses beginners. *Draft*
- **Explain four config settings: `baseURL`, `projects`, `reporter`, and trace and screenshot on failure.** The rest can wait. *Confirmed*
- **The tester confirms the project folder's location and name; Claude suggests one.** It's their file. *Confirmed*
- **End with a sample test on the demo site, inside the new project; passing it is M1.** It proves every tool works together. *Confirmed*
- **Sample test: Test Case 7 "Verify Test Cases Page".** It changes no data, so it passes on every run. *Confirmed*
- **Run it headed.** The tester sees the browser move. *Confirmed*
- **Check in two steps: a local page, then the demo site.** A failure then says whether the machine or the site is the problem. *Confirmed*
- **F-005 solves P-1 only; P-4 was removed.** Problems are solved one at a time, and P-4 hasn't been worked on yet. *Confirmed*
- **F-005 is a skill, `create-project`, separate from F-001.** Same reasons as [F-001's component decisions](../F-001-tool-setup/README.md#decisions). *Draft*
- **Answer `npm init playwright` with its own flags, not by typing into its prompts.** The flags are documented and give the same result every time. *Draft*

## Changelog

_Not started._
