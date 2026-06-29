#!/bin/bash
# agentic-coding/context/setup.sh — Link agent context files into work repos
#
# Run this once per machine after cloning dotfiles.
# Creates CLAUDE.local.md symlinks and adds them to each repo's local gitignore.
#
# Usage: bash ~/dotfiles/agentic-coding/context/setup.sh

set -euo pipefail

CONTEXT_DIR="$(cd "$(dirname "$0")" && pwd)"

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

  # Symlink CLAUDE.local.md into the repo root (layers on top of any shared CLAUDE.md)
  ln -sfn "$context_file" "$repo/CLAUDE.local.md"

  # Add to local gitignore (never touches shared .gitignore)
  local exclude="$repo/.git/info/exclude"
  mkdir -p "$(dirname "$exclude")"
  if ! grep -qxF 'CLAUDE.local.md' "$exclude" 2>/dev/null; then
    echo 'CLAUDE.local.md' >> "$exclude"
  fi

  echo "  OK   $(basename "$repo") → CLAUDE.local.md linked"
}

link_workflow() {
  local repo="$1"
  local workflow_file="$2"
  local workflow_name
  workflow_name="$(basename "$workflow_file")"

  if [ ! -d "$repo/.windsurf/workflows" ]; then
    mkdir -p "$repo/.windsurf/workflows"
  fi

  ln -sf "$workflow_file" "$repo/.windsurf/workflows/$workflow_name"

  # Add to local gitignore (never touches shared .gitignore)
  local exclude="$repo/.git/info/exclude"
  local pattern=".windsurf/workflows/$workflow_name"
  if ! grep -qxF "$pattern" "$exclude" 2>/dev/null; then
    echo "$pattern" >> "$exclude"
  fi
}

DOTFILES_DIR="$(cd "$CONTEXT_DIR/../.." && pwd)"
WORKFLOWS_DIR="$DOTFILES_DIR/.windsurf/workflows"

echo "Linking agent context into work repos..."
echo ""

# ── Add your repos here ──────────────────────────────────────────────────────
link_plan "$HOME/aircam"    "$CONTEXT_DIR/aircam/CONTEXT.md"
# link_plan "$HOME/other-repo"  "$CONTEXT_DIR/other-repo/CONTEXT.md"
# ─────────────────────────────────────────────────────────────────────────────

# ── Personal workflows (symlinked into each workspace) ────────────────────────
if [ -d "$WORKFLOWS_DIR" ]; then
  echo "Linking personal workflows..."
  for wf in "$WORKFLOWS_DIR"/*.md; do
    [ -f "$wf" ] || continue
    link_workflow "$HOME/aircam" "$wf"
    echo "  OK   $(basename "$wf") → aircam/.windsurf/workflows/"
  done
fi
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo "Done. CLAUDE.md symlinks are gitignored locally via .git/info/exclude."
