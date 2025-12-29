---
description: 清理累积的提交记录
allowed-tools: Bash(rm:.git/commit-accumulator/*), Bash(ls:.git/commit-accumulator/*)
argument-hint: [--all | branch-name]
---

# 清理累积记录

请执行以下操作：

1. 询问用户确认是否要清理累积记录
2. 如果确认，删除 `.git/commit-accumulator/` 目录下的相应文件
   - 如果用户指定了分支名（$1），只删除该分支的记录
   - 如果用户指定了 `--all`，删除所有累积记录
   - 如果没有参数，删除当前分支的记录
3. 报告清理结果

安全提示：此命令仅能删除 `.git/commit-accumulator/` 目录下的文件。
