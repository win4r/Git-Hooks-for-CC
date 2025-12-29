---
description: 查看所有版本标签
allowed-tools: Bash(git tag:*), Bash(git log:*), Bash(git show:*), Bash(git for-each-ref:*)
argument-hint: [--verbose]
---

# 查看版本标签列表

显示项目中所有的 Git 标签，帮助用户了解重要的版本节点。

## 执行步骤

1. 检查是否有标签存在
2. 如果用户指定了 `--verbose` 或 `-v`（$1），显示详细信息
3. 列出所有标签，包含：
   - 标签名称
   - 创建时间
   - 标签描述/注释
   - 对应的提交 hash
4. 以表格或列表形式展示

## 输出格式

简洁模式：
```
v1.0.0
v1.1.0
feature-auth
```

详细模式（--verbose）：
```
| 标签 | 提交 | 日期 | 描述 |
|------|------|------|------|
| v1.0.0 | a1b2c3d | 2025-01-01 | 初始版本 |
```

## 相关命令

- `/tag <name>` - 创建新标签
- `/checkout-version <tag>` - 回退到指定标签
- `/delete-tag <name>` - 删除标签
