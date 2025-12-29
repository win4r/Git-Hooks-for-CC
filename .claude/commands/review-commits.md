---
description: 查看累积的提交记录
allowed-tools: Bash(ls:.git/commit-accumulator/*), Bash(cat:.git/commit-accumulator/*), Bash(git branch:*)
argument-hint: [branch-name]
---

# 查看累积的提交记录

请执行以下操作：

1. 检查 `.git/commit-accumulator/` 目录是否存在
2. 列出所有累积文件
3. 显示提交详情：
   - 如果用户指定了分支名（$1），显示该分支的记录
   - 如果没有参数，显示当前分支的记录
   - 如果当前分支没有记录，显示所有可用的分支记录

显示格式：
- 分支名
- 提交数量
- 每个提交的简短信息（hash、消息、时间）
