# Claude Git Hooks AutoDoc

## 项目概述

这是一个基于 Git Hooks + Claude Code 的全自动功能文档生成系统。当开发者使用 Claude Code 编写代码时，系统会自动记录提交、在推送前生成功能文档。

## 核心功能

1. **自动提交代码** - Claude Code 写完代码后自动执行 `git commit`
2. **自动创建分支** - 在 main/master 分支时自动创建功能分支
3. **自动记录提交** - 每次 `git commit` 后记录提交信息到 JSON 文件
4. **智能文档生成** - `git push` 前自动调用 Claude 生成功能文档

## 目录结构

```
.githooks/           # Git hooks 脚本
  ├── post-commit    # 提交后记录 hook
  └── pre-push       # 推送前生成文档 hook
.claude/
  ├── settings.json  # Claude Code 配置（团队共享）
  └── commands/      # 自定义 slash commands
docs/features/       # 自动生成的功能文档
.git/commit-accumulator/  # 提交累积目录（不提交到仓库）
```

## 开发规范

### Git 分支约定
- `main`/`master` - 主分支，受保护
- `feature/*` - 功能分支
- `fix/*` - 修复分支

### 跳过的分支
以下分支不会触发文档生成：
- main, master, develop, release

### 文档生成
- 文档输出到 `docs/features/[分支名].md`
- 使用 Claude Code headless 模式生成
- 超时时间：120秒

## 安全注意事项

1. 不要在 settings.json 中存储敏感信息（API 密钥等）
2. `.git/commit-accumulator/` 目录不应提交到版本控制
3. 个人配置应放在 `.claude/settings.local.json`（已被 gitignore）

## 常用命令

### 文档生成命令
```bash
/review-commits          # 查看累积的提交记录
/generate-feature-doc    # 手动生成功能文档
/clear-commits           # 清理累积记录
```

### 版本管理命令
```bash
/tag <name> [desc]       # 给当前版本打标签
/list-tags               # 查看所有标签
/history                 # 查看提交历史
/checkout-version <ver>  # 回退到指定版本
/delete-tag <name>       # 删除标签
```

## 依赖要求

- Git
- Claude Code CLI (`npm install -g @anthropic-ai/claude-code`)
- jq（可选，用于 JSON 处理）
