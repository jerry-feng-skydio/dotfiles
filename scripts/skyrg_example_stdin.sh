#!/usr/bin/env bash
# Example SkyRG stdin action — reads stdin, transforms it, outputs result.
# Simulates an "Ask AI" or "process selection" workflow.

set -euo pipefail

echo "Received stdin:"
echo "---"
while IFS= read -r line; do
  echo "  > $line"
done
echo "---"
echo "Transformation complete ($(date +%T))"
