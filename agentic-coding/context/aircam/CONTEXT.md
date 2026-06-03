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

## Agent Notes

- This is a **shared repo** — do not commit agent plans, `CLAUDE.md`, or `.ai/` files
- `CLAUDE.local.md` is symlinked from `~/dotfiles/agentic-coding/context/aircam/CONTEXT.md` and excluded via `.git/info/exclude`
- In-flight work tracked in `~/dotfiles/agentic-coding/context/aircam/PROGRESS.md`
