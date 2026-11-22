# ADR-0004 — Install Node with fnm, with fallbacks

- Status: Accepted (user, 2026-11-22)
- Date: 2026-11-22
- Components: F-001, F-005

## Context

The setup stage needs Node at the LTS version, pinned in the project's `.nvmrc`. Three confirmed decisions constrain how: other work on the tester's machine may depend on the Node it already has; company laptops may block installs that need admin rights; and `.nvmrc` only does something if a tool reads it. No single installer meets all three on every machine: fnm on macOS needs Homebrew, and some laptops block everything.

## Decision

Claude tries these in order and stops at the first that works:

![Installing Node: first option that works](../assets/node-install.svg)

1. A Node of the LTS major is already on the machine: use it, install nothing.
2. fnm, per user: winget on Windows, Homebrew on macOS if it is there. Install the LTS with fnm and leave the machine's default Node unchanged.
3. The nodejs.org installer. It asks the tester for an admin password.
4. Stop, give the tester the manual steps for their OS, wait, then check again.

## Alternatives considered

- fnm only: no way forward on a Mac without Homebrew or a locked-down laptop.
- nodejs.org installer only: needs admin rights, puts one Node on the whole machine (upgrading it can break other work), and ignores `.nvmrc`.
- nvm: macOS and Linux only; nvm-windows is a separate program that needs admin rights and doesn't read `.nvmrc` by itself.
- Leave Node to the tester: brings back P-1 for the step that blocks everything else.

## Consequences

- Most testers (Windows, or a Mac with Homebrew) get a per-user Node without admin rights, and each project uses its pinned version.
- Under options 1 and 3, `.nvmrc` is a note rather than a switch; the version check in F-001 still confirms the major.
- F-005 must run project commands with the pinned Node (for example through `fnm exec`) when fnm is used.
- To verify during build on macOS and Windows: that installing with fnm doesn't change the machine's default Node, and that `fnm exec --using=.nvmrc` works.
