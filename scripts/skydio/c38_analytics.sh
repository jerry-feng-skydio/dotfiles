#!/bin/bash
# Pull C38 analytics logs and parse them into human-readable text.
#
# Usage:
#   c38_analytics.sh [dest_dir] [--json] [--skip-error-reports]
#
# Examples:
#   c38_analytics.sh                          # SCP + parse to /tmp/c38_analytics
#   c38_analytics.sh /tmp/my_analytics        # custom dest dir
#   c38_analytics.sh --json                   # output as JSON instead of txtlog
#   c38_analytics.sh /tmp/foo --json          # both

set -euo pipefail

DEST="/tmp/c38_analytics"
EXTRA_ARGS=("--skip-error-reports")

# Parse args
for arg in "$@"; do
    case "$arg" in
        --json|--skip-error-reports|--dont-parse-missing|--include-bytes-data)
            EXTRA_ARGS+=("$arg")
            ;;
        *)
            DEST="$arg"
            ;;
    esac
done

echo "==> Pulling analytics from c38:/data/vendor/analytics/ -> $DEST"
mkdir -p "$DEST"
scp -r c38:/data/vendor/analytics/ "$DEST/"

echo "==> Parsing analytics logs..."
cd ~/aircam
bazel run tools/analytics_tools/executables:analytics_to_file -- --dir "$DEST" "${EXTRA_ARGS[@]}"

echo "==> Done. Output in $DEST"
