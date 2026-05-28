# Dotfiles — In-Flight Work

## Recently Completed

### Portable AI Agent Plans System
- **Status**: done
- **Files**: `.ai/CONVENTIONS.md`, `.ai/ARCHITECTURE.md`, `.ai/git-non-interactive.md`, `CLAUDE.md`, `plans/setup.sh`, `plans/aircam/CONTEXT.md`, `plans/aircam/PROGRESS.md`, `plans/dotfiles/PROGRESS.md`
- **What it does**: Portable context system for AI agents across machines and tools.
- **Key decisions**:
  - `.ai/` is the single source of truth for all agent rules
  - `windsurf-rules/` contains only symlinks into `.ai/` — zero drift between tools
  - Work repos get `CLAUDE.local.md` symlinked (not `CLAUDE.md`) to avoid overwriting shared team files
  - Local gitignore via `.git/info/exclude` — never touches shared `.gitignore`
  - `plans/setup.sh` handles symlink creation, called from top-level `setup.sh` (runs in both full and soft-reset modes)
  - "checkpoint" keyword triggers progress dump; no auto-push — user reviews and pushes manually

### Revup Topics Context Action (SkyRG)
- **Status**: done
- **Files**: `skyrg-plugin/autoload/skyrg/revup.vim`, `skyrg-plugin/autoload/skyrg/revup_topics.py`, `skyrg-plugin/autoload/skyrg/backend/context.vim`, `skyrg-plugin/plugin/skyrg.vim`
- **What it does**: `:RevupTopics` opens a popup showing the topic chain from HEAD to auto-detected base branch. Registered as a context action (key `r`) in gitcommit buffers via `skyrg#backend#context#register()`.
- **Key decisions**:
  - Standalone popup, not integrated into main SkyRG search panel
  - Python script reads `.revupconfig` for `base_branch_globs` and `main_branch`
  - Base branch detected via `git for-each-ref` + fork-point distance (mimics revup logic)
  - `insert_or_replace()` replaces existing Topic:/Relative: lines in-place
  - Resolved merge conflict in `plugin/skyrg.vim` — kept upstream commands, added `RevupTopics`

### Other changes
- Added `jfeng` as author name convention for `TODO`/`NOTE` comments
- Added aircam pre-commit rules: `./skyrun bin code_format --file <path>` + `./skyrun bin lint_modified`
- Cleaned up accidental `windsurf-rules/windsurf-rules` self-symlink

## Pending

(none)
