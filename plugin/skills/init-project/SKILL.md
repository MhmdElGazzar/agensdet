---
name: init-project
description: Sets up a tester's machine and a new Playwright + TypeScript project, and ends with a sample test that passes (milestone M1). Use when the tester types /init-project, or asks to start test automation, set up Playwright, or install what they need to write automated tests. Not for writing or running tests in a project that already exists.
---

# init-project

Two parts, in order: **tools** (F-001), then **project** (F-005). The tester is a manual QA engineer starting automation: plain words, short messages, one question at a time.

Scripts are in this skill's `scripts/` folder (the base directory shown when the skill loads). Always run them with `bash`. Use them for everything they cover; don't replace them with your own commands. Never run an install before the tester approved the list (part 1, step 4).

Speak in the tester's language (`language` from `detect.sh`). The words of the messages below are a guide, not a script.

## Part 1: tools

1. Run `bash <base>/scripts/detect.sh` and read the JSON.
2. **Language.** If `language` is null, ask which language the tester wants you to use (offer Arabic and English, accept any). Save `{ "language": "<code>" }` to `~/.playwright-sdet/settings.json` and use it from now on. Then continue.
3. **Supported?** If `supported` is false, explain `reason` simply, say nothing was changed, and stop. Don't suggest other ways to install. If only nodejs.org couldn't be reached, run `detect.sh` once more; if it still fails, ask the tester to check their connection or proxy and run `/init-project` again, and stop.
4. **Pick the Node route** (ADR-0004), the first that fits:
   - `existing`: `node` starts with `v<ltsMajor>.`, or `fnmNode` is set.
   - `fnm`: `packageManager` is `winget` (Windows) or `homebrew` (macOS).
   - `nodejs-installer`: otherwise. If `node` is set (an older Node), this route replaces it: **ask separately** whether that's OK; if not, use `manual`.
5. **One list, one approval.** Show a short list and ask once:
   - Node `<ltsMajor>` (runs Playwright and the tests): its state (fine / missing / older `vX`), and how it will be installed.
   - On the `fnm` route: fnm (keeps one Node version per project, for this user only, no admin rights) and the one line added to `~/.zshrc` (macOS) or the PowerShell profile (Windows).
   - On the `nodejs-installer` route: the tester will type their admin password in the installer.
   - Where each lives: fnm and its Node are for this user; the nodejs.org Node is for the whole machine; Playwright and its browser come later, per project (the browser is shared by projects).
   If everything is already fine, skip the question and the install, and go to step 7 (route `existing`).
   If the tester declines: say nothing was changed and what is still missing, and stop.
6. **Install** after approval:
   - `fnm`: `bash <base>/scripts/install-node.sh fnm <ltsMajor>`
   - `nodejs-installer`: `bash <base>/scripts/install-node.sh nodejs-installer <ltsMajor>`, then wait until the tester says the installer finished.
   - `manual`: give the tester the steps for their OS: open https://nodejs.org, download the LTS installer (`.pkg` on macOS, `.msi` on Windows), run it. Wait until they say done.
   The last line of `install-node.sh` is JSON. If `ok` is false: from `fnm` move to `nodejs-installer` (ask again only if it replaces an older Node); from `nodejs-installer` move to `manual`.
7. **Save** `~/.playwright-sdet/machine.json` (create the folder if needed):
   `{ "os", "osVersion", "arch", "shell", "packageManager", "nodeRoute", "detectedAt" }` from `detect.sh`, with `nodeRoute` set to the route that worked and `detectedAt` the current time in ISO 8601.
8. **Check.** Run `detect.sh` again: the route worked if `node` starts with `v<ltsMajor>.` or `fnmNode` is set. If not, run it once more; if it still fails, ask the tester to restart VS Code and run `/init-project` again, and stop.
9. **Summary**, in a few lines: each tool, its version, where it lives. Then go straight to part 2.

## Part 2: project

Run every project command through `bash <base>/scripts/run.sh <project-dir> <command…>`, so it uses the project's Node.

1. **Folder.** A folder counts as empty if it has nothing, or only `.git`, `.vscode`, `.claude`, `.idea` or `.DS_Store`. If the folder open in VS Code (the current working directory) already has a `playwright.config.*`, say it's already a Playwright project and ask: use it (go to step 6) or create a new one in another folder. Else, if it's empty, suggest it; otherwise suggest a new `playwright-tests` folder inside it. Ask the tester to confirm or give another path.
   - The chosen folder has a `playwright.config.*`: say it's already a Playwright project and ask: use it (go to step 6) or pick another folder.
   - The chosen folder exists and has other files: ask for another folder. Never write into it.
2. Create the folder if needed. Write `.nvmrc` containing only `<ltsMajor>`.
3. Run `bash <base>/scripts/run.sh <dir> npm init playwright@latest -- --quiet --lang=TypeScript --browser=chromium --no-examples`. Its closing message mentions `tests/example.spec.ts`; that file isn't created, so ignore it. On a network error, run it once more; then stop and ask the tester to check their connection or proxy.
4. In `playwright.config.ts`, change exactly three things:
   - `// baseURL: 'http://localhost:3000',` → `baseURL: 'https://www.automationexercise.com',`
   - `trace: 'on-first-retry',` → `trace: 'retain-on-failure',`
   - add `screenshot: 'only-on-failure',` right after the trace line.
5. **Explain** briefly: `package.json` (the project and its packages), `playwright.config.ts` (settings), `tests/` (the tests), `.gitignore`, `node_modules/` (downloaded packages, never edited); and the four settings: `baseURL`, `projects` (only Chromium for now; other browsers can be added later), `reporter` (the HTML report), trace and screenshot on failure.
6. Create `tests/` and copy `<base>/templates/sample.spec.ts` to `tests/sample.spec.ts`. Tell the tester what the two checks do.
7. Run `bash <base>/scripts/run.sh <dir> npx playwright test tests/sample.spec.ts --headed`. Tell the tester a browser window will open.
8. Result:
   - Both pass: say **milestone M1 is reached: tools installed and verified**. Show how to run the tests again (`npx playwright test --headed`) and open the report (`npx playwright show-report`).
   - The machine check fails: run `bash <base>/scripts/run.sh <dir> npx playwright install chromium`, then the test once more. If it still fails, stop and show the error.
   - The Test Case 7 check fails: run it once more. If it still fails, say the machine is fine (the first check passed) and the website didn't respond as expected, and show the error.

## Running it again

Steps already done only re-check: a saved language isn't asked again, a working Node isn't reinstalled, and an existing project skips to step 6 of part 2.
