#!/usr/bin/env zsh
# wt - git worktree 快速切换工具
# source 此文件以启用 wt 命令

_WT_SCRIPT="${0:A:h}/wt.sh"

_wt_set_title() {
  local repo branch
  repo=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached")
  printf '\033]0;%s/%s\007' "$repo" "$branch"
}

wt() {
  local target
  case "$1" in
    list)
      bash "$_WT_SCRIPT" list
      ;;
    new)
      target=$(bash "$_WT_SCRIPT" new "$2" "$3")
      if [[ -n "$target" ]]; then
        cd "$target" && _wt_set_title
      fi
      ;;
    rm|remove)
      bash "$_WT_SCRIPT" rm "$2"
      ;;
    -h|--help|help)
      echo "usage: wt [list|new <name> [base]|rm <name>]"
      echo ""
      echo "  wt           interactive fuzzy select & switch"
      echo "  wt list      show all worktrees with status"
      echo "  wt new NAME  create worktree & switch to it"
      echo "  wt rm NAME   remove a worktree"
      ;;
    *)
      target=$(bash "$_WT_SCRIPT" select)
      if [[ -n "$target" ]]; then
        cd "$target" && _wt_set_title
      fi
      ;;
  esac
}
