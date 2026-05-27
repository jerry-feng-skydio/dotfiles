# Aircam

## Overview

Monorepo for the Aircam product. Shared by the team.

## Workflow

- **PR tool**: revup (`revup upload`)
- **Topic tags**: `Topic:` and `Relative:` in commit messages
- **Base branches**: release branches matching `rc*`, `mfg*`, `npi*`, `feature/**`, `stable-candidate` (configured in `.revupconfig`)
- **Main branch**: `master`
- **Remote**: `origin`

## Conventions

- Revup config at repo root `.revupconfig`
- User oauth in `~/.revupconfig`

## Agent Notes

- This is a **shared repo** — do not commit agent plans, `CLAUDE.md`, or `.ai/` files
- `CLAUDE.md` is symlinked from `~/dotfiles/plans/aircam/CONTEXT.md` and excluded via `.git/info/exclude`
- In-flight work tracked in `~/dotfiles/plans/aircam/PROGRESS.md`
