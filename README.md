# [🚀观看我的哔哩哔哩视频](https://space.bilibili.com/3493277319825652)

# 🤖 Claude Git Hooks AutoDoc

### 我的b站频道：https://space.bilibili.com/3493277319825652
### 我的yt频道：https://www.youtube.com/@AIsuperdomain

基于 Git Hooks + Claude Code 的**全自动**功能文档生成系统。

## ✨ 功能特点

- **🔥 自动提交代码**：Claude Code 写完代码后自动 `git commit`（可选）
- **🌿 自动创建分支**：在 main/master 分支时自动创建功能分支（可选）
- **自动记录提交**：每次 `git commit` 后自动记录提交信息到 JSON 文件
- **智能文档生成**：`git push` 前自动调用 Claude 生成功能文档
- **累积汇总**：支持多次提交累积，推送时一次性生成完整文档
- **Claude Code 集成**：提供 slash commands 支持手动操作
- **一键安装**：单个脚本完成所有配置

## 📊 工作流程

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        🚀 全自动开发工作流                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   Claude Code 写代码                                                    │
│         │                                                               │
│         ├──► PreToolUse Hook ──► 如果在 main 分支，自动创建功能分支      │
│         │                                                               │
│         ├──► PostToolUse Hook ──► 自动 git commit                       │
│         │                                                               │
│         ▼                                                               │
│   post-commit hook ──► 记录到 JSON (.git/commit-accumulator/)           │
│         │                                                               │
│         ▼                                                               │
│   git push ──► pre-push hook                                            │
│                   │                                                     │
│                   ├──► 读取累积的提交记录                                │
│                   ├──► 调用 Claude Code 生成文档                         │
│                   ├──► 自动提交文档到 docs/features/                     │
│                   └──► 清理累积文件                                      │
│                                                                         │
│   ✨ 你只需要: 让 Claude Code 写代码 + git push                          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## 🚀 快速安装

### 方法一：一键安装（推荐）

在你的项目目录中运行：

```bash
# 下载并执行安装脚本（推荐使用 jsDelivr CDN，更新更快）
curl -fsSL https://cdn.jsdelivr.net/gh/win4r/Git-Hooks-for-CC@main/install.sh | bash

# 或使用 GitHub Raw（可能有缓存延迟）
curl -fsSL https://raw.githubusercontent.com/win4r/Git-Hooks-for-CC/main/install.sh | bash
```

或者克隆仓库后安装：

```bash
git clone https://github.com/win4r/Git-Hooks-for-CC.git
cd Git-Hooks-for-CC
./install.sh /path/to/your/project
```

### 方法二：Claude Code 中一键安装

在 Claude Code 中直接执行：

```
请帮我安装 Claude Git Hooks AutoDoc 系统：

1. 创建目录结构：.githooks/, .claude/commands/, docs/features/, .git/commit-accumulator/
2. 下载并配置 post-commit 和 pre-push hooks
3. 创建 Claude Code slash commands（review-commits, generate-feature-doc, clear-commits）
4. 配置 git config core.hooksPath .githooks
5. 更新 .gitignore

请从 https://github.com/win4r/Git-Hooks-for-CC 获取脚本内容。
```

### 方法三：手动安装

```bash
# 1. 克隆仓库
git clone https://github.com/win4r/Git-Hooks-for-CC.git
cd Git-Hooks-for-CC

# 2. 复制文件到你的项目
cp -r .githooks /path/to/your/project/
cp -r .claude /path/to/your/project/
mkdir -p /path/to/your/project/docs/features

# 3. 设置权限
chmod +x /path/to/your/project/.githooks/*

# 4. 配置 Git
cd /path/to/your/project
git config core.hooksPath .githooks

# 5. 创建累积目录
mkdir -p .git/commit-accumulator
```

**仓库文件说明：**
| 文件 | 说明 |
|------|------|
| `.githooks/post-commit` | 提交后记录 hook |
| `.githooks/pre-push` | 推送前生成文档 hook |
| `.claude/settings.json` | 自动提交 + 自动创建分支配置 |
| `.claude/commands/*.md` | 斜杠命令 |
| `scripts/setup-hooks.sh` | 备用安装脚本 |

## 📁 目录结构

