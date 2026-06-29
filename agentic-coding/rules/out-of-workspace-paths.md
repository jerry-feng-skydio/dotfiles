---
trigger: always
alwaysApply: true
---

# Editing Files Outside the Workspace

## The Problem

The `edit` / `multi_edit` tools **silently fail** on files outside the active workspace.
They report success but do NOT write to disk. This is the #1 cause of "lost edits" for
files in `~/c38_logging_notes` and `~/.dotfiles`.

## How to Detect

After any edit to a file that might be outside the workspace, **verify the write persisted**:

```bash
# Quick check — run_command reads the real disk, not a cached buffer
head -5 /path/to/edited/file
```

If the output doesn't reflect your edit, the write was silently dropped.

## How to Fix

Symlinks into the aircam workspace exist for commonly-edited external directories:

| Real Path             | Workspace Symlink            |
| --------------------- | ---------------------------- |
| `~/c38_logging_notes` | `~/aircam/c38_logging_notes` |
| `~/.dotfiles`         | `~/aircam/.dotfiles_link`    |

**Always use the workspace symlink path** when calling `edit`, `multi_edit`, `read_file`,
or `write_to_file` on files in these directories. The real path will silently fail.

Examples:

- ✅ `edit(file_path="/home/jerryfeng/aircam/c38_logging_notes/reference/ga_roadmap.md", ...)`
- ❌ `edit(file_path="/home/jerryfeng/c38_logging_notes/reference/ga_roadmap.md", ...)`
- ✅ `edit(file_path="/home/jerryfeng/aircam/.dotfiles_link/.windsurf/workflows/weekly-status.md", ...)`
- ❌ `edit(file_path="/home/jerryfeng/.dotfiles/.windsurf/workflows/weekly-status.md", ...)`

## Fallback

If no symlink exists, use `run_command` with shell writes (e.g., `cat > file << 'EOF'`)
to modify files outside the workspace. The `run_command` tool is not restricted by
workspace boundaries.

## Adding New Symlinks

To add a new external directory:

```bash
ln -s /real/path /home/jerryfeng/aircam/<link_name>
echo '<link_name>' >> /home/jerryfeng/aircam/.git/info/exclude
```

`.git/info/exclude` is local-only (never committed to the repo).
