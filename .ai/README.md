# AI Agent Context — How This Works

This directory provides context and rules that AI coding assistants
(Windsurf/Cascade, Claude, Cursor, Copilot, etc.) automatically pick up
when working in this repository.

## File roles

| File | Who reads it | Purpose |
|------|-------------|---------|
| `.windsurf/rules/*.md` | Windsurf/Cascade | Per-rule files with activation frontmatter |
| `.ai/ARCHITECTURE.md` | All agents | Repo structure, setup flow, plugin layers |
| `.ai/CONVENTIONS.md` | All agents | Code style, git rules, revup labels, checkpointing |
| `.ai/git-non-interactive.md` | All agents | How to use git without opening editors |
| `plans/<project>/CONTEXT.md` | All agents | Per-project architecture (symlinked as `CLAUDE.md` into work repos) |
| `plans/<project>/PROGRESS.md` | All agents | In-flight work state for multi-session continuity |

## How agents discover these files

- **Windsurf/Cascade**: reads `.windsurf/rules/*.md` files. Each file has YAML
  frontmatter with a `trigger:` field controlling when it activates:
  - `always_on` — included in every conversation
  - `model_decision` — description shown always, full content loaded on demand
  - `glob` — activated when matching files are read/edited (e.g. `globs: **/*.py`)
  - `manual` — only when user types `@rule-name`
  Windsurf also reads `AGENTS.md` files (root = always on, subdirectory = scoped).
- **Claude Code**: reads `CLAUDE.md` at repo root (symlinked from `plans/<project>/CONTEXT.md` by `plans/setup.sh`).
- **Cursor**: reads `.cursorrules` if present (not currently used here).
- **General**: any agent that scans for markdown in `.ai/` or reads `ARCHITECTURE.md` / `CONVENTIONS.md`.

Note: `.windsurfrules` (single file at root) is a legacy format. We use
`.windsurf/rules/` (one file per rule) instead.

## Adding new rules

1. For Windsurf rules: add a `.md` file to `.windsurf/rules/` with appropriate
   `trigger:` frontmatter (`always_on`, `model_decision`, `glob`, or `manual`).
2. For cross-agent rules: add to `.ai/CONVENTIONS.md` or create a new `.ai/*.md`
   file with `trigger: always` frontmatter.
3. Keep rules concise and imperative — agents work best with clear "do/don't" instructions.
4. Update `ARCHITECTURE.md` if repo structure changes.
5. Update `CONVENTIONS.md` for new code style or workflow rules.

## Cross-repo portability

`plans/setup.sh` symlinks project context into work repos:
```
~/dotfiles/plans/aircam/CONTEXT.md  →  ~/aircam/CLAUDE.md
```
This means agents working in `~/aircam` get project-specific context
without duplicating files. Run `setup.sh` after adding new project plans.
