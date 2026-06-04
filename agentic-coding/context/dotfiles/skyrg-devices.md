# SkyRG Device Model — Agent Reference

## When to read this

Read this when the task involves:
- Adding a new Skydio vehicle or board type
- Changing SSH directory options for device actions
- Modifying device detection probes
- Updating on-device paths (logs, analytics, firmware, etc.)

## Architecture

### Probe definitions → board dicts → UI actions

```
g:skyrg_device_defs (or defaults in device.vim)
  └─ probes: [{board, host, platform}, ...]
       │
       ▼  (SSH probe succeeds)
  board dict: {name, host, platform}
       │
       ▼  (used by views/device.vim)
  SSH, tail logs, search logs, view file, etc.
```

### Key files

| File | What it controls |
|------|-----------------|
| `autoload/skyrg/backend/device.vim` | Probe definitions, detection, `board.platform` propagation |
| `autoload/skyrg/views/device.vim` | All device UI actions (SSH, logs, file view, etc.) |
| `autoload/skyrg/backend/context.vim` | Context action registry (device group actions) |
| `~/dotfiles/skyrg/global.vim` | Page config — Device page is index 3 |

### Platform model

The `platform` field on each board probe is the key distinction:

| platform | `SKYDIO_DIR_PATH` | `SemiPersistentPath` | `ProcessLogsPath` | Examples |
|----------|-------------------|----------------------|-------------------|----------|
| `android` | `/odm` | `/data/vendor` | `/data/vendor/logs/process_logs` | C38 SOC |
| `linux` | `/home/skydio` | `/home/skydio/semi_persistent` | `~/semi_persistent/process_logs` | NVU, QCU, Radio, R47, G47 |

These are derived from `util/path_util/BUILD.bazel` in aircam:
```python
# c38_soc
"SKYDIO_DIR_PATH=/odm",
"STAMPS_IN_HOME=1",
"SEMI_PERSISTENT_OVERRIDE_PATH=/data/vendor",

# default linux
"SKYDIO_DIR_PATH=/home/skydio",
```

### Current probe definitions

```vim
" R47
{'board': 'NVU',        'host': 'nvu',       'platform': 'linux'}
{'board': 'QCU',        'host': 'qcu',       'platform': 'linux'}
{'board': 'NVU (wifi)', 'host': 'nvu-wifi',  'platform': 'linux'}
{'board': 'QCU (wifi)', 'host': 'qcu-wifi',  'platform': 'linux'}

" C38
{'board': 'SOC',   'host': 'c38',       'platform': 'android'}
{'board': 'Radio', 'host': 'c38-radio', 'platform': 'linux'}
```

## How to add a new vehicle

1. Add probe definitions in `s:get_vehicle_defs()` in `backend/device.vim`:
   ```vim
   let l:g47_probes = [
     \ {'board': 'Main', 'host': 'g47', 'platform': 'linux'},
     \ ]
   ```
   Add to the return list: `{'type': 'G47', 'probes': l:g47_probes}`

2. SSH host alias must exist in `~/.ssh/config` for the `host` value.

3. SSH directory picker (`s:ssh_directories`) and all path-dependent
   actions automatically work via `board.platform`. No changes needed
   unless the new vehicle has a novel platform type.

4. If the vehicle has platform-specific paths not covered by `android`
   or `linux`, add a new platform value and update `s:ssh_directories`.

## How to update on-device paths

1. Check `util/path_util/BUILD.bazel` in aircam for the authoritative
   `local_defines` per platform (`SKYDIO_DIR_PATH`, `SEMI_PERSISTENT_OVERRIDE_PATH`).

2. Cross-reference with `util/path_util/path_util_base.cc` for the
   path construction logic (e.g. `ProcessLogsPath()`, `AnalyticsLogsPath()`).

3. Update `s:ssh_directories()` in `views/device.vim`. Paths are
   grouped by `board.platform`, so a single change covers all boards
   of that type.

## SSH directory picker UX

- Board picker → Directory picker → SSH connect
- First entry is pre-selected (double-tap Enter for default)
- `android` default: `/` (root)
- `linux` default: `~/` (home)
- Command: `ssh -t <host> "cd <dir> && exec $SHELL -l"`
