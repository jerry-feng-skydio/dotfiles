---
trigger: always_on
---

# Git: Non-Interactive Usage

When using git from `run_command`, you MUST avoid any command that opens an interactive editor. The agent's terminal cannot interact with editors like vim.

## Rules

### Commits
- **Always** pass `-m "message"` to `git commit`.
- **Never** run bare `git commit` (it opens an editor).
- For `git commit --amend`, **always** include `--no-edit` if keeping the existing message, or `-m "new message"` if changing it.

### Rebases
- For `git rebase -i`, **always** set `GIT_SEQUENCE_EDITOR` inline to a non-interactive command.
  - Example (autosquash): `GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash HEAD~3`
  - Example (custom reorder): `GIT_SEQUENCE_EDITOR="sed -i 's/^pick HASH/fixup HASH/'" git rebase -i HEAD~3`
- **Never** run bare `git rebase -i` without `GIT_SEQUENCE_EDITOR`.

### Merges
- For merge commits, use `git merge --no-edit` to accept the default message.
- Or pass `-m "message"` explicitly.

### Tags
- Use `git tag -m "message"` for annotated tags, never bare `git tag -a`.

### General
- If a git subcommand has a `--no-edit` flag, prefer using it.
- Prefer `GIT_EDITOR=true` as an environment prefix if no better option exists:
  `GIT_EDITOR=true git <subcommand>`
