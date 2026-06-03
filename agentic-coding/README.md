# Agentic Coding

Single source of truth for all AI agent rules, conventions, and per-project
context used across this dotfiles repo and linked into work repos.

## Directory Structure

```
agentic-coding/
├── README.md           # This file
├── ARCHITECTURE.md     # Dotfiles repo structure, setup flow, plugin layers
├── CONVENTIONS.md      # Full conventions reference (code style, git, revup, vim)
├── rules/              # Individual rule files with Windsurf frontmatter
│   ├── revup-labels.md
│   ├── git-non-interactive.md
│   ├── code-style.md
│   └── checkpointing.md
└── context/            # Per-project agent context
    ├── setup.sh        # Symlinks CLAUDE.local.md into work repos
    ├── aircam/
    │   ├── CONTEXT.md  # Aircam-specific conventions
    │   └── PROGRESS.md # In-flight work state
    └── dotfiles/
        └── PROGRESS.md
```

## How Each Tool Discovers Rules

### Windsurf / Cascade

`setup.sh` symlinks `agentic-coding/rules/` to `~/.windsurf/rules/`, making
these rules apply **globally** across all workspaces. Each `.md` file has YAML
frontmatter with a `trigger:` field:

| Mode | `trigger:` value | When it activates |
|------|-------------------|-------------------|
| Always On | `always_on` | Every conversation |
| Model Decision | `model_decision` | Agent reads full content when `description` seems relevant |
| Glob | `glob` | When matching files are read/edited (set `globs:` pattern) |
| Manual | `manual` | Only when user types `@rule-name` in chat |

Windsurf also reads `AGENTS.md` if present (root = always on, subdirectory = scoped).

### Claude Code CLI

Claude reads `CLAUDE.md` at each repo root. For this repo, `CLAUDE.md` is
checked in and points to `agentic-coding/CONVENTIONS.md` and `ARCHITECTURE.md`.

For **other repos** (e.g. aircam), `context/setup.sh` creates a
`CLAUDE.local.md` symlink pointing to `agentic-coding/context/<project>/CONTEXT.md`.
The symlink is excluded from git via `.git/info/exclude` so it never pollutes
the shared repo.

### Cross-Tool Compatibility

Rule files use Windsurf's frontmatter format (`trigger: always_on`, etc.).
Claude ignores YAML frontmatter in markdown, so the same files work for both
tools without modification.

## Adding New Rules

1. Create a `.md` file in `agentic-coding/rules/` with appropriate frontmatter.
2. If the rule contains general conventions (not just a directive), also add it
   to `CONVENTIONS.md` for Claude and other agents to pick up.
3. Keep rules concise and imperative — agents work best with clear do/don't.

## Adding a New Project Context

1. Create `agentic-coding/context/<project>/CONTEXT.md`.
2. Add a `link_plan` line to `agentic-coding/context/setup.sh`.
3. Run `bash ~/dotfiles/agentic-coding/context/setup.sh`.
