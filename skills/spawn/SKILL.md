---
name: spawn
description: Summarize current discussion, create a new git worktree, and launch a new Claude Code instance with context
disable-model-invocation: true
argument-hint: <branch-name>
allowed-tools: Bash, Write, Read, Grep, Glob
---

# Spawn: 带上下文创建新 worktree 并启动 Claude Code

用户希望将当前讨论的结论带到一个新的 git worktree 中，由一个新的 Claude Code 实例继续执行。

## 参数

- `$ARGUMENTS`：新 worktree 的分支名（必填）

## 执行步骤

### 1. 检查参数

如果 `$ARGUMENTS` 为空，提示用户提供分支名，例如 `/spawn fix-login`。不要继续。

### 2. 总结当前上下文

回顾当前对话，提炼出新实例需要知道的信息，写成一段结构化的任务简报，包含：

- **任务目标**：要做什么，一句话说清
- **技术方案**：讨论中确定的实现方式、关键决策
- **关键文件**：涉及哪些文件，简要说明各自的作用
- **注意事项**：讨论中提到的坑、约束、边界条件

不要搬运原始对话，只提炼结论。保持简洁。

### 3. 创建 worktree

```bash
git worktree add ../$ARGUMENTS -b $ARGUMENTS
```

如果分支已存在，改用：

```bash
git worktree add ../$ARGUMENTS $ARGUMENTS
```

记录新 worktree 的绝对路径。

### 4. 写入上下文文件

在新 worktree 中创建 `.claude/CLAUDE.md`：

```bash
mkdir -p ../$ARGUMENTS/.claude
```

然后用 Write 工具将第 2 步的任务简报写入 `<worktree-path>/.claude/CLAUDE.md`。

格式：

```markdown
# 任务简报

## 目标
（一句话）

## 技术方案
（要点）

## 关键文件
（列表）

## 注意事项
（如有）
```

### 5. 在新终端中启动 Claude Code

使用 AppleScript 打开新终端窗口并启动 claude：

```bash
osascript -e "tell application \"Terminal\" to do script \"cd $(realpath ../$ARGUMENTS) && claude\""
```

### 6. 确认

告诉用户：
- 新 worktree 已创建在什么路径
- 上下文已写入 `.claude/CLAUDE.md`
- 新终端窗口已打开，Claude Code 正在启动
- 新实例会自动读取任务简报开始工作
