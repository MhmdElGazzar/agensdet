# F-001 tool-setup

> Installs every tool the user needs for Playwright automation, and verifies each one works.

<!-- registry:start (generated from registry.json; do not edit) -->
| Type | Release | Solves | Stage |
|------|---------|--------|-------|
| skill | v0.1 | P-1 | Evals: draft ([board](../../status-matrix.md)) |
<!-- registry:end -->

## Problem and users

### Users

[Manual QA starting automation](../../personas/manual-qa.md).

### Problems

- **P-1** Doesn't know where to start. Here: which tools to install, which versions, and how to know they work.

Details are in the [persona doc](../../personas/manual-qa.md#problems).

### Workflow today

Without Playwright SDET, the tester follows Playwright's installation page and web searches on their own. **Confirmed** (2026-11-22)

| # | What they do | Where it hurts (P-1) |
|---|--------------|----------------------|
| 1 | Open Playwright's installation page. | It assumes Node.js is installed and doesn't say how to install it. |
| 2 | Search how to install Node.js, Git and an editor. | Guides mix macOS and Windows commands, and some are old. |
| 3 | Install Node.js. | Doesn't know which version to pick, or whether an older Node already on the machine is enough or will break other work. |
| 4 | Install Git. | Doesn't know whether it's needed now or later. |
| 5 | Move on to creating the project ([F-005](../F-005-project-create/README.md#workflow-today)). | Never checked that the tools work; finds out only when a later command fails. |

### What success looks like

- Each tool is installed and answers a version check. **Confirmed** (2026-11-22)
- This is the first part of the setup stage; the stage ends at milestone M1 (see the [persona doc](../../personas/manual-qa.md#what-success-looks-like)).

## Solution

**Component:** the first half of the `init-project` skill. The tester types `/init-project`, or just tells Claude they want to start automation; it runs F-001, then [F-005](../F-005-project-create/README.md). See [Decisions](#decisions).

**Flow** (numbers in brackets are the [Workflow today](#workflow-today) rows each step answers):

1. Claude reads the machine (OS, version, CPU, shell) and saves it in `~/.playwright-sdet/machine.json`. Every command after this fits that machine. [2]
2. Claude checks which tools are there and at which version. [3, 4]
3. Claude shows one list: each tool, what it's for, where it lives (machine-wide or per project), and whether it's missing, old, or fine. **The tester approves the list once.** [1, 3, 4]
4. If Node is older than the LTS, **Claude asks separately before upgrading it.** [3]
5. Claude installs what's missing with the commands for this machine; Node follows the order in [ADR-0004](../../adr/0004-node-install-with-fallbacks.md).
6. If an install fails or is blocked, Claude stops, gives the tester the manual steps for their OS, waits, then checks again.
7. Claude runs a version check of each tool and shows the result. [5]

**Hands over to [F-005](../F-005-project-create/README.md):** `machine.json`, and a working Node and npm.

## Behavior

F-001 is the first half of `/init-project`; [F-005](../F-005-project-create/README.md#behavior) starts when it ends well.

### Trigger

- The tester types `/init-project`, or asks Claude in their own words to set up Playwright or start test automation.
- It doesn't start by itself for other requests (writing or running a test in an existing project).

### Inputs

- The machine, read with read-only commands (step 2).
- `~/.playwright-sdet/settings.json` and `~/.playwright-sdet/machine.json`, if they exist.
- The current Node LTS version, from `https://nodejs.org/dist/index.json` (the first entry whose `lts` isn't `false`).
- The tester's answers: language (first run only), approval of the list, approval to change an older Node.

### Outputs

- `~/.playwright-sdet/settings.json`: `{ "language": "ar" }` (the code of the language the tester chose).
- `~/.playwright-sdet/machine.json`:

  ```json
  { "os": "macos", "osVersion": "15.1", "arch": "arm64", "shell": "zsh",
    "packageManager": "homebrew", "nodeRoute": "fnm", "detectedAt": "2026-11-22T10:00:00Z" }
  ```

  `os` is `macos` or `windows`; `packageManager` is `homebrew`, `winget` or `null`; `nodeRoute` is `existing`, `fnm`, `nodejs-installer` or `manual` ([ADR-0004](../../adr/0004-node-install-with-fallbacks.md)).
- Node at the LTS major, through the route in `nodeRoute`. On the `fnm` route, one line added to the tester's shell profile.
- A summary for the tester: each tool, its version, and where it lives (for this user, for the whole machine, or per project).

### Steps

1. If `settings.json` has no language, **ask the tester which language to use**, save it, and use it from here on.
2. Read the machine and write `machine.json`:
   - macOS: `sw_vers -productVersion`, `uname -m`, `$SHELL`, `brew --version`.
   - Windows: `powershell -NoProfile -Command "[Environment]::OSVersion.Version.ToString()"`, `$PROCESSOR_ARCHITECTURE`, `winget --version`. The shell is PowerShell.
3. Check the OS is supported: macOS 13 or later, Windows 10 build 17763 (1809) or later.
4. Read the Node LTS major, and check what is there: `node --version` (any source) and `fnm --version`.
5. **Show one list and ask once**: each tool with what it's for, where it lives, its state (fine, missing, old), and what will change (for example "add one line to `~/.zshrc`").
6. The `fnm` route leaves the machine's default Node alone. The `nodejs-installer` route replaces it, so if an older Node is there, **ask separately** before taking that route.
7. Install Node by the first route that works ([ADR-0004](../../adr/0004-node-install-with-fallbacks.md)):
   - `existing`: a Node of the LTS major is already the default; install nothing.
   - `fnm` on Windows: `winget install Schniz.fnm`, then `fnm install <major>`; add `fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression` to `$PROFILE`.
   - `fnm` on macOS with Homebrew: `brew install fnm`, then `fnm install <major>`; add `eval "$(fnm env --use-on-cd --shell zsh)"` to `~/.zshrc` (or the bash line to `~/.bashrc`).
   - On the `fnm` route, the machine's default Node stays as it was.
   - `nodejs-installer`: download the LTS `.pkg` (macOS) or `.msi` (Windows) from nodejs.org and open it; the tester types the admin password.
   - `manual`: give the tester the download link and steps for their OS, and wait until they say it's done.
8. Check: `node --version` shows the LTS major (on the `fnm` route, `fnm exec --using=<major> node --version`), and `npm --version` answers.
9. Show the summary and hand over to F-005.

### When something fails

| Situation | What Claude does |
|-----------|------------------|
| The OS is not macOS or Windows | Stops: v0.1 supports macOS and Windows only. |
| The OS is older than the minimum | Stops and says the minimum version. |
| nodejs.org can't be reached | Retries once; then stops and asks the tester to check their connection or proxy, and to run `/init-project` again. |
| The tester declines the list | Stops; nothing was changed. Says what is missing. |
| The tester declines replacing an older Node | Keeps it, and moves to the `manual` route. |
| `winget` or Homebrew is missing, or the fnm install fails | Moves to the `nodejs-installer` route. |
| The installer is blocked or fails | Moves to the `manual` route. |
| The check in step 8 fails | Retries the check by the full path; if it still fails, asks the tester to restart VS Code and run `/init-project` again. |

### Running it again

- Language, machine details and a working Node are kept; those steps only re-check.
- If everything is in place, F-001 shows the summary and goes straight to F-005.

### To verify during build

- On the `fnm` route, installing a Node doesn't change the machine's default Node (fnm may make the first installed version its default).
- `fnm exec --using=<major>` works on Windows and macOS.
- `winget install Schniz.fnm` needs no admin rights.

## Quality

Cases: [`evals/F-001-tool-setup/`](https://github.com/agentic-testers/playwright-sdet/tree/main/evals/F-001-tool-setup). Automated cases run with `claude plugin eval` (3 runs each) on a fake machine (`EVAL_PSDET_MACHINE`), so nothing is installed. The rest need a recorded conversation or a real machine. All **Draft**.

| Case | Checks | How |
|------|--------|-----|
| 01 | Starts when the tester asks in their own words | automated |
| 02 | Doesn't start for a request in an existing project | automated |
| 03 | First run: asks the language first, changes nothing | automated |
| 04 | One list (purpose, where it lives, state, profile line), one approval, nothing installed yet | automated |
| 05 | Windows without winget: nodejs.org installer, admin password | automated |
| 06 | Another OS: stops | automated |
| 07 | macOS 12: stops, says macOS 13 | automated |
| 08 | Node LTS already there: installs nothing, shows the summary | automated |
| 09 | Tester approves: `brew install fnm`, then `fnm install <major>`, then the `.zshrc` line, in that order | recorded conversation |
| 10 | Tester declines the list: nothing changed, says what's missing | recorded conversation |
| 11 | Tester declines replacing an older Node: moves to the manual route | recorded conversation |
| R1 | Clean Mac with Homebrew: fnm route; the default Node is unchanged | real machine |
| R2 | Mac without Homebrew: installer route | real machine |
| R3 | Clean Windows 11: winget, fnm route, no admin prompt | real machine |
| R4 | Run `/init-project` again: everything re-checked, nothing reinstalled | real machine |

To run the automated cases: Claude Code 2.1.269 or later, the fake-machine mode built into the skill's scripts, and `--allow-tools Bash Write Edit`.

## Decisions

One decision per line: the decision, then why.

### 2026-11-22

- **F-001 covers step 1 only: installing the tools.** `automation-init` was too big; steps 2–4 went to F-005 and F-006, step 12 to F-007. *Confirmed*
- **Stack: Playwright + TypeScript, Azure Pipelines.** See [ADR-0002](../../adr/0002-stack-playwright-typescript-azure-pipelines.md). *Confirmed*
- **Step 0 is done by hand, before F-001.** The plugin can't install itself. *Confirmed*
- **Two ways for step 0: VS Code + Claude Code extension, or the Claude Code app.** Both run Claude Code on macOS 13+ and Windows 10 (1809)+. *Confirmed*
- **Prefer VS Code.** It has an editor for the tests, Playwright's extension, and a documented way to install Playwright SDET; the app has none of the three documented. *Confirmed*
- **A paid Claude account is required.** The free plan doesn't include Claude Code. *Confirmed*
- **Install Playwright SDET from `/plugins` → Marketplaces → `agentic-testers/marketplace`, then install `playwright-sdet`.** It's the documented path in VS Code. Not yet tested in VS Code. *Draft*
- **Detect the OS once and save it; later features read it.** Every command then fits the machine instead of being guessed. *Confirmed*
- **Save it in `~/.playwright-sdet/machine.json`.** The OS is machine-wide, like the tools. *Confirmed*
- **Skip a tool that is already installed at a suitable version.** Installing it again wastes time and can break other work. *Confirmed*
- **Ask once, for the whole list, before installing anything.** It changes the tester's machine; one question beats one per tool. *Confirmed*
- **Ask before upgrading an older Node.** Other work on the machine may depend on it. *Confirmed*
- **Node: the LTS version, pinned in `.nvmrc`.** Everyone on the team gets the same version. *Confirmed*
- **If a tool can't be installed, stop and ask the tester to install it, then check it.** Company laptops may block installs. *Confirmed*
- **End F-001 with a version check of each tool.** The full check, the sample test, needs the project from F-005. *Confirmed*
- **Tell the tester where each thing lives: machine-wide, per project, or shared.** Beginners mix these up, like the JDK versus a project's jars. *Confirmed*
- **`init-project` is built as a skill, not a plain command.** A skill still shows up as `/init-project`, and a beginner can also ask in their own words and Claude starts it; a plain command only runs when typed. Not an agent: the tester has to see and approve each step, and an agent works out of view. *Confirmed*
- **One command for the whole setup stage, `/init-project`: it runs F-001, then F-005, up to M1.** The tester starts the stage once; tools already in place are skipped, so it also works for a second project on a machine that is set up. *Confirmed*
- **Named `init-project`, not `init`.** Claude Code already has `/init` (it writes `CLAUDE.md`), so a tester typing `/init` would get that instead. *Confirmed*
- **F-001 installs Node only; Git waits for the "Save to git" step.** M1 doesn't need Git, so the tester isn't asked about a tool they won't use yet. *Confirmed*
- **Node is installed by the first option that works: (1) a Node of the LTS major already on the machine is used as is; (2) else fnm, per user (winget on Windows, Homebrew on macOS if it's there), keeping the machine's default Node unchanged; (3) else the nodejs.org installer, which asks for an admin password; (4) else stop and ask the tester to install it.** fnm needs no admin rights and reads `.nvmrc`, but on macOS it needs Homebrew, and blocked laptops need a way out. See [ADR-0004](../../adr/0004-node-install-with-fallbacks.md). *Confirmed*
- **v0.1 supports macOS and Windows only; on another OS `/init-project` stops.** Every command and fallback is written and tested for those two. *Confirmed*
- **Network failures are retried once, then Claude stops and asks.** One retry covers a short glitch without hiding a real proxy problem. *Confirmed*
- **The skill reads and changes the machine through its own scripts, which have a fake-machine mode for evals.** Evals can then check every route without installing anything. *Draft*
- **Eval cases live in `evals/` at the repo root, not inside `plugin/`.** Testers install only what they use. If `claude plugin eval` can't read them from there, they move to `plugin/evals/`. *Draft*

## Changelog

_Not started._
