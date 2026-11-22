# F-001 tool-setup

> Installs every tool the user needs for Playwright automation, and verifies each one works.

<!-- registry:start (generated from registry.json; do not edit) -->
| Type | Release | Solves | Stage |
|------|---------|--------|-------|
| command | v0.1 | P-1 | Workflow: not-started ([board](../../status-matrix.md)) |
<!-- registry:end -->

## Problem and users

### Users

[Manual QA starting automation](../../personas/manual-qa.md).

### Problems

- **P-1** Doesn't know where to start. Here: which tools to install, which versions, and how to know they work.

Details are in the [persona doc](../../personas/manual-qa.md#problems).

### Workflow today

_Not started._

### What success looks like

- Each tool is installed and answers a version check. **Confirmed** (2026-11-22)
- This is the first part of the setup stage; the stage ends at milestone M1 (see the [persona doc](../../personas/manual-qa.md#what-success-looks-like)).

## Solution

_Not started._

## Behavior

_Not started._

## Quality

_Not started._

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

## Changelog

_Not started._
