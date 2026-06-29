# Aircam — Personal Context

See also the shared `CLAUDE.md` in the repo root for team-wide context.

## Workflow

- **PR tool**: revup (`revup upload`)
- **Topic tags**: `Topic:` and `Relative:` in commit messages
- **Base branches**: release branches matching `rc*`, `mfg*`, `npi*`, `feature/**`, `stable-candidate` (configured in `.revupconfig`)
- **Main branch**: `master`
- **Remote**: `origin`

## Conventions

- Revup config at repo root `.revupconfig`
- User oauth in `~/.revupconfig`

## Pre-Commit Validation

Before committing any changes, you MUST run these checks and fix any issues:

1. **Format modified files**: run `./skyrun bin code_format` on each changed file individually:
   ```
   ./skyrun bin code_format --file <path>
   ```
   If per-file mode is unavailable or fails, fall back to:
   ```
   ./skyrun bin code_format --mod
   ```

2. **Lint modified files**:
   ```
   ./skyrun bin lint_modified
   ```

Do NOT commit until both pass cleanly. If either reports errors, fix them and re-run before committing.

## Skydio Devices

Skydio drones have multiple onboard compute boards accessible via SSH (aliases in `~/.ssh/config`).

| Vehicle | Type | Boards | SSH hosts | Log mechanism |
|---------|------|--------|-----------|---------------|
| R47 | Drone | NVU (main), QCU (camera) | `nvu`, `qcu`, `nvu-wifi`, `qcu-wifi` | `ssh <host> tail -f <logfile>` |
| C38 | Remote controller | SOC (main), Radio | `c38`, `c38-radio` | `ssh c38 logcat \| grep ucon` |

- **R47 logs** live at `/home/skydio/semi_persistent/process_logs/latest/<process>/` on each board
- **C38 logs** use Android `logcat` (the SOC runs Android)
- Device detection works by probing SSH hosts with `ConnectTimeout=2`
- Boards can be connected via USB-Ethernet or WiFi (the `-wifi` variants)

## C38 Logging Documentation

C38 subsystem work (AFU, analytics, SkyCat, debug logs, upload paths) is documented in an **Obsidian vault** at `~/c38_logging_notes`.

- **Read `~/c38_logging_notes/AGENTS.md` first** — it has full conventions for navigating, editing, and committing to the vault.
- **When to use the vault**: any work touching C38 upload pipeline, UCON analytics, SkyCat telemetry, debug log tooling, file class coverage, or GA roadmap tasks.
- **What goes there**: work logs on task pages, PR status updates, coverage gap tracking, implementation plans, architecture docs.
- **What does NOT go there**: code, test files, or anything that belongs in aircam.
- **Key entry points**: `README.md` (index), `reference/ga_roadmap.md` (task tracker), `reference/open_threads.md` (active PRs/meetings).
- **Workflows**: `/dump-state`, `/update-logging-vault`, `/vault-consistency-check` automate common vault operations.

## Agent Notes

- This is a **shared repo** — do not commit agent plans, `CLAUDE.md`, or `.ai/` files
- `CLAUDE.local.md` is symlinked from `~/.dotfiles/agentic-coding/context/aircam/CONTEXT.md` and globally gitignored via `~/.gitignore_global`
- In-flight work tracked in `~/.dotfiles/agentic-coding/context/aircam/PROGRESS.md`
- **Personal workflows** live in `~/.dotfiles/.windsurf/workflows/` and are symlinked into `.windsurf/workflows/`. Never create personal workflows directly in the repo — author them in dotfiles and run `bash ~/.dotfiles/agentic-coding/context/setup.sh` to link them
- See `~/.dotfiles/agentic-coding/CONVENTIONS.md` for the full personal tools policy
