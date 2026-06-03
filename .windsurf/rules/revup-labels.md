---
trigger: always_on
---

# Revup Commit Message Labels

This project uses Skydio's revup (https://github.com/Skydio/revup) for stacked PRs.

When editing or amending commit messages, **NEVER** remove, rename, reorder, or modify these revup labels:

- `Topic:` — maps the commit to a pull request (required)
- `Relative:` — declares a dependency on another topic
- `Reviewers:` — GitHub usernames or org/team slugs
- `Assignees:` — GitHub usernames
- `Labels:` — GitHub PR labels (e.g. `bug`, `feature`, `draft`)
- `Branches:` — target branch(es) for the PR

These appear at the end of the commit message body, each on its own line.
Treat them as structured metadata — preserve exactly as-is.
When amending a commit with revup labels, use `--no-edit` or pass the full
original message (including labels) back via `-m`.
