#!/bin/bash
#===============================================================================
# Claude Git Hooks AutoDoc - 一键安装脚本
#
# 用法:
#   curl -fsSL https://raw.githubusercontent.com/YOUR_REPO/install.sh | bash
#   或
#   ./install.sh [目标项目路径]
#
# 功能：
#   - 自动安装 Git Hooks（post-commit + pre-push）
#   - 配置 Claude Code slash commands
#   - 创建必要的目录结构
#===============================================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印函数
print_header() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     🤖 Claude Git Hooks AutoDoc 安装程序                     ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}▶${NC} $1"
}

print_success() {
    echo -e "  ${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "  ${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "  ${RED}✗${NC} $1"
}

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 确定目标项目路径
if [[ -n "$1" ]]; then
    TARGET_DIR="$1"
else
    TARGET_DIR="$(pwd)"
fi

# 转换为绝对路径
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || {
    print_error "目标路径不存在: $1"
    exit 1
}

print_header

echo "📁 安装目标: $TARGET_DIR"
echo ""

#-------------------------------------------------------------------------------
# 检查是否是 Git 仓库
#-------------------------------------------------------------------------------
print_step "检查 Git 仓库..."

if [[ ! -d "$TARGET_DIR/.git" ]]; then
    print_warning "目标路径不是 Git 仓库"
    echo ""
    echo -e "   是否要在此目录初始化 Git 仓库？"
    echo -e "   ${YELLOW}[y]${NC} 是，初始化 Git 仓库"
    echo -e "   ${YELLOW}[n]${NC} 否，退出安装"
    echo ""
    read -p "   请选择 (y/N): " -n 1 -r < /dev/tty
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$TARGET_DIR"
        git init
        print_success "Git 仓库已初始化"
    else
        print_error "安装已取消"
        echo "   请先运行 'git init' 或选择一个 Git 仓库"
        exit 1
    fi
else
    print_success "Git 仓库检测通过"
fi

#-------------------------------------------------------------------------------
# 创建目录结构
#-------------------------------------------------------------------------------
print_step "创建目录结构..."

mkdir -p "$TARGET_DIR/.githooks"
mkdir -p "$TARGET_DIR/.claude/commands"
mkdir -p "$TARGET_DIR/scripts"
mkdir -p "$TARGET_DIR/docs/features"
mkdir -p "$TARGET_DIR/.git/commit-accumulator"

touch "$TARGET_DIR/docs/features/.gitkeep"

print_success "目录结构已创建"

#-------------------------------------------------------------------------------
# 安装 Git Hooks
#-------------------------------------------------------------------------------
print_step "安装 Git Hooks..."

# post-commit hook
cat > "$TARGET_DIR/.githooks/post-commit" << 'HOOK_EOF'
#!/bin/bash
#===============================================================================
# Post-Commit Hook: 累积记录每次提交信息
#===============================================================================

set -e

ACCUMULATOR_DIR=".git/commit-accumulator"
LOG_FILE=".git/hooks.log"
SKIP_BRANCHES=("main" "master" "develop" "release")

log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [post-commit] $1" >> "$LOG_FILE"
}

is_skip_branch() {
    local branch=$1
    for skip in "${SKIP_BRANCHES[@]}"; do
        [[ "$branch" == "$skip" ]] && return 0
    done
    return 1
}

