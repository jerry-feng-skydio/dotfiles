# Dotfiles — In-Flight Work

## Pending

### SkyRG Device Workflow — Detect, Flash, Debug Drones from Vim
- **Status**: planned, not yet implemented
- **Plan file**: `~/.windsurf/plans/skyrg-device-workflow-e1573e.md`
- **Summary**: Context actions that detect a USB-connected drone (SSH), then offer build flashpack, flash device, tail logs, view remote files — all from the SkyRG context popup.
- **Key design decisions so far**:
  - Device detection via `ssh -o ConnectTimeout=1` to known IPs (192.168.11.1, 11.2, 10.1)
  - Remote file viewing via Vim's built-in `scp://` netrw support
  - Live log tailing via SkyRG interactive terminal (`ssh tail -f`)
  - Build/flash as async job + interactive terminal
  - Hot paths configurable via `g:skyrg_device_hot_paths`
- **Needs answers before implementing**:
  - Exact `skyrun` build target for flashpacks
  - Exact log paths for hot path defaults
  - SSH user (assumed `aircam@`) and identity file needs
  - Default device priority (QCU vs NVU vs Wi-Fi)

## Recently Completed

### Portable AI Agent Plans System
- **Status**: done
- **Files**: `.ai/CONVENTIONS.md`, `.ai/ARCHITECTURE.md`, `.ai/git-non-interactive.md`, `CLAUDE.md`, `plans/setup.sh`, `plans/aircam/CONTEXT.md`, `plans/aircam/PROGRESS.md`
- **Key decisions**:
  - `.ai/` is the single source of truth for all agent rules
  - `windsurf-rules/` contains only symlinks into `.ai/` — zero drift between tools
  - Work repos get `CLAUDE.local.md` (not `CLAUDE.md`) to avoid overwriting shared team files
  - `plans/setup.sh` called from top-level `setup.sh` in both full and soft-reset modes
  - "checkpoint" keyword triggers progress dump; no auto-push

### Revup Topics Context Action (SkyRG)
- **Status**: done
- **Files**: `skyrg-plugin/autoload/skyrg/revup.vim`, `skyrg-plugin/autoload/skyrg/revup_topics.py`, `skyrg-plugin/autoload/skyrg/backend/context.vim`, `skyrg-plugin/plugin/skyrg.vim`
- **Key decisions**:
  - Registered as context action (key `r`) in gitcommit buffers
  - Python script mimics revup's base branch detection
  - `insert_or_replace()` replaces existing Topic:/Relative: lines in-place

### Other changes
- `jfeng` as author name in `TODO`/`NOTE` comments
- Aircam pre-commit rules: `code_format` + `lint_modified`
- Cleaned up self-symlink in `windsurf-rules/`
