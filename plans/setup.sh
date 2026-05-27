#!/bin/bash
# plans/setup.sh — Link agent context files into work repos
#
# Run this once per machine after cloning dotfiles.
# Creates CLAUDE.md symlinks and adds them to each repo's local gitignore.
#
# Usage: bash ~/dotfiles/plans/setup.sh

set -euo pipefail

PLANS_DIR="$(cd "$(dirname "$0")" && pwd)"

link_plan() {
  local repo="$1"
  local context_file="$2"

  if [ ! -d "$repo" ]; then
    echo "  SKIP $(basename "$repo") — directory not found"
    return
  fi
  if [ ! -d "$repo/.git" ]; then
    echo "  SKIP $(basename "$repo") — not a git repo"
    return
  fi
  if [ ! -f "$context_file" ]; then
    echo "  SKIP $(basename "$repo") — context file not found: $context_file"
    return
  fi

  # Symlink CLAUDE.md into the repo root
  ln -sfn "$context_file" "$repo/CLAUDE.md"

  # Add to local gitignore (never touches shared .gitignore)
  local exclude="$repo/.git/info/exclude"
  mkdir -p "$(dirname "$exclude")"
  if ! grep -qxF 'CLAUDE.md' "$exclude" 2>/dev/null; then
    echo 'CLAUDE.md' >> "$exclude"
  fi

  echo "  OK   $(basename "$repo") → CLAUDE.md linked"
}

echo "Linking agent context into work repos..."
echo ""

# ── Add your repos here ──────────────────────────────────────────────────────
link_plan "$HOME/aircam"    "$PLANS_DIR/aircam/CONTEXT.md"
# link_plan "$HOME/other-repo"  "$PLANS_DIR/other-repo/CONTEXT.md"
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo "Done. CLAUDE.md symlinks are gitignored locally via .git/info/exclude."