```
your-project/
├── .githooks/
│   ├── post-commit              # 提交后记录 hook
│   └── pre-push                 # 推送前生成文档 hook
├── .claude/
│   ├── settings.json            # 自动提交 + 自动创建分支配置
│   └── commands/
│       ├── review-commits.md    # 查看累积的提交
│       ├── generate-feature-doc.md  # 手动生成文档
│       └── clear-commits.md     # 清理累积记录
├── docs/
│   └── features/                # 自动生成的文档目录
│       └── [branch-name].md
├── .git/
│   └── commit-accumulator/      # 提交累积目录（不提交到仓库）
│       └── [branch-name].json
└── .gitignore
```

## 📋 使用方法

### 自动模式（推荐）

正常使用 Git 即可，hooks 会自动运行：

```bash
# 创建功能分支
git checkout -b feature/my-new-feature

# 正常开发并提交
git add .
git commit -m "feat: 添加新功能"      # ← 自动记录提交
git commit -m "fix: 修复问题"         # ← 继续累积
git commit -m "refactor: 优化代码"    # ← 继续累积

# 推送时自动生成文档
git push                              # ← 自动生成 docs/features/feature-my-new-feature.md
```

### 手动模式

使用 Claude Code 的 slash commands：

```bash
# 查看累积的提交记录
/review-commits

# 手动生成文档（不推送）
/generate-feature-doc

# 清理累积记录
/clear-commits
```

## ⚙️ 配置选项

### 自动提交配置

安装时会询问是否启用自动提交。如需手动配置，编辑 `.claude/settings.json`（项目级配置，不会被覆盖）：

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'if [[ -n $(git status --porcelain 2>/dev/null) ]]; then git add -A && git commit -m \"auto: Claude Code 自动提交\" --no-verify 2>/dev/null && echo \"✅ 已自动提交\"; fi'"
          }
        ]
      }
    ]
  }
}
```

删除此文件可禁用自动提交功能。

### 跳过特定分支

编辑 `.githooks/post-commit` 和 `.githooks/pre-push`：

```bash
# 不记录/生成这些分支的文档
SKIP_BRANCHES=("main" "master" "develop" "release")
```

### Claude 超时设置

编辑 `.githooks/pre-push`：

```bash
CLAUDE_TIMEOUT=120  # 秒
```

### 文档输出目录

编辑 `.githooks/pre-push`：

```bash
DOCS_DIR="docs/features"
```

## 📝 生成的文档示例

```markdown
# 用户认证功能

## 概述
实现了完整的用户认证系统，包括登录、注册和 JWT token 管理。

## 变更摘要
- 添加用户登录 API 端点
- 实现 JWT token 生成和验证
- 创建用户注册表单组件
- 添加密码加密处理

## 技术细节
- 使用 bcrypt 进行密码哈希
- JWT token 有效期 7 天
- 支持 refresh token 机制

## 影响范围
- `src/api/auth/` - 认证 API
- `src/components/auth/` - 认证组件
- `src/middleware/` - 认证中间件

## 相关提交
| Hash | 消息 | 时间 |
|------|------|------|
| `a1b2c3d` | feat: 添加登录 API | 2025-01-15 10:30:00 |
| `e4f5g6h` | feat: 实现 JWT 验证 | 2025-01-15 14:20:00 |

---
*此文档由 Claude Code 自动生成*
```

## 🔧 依赖要求

| 依赖 | 必需 | 说明 |
|------|------|------|
| Git | ✅ | 版本控制 |
| Claude Code CLI | ✅ | 文档生成 |
| jq | ⬜ | JSON 处理（可选，有备用方案） |
| Bash | ✅ | Shell 脚本执行 |

### 安装 Claude Code CLI

```bash
npm install -g @anthropic-ai/claude-code
```

### 安装 jq（推荐）

```bash
# macOS
brew install jq

# Ubuntu/Debian
apt install jq

# Windows (通过 scoop)
scoop install jq
```

## ❓ 常见问题

### Q: Claude Code 不可用怎么办？

A: pre-push hook 会生成一个基础模板，不会阻止推送。

### Q: 如何跳过 hooks？

```bash
git commit --no-verify -m "message"
git push --no-verify
```

### Q: 累积文件在哪里？

```bash
ls .git/commit-accumulator/
cat .git/commit-accumulator/[branch-name].json
```

### Q: 如何查看 hooks 日志？

```bash
cat .git/hooks.log
```

### Q: Slash commands 找不到？

确保命令文件有正确的 YAML frontmatter：

```markdown
---
description: 命令描述
allowed-tools: Bash(ls:*), Read
---

# 命令内容
```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📜 许可证

MIT License
