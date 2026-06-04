# SkyRG Debugging — Agent Quick Reference

## Log location

All SkyRG logs live in a single file:

```
~/.local/share/skyrg/skyrg.log
```

## Reading the log

Entries are timestamped with `[LEVEL] [module]` prefixes:

```
2026-06-03 20:05:29 [INFO] [views/context] execute "Instabug (dump screen to log)"
2026-06-03 20:05:44 [INFO] [instabug] note: "Popup covers input zone"
```

Key modules:
- `views/context` — popup open/close/execute events
- `context_pages` — page navigation
- `context_history` — action recording/replay
- `action` — dispatch (vim/shell/job)
- `tasks` — async task lifecycle (start, output, complete)
- `ui/live_split` — live log viewer open/close/exit
- `instabug` — annotated screen dumps (bug reports)

## Instabug dumps

When the user files a bug, they run the Instabug action from the context popup
(page 0 → key `i`). This appends a structured dump to the log:

```
=== INSTABUG DUMP ===
note: "user's description of the bug"
screen: 102x276
--- SCREEN ---
(full text screenshot)
--- MESSAGES ---
(recent Vim :messages output — errors, warnings, echom)
--- WINDOWS ---
(JSON: window IDs, bufnames, filetypes, dimensions, terminal status)
--- LAYOUT ---
(JSON: Vim winlayout() tree)
=== END INSTABUG ===
```

**To diagnose a bug from an Instabug**, search for `=== INSTABUG DUMP ===` in the
log, read the `note:` line for the user's description, then:

1. Check `--- MESSAGES ---` for Vim errors (`E\d+:`, `Error detected while processing`)
2. Check the log lines *before* the dump for the sequence of actions leading up to the bug
3. Check `--- SCREEN ---` for visual state (popup position, buffer content, statusline)
4. Check `--- WINDOWS ---` for unexpected buffers or terminal states

## Searching the log

```bash
# Find all errors
grep -i 'error\|warn\|E[0-9]\+:' ~/.local/share/skyrg/skyrg.log

# Find recent popup activity
grep -E '(views/context|context_pages|context_history)' ~/.local/share/skyrg/skyrg.log | tail -30

# Find the last instabug dump
grep -n 'INSTABUG DUMP' ~/.local/share/skyrg/skyrg.log | tail -1
# then read from that line number

# Find Vim errors in instabug messages section
sed -n '/=== INSTABUG DUMP ===/,/=== END INSTABUG ===/p' ~/.local/share/skyrg/skyrg.log | grep -i error
```

## Key files

| File | Purpose |
|------|---------|
| `autoload/skyrg/instabug.vim` | Instabug dump implementation |
| `autoload/skyrg/views/context.vim` | Context popup view (paginated) |
| `autoload/skyrg/backend/context.vim` | Action registry and built-in actions |
| `autoload/skyrg/backend/context_pages.vim` | Page definitions, navigation, predicates |
| `autoload/skyrg/backend/context_history.vim` | Execution history ring buffer, replay |
| `autoload/skyrg/ui/input.vim` | Input prompt wrapper (record/replay) |
| `autoload/skyrg/backend/action.vim` | Action dispatch (vim/shell/job) |
| `autoload/skyrg/backend/tasks.vim` | Async task tracking |
| `autoload/skyrg/ui/live_split.vim` | Live log viewer |
| `autoload/skyrg/views/device.vim` | Device-specific actions (SSH, logs) |
| `~/.dotfiles/skyrg/global.vim` | Page config (`g:skyrg_pages`, `g:skyrg_group_pages`) |

## Context popup pages

Pages are configured in `global.vim` via `g:skyrg_pages` (page defs) and
`g:skyrg_group_pages` (group→page mapping). Current layout:

| Key | Page | Groups | Notes |
|-----|------|--------|-------|
| `1` | Search | search, open, revup | Default page |
| `3` | Device | device | Hidden when no device connected |
| `9` | Buffer | live_split | Auto-switches in live_split buffers |
| `0` | SkyRG | debug | Instabug, refresh |

Navigation: `←/→` arrows, `0-9` jump, `` ` `` history, `Esc` close.
