#!/usr/bin/env bash
# Example SkyRG action script — proves external action dispatch works.
#
# Usage (from SkyRG context popup):
#   Dispatched with the word under cursor as $1.
#   Sleeps briefly to simulate work, then echoes the input.

set -euo pipefail

echo "[skyrg_example] Starting with input: $1"
sleep 2
echo "[skyrg_example] Processing..."
sleep 1
echo "[skyrg_example] Done: $1"
