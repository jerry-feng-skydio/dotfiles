#!/usr/bin/env bash
# Example SkyRG stdin action — reads stdin, analyzes it, outputs result.
# Simulates a "process selection" workflow.

set -euo pipefail

input=$(cat)
lines=$(echo "$input" | wc -l | tr -d ' ')
words=$(echo "$input" | wc -w | tr -d ' ')
chars=$(echo "$input" | wc -c | tr -d ' ')

echo "=== Selection Analysis ==="
echo "Lines: $lines  Words: $words  Chars: $chars"
echo ""
echo "--- UPPERCASE ---"
echo "$input" | tr '[:lower:]' '[:upper:]'
echo ""
echo "--- Sorted unique words ---"
echo "$input" | tr -cs '[:alnum:]_' '\n' | sort -uf | head -20
