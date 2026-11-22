# ADR-0002 — Scaffold targets Playwright, TypeScript and Azure Pipelines

- Status: Accepted (user, 2026-11-22)
- Date: 2026-11-22
- Components: v0.1 features (`/automation-init`, `/automation-run`, `test-design-basics`)

## Context

v0.1 generates an automation foundation. The scaffold, runner and CI file must target one stack to stay small. The working reference (VAS framework) uses Playwright with TypeScript and runs on Azure Pipelines, and the team's stories live in Azure DevOps.

## Decision

The v0.1 scaffold targets Playwright + TypeScript, and the generated CI file is an Azure Pipelines YAML.

## Alternatives considered

- GitHub Actions first: the team's work and the reference pipeline are on Azure. Possible in a later release.
- Several stacks (Cypress, Selenium): multiplies templates and evals before the first one is proven.

## Consequences

- VAS code can be adapted directly instead of rewritten.
- Users on other stacks or CI are not served by v0.1.
