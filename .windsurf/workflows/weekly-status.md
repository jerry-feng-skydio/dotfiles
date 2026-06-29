---
description: Generate weekly status update from c38_logging_notes vault and push to Notion pages
---

# Weekly Status Update

Generate a status update from the C38 logging vault and push it to three Notion pages.

## When to Use

- Before Middleware Sync meetings (typically Friday)
- When user says "weekly status", "write status update", or similar
- Triggered via `/weekly-status`

## Notion References

| What                       | ID / Value                             |
| -------------------------- | -------------------------------------- |
| Personal page              | `2f1dc5ce829380168abec9f675297e71`     |
| Middleware Weekly          | `317dc5ce829380c4a322d4e5e2c31912`     |
| C38 GA Milestone           | `263dc5ce829380d9bdc9e0730d3b8112`     |
| Jerry's Notion user ID     | `9a923586-64b5-4c7b-bcce-ea429b530306` |
| Project DB synced block ID | `372dc5ce8293805a9bbadc357744081e`     |

## Vault Paths

| What                  | Path                                                          |
| --------------------- | ------------------------------------------------------------- |
| Vault (use for edits) | `~/aircam/c38_logging_notes`                                  |
| Status archive        | `~/aircam/c38_logging_notes/status_updates/`                  |
| Last status date      | `~/aircam/c38_logging_notes/status_updates/.last_status_date` |

## Steps

### 1. Gather vault data

Read from `~/aircam/c38_logging_notes` (always use workspace symlink path):

- `reference/ga_roadmap.md` — task statuses and milestones
- `reference/open_threads.md` — PRs awaiting review, meetings, follow-ups
- All files in `tasks/` — focus on work log entries since **last status date**
- `reference/coverage_gaps.md` — if any gaps were addressed this week

**Determining the reporting window:**

1. Read `status_updates/.last_status_date` — contains a `YYYY-MM-DD` date string.
2. Only include work log entries dated **after** that date.
3. If the file doesn't exist (first run), include the last 7 days and note this to the user.

Extract:

- Completed items (merged PRs, shipped work, resolved issues)
- In-progress items (open PRs, partially complete subtasks)
- Blockers (anything preventing progress — SSH issues, blocked dependencies, etc.)
- Upcoming items (meetings, planned work)
- Per-project status (derive from subtask completion in task pages)

**Omit:** Vault maintenance work (creating task pages, updating roadmap structure, etc.) — only report substantive engineering work.

### 2. Check live PR status

For every PR referenced in `open_threads.md`, check current status via GitHub MCP:

```
mcp2_get_pull_request(owner="Skydio", repo="aircam", pullNumber=<N>)
```

Classify each as: **merged** / **approved** / **changes-requested** / **open** / **closed**.
Note any status changes since the vault was last updated.

### 3. Generate the status update

Produce a single status update with these sections in order:

```
# Weekly Status — Jerry Feng — W<week_number> (<date_range>)

## This Week
<toggle list per work stream>

## Blockers
<blockers, if any>

## Overall Project Status — C38 GA
<table: Task | Status>

## Open Threads
<bullet list>

## Next Week
<bullet list>
```

**Section details:**

#### This Week — toggle lists per work stream

Each active work stream gets a Notion toggle (`<details>/<summary>`):

- **Summary line** (always visible): bold work stream name + short phrase describing the week's focus
- **Toggle body** (hidden by default): detailed bullets, PR links, technical notes

PR links should include the title: `[#NNNNN — PR title](url)`

Group PRs as sub-items under a "PRs open:" or "PRs merged:" bullet.

#### Blockers

Anything preventing progress. Include:

- What is blocked
- Impact (which work streams are affected)
- What needs to happen to unblock

Omit this section entirely if there are no blockers.

#### Overall Project Status — C38 GA

A table with two columns: **Task** and **Status**. No priority column — items are sorted by priority (high first). Derived from `ga_roadmap.md` — only include C38 GA milestone items.

Do NOT use emoji in the Task or Status columns (emoji is typically reserved for project-level health indicators set by leads).

#### Open Threads

PRs awaiting review, meetings, follow-ups. Do not duplicate items already in Blockers.

#### Next Week

Dated items first (e.g., "**Mon 6/30**: ..."), then undated items.

### 4. Present draft for user review

Show the full status update in markdown. Ask the user to review, edit, or approve before writing to Notion. Do NOT proceed to write without explicit approval.

### 5. Push to Notion

After user approval, push the status update to the target Notion pages.

The exact push targets and insertion strategy depend on the Notion page structure at the time. Fetch each target page first to understand its current content, then use `update_content` or `insert_content` as appropriate.

Target pages (from Notion References table above):

- Personal page
- Middleware Weekly (Jerry's C38 section)
- C38 GA Milestone (via Project DB synced block)

**Edge cases:**

- If Jerry's section on Middleware Weekly doesn't exist yet, tell the user and skip.
- If a synced_block_reference is present, replace it with direct content.
- If `update_content` can't reliably target an insertion point, fall back to presenting the content for the user to paste manually.

### 6. Archive to vault

Save the status update to the vault for historical reference:

1. Write the approved markdown content to `~/aircam/c38_logging_notes/status_updates/YYYY-MM-DD.md`
2. Update `~/aircam/c38_logging_notes/status_updates/.last_status_date` with today's date (`YYYY-MM-DD`)
3. Commit the vault changes:
   ```bash
   cd ~/c38_logging_notes && git add -A && git commit -m "Weekly status update YYYY-MM-DD" && git push
   ```

### 7. Confirm completion

Show a summary:

```
## Status Update Published — YYYY-MM-DD

| Destination | Action |
|---|---|
| Personal page | ✅ Updated |
| Middleware Weekly | ✅ Jerry's C38 section updated |
| C38 GA | ✅ Auto-synced via Project DB block |
| Vault archive | ✅ status_updates/YYYY-MM-DD.md |
```

## Content Guidelines

### Tone

- **Be conservative** — do not overstate progress. If something hasn't been verified on-device, say "awaiting device test", not "working".
- Be factual — only report work evidenced by vault work logs, PRs, or commits.
- Do not fabricate or embellish.
- Match the tone of existing updates on the personal page.

### Formatting

- PR links must include the PR title: `[#NNNNN — Title](url)`. Group under a "PRs open:" or "PRs merged:" parent bullet.
- Use bullet points, not paragraphs.
- No emoji in the project status table (emoji is reserved for project-level health set by leads).
- Use Notion toggle syntax (`<details>/<summary>`) for work stream sections.
- Carry forward items from the previous week's "Next Week" section unless completed or dropped.

### What to omit

- Vault maintenance (creating task pages, restructuring roadmap, updating AGENTS.md, etc.)
- Historical context that was already reported in a previous status update
- Faraday Release or Post-GA items (only report C38 GA milestone work unless Post-GA items had active work this week)
