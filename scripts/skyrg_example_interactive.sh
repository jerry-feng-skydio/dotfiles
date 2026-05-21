#!/usr/bin/env bash
# Example SkyRG interactive action — prompts for user input.
# Simulates a deploy script that needs confirmation.

set -euo pipefail

echo "=== Deploy Preview ==="
echo "Target: production"
echo "Artifact: build-$(date +%Y%m%d)"
echo ""
read -p "Type 'yes' to confirm deploy: " confirm

if [ "$confirm" = "yes" ]; then
  echo "Deploying..."
  sleep 1
  echo "Deploy complete!"
  exit 0
else
  echo "Deploy cancelled by user."
  exit 1
fi
