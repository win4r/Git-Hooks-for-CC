---
description: 手动生成功能文档
allowed-tools: Bash(ls:*), Bash(cat:*), Bash(git branch:*), Read, Write
---

# 生成功能文档

请执行以下操作：

1. 检查 `.git/commit-accumulator/` 目录中是否有累积的提交记录
2. 如果有，读取当前分支对应的 JSON 文件
3. 基于累积的提交信息生成功能文档
4. 将文档保存到 `docs/features/[分支名].md`

如果没有累积记录，请告知用户。
