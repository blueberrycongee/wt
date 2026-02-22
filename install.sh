#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_PATH="${SCRIPT_DIR}/wt.plugin.zsh"
ZSHRC="${HOME}/.zshrc"
SOURCE_LINE="source \"${PLUGIN_PATH}\""

# check dependencies
for cmd in git fzf; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "error: '$cmd' is required but not found. Please install it first." >&2
    exit 1
  fi
done

# make wt.sh executable
chmod +x "${SCRIPT_DIR}/wt.sh"

# add source line to .zshrc if not already present
if grep -qF "$PLUGIN_PATH" "$ZSHRC" 2>/dev/null; then
  echo "wt plugin already configured in $ZSHRC"
else
  echo "" >> "$ZSHRC"
  echo "# wt - git worktree switcher" >> "$ZSHRC"
  echo "$SOURCE_LINE" >> "$ZSHRC"
  echo "Added to $ZSHRC. Run 'source ~/.zshrc' or open a new terminal to use 'wt'."
fi

# install /spawn skill for Claude Code
SKILL_SRC="${SCRIPT_DIR}/skills/spawn"
SKILL_DST="${HOME}/.claude/skills/spawn"

if [[ -L "$SKILL_DST" || -d "$SKILL_DST" ]]; then
  echo "/spawn skill already installed at $SKILL_DST"
else
  mkdir -p "${HOME}/.claude/skills"
  ln -s "$SKILL_SRC" "$SKILL_DST"
  echo "Installed /spawn skill for Claude Code."
fi
