---
description: 查看累积的提交记录
allowed-tools: Bash(ls:*), Bash(cat:*), Bash(git branch:*)
---

# 查看累积的提交记录

请执行以下操作：

1. 检查 `.git/commit-accumulator/` 目录
2. 列出所有累积文件
3. 显示当前分支的累积提交详情（如果存在）

显示格式：
- 分支名
- 提交数量
- 每个提交的简短信息（hash、消息、时间）
