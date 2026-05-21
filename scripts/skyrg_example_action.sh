#!/usr/bin/env bash
# Example SkyRG action script — simulates a build with compiler errors.
# Outputs file:line:col:text format that the 'matches' parser can parse.

set -euo pipefail

word="${1:-unknown}"

echo "Building project for: $word"
sleep 1

echo "Compiling src/main.cc..."
sleep 1

echo "src/main.cc:42:10: error: undefined reference to '$word'"
echo "src/main.cc:87:5: warning: unused variable 'result'"
sleep 1

echo "Compiling src/util.h..."
echo "src/util.h:12:1: error: missing semicolon"
sleep 1

echo "Build failed: 2 errors, 1 warning"
exit 1
