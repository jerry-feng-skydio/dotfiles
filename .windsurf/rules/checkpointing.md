---
trigger: model_decision
description: How to handle checkpoint / wrap-up requests — write progress to plans/ directory.
---

# Checkpointing

When the user says **"checkpoint"** or **"wrap up"**:

1. Write a concise summary of current progress, key decisions, and next steps to `~/dotfiles/plans/<project>/PROGRESS.md`.
2. Do NOT `git add`, `git commit`, or `git push` the dotfiles repo — the user will review and push manually.
3. Keep the summary short and actionable. Focus on: what was done, what's left, what files matter, and any decisions made.

Do NOT write plans or progress unprompted during normal work. Only write when checkpointing.
