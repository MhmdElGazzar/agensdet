# ADR-0001 — One registry file is the source for all design views

- Status: Proposed (waiting for the user to confirm)
- Date: 2026-11-22
- Components: all

## Context

Hand-drawn diagrams and a hand-edited board go stale within weeks. The plugin needs a component map, a workflow view and a status matrix that stay correct as it grows.

## Decision

- `registry.json` at the repo root lists every component (type, state, release, dependencies, task status) and every main workflow.
- `scripts/registry.mjs` generates the three views into `docs/` and can check and snapshot them.
- A component's stage is derived from its task status, never typed by hand.

## Alternatives considered

- `registry.yaml`: easier to read and allows comments, but needs a YAML parser installed. JSON runs on plain Node with no install step, locally and in CI.
- Reading everything from the component files with no registry: cannot hold ideas that have no file yet, releases, or dependencies.
- A stage field typed by hand: lets the board say "Ready" while the evidence says otherwise.

## Consequences

- The feature board is generated (`docs/status-matrix.md`); `planning/04-roadmap.md` keeps only releases and deferred ideas.
- Adding a component file without registering it fails `check`.
- JSON has no comments, so the reason behind a choice goes in an ADR.
