---
description: 删除版本标签
allowed-tools: Bash(git tag:*), Bash(git push:*)
argument-hint: <tag-name> [--remote]
---

# 删除版本标签

删除本地或远程的 Git 标签。

## 执行步骤

1. 获取要删除的标签名（$1）
2. 如果没有提供标签名，列出所有标签供选择
3. 确认标签存在
4. 询问用户确认是否删除
5. 删除本地标签：`git tag -d <tag-name>`
6. 如果用户指定了 `--remote`，同时删除远程标签：
   `git push origin --delete <tag-name>`
7. 显示删除结果

## 注意事项

- 删除标签是不可逆操作
- 删除远程标签需要有推送权限
- 建议只删除不再需要的临时标签

## 示例

```
/delete-tag temp-backup
/delete-tag old-version --remote
```
