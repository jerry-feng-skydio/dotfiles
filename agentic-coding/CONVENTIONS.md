---
trigger: always
---

# Agent Conventions

Rules and conventions for AI coding agents working in this environment.

## Git

- **Always** pass `-m "message"` to `git commit`. Never open an interactive editor.
- For `git commit --amend`, always include `--no-edit` or `-m "new message"`.
- For `git rebase -i`, always set `GIT_SEQUENCE_EDITOR` inline.
- For merge commits, use `--no-edit` or `-m "message"`.
- Use `git tag -m "message"` for annotated tags.
- Prefer `GIT_EDITOR=true` as a fallback if no better option exists.

## Checkpointing

When the user says **"checkpoint"** or **"wrap up"**:
1. Write a concise summary of current progress, key decisions, and next steps to `~/dotfiles/agentic-coding/context/<project>/PROGRESS.md`.
2. Do NOT `git add`, `git commit`, or `git push` the dotfiles repo — the user will review and push manually.
3. Keep the summary short and actionable. Focus on: what was done, what's left, what files matter, and any decisions made.

Do NOT write plans or progress unprompted during normal work. Only write when checkpointing.

## Personal Tools, Workflows, and Documentation

All personal agent artifacts belong in **`~/.dotfiles`** — never commit them to shared repos.

| Artifact | Location in dotfiles | Linked into workspace via |
|----------|---------------------|--------------------------|
| Windsurf rules | `agentic-coding/rules/*.md` | `~/.windsurf/rules/` (global symlink) |
| Windsurf workflows | `.windsurf/workflows/*.md` | `<repo>/.windsurf/workflows/` (per-repo symlinks) |
| Per-project context | `agentic-coding/context/<project>/CONTEXT.md` | `<repo>/CLAUDE.local.md` (symlink) |
| In-flight progress | `agentic-coding/context/<project>/PROGRESS.md` | read directly from dotfiles |

When creating a new personal workflow or rule:
1. Create the file in `~/.dotfiles` at the appropriate location above.
2. Run `bash ~/.dotfiles/agentic-coding/context/setup.sh` to create symlinks into work repos.
3. The symlinks and `CLAUDE.local.md` are excluded from git via `~/.gitignore_global` and `.git/info/exclude`.

**Never** create personal workflows, rules, or `CLAUDE.local.md` directly in a shared repo — always author them in dotfiles and symlink.

## Code Style

- Follow existing code style in each file. Do not add or remove comments unless asked.
- No emojis in code unless explicitly requested.
- Imports always at the top of the file.
- Use `jfeng` as the author name in `TODO` and `NOTE` comments, e.g. `TODO(jfeng):`, `NOTE(jfeng):`.

## Vim / SkyRG

- SkyRG is a personal Vim plugin at `skyrg-plugin/` (git submodule).
- Uses Vim 8.2+ popup windows, autoload function namespacing.
- UI layer: `autoload/skyrg/ui/` — style, popup factory, keymap, events.
- Backend layer: `autoload/skyrg/backend/` — context actions, tasks, history.
- Views layer: `autoload/skyrg/views/` — search, context popup, history, tasks.
- Context actions: register via `skyrg#backend#context#register()` with `{name, key, group, priority, predicate, execute}`.
- Highlight groups managed by `skyrg#ui#style#init()`.

## Revup

- PR workflow tool (https://github.com/Skydio/revup). Topics defined by trailer-style labels in commit messages.
- Config at repo-root `.revupconfig` and `~/.revupconfig`.
- Base branch detected via `base_branch_globs` in config.
- Python helper script at `skyrg-plugin/autoload/skyrg/revup_topics.py`.

### Commit message labels — DO NOT TRAMPLE

When editing or amending commit messages, **NEVER** remove, rename, reorder, or modify the following revup labels:

| Label | Purpose |
|-------|---------|
| `Topic:` | Maps the commit to a pull request (required) |
| `Relative:` | Declares a dependency on another topic |
| `Reviewers:` | GitHub usernames or org/team slugs |
| `Assignees:` | GitHub usernames |
| `Labels:` | GitHub PR labels (e.g. `bug`, `feature`, `draft`) |
| `Branches:` | Target branch(es) for the PR |

These appear at the end of the commit message body, each on its own line.
Treat them as structured metadata — preserve them exactly as-is, including
casing and comma-separated values. When amending a commit with revup labels,
always use `--no-edit` or pass the full original message (including labels)
back via `-m`.
