# F-005 project-create

> Creates the Playwright project, explains its files, and ends the setup stage with a sample test (milestone M1).

<!-- registry:start (generated from registry.json; do not edit) -->
| Type | Release | Solves | Stage |
|------|---------|--------|-------|
| skill | v0.1 | P-1 | Build: draft ([board](../../status-matrix.md)) |
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

**Component:** the second half of the `init-project` skill (`/init-project`), right after [F-001](../F-001-tool-setup/README.md). See [F-001's decisions](../F-001-tool-setup/README.md#decisions).

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

F-005 is the second half of `/init-project`; it starts only when [F-001](../F-001-tool-setup/README.md#behavior) ended well.

### Trigger

- F-001 finished with a working Node, in the same `/init-project` run.

### Inputs

- `~/.playwright-sdet/machine.json` (OS, `nodeRoute`) and the Node LTS major, from F-001.
- The folder open in VS Code.
- The tester's answer: the project folder.

### Outputs

A project folder containing:

- `.nvmrc`: the LTS major only, for example `24`.
- What `create-playwright` makes: `package.json`, `playwright.config.ts`, `.gitignore`, `node_modules/`, and Chromium in Playwright's shared browser folder. With `--no-examples` it makes no `tests/` folder; Claude creates it for the sample test.
- `playwright.config.ts` changed in three places: `baseURL: 'https://www.automationexercise.com'`, `trace: 'retain-on-failure'`, `screenshot: 'only-on-failure'`.
- `tests/sample.spec.ts`, two tests run in order (`test.describe.serial`), so the second runs only if the first passes:
  1. **Machine check**: opens a local page (`page.setContent`) and sees its heading. No network.
  2. **Test Case 7: Verify Test Cases Page**: blocks the site's ad requests, opens the home page and checks it's visible, clicks the menu link "Test Cases", checks the URL ends with `/test_cases` and the "Test Cases" heading is visible.
- For the tester: what each main file is for, the four config settings, how to run the tests again (`npx playwright test --headed`) and open the report (`npx playwright show-report`).

### Steps

Commands run with the project's Node: on the `fnm` route, through `fnm exec --using=.nvmrc`.

1. If the open folder is already a Playwright project, say so and **ask: use it, or create a new one elsewhere**. Otherwise suggest a folder: the open folder if it's empty, else a new `playwright-tests` folder inside it. Empty means nothing, or only `.git`, `.vscode`, `.claude`, `.idea` or `.DS_Store`. **The tester confirms or gives another.**
2. Write `.nvmrc`.
3. Run `npm init playwright@latest -- --quiet --lang=TypeScript --browser=chromium --no-examples`.
4. Change the three config settings.
5. Explain the files and the four settings (`baseURL`, `projects`, `reporter`, trace and screenshot on failure).
6. Write `tests/sample.spec.ts`.
7. Run `npx playwright test tests/sample.spec.ts --headed`. The tester watches the browser.
8. Both pass: say milestone M1 is reached. One fails: say which one.

### When something fails

| Situation | What Claude does |
|-----------|------------------|
| The chosen folder isn't empty | Asks for another folder; never writes into a folder with other files. |
| The chosen folder already has a `playwright.config.*` | Says it's already a Playwright project and asks: use it (go to step 6) or pick another folder. |
| `npm init` or the browser download can't reach the network | Retries once; then stops, shows the error, and asks the tester to check their connection or proxy and run `/init-project` again. |
| The machine check fails | Runs `npx playwright install chromium` and tries once more; if it still fails, stops and shows the error. The site test isn't run. |
| The Test Case 7 test fails | Runs it once more; if it still fails, says the machine is fine (the first check passed) and the site didn't respond as expected, and shows the error. |

### Running it again

- If the folder already holds this project, steps 1–5 are skipped and the sample test runs again.

### To verify during build

- ~~A cookie or consent dialog on automationexercise.com~~ Found 2026-11-22: no consent dialog from Egypt, but a full-page Google ad (`#google_vignette`) can cover the menu; blocking ad requests fixed it (10 of 10 runs passed). Still to check from the EU, where a consent dialog may show.
- ~~`--quiet` makes `tests` the test folder~~ Verified 2026-11-22: `testDir: './tests'`.

## Quality

Cases: [`plugin/evals/F-005-project-create/`](https://github.com/agentic-testers/playwright-sdet/tree/main/plugin/evals/F-005-project-create). How they run: see [F-001's Quality](../F-001-tool-setup/README.md#quality). **Confirmed** (2026-11-22).

| Case | Checks | How |
|------|--------|-----|
| 01 | Empty open folder: suggests it, asks to confirm | automated |
| 02 | Folder with other files: suggests `playwright-tests` inside it, writes nothing | automated |
| 03 | Folder already a Playwright project: says so, asks use it or pick another | automated |
| 04 | After the folder is confirmed: `.nvmrc` with the major, `npm init` with the exact flags, the three config changes, `sample.spec.ts` with the two checks in order | recorded conversation |
| R5 | Clean Mac and clean Windows: both checks pass headed, M1 is announced | real machine |
| R6 | No network to the demo site: the machine check passes, Claude says the site didn't respond | real machine |
| R7 | Consent dialog (EU) and full-page ads on automationexercise.com are handled | real machine |

## Decisions

One decision per line: the decision, then why.

### 2026-11-22

- **F-005 covers steps 2–4: create the project, explain its files, run a sample test.** Together they end the setup stage. *Confirmed*
- **Playwright SDET answers the `npm init playwright` questions: TypeScript, `tests`, no GitHub Actions.** A beginner can't judge them, and we use Azure Pipelines. *Confirmed*
- **Chromium only at first.** One download, and one place to look when something fails. *Confirmed*
- **Chromium, not Chrome.** It ships with Playwright at a matching version; installed Chrome updates by itself and can stop matching. *Confirmed*
- **Chromium, not Firefox.** It's the engine inside Chrome and Edge, which most people use. *Confirmed*
- **Add other browsers later, based on the real users of the tester's product.** It's one line in `projects`. *Confirmed*
- **Create the project with `--no-examples` (was: remove `tests-examples/`).** `create-playwright` 1.17.139 no longer makes `tests-examples/`; its remaining example tests playwright.dev, which confuses beginners. *Confirmed*
- **Explain four config settings: `baseURL`, `projects`, `reporter`, and trace and screenshot on failure.** The rest can wait. *Confirmed*
- **The tester confirms the project folder's location and name; Claude suggests one.** It's their file. *Confirmed*
- **End with a sample test on the demo site, inside the new project; passing it is M1.** It proves every tool works together. *Confirmed*
- **Sample test: Test Case 7 "Verify Test Cases Page".** It changes no data, so it passes on every run. *Confirmed*
- **Run it headed.** The tester sees the browser move. *Confirmed*
- **Check in two steps: a local page, then the demo site.** A failure then says whether the machine or the site is the problem. *Confirmed*
- **F-005 solves P-1 only; P-4 was removed.** Problems are solved one at a time, and P-4 hasn't been worked on yet. *Confirmed*
- **Answer `npm init playwright` with its own flags, not by typing into its prompts.** The flags are documented and give the same result every time. *Confirmed*
- **Suggested folder: the open folder if it's empty, else a new `playwright-tests` folder inside it.** The tester most likely opened the folder they want to work in. *Confirmed*
- **Never write into a folder that has other files.** The tester's files stay untouched. *Confirmed*
- **The sample test blocks the demo site's ad requests.** A full-page ad covered the menu and failed the first real run; ads aren't part of the test. *Draft*
- **A folder with only `.git`, `.vscode`, `.claude`, `.idea` or `.DS_Store` counts as empty.** Editors and git create these on their own; found while running the evals. *Draft*
- **The two sample checks run in order, and the site check only runs after the machine check passes.** A site failure then can't hide a machine problem. *Confirmed*

## Changelog

_Not started._
