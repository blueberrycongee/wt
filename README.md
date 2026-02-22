# wt - Git Worktree Switcher

[中文文档](README_zh.md)

A tiny shell tool for quickly switching between git worktrees with fuzzy search and automatic terminal tab titles.

Built for workflows where you run multiple worktrees side by side (e.g. one per AI coding agent).

## Features

- **Fuzzy switch** — `wt` opens fzf to pick a worktree, then `cd`s into it
- **Status overview** — `wt list` shows all worktrees with branch name and change count
- **Quick create** — `wt new <name>` creates a worktree and switches to it
- **Tab titles** — automatically sets terminal tab title to `project/branch` on switch

## Requirements

- git
- [fzf](https://github.com/junegunn/fzf)
- zsh

## Install

```bash
git clone https://github.com/YOUR_USER/wt.git ~/.wt
cd ~/.wt && bash install.sh
source ~/.zshrc
```

The install script adds `source ~/.wt/wt.plugin.zsh` to your `~/.zshrc`.

## Usage

```bash
wt                  # fuzzy select a worktree and switch
wt list             # show all worktrees with status
wt new feature-x    # create worktree on new branch "feature-x", switch to it
wt new hotfix main  # create "hotfix" based on "main"
wt rm feature-x     # remove a worktree
```

### Tab title

After switching, your terminal tab title updates to:

```
myproject/feature-x
```

This makes it easy to tell tabs apart when running multiple worktrees.

## How it works

`wt` is a zsh function (defined in `wt.plugin.zsh`) that calls `wt.sh` for the heavy lifting, then runs `cd` in the current shell. This is necessary because a subprocess cannot change the parent shell's working directory.

## License

MIT
