---
description: 手动生成功能文档
allowed-tools: Bash(ls:.git/commit-accumulator/*), Bash(cat:.git/commit-accumulator/*), Bash(git branch:*), Read, Write(docs/features/*)
argument-hint: [branch-name]
---

# 生成功能文档

请执行以下操作：

1. 检查 `.git/commit-accumulator/` 目录中是否有累积的提交记录
2. 确定要处理的分支：
   - 如果用户指定了分支名（$1），使用该分支
   - 如果没有参数，使用当前分支
3. 读取对应的 JSON 文件
4. 基于累积的提交信息生成功能文档，包含：
   - 功能概述
   - 变更摘要
   - 技术细节
   - 影响范围
   - 相关提交列表
5. 将文档保存到 `docs/features/[分支名].md`

如果没有累积记录，请告知用户可以先进行一些提交。
