---
description: Read the entire C38 logging Obsidian vault and flag inconsistencies, stale info, or documentation gaps
---

# Vault Consistency Check

Audit the C38 logging Obsidian vault at `~/c38_logging_notes` for internal inconsistencies, stale information, and documentation gaps. Present findings to the user for resolution.

## When to Use

- Periodically (e.g., after a batch of PRs land)
- Before a milestone or review
- When the user asks to "check the vault" or "audit the docs"

## Steps

### 1. Read the entire vault

Read every `.md` file in the vault. Start with the index, then systematically read all directories:

```
~/c38_logging_notes/README.md
~/c38_logging_notes/overview/*.md
~/c38_logging_notes/file_classes/*.md
~/c38_logging_notes/upload/*.md
~/c38_logging_notes/reference/*.md
~/c38_logging_notes/tasks/*.md
~/c38_logging_notes/plans/*.md
~/c38_logging_notes/diagrams/*.md
```

Build a mental model of:
- Every file class and its documented upload status
- Every task and its status (done / in progress / not started)
- Every known issue and whether it's resolved or open
- Every upload path and what it covers
- Cross-references between pages (wiki links)

### 2. Check for internal inconsistencies

Compare information across pages. Flag any case where two pages disagree:

- **Upload status mismatch** — does the README file class table match the file class page's Quick Reference? Does it match the `log_class_coverage` task's per-class table? Does `upload_overview.md`'s coverage matrix agree?
- **Task status mismatch** — does `ga_roadmap.md`'s tracker table match the individual task page's status? Are checked-off items in `coverage_gaps.md` consistent with task pages?
- **Readiness status vs. reality** — does the readiness table in `coverage_gaps.md` match the actual state described in task pages and file class pages?
- **Wiki link targets** — are there broken wiki links (references to pages that don't exist)?
- **Naming consistency** — are upload paths referred to by their explicit names (Vehicle AFU, Appcore UCON, Kotlin Upload, C38 SOC AFU, SkyCat/Datadog) everywhere, or do stale "Path A/B/C/D/E" references remain?

### 3. Check for stale information

Flag content that may be outdated:

- **Merged PRs not reflected** — ask the user which branches/PRs have landed recently. Use the GitHub MCP to fetch recent merged PRs touching C38-related paths (`vehicle/vehicle_options/c38*`, `util/ucon/`, `accessories/controller_analytics/`, `bsp/board/c38*`). Cross-reference against the vault.
- **TODO items in code** — if a task page references a code TODO, spot-check whether it still exists in aircam (the user may be on different work trees, so ask before assuming).
- **Status fields** — "Not started" items that may have progressed, "In progress" items that may have shipped.
- **Known issues** — bugs listed as open that may have been fixed.

### 4. Follow embedded PR and JIRA references

Scan all vault pages for embedded links:

- **GitHub PR URLs** — pattern: `https://github.com/Skydio/aircam/pull/NNNNN` or `[#NNNNN](...)`
- **JIRA tickets** — pattern: `SW-NNNNN` or `https://skydio.atlassian.net/browse/SW-NNNNN`

For each PR found:
1. Use GitHub MCP `get_pull_request(owner="Skydio", repo="aircam", pullNumber=N)` to check its current state (merged, open, closed).
2. If merged, check whether the vault page accurately reflects what shipped. Use `get_pull_request_files()` if needed to understand the scope.
3. If still open or closed-without-merge, flag it — the vault may be claiming something shipped that hasn't.
4. If the PR description or comments reference follow-up work, check whether that follow-up is captured as a task or TODO in the vault.

For JIRA tickets:
1. Note any ticket references and their context (bug, feature request, action item).
2. Flag tickets that are referenced as blockers but may have been resolved — ask the user to verify status since we can't query JIRA directly.

This step runs autonomously — no need to ask the user before fetching PR details.

### 5. Check for documentation gaps

Identify missing or incomplete documentation:

- **File classes without pages** — are there log types mentioned in upload tables or coverage matrices that don't have a dedicated file class page?
- **Upload paths without pages** — same for upload paths.
- **Task pages missing sections** — does every task page have: Why, Subtasks, Related Pages, Work Log? Are work logs empty for items marked "In progress" or "Shipped"?
- **Plans not linked** — are there plan files in `plans/` that aren't referenced from any task page?
- **Orphan pages** — pages that exist but aren't linked from anywhere (README, roadmap, coverage gaps, etc.).
- **Missing cross-references** — file class pages that don't link back to their upload path, or vice versa.

### 6. Spot-check against aircam (optional, with user input)

If the user agrees, read key source files to verify documentation accuracy:

- `vehicle/vehicle_options/c38_controller_types.py` — channel lists, logger config
- `util/ucon/platforms/controller/executables/automatic_file_upload_front.cc` — AFU behavior
- `accessories/controller_analytics/skycat_front.cc` — SkyCat/spillover config
- `accessories/common/debug_logs.py` — debug log encryption

**Important:** The user may be working on multiple branches. Always ask which branch to check before reading aircam files, since the documentation may reflect work-in-progress that hasn't landed on the main branch yet.

### 7. Present findings

Organize findings into a structured report:

```
## Vault Consistency Report

### 🔴 Inconsistencies (pages disagree with each other)
- [page A] says X, but [page B] says Y

### 🟡 Possibly Stale (may need updating)
- [page] says "not started" but [PR/branch] suggests work has begun
- [page] references a TODO that may no longer exist

### 🔵 Documentation Gaps (missing content)
- [file class] has no dedicated page
- [task page] has empty work log despite being "in progress"
- [plan file] is not linked from any task

### 🟢 Suggestions (optional improvements)
- [page] could benefit from a diagram
- [section] duplicates content from [other page] — consider consolidating
```

Present one category at a time. For each finding, propose a fix and wait for user confirmation before applying.

## Conventions

- **Plans are exempt from codebase consistency checks** — files in `plans/` represent point-in-time design thinking. The actual implementation may differ from the plan. Do not flag plan-vs-code discrepancies as inconsistencies. Only flag plan-vs-vault issues (e.g., a plan linked from the wrong task page).
- Never silently fix inconsistencies — always present them first
- Ask the user which branch to check before reading aircam source
- Group related findings together (e.g., if a status mismatch affects 3 pages, present it as one finding)
- Prioritize inconsistencies over gaps — wrong info is worse than missing info
