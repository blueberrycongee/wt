#!/usr/bin/env bash
set -euo pipefail

# ── helpers ──────────────────────────────────────────────

_wt_ensure_git() {
  git rev-parse --git-dir >/dev/null 2>&1 || {
    echo "error: not inside a git repository" >&2
    exit 1
  }
}

_wt_repo_name() {
  basename "$(git rev-parse --show-toplevel)"
}

# Print tab-title escape sequence to stderr (so stdout stays clean for paths)
_wt_set_title() {
  local dir="${1:-.}"
  local repo branch
  repo=$(_wt_repo_name)
  branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached")
  printf '\033]0;%s/%s\007' "$repo" "$branch" >&2
}

# ── list ─────────────────────────────────────────────────

_wt_list() {
  _wt_ensure_git

  local path="" branch="" bare=""

  while IFS= read -r line; do
    if [[ "$line" == "worktree "* ]]; then
      path="${line#worktree }"
    elif [[ "$line" == "branch "* ]]; then
      branch="${line#branch refs/heads/}"
    elif [[ "$line" == "HEAD "* ]]; then
      : # ignore
    elif [[ "$line" == "bare" ]]; then
      bare=1
    elif [[ -z "$line" ]]; then
      # end of one entry
      if [[ -n "$path" ]]; then
        if [[ "$bare" == "1" ]]; then
          printf "%-20s  %-30s  %s\n" "(bare)" "-" "$path"
        else
          local changes
          changes=$(git -C "$path" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
          local status_mark=""
          [[ "$changes" -gt 0 ]] && status_mark=" [${changes} changed]"
          printf "%-20s  %s%s\n" "${branch:-detached}" "$path" "$status_mark"
        fi
      fi
      path="" branch="" bare=""
    fi
  done < <(git worktree list --porcelain; echo)
}

# ── select (fzf) ─────────────────────────────────────────

_wt_select() {
  _wt_ensure_git

  command -v fzf >/dev/null 2>&1 || {
    echo "error: fzf is required for interactive selection" >&2
    exit 1
  }

  local entries=()
  local path="" branch="" bare=""

  while IFS= read -r line; do
    if [[ "$line" == "worktree "* ]]; then
      path="${line#worktree }"
    elif [[ "$line" == "branch "* ]]; then
      branch="${line#branch refs/heads/}"
    elif [[ "$line" == "bare" ]]; then
      bare=1
    elif [[ -z "$line" ]]; then
      if [[ -n "$path" && "$bare" != "1" ]]; then
        entries+=("$(printf "%-20s  %s" "${branch:-detached}" "$path")")
      fi
      path="" branch="" bare=""
    fi
  done < <(git worktree list --porcelain; echo)

  if [[ ${#entries[@]} -eq 0 ]]; then
    echo "error: no worktrees found" >&2
    exit 1
  fi

  local selected
  selected=$(printf '%s\n' "${entries[@]}" | fzf --prompt="worktree> " --height=40% --reverse)
  [[ -z "$selected" ]] && exit 0

  # extract path (everything after the branch column)
  local target
  target=$(echo "$selected" | awk '{print $2}')
  echo "$target"
}

# ── new ──────────────────────────────────────────────────

_wt_new() {
  _wt_ensure_git
  local name="${1:?usage: wt new <name> [base]}"
  local base="${2:-HEAD}"

  local root
  root=$(git rev-parse --show-toplevel)
  local parent
  parent=$(dirname "$root")
  local target="${parent}/${name}"

  git worktree add "$target" -b "$name" "$base" >&2
  echo "$target"
}

# ── remove ───────────────────────────────────────────────

_wt_remove() {
  _wt_ensure_git
  local name="${1:?usage: wt rm <name>}"

  local root
  root=$(git rev-parse --show-toplevel)
  local parent
  parent=$(dirname "$root")
  local target="${parent}/${name}"

  if [[ ! -d "$target" ]]; then
    echo "error: worktree directory not found: $target" >&2
    exit 1
  fi

  git worktree remove "$target" >&2
  echo "removed: $target" >&2
}

# ── dispatch ─────────────────────────────────────────────

cmd="${1:-select}"
shift || true

case "$cmd" in
  list)       _wt_list ;;
  select)     _wt_select ;;
  new)        _wt_new "$@" ;;
  rm|remove)  _wt_remove "$@" ;;
  set-title)  _wt_set_title "$@" ;;
  *)
    echo "usage: wt [list|new <name> [base]|rm <name>]" >&2
    exit 1 ;;
esac
