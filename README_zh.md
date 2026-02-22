# wt - Git Worktree 快速切换工具

[English](README.md)

一个轻量的 shell 工具，用 fuzzy search 快速切换 git worktree，并自动设置终端标签页标题。

适合同时开多个 worktree 的工作流（比如每个 AI 编码实例各用一个 worktree）。

## 功能

- **模糊切换** — `wt` 弹出 fzf 选择 worktree，选中后自动 `cd`
- **状态总览** — `wt list` 显示所有 worktree 的分支名和改动数
- **快速创建** — `wt new <name>` 创建 worktree 并切换过去
- **标签页标题** — 切换后自动将终端标签页标题设为 `项目名/分支名`

## 依赖

- git
- [fzf](https://github.com/junegunn/fzf)
- zsh

## 安装

```bash
git clone https://github.com/YOUR_USER/wt.git ~/.wt
cd ~/.wt && bash install.sh
source ~/.zshrc
```

安装脚本会在 `~/.zshrc` 中添加 `source ~/.wt/wt.plugin.zsh`。

## 使用

```bash
wt                  # 模糊选择 worktree 并切换
wt list             # 显示所有 worktree 状态
wt new feature-x    # 创建新分支 "feature-x" 的 worktree 并切换
wt new hotfix main  # 基于 "main" 创建 "hotfix"
wt rm feature-x     # 删除 worktree
```

### 标签页标题

切换后终端标签页标题会自动更新为：

```
myproject/feature-x
```

多个 worktree 同时开着时一眼就能分清。

## 原理

`wt` 是一个 zsh 函数（定义在 `wt.plugin.zsh` 中），它调用 `wt.sh` 执行具体逻辑，然后在当前 shell 中执行 `cd`。这样设计是因为子进程无法改变父 shell 的工作目录。

## 许可证

MIT
