---
description: Update the C38 logging Obsidian vault (~/c38_logging_notes) based on merged PRs
---

# Update C38 Logging Vault from Merged PRs

Use this workflow when a PR has been merged that affects the C38 logging infrastructure and the Obsidian vault at `~/c38_logging_notes` needs to be updated.

## Input

The user provides one or more GitHub PR numbers from `Skydio/aircam`.

## Steps

### 1. Fetch PR details

Use the GitHub MCP to get each PR's title, description, merge status, and changed files:

- `get_pull_request(owner="Skydio", repo="aircam", pullNumber=<N>)`
- `get_pull_request_files(owner="Skydio", repo="aircam", pullNumber=<N>)`

Confirm the PR is merged. If not, warn the user and ask whether to proceed.

### 2. Read the vault index and relevant pages

Start by reading:
- `~/c38_logging_notes/README.md` — file class table, key findings
- `~/c38_logging_notes/reference/coverage_gaps.md` — task list + readiness status
- `~/c38_logging_notes/reference/ga_roadmap.md` — GA work items and per-class status
- `~/c38_logging_notes/reference/known_issues.md` — bug descriptions

Then read any file class pages, upload pages, or reference pages that the PR's changed files or description relate to. Use the PR description, changed file paths, and channel/component names to identify which vault pages are affected.

### 3. Map the PR to vault items

For each PR, determine:
- **Which task list items** (in `coverage_gaps.md` or `ga_roadmap.md`) does this resolve or advance?
- **Which file class pages** need updating (e.g., upload status, data streams, lifecycle)?
- **Which known_issues bugs** are addressed or mitigated?
- **Which readiness status rows** change?
- **Does the README file class table need a status update?**

### 4. Critical assessment — does this fully resolve the requirement?

For each mapped task/requirement, evaluate:

1. **Fully resolved?** — Does the PR completely close the task? Check if all subtasks, edge cases, and related items are addressed.
2. **Partially resolved?** — What specific work remains? Be concrete (e.g., "code ships but Databricks dashboard not created yet").
3. **Mitigated but not fixed?** — Does it reduce impact without fixing root cause? (e.g., disabling a logger mitigates disk exhaustion without fixing the cleanup bugs). Note what's still broken and the residual risk.
4. **Side effects or TODOs?** — Does the PR leave TODOs in the code? Are there follow-up items that should become new tasks?

Present this assessment to the user before applying updates. Ask for confirmation if any judgment calls are ambiguous.

### 5. Apply vault updates

For each affected page, make targeted edits:

**Task lists (`coverage_gaps.md`, `ga_roadmap.md`):**
- Check off resolved items: `- [ ]` → `- [x]`
- Add PR link and merge date: `([#NNNNN](https://github.com/Skydio/aircam/pull/NNNNN), merged YYYY-MM-DD)`
- For mitigated-but-not-fixed items, add italic annotation: `*Mitigated: <reason>. Remaining: <what's left>.*`
- Strike through text if the task is fully superseded: `~~old task text~~`

**Readiness status table (`coverage_gaps.md`):**
- Update status emoji: 🔴 → 🟡 → ✅
- Add PR links to notes column
- Add new rows for newly shipped capabilities

**File class pages (`file_classes/*.md`):**
- Update Quick Reference table (upload status, cleanup, status fields)
- Update data streams section if channels changed
- Add resolution notes to lifecycle section
- Update key source files table if new files are relevant

**README.md:**
- Update file class table upload status column
- Update key findings if a finding is now resolved

**Known issues (`known_issues.md`):**
- Add resolution notes at the end of affected bug sections
- Do NOT delete bug descriptions — they're historical reference

**GA roadmap (`ga_roadmap.md`):**
- Update per-class status table
- Update subtask checklists
- Update summary table status column if an item moves to shipped

### 6. Summarize changes

After applying all edits, provide a summary:

```
## Vault Update Summary

**PRs processed:** #NNNNN, #NNNNN

### Tasks resolved
- [task name] — fully resolved / mitigated / advanced

### Tasks remaining
- [task name] — what's left and why

### Pages updated
- `page.md` — what changed

### New follow-ups identified
- [any new tasks from TODOs or gaps discovered during review]
```

## Conventions

- Always link PRs as `[#NNNNN](https://github.com/Skydio/aircam/pull/NNNNN)`
- Always include merge date when checking off tasks
- Use `⚠️` for caveats or partial resolutions inline
- Never delete historical content from `known_issues.md` — append resolution notes
- Keep task list items even when done (checked off) — they serve as an audit trail
- If a PR creates a new log class or upload path, create a new file class page following the 7-section template used by existing pages
