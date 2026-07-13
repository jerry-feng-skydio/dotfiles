#!/bin/bash
# agentic-coding/context/setup.sh — Link agent context files into work repos
#
# Run this once per machine after cloning dotfiles.
# Creates CLAUDE.local.md symlinks and adds exclusions to ~/.gitignore_global.
#
# NOTE: We use ~/.gitignore_global (via git config core.excludesFile) instead
# of .git/info/exclude because some repos (e.g. aircam) regenerate the exclude
# file automatically, wiping any appended entries.
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

  add_global_ignore 'CLAUDE.local.md'

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

  add_global_ignore ".windsurf/workflows/$workflow_name"
}

ensure_companion_repo() {
  local repo_path="$1"
  local git_url="$2"
  local workspace="$3"
  local link_name="$4"

  # Clone if missing
  if [ ! -d "$repo_path" ]; then
    echo "  CLONE $(basename "$repo_path") from $git_url"
    git clone "$git_url" "$repo_path"
  fi

  # Symlink into workspace for edit tool access
  if [ -d "$workspace" ] && [ ! -e "$workspace/$link_name" ]; then
    ln -s "$repo_path" "$workspace/$link_name"
    echo "  LINK  $workspace/$link_name → $repo_path"
  fi

  add_global_ignore "$link_name"
}

GLOBAL_IGNORE="$HOME/.gitignore_global"

add_global_ignore() {
  local pattern="$1"
  if ! grep -qxF "$pattern" "$GLOBAL_IGNORE" 2>/dev/null; then
    echo "$pattern" >> "$GLOBAL_IGNORE"
  fi
}

# Ensure global gitignore is configured
if [ "$(git config --global core.excludesFile 2>/dev/null)" != "$GLOBAL_IGNORE" ]; then
  git config --global core.excludesFile "$GLOBAL_IGNORE"
  echo "Set core.excludesFile → $GLOBAL_IGNORE"
fi

DOTFILES_DIR="$(cd "$CONTEXT_DIR/../.." && pwd)"
WORKFLOWS_DIR="$DOTFILES_DIR/.windsurf/workflows"

echo "Linking agent context into work repos..."
echo ""

# ── Add your repos here ──────────────────────────────────────────────────────
link_plan "$HOME/aircam"    "$CONTEXT_DIR/aircam/CONTEXT.md"
# link_plan "$HOME/other-repo"  "$CONTEXT_DIR/other-repo/CONTEXT.md"
# ─────────────────────────────────────────────────────────────────────────────

# ── Companion repos (cloned if missing, symlinked into workspace) ────────────
ensure_companion_repo \
  "$HOME/c38_logging_notes" \
  "git@github.com:jerry-feng-skydio/c38_logging_notes.git" \
  "$HOME/aircam" \
  "c38_logging_notes"
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
echo "Done. Symlinks are gitignored globally via $GLOBAL_IGNORE."
