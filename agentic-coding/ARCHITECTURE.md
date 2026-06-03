# Dotfiles Architecture

## Repository Structure

```
dotfiles/
├── .vimrc              # Main Vim config, symlinked to ~/.vimrc
├── .vimrc_macos        # macOS-specific Vim config
├── .bashrc             # Shell config, symlinked to ~/.bashrc
├── .tmux.conf          # Tmux config
├── .gitconfig          # Git config
├── setup.sh            # Machine bootstrap script (installs + symlinks)
├── skyrg-plugin/       # SkyRG Vim plugin (git submodule → SkyRG repo)
├── vim-lcm/            # LCM syntax highlighting plugin
├── skyrg.vim           # Legacy standalone SkyRG (pre-plugin version)
├── scripts/            # Utility scripts
├── CLAUDE.md           # Claude Code entry point → points to agentic-coding/
└── agentic-coding/     # All AI agent rules, conventions, and project context
    ├── rules/          # Windsurf rules (symlinked to ~/.windsurf/rules)
    ├── context/        # Per-project context (CONTEXT.md, PROGRESS.md)
    ├── ARCHITECTURE.md # This file
    └── CONVENTIONS.md  # Full conventions reference
```

## Setup Flow

`setup.sh` bootstraps a new machine:
1. Parses flags (`-s` for soft reset, skips installs)
2. Symlinks dotfiles into `$HOME`
3. Symlinks `agentic-coding/rules/` to `~/.windsurf/rules/`
4. Installs Vundle plugins, fzf, vim, tmux, etc.
5. Runs `agentic-coding/context/setup.sh` to link agent context into work repos

## SkyRG Plugin (`skyrg-plugin/`)

Managed as a git submodule. Loaded into Vim via runtimepath in `.vimrc`.

### Layers
- **UI** (`autoload/skyrg/ui/`): popup factory, style registry, keymap, events
- **Backend** (`autoload/skyrg/backend/`): context actions, async tasks, action log, history
- **Views** (`autoload/skyrg/views/`): search panel, context popup, history browser, task viewer
- **Panel** (`autoload/skyrg/panel/`): legacy multi-pane search UI (form, results, preview, tree)

### Key entry points
- `:SkyRG <query>` — open search
- Context popup via `g:skyrg_context_key` mapping
- `:RevupTopics` — revup topic chain viewer (gitcommit context action)

## Context System (`agentic-coding/context/`)

Portable AI agent context for cross-machine, cross-tool work.
- `context/<project>/CONTEXT.md` — architecture, conventions for that project
- `context/<project>/PROGRESS.md` — in-flight work state
- `context/setup.sh` — symlinks `CONTEXT.md` as `CLAUDE.local.md` into each work repo