main() {
    local current_branch=$(git branch --show-current 2>/dev/null)

    [[ -z "$current_branch" ]] && exit 0
    is_skip_branch "$current_branch" && exit 0

    mkdir -p "$ACCUMULATOR_DIR"

    local safe_branch_name=$(echo "$current_branch" | tr '/' '-')
    local accumulator_file="$ACCUMULATOR_DIR/${safe_branch_name}.json"

    local commit_hash=$(git log -1 --pretty=%H)
    local commit_hash_short=$(git log -1 --pretty=%h)
    local commit_message=$(git log -1 --pretty=%B | head -1)
    local commit_body=$(git log -1 --pretty=%b)
    local commit_author=$(git log -1 --pretty=%an)
    local commit_date=$(git log -1 --pretty=%ci)
    local changed_files=$(git diff-tree --no-commit-id --name-only -r HEAD | tr '\n' ',' | sed 's/,$//')
    local stats=$(git diff-tree --no-commit-id --stat -r HEAD | tail -1)

    # 转义 JSON 特殊字符
    local escaped_message=$(echo "$commit_message" | sed 's/\\/\\\\/g; s/"/\\"/g')
    local escaped_stats=$(echo "$stats" | sed 's/\\/\\\\/g; s/"/\\"/g')

    local json_entry=$(cat << EOF
{
    "hash": "$commit_hash",
    "hash_short": "$commit_hash_short",
    "message": "$escaped_message",
    "body": $(echo "$commit_body" | jq -Rs . 2>/dev/null || echo '""'),
    "author": "$commit_author",
    "date": "$commit_date",
    "files": "$changed_files",
    "stats": "$escaped_stats"
}
EOF
)

    if [[ ! -f "$accumulator_file" ]]; then
        echo '{
    "branch": "'"$current_branch"'",
    "created_at": "'"$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')"'",
    "commits": []
}' > "$accumulator_file"
    fi

    if command -v jq &> /dev/null; then
        local temp_file=$(mktemp)
        jq --argjson commit "$json_entry" '.commits += [$commit] | .updated_at = "'"$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')"'"' "$accumulator_file" > "$temp_file"
        mv "$temp_file" "$accumulator_file"
    else
        local text_file="$ACCUMULATOR_DIR/${safe_branch_name}.txt"
        echo -e "---\nCommit: $commit_hash_short\nDate: $commit_date\nMessage: $commit_message\nFiles: $changed_files\n" >> "$text_file"
    fi

    log "已记录提交 $commit_hash_short 到 $accumulator_file"
    echo "📝 已记录提交 $commit_hash_short"
}

main "$@"
HOOK_EOF

chmod +x "$TARGET_DIR/.githooks/post-commit"
print_success "post-commit hook 已安装"

# pre-push hook
cat > "$TARGET_DIR/.githooks/pre-push" << 'HOOK_EOF'
#!/bin/bash
#===============================================================================
# Pre-Push Hook: 汇总累积的提交并生成功能文档
#===============================================================================

set -e

ACCUMULATOR_DIR=".git/commit-accumulator"
DOCS_DIR="docs/features"
LOG_FILE=".git/hooks.log"
SKIP_BRANCHES=("main" "master" "develop" "release")
CLAUDE_TIMEOUT=120

log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [pre-push] $1" >> "$LOG_FILE"
}

is_skip_branch() {
    local branch=$1
    for skip in "${SKIP_BRANCHES[@]}"; do
        [[ "$branch" == "$skip" ]] && return 0
    done
    return 1
}

