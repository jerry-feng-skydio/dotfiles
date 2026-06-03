---
trigger: always_on
---

# Git: Non-Interactive Usage

Never open an interactive editor from `run_command`.

- **Commits**: always pass `-m "message"`. Never bare `git commit`.
- **Amend**: use `--no-edit` or `-m "new message"`.
- **Rebase -i**: always set `GIT_SEQUENCE_EDITOR` inline (e.g. `GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash HEAD~3`).
- **Merge**: use `--no-edit` or `-m "message"`.
- **Tags**: use `git tag -m "message"` for annotated tags.
- **Fallback**: `GIT_EDITOR=true git <subcommand>`.
