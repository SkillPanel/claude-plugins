#!/usr/bin/env bash
# Setup Serena MCP for a git worktree.
# Copies pre-indexed cache and installs a post-checkout hook for future worktrees.
# project.yml and memories should be committed to git.
set -euo pipefail

CURRENT_DIR="$PWD"
SERENA_INDEX_CMD="uvx --from git+https://github.com/oraios/serena serena project index --timeout 300"
MAIN_WORKTREE="$(git worktree list --porcelain | head -1 | awk '{print $2}')"

# --- Main repo: install hook only ---
if [[ "$CURRENT_DIR" == "$MAIN_WORKTREE" ]]; then
    echo "=== Serena Hook Setup (main repo) ==="
    echo ""

    HOOK_DIR="$MAIN_WORKTREE/.git/hooks"
    HOOK_FILE="$HOOK_DIR/post-checkout"
    MARKER="# --- serena-worktree-hook ---"
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

    mkdir -p "$HOOK_DIR"
    if [[ ! -f "$HOOK_FILE" ]]; then
        echo '#!/usr/bin/env bash' > "$HOOK_FILE"
        chmod +x "$HOOK_FILE"
    fi

    if grep -q "$MARKER" "$HOOK_FILE" 2>/dev/null; then
        sed -i "/$MARKER/,/$MARKER/d" "$HOOK_FILE"
        echo "[done] Updated post-checkout hook"
    else
        echo "[done] Installed post-checkout hook"
    fi

    {
        echo ""
        echo "$MARKER"
        cat "$SCRIPT_DIR/post-checkout-serena.sh"
        echo "$MARKER"
    } >> "$HOOK_FILE"

    echo ""
    echo "Future worktrees will get .serena/cache automatically."
    echo "No other setup needed in main repo — Serena works here by default."
    exit 0
fi

echo "=== Serena Worktree Setup ==="
echo "  Worktree:  $CURRENT_DIR"
echo "  Main repo: $MAIN_WORKTREE"
echo ""

# --- Validate: project.yml must exist (should come from git checkout) ---
if [[ ! -f ".serena/project.yml" ]]; then
    if [[ -f "$MAIN_WORKTREE/.serena/project.yml" ]]; then
        echo "ERROR: .serena/project.yml is missing from this worktree"
        echo ""
        echo "It should be committed to git. In the main repo:"
        echo "  cd $MAIN_WORKTREE"
        echo "  git add .serena/project.yml .serena/memories/"
        echo "  git commit -m 'chore: track serena config'"
        echo ""
        echo "As a workaround, copying from main:"
        mkdir -p .serena
        cp "$MAIN_WORKTREE/.serena/project.yml" .serena/project.yml
        echo "[done] Copied .serena/project.yml from main"
    else
        echo "ERROR: Main project has no .serena/project.yml"
        echo ""
        echo "Serena must be set up in the main repo first:"
        echo "  cd $MAIN_WORKTREE"
        echo "  1. Pre-index:  $SERENA_INDEX_CMD"
        echo "  2. Onboarding: start Claude Code and ask \"run Serena onboarding\""
        echo "  3. Come back to this worktree and run /setup-serena again"
        exit 1
    fi
else
    echo "[ok]   .serena/project.yml present"
fi

# --- Step 1: Copy pre-indexed cache ---
# See: https://oraios.github.io/serena/02-usage/999_additional-usage.html
has_cache=false
[[ -d "$MAIN_WORKTREE/.serena/cache" ]] && [[ -n "$(ls -A "$MAIN_WORKTREE/.serena/cache" 2>/dev/null)" ]] && has_cache=true

if [[ -d ".serena/cache" ]]; then
    echo "[skip] .serena/cache already exists"
elif $has_cache; then
    cp -r "$MAIN_WORKTREE/.serena/cache" .serena/cache
    echo "[done] Copied .serena/cache from main (avoids re-indexing)"
else
    echo "[warn] Main has no pre-indexed cache — worktree will need to index from scratch"
    echo "       Fix: cd $MAIN_WORKTREE && $SERENA_INDEX_CMD"
fi

# --- Step 2: Install post-checkout hook for future worktrees ---
HOOK_DIR="$MAIN_WORKTREE/.git/hooks"
HOOK_FILE="$HOOK_DIR/post-checkout"
MARKER="# --- serena-worktree-hook ---"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$HOOK_DIR"
if [[ ! -f "$HOOK_FILE" ]]; then
    echo '#!/usr/bin/env bash' > "$HOOK_FILE"
    chmod +x "$HOOK_FILE"
fi

if [[ -f "$HOOK_FILE" ]] && grep -q "$MARKER" "$HOOK_FILE"; then
    # Remove old hook block and replace with current version
    sed -i "/$MARKER/,/$MARKER/d" "$HOOK_FILE"
    echo "[done] Updated post-checkout hook"
else
    echo "[done] Installed post-checkout hook"
fi

{
    echo ""
    echo "$MARKER"
    cat "$SCRIPT_DIR/post-checkout-serena.sh"
    echo "$MARKER"
} >> "$HOOK_FILE"

# --- Summary ---
echo ""
echo "=== Serena configured for worktree ==="
echo "  .serena/project.yml  — from git"
echo "  .serena/cache/       — $(if [[ -d .serena/cache ]]; then echo "copied from main"; else echo "not available"; fi)"
echo "  post-checkout hook   — installed"