generate_documentation() {
    local branch=$1
    local accumulator_file=$2
    local output_file=$3

    local commits_content=""

    if command -v jq &> /dev/null && [[ -f "$accumulator_file" ]]; then
        commits_content=$(jq -r '
            "## 分支信息\n- 分支名: \(.branch)\n- 创建时间: \(.created_at)\n\n## 提交记录\n" +
            ([.commits[] | "### \(.hash_short) - \(.message)\n- 时间: \(.date)\n- 作者: \(.author)\n- 文件: \(.files)\n- 统计: \(.stats)\n"] | join("\n"))
        ' "$accumulator_file" 2>/dev/null)
    else
        local text_file="${accumulator_file%.json}.txt"
        [[ -f "$text_file" ]] && commits_content=$(cat "$text_file")
    fi

    [[ -z "$commits_content" ]] && return 1

    local prompt="你是一个专业的技术文档工程师。请基于以下 Git 提交记录生成功能文档。

$commits_content

生成 Markdown 格式文档，包含：
# [功能名称]
## 概述（2-3句话）
## 变更摘要（bullet points）
## 技术细节
## 影响范围
## 相关提交

要求：简洁专业，300字以内，只输出Markdown。"

    log "开始调用 Claude 生成文档..."
    echo "🤖 正在调用 Claude 生成文档..."

    local claude_output
    claude_output=$(timeout "$CLAUDE_TIMEOUT" claude -p "$prompt" --output-format text 2>&1) || true

    if [[ -z "$claude_output" ]] || [[ "$claude_output" == *"error"* ]]; then
        log "Claude 生成失败，使用基础模板"
        claude_output="# 功能文档: $branch

## 提交记录
$commits_content

---
*此文档需要手动完善*"
    fi

    echo "$claude_output" > "$output_file"
    log "文档已生成: $output_file"
    return 0
}

main() {
    log "========== Pre-push hook 开始 =========="

    local current_branch=$(git branch --show-current 2>/dev/null)
    [[ -z "$current_branch" ]] && exit 0

    log "当前分支: $current_branch"

    if is_skip_branch "$current_branch"; then
        echo "📌 跳过文档生成（分支: $current_branch）"
        exit 0
    fi

    local safe_branch_name=$(echo "$current_branch" | tr '/' '-')
    local accumulator_file="$ACCUMULATOR_DIR/${safe_branch_name}.json"
    local accumulator_text="$ACCUMULATOR_DIR/${safe_branch_name}.txt"

    if [[ ! -f "$accumulator_file" ]] && [[ ! -f "$accumulator_text" ]]; then
        echo "📌 没有新的提交记录需要生成文档"
        exit 0
    fi

    if ! command -v claude &> /dev/null; then
        echo "⚠️ Claude Code CLI 未安装，跳过文档生成"
        exit 0
    fi

    mkdir -p "$DOCS_DIR"
    local doc_file="$DOCS_DIR/${safe_branch_name}.md"

    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           📝 Claude Code 文档生成器                          ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║  分支: $current_branch"
    echo "║  输出: $doc_file"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""

    if generate_documentation "$current_branch" "$accumulator_file" "$doc_file"; then
        echo "✅ 文档生成成功！"

        if [[ -s "$doc_file" ]]; then
            git add "$doc_file"
            if ! git diff --cached --quiet "$doc_file" 2>/dev/null; then
                # 注意：使用 --no-verify 是为了避免 pre-push hook 的无限循环
                # 这仅用于自动生成的文档提交
                git commit -m "docs($safe_branch_name): auto-generate feature documentation" --no-verify
                echo "✅ 文档已提交到仓库"
            fi
        fi

        rm -f "$accumulator_file" "$accumulator_text"
        echo "🧹 累积记录已清理"
    fi

    log "========== Pre-push hook 完成 =========="
    exit 0
}

main "$@"
HOOK_EOF

chmod +x "$TARGET_DIR/.githooks/pre-push"
print_success "pre-push hook 已安装"

#-------------------------------------------------------------------------------
# 安装 Claude Commands
#-------------------------------------------------------------------------------
print_step "安装 Claude Code 命令..."

# review-commits command
cat > "$TARGET_DIR/.claude/commands/review-commits.md" << 'CMD_EOF'
---
description: 查看累积的提交记录
allowed-tools: Bash(ls:.git/commit-accumulator/*), Bash(cat:.git/commit-accumulator/*), Bash(git branch:*)
argument-hint: [branch-name]
---

# 查看累积的提交记录

请执行以下操作：

1. 检查 `.git/commit-accumulator/` 目录是否存在
2. 列出所有累积文件
3. 显示提交详情：
   - 如果用户指定了分支名（$1），显示该分支的记录
   - 如果没有参数，显示当前分支的记录
   - 如果当前分支没有记录，显示所有可用的分支记录

显示格式：
- 分支名
- 提交数量
- 每个提交的简短信息（hash、消息、时间）
CMD_EOF

# generate-feature-doc command
cat > "$TARGET_DIR/.claude/commands/generate-feature-doc.md" << 'CMD_EOF'
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
CMD_EOF

# clear-commits command
cat > "$TARGET_DIR/.claude/commands/clear-commits.md" << 'CMD_EOF'
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
CMD_EOF

print_success "Claude Code 命令已安装"

#-------------------------------------------------------------------------------
# 配置自动提交（可选）
#-------------------------------------------------------------------------------
print_step "配置 Claude Code 自动提交..."

echo ""
echo -e "   是否启用 Claude Code 自动提交功能？"
echo -e "   ${YELLOW}[y]${NC} 是，Claude Code 写代码后自动 git commit"
echo -e "   ${YELLOW}[n]${NC} 否，手动执行 git commit"
echo ""
read -p "   请选择 (Y/n): " -n 1 -r < /dev/tty
echo ""

if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    # 使用 settings.json（项目级配置，不会被 Claude Code 覆盖）
    cat > "$TARGET_DIR/.claude/settings.json" << 'SETTINGS_EOF'
{
  "permissions": {
    "allow": [
      "Read(docs/**)",
      "Read(.githooks/**)",
      "Read(.claude/**)",
      "Write(docs/features/**)",
      "Bash(git:*)",
      "Bash(ls:*)",
      "Bash(cat:.git/commit-accumulator/*)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Read(./**/*.pem)",
      "Read(./**/*.key)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'branch=\"$(git branch --show-current 2>/dev/null)\"; if [[ \"$branch\" == \"main\" || \"$branch\" == \"master\" ]]; then new_branch=\"feature/auto-$(date +%Y%m%d-%H%M%S)\"; git checkout -b \"$new_branch\" 2>/dev/null && echo \"已自动创建分支: $new_branch\"; fi'",
            "timeout": 30
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'if [[ -n \"$(git status --porcelain 2>/dev/null)\" ]]; then git add -A && git commit -m \"auto: Claude Code 自动提交\" --no-verify 2>/dev/null && echo \"已自动提交\"; fi'",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
SETTINGS_EOF
    print_success "自动提交已启用（配置文件: .claude/settings.json）"
    print_success "自动创建分支已启用（在 main/master 分支时自动创建功能分支）"
    print_success "权限配置已添加（保护敏感文件）"
else
    print_warning "自动提交未启用（可稍后手动配置）"
fi

#-------------------------------------------------------------------------------
# 配置 Git
#-------------------------------------------------------------------------------
print_step "配置 Git hooks 路径..."

cd "$TARGET_DIR"
git config core.hooksPath .githooks

print_success "Git hooks 路径已设置为 .githooks"

#-------------------------------------------------------------------------------
# 更新 .gitignore
#-------------------------------------------------------------------------------
print_step "更新 .gitignore..."

GITIGNORE_ENTRIES=(
    ""
    "# Claude Git Hooks AutoDoc"
    ".git/commit-accumulator/"
    ".git/hooks.log"
    ""
    "# Claude Code 本地配置"
    ".claude/settings.local.json"
    ".claude.local.md"
    "CLAUDE.local.md"
    ""
    "# 敏感文件"
    ".env"
    ".env.*"
    "secrets/"
)

for entry in "${GITIGNORE_ENTRIES[@]}"; do
    if [[ -n "$entry" ]] && ! grep -qF "$entry" "$TARGET_DIR/.gitignore" 2>/dev/null; then
        echo "$entry" >> "$TARGET_DIR/.gitignore"
    fi
done

print_success ".gitignore 已更新"

#-------------------------------------------------------------------------------
# 检查依赖
#-------------------------------------------------------------------------------
print_step "检查依赖..."

if command -v jq &> /dev/null; then
    print_success "jq: $(jq --version)"
else
    print_warning "jq 未安装（将使用备用文本格式）"
    echo "      建议安装: brew install jq"
fi

if command -v claude &> /dev/null; then
    print_success "Claude Code: 已安装"
else
    print_warning "Claude Code CLI 未安装"
    echo "      请安装 Claude Code: npm install -g @anthropic-ai/claude-code"
fi

#-------------------------------------------------------------------------------
# 完成
#-------------------------------------------------------------------------------
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         ✅ 安装完成！                                        ║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}║  🚀 完整自动化流程:                                          ║${NC}"
echo -e "${GREEN}║    Claude Code 写代码 → 自动提交 → 自动记录                  ║${NC}"
echo -e "${GREEN}║    git push → 自动生成文档 → 自动提交文档                    ║${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}║  📋 Claude Code 命令:                                        ║${NC}"
echo -e "${GREEN}║    /review-commits        查看累积的提交                     ║${NC}"
echo -e "${GREEN}║    /generate-feature-doc  手动生成文档                       ║${NC}"
echo -e "${GREEN}║    /clear-commits         清理累积记录                       ║${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
