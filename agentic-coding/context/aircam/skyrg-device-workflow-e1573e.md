# SkyRG Device Workflow — Detect, Flash, Debug Drones from Vim

Add context actions that detect a connected drone/controller over USB (SSH), and provide quick actions to build flashpacks, flash the device, and tail logs — all from the SkyRG context popup.

## Evaluation

**This is very doable.** SkyRG already has all the building blocks:

- **Context actions** with predicates (can gate on device reachability)
- **Async jobs** via `job_start()` for long builds
- **Interactive terminals** for commands needing user interaction (flash confirmation, etc.)
- **Shell actions** for quick one-shot checks

The existing `lazy_ota.sh` and `watch_vehicle_flight_deck.sh` scripts already encode the IPs, SSH patterns, and log paths — we'd be wrapping them in SkyRG actions.

**One design choice:** device detection should be fast and non-blocking. A background ping/SSH check on a timer is overkill for now — instead, we do a quick connectivity check when the context popup opens, and only show device actions if the check passes (< 1s timeout).

## Implementation Plan

### 1. Device detection module — `autoload/skyrg/backend/device.vim`

A small module that checks if a device is reachable:

```vim
" Check SSH reachability with a short timeout
function! skyrg#backend#device#is_reachable(host) abort
  let l:result = system('ssh -o ConnectTimeout=1 -o BatchMode=yes aircam@' . a:host . ' true 2>/dev/null')
  return v:shell_error == 0
endfunction

" Return the first reachable device from a known list, or ''
function! skyrg#backend#device#detect() abort
  for host in ['192.168.11.1', '192.168.11.2', '192.168.10.1']
    if skyrg#backend#device#is_reachable(host)
      return host
    endif
  endfor
  return ''
endfunction
```

The host list and SSH user should be configurable via `g:skyrg_device_hosts` and `g:skyrg_device_user`.

**Concern:** sequential SSH checks could take up to 3s if all fail. Mitigations:
- Use `ssh -o ConnectTimeout=1` (1s per host)
- Try the most common host first (QCU `192.168.11.1`)
- Cache the result for the lifetime of the context popup

### 2. Context action predicates

Register a group of `device` context actions in `backend/context.vim`. The predicate calls `skyrg#backend#device#detect()` and caches the result in `s:cached_device` for the session:

```vim
'predicate': {ctx -> !empty(skyrg#backend#device#detect())},
```

### 3. Context actions to register

| Action | Key | Type | Command |
|--------|-----|------|---------|
| Build flashpack | `b` | `job` (async) | `./skyrun bin build_flashpack` (or similar) |
| Flash device | `f` | `job` (interactive) | `lazy_ota.sh -t <detected_host>` |
| Tail flight_deck log | `l` | `job` (interactive) | Opens a terminal split with `ssh aircam@<host> tail -f /home/skydio/semi_persistent/process_logs/latest/flight_deck.txt` |
| View crash logs | `c` | `execute` | Opens a remote file via `scp://` or `netrw` — Vim natively supports `:edit scp://aircam@host//path/to/log` |
| SSH shell | `S` | `job` (interactive) | Opens a terminal with `ssh aircam@<host>` |

All gated to the `device` group with priority ~80 (after revup actions).

### 4. Remote file viewing via netrw

Vim has **built-in** support for editing remote files:
```
:edit scp://aircam@192.168.11.1//home/skydio/semi_persistent/process_logs/latest/flight_deck.txt
```

No plugin needed. The context action just calls `:edit scp://...`. This gives you syntax highlighting, search, and the full Vim experience on a remote file.

For live tailing, the interactive terminal with `ssh tail -f` is better.

### 5. Configurable hot paths

Add a `g:skyrg_device_hot_paths` variable so you can define your go-to files:

```vim
let g:skyrg_device_hot_paths = [
  \ {'label': 'flight_deck.txt', 'path': '/home/skydio/semi_persistent/process_logs/latest/flight_deck.txt'},
  \ {'label': 'crash_reports',   'path': '/home/skydio/semi_persistent/crash_reports/'},
  \ {'label': 'system config',   'path': '/etc/skydio/vehicle.conf'},
  \ ]
```

When you pick "View device file", a sub-popup lists these paths.

### 6. Files to create/modify

| File | Action |
|------|--------|
| `autoload/skyrg/backend/device.vim` | **Create** — device detection |
| `autoload/skyrg/backend/context.vim` | **Modify** — register device actions in `s:ensure_builtins()` |
| `.ai/CONVENTIONS.md` | **Modify** — document device action conventions |

### 7. Things to confirm with you before implementing

- **Exact `skyrun` build command** for flashpacks (need the full target name)
- **Exact log paths** you want as hot paths
- **SSH user** — `aircam@` for all devices?
- **SSH identity file** — do you need `-i path/to/key` or does the default work?
- **QCU vs NVU vs Wi-Fi** — which is the most common connection to default to first?
