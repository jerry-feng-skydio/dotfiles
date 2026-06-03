# AI Agent Context — How This Works

This directory provides context and rules that AI coding assistants
(Windsurf/Cascade, Claude, Cursor, Copilot, etc.) automatically pick up
when working in this repository.

## File roles

| File | Who reads it | Purpose |
|------|-------------|---------|
| `.windsurfrules` | Windsurf/Cascade | Entry point — points agents to `.ai/` |
| `.ai/ARCHITECTURE.md` | All agents | Repo structure, setup flow, plugin layers |
| `.ai/CONVENTIONS.md` | All agents | Code style, git rules, revup labels, checkpointing |
| `.ai/git-non-interactive.md` | All agents | How to use git without opening editors |
| `plans/<project>/CONTEXT.md` | All agents | Per-project architecture (symlinked as `CLAUDE.md` into work repos) |
| `plans/<project>/PROGRESS.md` | All agents | In-flight work state for multi-session continuity |

## How agents discover these files

- **Windsurf**: reads `.windsurfrules` at workspace root automatically.
  Files in `.ai/` with `trigger: always` frontmatter are loaded on every conversation.
- **Claude Code**: reads `CLAUDE.md` at repo root (symlinked from `plans/<project>/CONTEXT.md` by `plans/setup.sh`).
- **Cursor**: reads `.cursorrules` if present (not currently used here).
- **General**: any agent that scans for markdown in `.ai/` or reads `ARCHITECTURE.md` / `CONVENTIONS.md`.

## Adding new rules

1. Add a markdown file to `.ai/`.
2. Use `trigger: always` frontmatter if the rule should apply to every conversation.
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
