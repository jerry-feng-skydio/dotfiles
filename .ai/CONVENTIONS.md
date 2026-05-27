# Agent Conventions

Rules and conventions for AI coding agents working in this environment.

## Git

- **Always** pass `-m "message"` to `git commit`. Never open an interactive editor.
- For `git commit --amend`, always include `--no-edit` or `-m "new message"`.
- For `git rebase -i`, always set `GIT_SEQUENCE_EDITOR` inline.
- For merge commits, use `--no-edit` or `-m "message"`.
- Use `git tag -m "message"` for annotated tags.
- Prefer `GIT_EDITOR=true` as a fallback if no better option exists.

## Code Style

- Follow existing code style in each file. Do not add or remove comments unless asked.
- No emojis in code unless explicitly requested.
- Imports always at the top of the file.

## Vim / SkyRG

- SkyRG is a personal Vim plugin at `skyrg-plugin/` (git submodule).
- Uses Vim 8.2+ popup windows, autoload function namespacing.
- UI layer: `autoload/skyrg/ui/` — style, popup factory, keymap, events.
- Backend layer: `autoload/skyrg/backend/` — context actions, tasks, history.
- Views layer: `autoload/skyrg/views/` — search, context popup, history, tasks.
- Context actions: register via `skyrg#backend#context#register()` with `{name, key, group, priority, predicate, execute}`.
- Highlight groups managed by `skyrg#ui#style#init()`.

## Revup

- PR workflow tool. Topics defined by `Topic:` and `Relative:` tags in commit messages.
- Config at repo-root `.revupconfig` and `~/.revupconfig`.
- Base branch detected via `base_branch_globs` in config.
- Python helper script at `skyrg-plugin/autoload/skyrg/revup_topics.py`.
