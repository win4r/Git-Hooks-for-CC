---
description: 回退到指定版本（标签或提交）
allowed-tools: Bash(git checkout:*), Bash(git log:*), Bash(git tag:*), Bash(git stash:*), Bash(git status:*), Bash(git branch:*)
argument-hint: <tag-or-commit> [--file <path>]
---

# 回退到指定版本

安全地回退代码到指定的标签或提交版本。

## 执行步骤

1. 获取目标版本（$1）- 可以是标签名或提交 hash
2. 如果没有提供版本，显示可用的标签列表供选择
3. 检查当前是否有未提交的修改
   - 如果有，询问用户是否要 stash 保存
4. 判断回退模式：
   - 如果指定了 `--file`（$2）和文件路径（$3），只恢复特定文件
   - 否则执行完整版本切换
5. 执行回退操作
6. 显示回退结果和当前状态

## 回退模式

### 模式1：查看历史版本（临时）
创建临时分支查看，不影响当前工作：
```bash
git checkout <version>
# 查看完后返回
git checkout -
```

### 模式2：恢复特定文件
只恢复某个文件到历史版本：
```bash
/checkout-version v1.0.0 --file src/main.py
```

### 模式3：完全回退（谨慎）
将当前分支重置到历史版本，会丢失之后的提交。

## 安全提示

- 回退前会自动检查未保存的修改
- 建议在回退前先打个标签标记当前位置
- 使用 `git reflog` 可以找回误删的提交

## 示例

```
/checkout-version v1.0.0
/checkout-version a1b2c3d
/checkout-version feature-auth --file config.py
```
