---
description: Summarize today's work session into the C38 logging vault task pages and plans
---

# Dump State

Capture the current session's work into the Obsidian vault at `~/c38_logging_notes`. This writes a dated work log entry to the relevant task page(s) and saves any generated plans.

## When to Use

- At the end of a work session
- When switching context to a different task
- When the user says "dump state", "save progress", "write worklog", or similar

## Steps

### 1. Identify which tasks were worked on

Review the conversation history to determine:

- Which GA task(s) were discussed or advanced (map to pages in `tasks/`)
- Which coverage gap items were addressed (map to `coverage_gaps.md`)
- Whether any new file classes, upload paths, or reference pages were created or modified

### 2. Summarize the session

For each task touched, write a concise summary covering:

- **What was discussed** — key decisions, design tradeoffs, questions resolved
- **What was implemented** — code changes, PRs created/updated, files modified (with paths)
- **What was discovered** — bugs found, assumptions invalidated, new requirements identified
- **What remains** — open questions, next steps, blockers

Keep it factual and concise. Include specific file paths, PR numbers, branch names, and commit messages where available. This is a work log, not a narrative.

### 3. Save any generated plans

If the session produced implementation plans, design docs, or detailed technical analysis:

1. Save to `~/c38_logging_notes/plans/<descriptive-kebab-name>.md`
2. Link from the relevant task page under its Plans field or Related Pages section
3. Plans should include the date they were generated and a brief context note at the top

### 4. Append work log entries

For each affected task page in `tasks/`, append a dated entry under `## Work Log`:

```markdown
### YYYY/MM/DD HH:MM — <short title>

**Host:** `<hostname>` | **Branch:** `<branch>` (base: `<base-branch>`)

- <bullet points summarizing work done>
- <decisions made, with rationale if non-obvious>
- <PRs/commits: [#NNNNN](url) or `commit-hash`>
- <next steps or open questions>
```

Get the hostname from `$HOSTNAME` or `hostname` command. Get the branch from `git -C ~/aircam rev-parse --abbrev-ref HEAD`.

Use today's date. If there's already an entry for today, append to it rather than creating a duplicate.

### 5. Update task status if needed

If the session moved a task's status (e.g., "Not started" → "In progress", or "In progress" → "Shipped"):

1. Update the task page's **Status** field
2. Update the corresponding row in `reference/ga_roadmap.md`'s tracker table

### 6. Confirm with user

Show the user a summary of what was written and where before committing. Include:

```
## State Dump Summary

### Task pages updated
- `tasks/<page>.md` — added work log entry for YYYY/MM/DD HH:MM

### Plans saved
- `plans/<name>.md` — linked from `tasks/<page>.md`

### Status changes
- <task>: <old status> → <new status> (updated in task page + ga_roadmap.md)
```

## Conventions

- Always use `### YYYY/MM/DD HH:MM — <title>` format for work log entries
- Never overwrite existing work log entries — append only
- If the same session already has an entry, add new bullets under the existing heading
- Keep summaries concise — aim for 5-15 bullets per session, not paragraphs
- Always include **host machine** (`$HOSTNAME`) and **git branch** at the top of each work log entry
- Include branch names when referencing code work (e.g., "on `jfeng.c38_analytics`")
- Link PRs as `[#NNNNN](https://github.com/Skydio/aircam/pull/NNNNN)`
