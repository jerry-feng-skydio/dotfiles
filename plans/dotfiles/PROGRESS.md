# Dotfiles — In-Flight Work

## Recently Completed

### Revup Topics Extension (SkyRG)
- **Status**: done
- **Files**: `skyrg-plugin/autoload/skyrg/revup.vim`, `skyrg-plugin/autoload/skyrg/revup_topics.py`, `skyrg-plugin/autoload/skyrg/backend/context.vim`
- **What it does**: `:RevupTopics` opens a popup showing the topic chain from HEAD to auto-detected base branch. Also registered as a context action (key `r`) in gitcommit buffers.
- **Key decisions**:
  - Standalone popup, not integrated into main SkyRG search panel
  - Python script reads `.revupconfig` for `base_branch_globs` and `main_branch`
  - Base branch detected via `git for-each-ref` + fork-point distance (mimics revup logic)
  - `insert_or_replace()` replaces existing Topic:/Relative: lines in-place

## Pending

(none)
