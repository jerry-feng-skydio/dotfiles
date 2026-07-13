---
trigger: always
alwaysApply: true
---

# Stale IDE Buffer Guard

## The Problem

When editing files that are open in the IDE (especially vault files outside the
workspace), Windsurf may show a "content of the file is newer" popup. If the user
is alt-tabbed away, this popup blocks the edit from persisting — and the stale
buffer eventually overwrites the disk change.

## Rule

After editing any file that is currently **open in the IDE** (check the
`Open documents` list in the IDE metadata), **pause and tell the user**:

> ⚠️ `<filename>` is open in the IDE. If you see a "content of the file is newer"
> popup in Windsurf, please click **Overwrite** to accept the disk version.

Then **verify the edit persisted** before proceeding:

```bash
grep -c '<unique string from the edit>' /path/to/file
```

If the edit was reverted (count is 0), re-apply it and pause again.

## When This Applies

- Editing any file listed in the IDE's `Other open documents` metadata
- Especially vault files in `~/c38_logging_notes` (symlinked into workspace)
- Especially when committing + pushing vault changes (the commit may capture
  the stale version if the buffer overwrites between edit and `git add`)

## Prevention

- Prefer editing files that are NOT open in the IDE
- If you must edit an open file, always verify with `grep` or `head` after editing
- Do `git add` immediately after the edit, before the IDE buffer can overwrite
