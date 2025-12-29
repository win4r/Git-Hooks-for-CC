---
description: 查看提交历史和版本记录
allowed-tools: Bash(git log:*), Bash(git show:*), Bash(git diff:*)
argument-hint: [--file <path>] [--count <n>]
---

# 查看提交历史

显示项目的提交历史，帮助用户了解代码变更记录。

## 执行步骤

1. 解析参数：
   - `--file <path>` 或 `-f <path>`：只显示特定文件的历史
   - `--count <n>` 或 `-n <n>`：显示最近 n 条记录（默认 10）
2. 获取提交历史
3. 以表格形式展示：
   - 提交 Hash（短）
   - 提交时间
   - 作者
   - 提交信息
   - 变更文件数量
4. 如果用户想查看某个提交的详情，可以进一步展示

## 输出格式

```
最近 10 条提交记录：

| Hash | 时间 | 作者 | 信息 | 文件数 |
|------|------|------|------|--------|
| a1b2c3d | 2025-01-01 10:30 | win4r | auto: Claude Code 自动提交 | 3 |
| e4f5g6h | 2025-01-01 10:25 | win4r | auto: Claude Code 自动提交 | 1 |

提示：使用 /checkout-version <hash> 回退到指定版本
```

## 示例

```
/history
/history --count 20
/history --file src/main.py
/history -f test.py -n 5
```

## 相关命令

- `/tag` - 给重要版本打标签
- `/list-tags` - 查看所有标签
- `/checkout-version` - 回退到指定版本
