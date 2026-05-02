ssh c38 'bash -s' -- 'process_substring' <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

needle="$1"

pids=$(
  top -b -n 1 |
    awk -v needle="$needle" '
      NR > 7 && index($0, needle) && $0 !~ /grep/ {
        print $1
      }
    '
)

if [[ -z "${pids}" ]]; then
  echo "No matching processes found for: $needle" >&2
  exit 1
fi

pid_regex=$(echo "$pids" | paste -sd'|' -)

echo "Matching PIDs: $(echo "$pids" | paste -sd',' -)" >&2

logcat -v threadtime | awk -v pids="$pid_regex" '
  $3 ~ "^(" pids ")$" { print }
'
EOF
