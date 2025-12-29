---
description: 给当前版本打标签（重要节点标记）
allowed-tools: Bash(git tag:*), Bash(git log:*), Bash(git branch:*)
argument-hint: <tag-name> [description]
---

# 创建版本标签

为当前提交创建一个带注释的 Git 标签，用于标记重要的版本节点。

## 执行步骤

1. 获取用户提供的标签名称（$1）和描述（$ARGUMENTS 中除第一个参数外的内容）
2. 如果没有提供标签名，询问用户输入
3. 检查标签名是否已存在
4. 显示当前提交信息，让用户确认
5. 创建带注释的标签：`git tag -a <tag-name> -m "<description>"`
6. 显示创建成功的信息

## 标签命名建议

- `v1.0.0` - 版本号格式
- `feature-完成` - 功能完成标记
- `stable-日期` - 稳定版本标记
- `before-重构` - 重大修改前的备份点

## 示例

```
/tag v1.0.0 初始版本发布
/tag feature-auth 完成用户认证功能
/tag stable-20250101 稳定版本备份
```

创建后可使用 `/list-tags` 查看所有标签，使用 `/checkout-version` 回退到指定版本。
