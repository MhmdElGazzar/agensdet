# Getting started

> **Status: planning.** Nothing is installable yet. The journey below is what v0.1 is being built for.

## The journey

From an empty folder to a first passing test on a demo website such as [automationexercise.com](https://www.automationexercise.com/test_cases).

<!-- journey:start (generated from registry.json; do not edit) -->
![First test (P-1)](assets/journey.svg)

Red dashed: no feature covers the step yet (pick a scenario, find the elements). Grey dashed: done by hand. Faded: later, not part of the first goal.
<!-- journey:end -->

## Before you start

You need a paid Claude account (Pro, Max, Team, Enterprise or Console) and macOS 13+ or Windows 10 (1809)+.

1. Get Claude Code, one of two ways:
   - **A. VS Code + the Claude Code extension (recommended).** You get an editor for your tests and Playwright's VS Code extension.
   - **B. The Claude Code desktop app.**
2. Install AgenSDET: type `/plugins`, open **Marketplaces**, add `MhmdElGazzar/agensdet`, then **Install**.

Why these choices: [F-001 decisions](features/F-001-tool-setup/README.md#decisions).
