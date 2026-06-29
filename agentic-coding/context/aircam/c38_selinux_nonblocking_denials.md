# C38 SELinux Denials Summary

## Fixed Blocking Denials (permissive=0)

Fixed in this commit:
- telit_controller: MLS bypass for system_data_file categories
- skycatd: proc_net read for somaxconn
- system_suspend: vendor_sysfs_usb_node file read
- vendor_wcnss_service: create/rename/unlink for WiFi log rotation

## Remaining Blocking Denials (permissive=0) - Non-Critical

These are blocking but non-critical (device boots successfully, OTA works):

1. **vendor_init**: Reading `vendor_aircam_prop` property (USB FFS ready check during boot)
   - Type only defined in CIL, not .te
   - Cannot be fixed in .te files without declaring the type
   - Boot-time check, device boots successfully despite denial
   - Solution: Add type declaration in .te or fix via CIL

2. **atrace**: Writing to `debugfs_tracing_debug` (performance tracing)
   - Performance tracing feature, not critical for operation
   - Solution: Add allow atrace debugfs_tracing_debug:file write

## Non-Blocking Denials (permissive=1)

These denials are in permissive mode and are not blocking functionality, but should be cleaned up later.

## Affected Domains

- **analytics_logger**: Permissive denials during log operations
- **automatic_file_upload**: Permissive denials during file upload operations
- **bmu_shutdown_fs_watcher**: Permissive denials during filesystem monitoring
- **cloud_ota_server**: Permissive denials during OTA operations
- **ifplugd**: Permissive denials for toybox execution (already has dontaudit in policy)
- **launch_logger**: Permissive denials for toybox execution and data directory search
- **mfg_c38_api**: Permissive denials during manufacturing API operations
- **minex_server**: Permissive denials during minex server operations
- **mount_radio_nfs**: Permissive denials during NFS mount operations
- **skydio_init**: Permissive denials during init operations (tmpfs, log files, vendor_shell_exec)

## Common Patterns

1. **toybox execution**: Several domains (ifplugd, launch_logger) try to execute `/system/bin/toybox` but neverallow blocks vendor domains from executing platform file types. Solution: Use vendor-specific busybox or relabel needed utilities.

2. **data directory search**: Domains search `/data` directories with MLS categories (s0:c512,c768). Solution: Add `typeattribute <domain> mlstrustedsubject;` to bypass MLS.

3. **tmpfs operations**: skydio_init creates files in tmpfs. Solution: Add proper tmpfs permissions.

4. **vendor_shell_exec**: Domains execute vendor shell scripts. Solution: Ensure proper execute permissions.

## Recommended Approach

1. Fix the MLS category issues by adding `mlstrustedsubject` attribute to affected domains.
2. Add proper tmpfs permissions for skydio_init.
3. Address toybox execution by using vendor_toolbox_exec instead of toolbox_exec.
4. Review each domain's specific needs and add targeted permissions rather than broad allows.

## Priority

These are non-blocking and can be addressed in a follow-up cleanup. The blocking denials (permissive=0) have been fixed in this commit.
