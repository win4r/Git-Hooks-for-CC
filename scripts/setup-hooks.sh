#!/bin/bash
#===============================================================================
# Git Hooks 安装脚本
# 
# 用法: ./scripts/setup-hooks.sh
# 
# 此脚本将：
#   1. 配置 Git 使用 .githooks 目录
#   2. 设置 hook 文件为可执行
#   3. 创建必要的目录结构
#   4. 验证 Claude Code 是否可用
#===============================================================================

set -e

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         🔧 Git Hooks 安装程序                                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

#-------------------------------------------------------------------------------
# 检查是否在 Git 仓库中
#-------------------------------------------------------------------------------
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ 错误：当前目录不是 Git 仓库"
    exit 1
fi

PROJECT_ROOT=$(git rev-parse --show-toplevel)
cd "$PROJECT_ROOT"

echo "📁 项目根目录: $PROJECT_ROOT"
echo ""

#-------------------------------------------------------------------------------
# Step 1: 创建目录结构
#-------------------------------------------------------------------------------
echo "📂 Step 1: 创建目录结构..."

mkdir -p .githooks
mkdir -p .claude/commands
mkdir -p scripts
mkdir -p docs/features
mkdir -p .git/commit-accumulator

touch docs/features/.gitkeep

echo "   ✅ 目录结构已创建"

#-------------------------------------------------------------------------------
# Step 2: 设置 hook 文件权限
#-------------------------------------------------------------------------------
echo ""
echo "🔐 Step 2: 设置文件权限..."

if [[ -f ".githooks/post-commit" ]]; then
    chmod +x .githooks/post-commit
    echo "   ✅ post-commit: 可执行"
else
    echo "   ⚠️  post-commit: 文件不存在"
fi

if [[ -f ".githooks/pre-push" ]]; then
    chmod +x .githooks/pre-push
    echo "   ✅ pre-push: 可执行"
else
    echo "   ⚠️  pre-push: 文件不存在"
fi

#-------------------------------------------------------------------------------
# Step 3: 配置 Git hooks 路径
#-------------------------------------------------------------------------------
echo ""
echo "⚙️  Step 3: 配置 Git hooks 路径..."

git config core.hooksPath .githooks
echo "   ✅ Git hooks 路径已设置为 .githooks"

# 验证配置
HOOKS_PATH=$(git config --get core.hooksPath)
echo "   📍 当前配置: $HOOKS_PATH"

#-------------------------------------------------------------------------------
# Step 4: 检查依赖
#-------------------------------------------------------------------------------
echo ""
echo "🔍 Step 4: 检查依赖..."

# 检查 jq
if command -v jq &> /dev/null; then
    echo "   ✅ jq: $(jq --version)"
else
    echo "   ⚠️  jq: 未安装（将使用备用文本格式）"
    echo "      建议安装: brew install jq 或 apt install jq"
fi

# 检查 Claude Code
if command -v claude &> /dev/null; then
    echo "   ✅ Claude Code: 已安装"
    
    # 尝试获取版本
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "版本未知")
    echo "      版本: $CLAUDE_VERSION"
else
    echo "   ❌ Claude Code: 未安装"
    echo "      请先安装 Claude Code CLI"
    echo "      参考: https://docs.anthropic.com/claude-code"
fi

#-------------------------------------------------------------------------------
# Step 5: 创建 .gitignore 条目
#-------------------------------------------------------------------------------
echo ""
echo "📝 Step 5: 更新 .gitignore..."

GITIGNORE_ENTRIES=(
    "# Git hooks 临时文件"
    ".git/commit-accumulator/"
    ".git/hooks.log"
)

for entry in "${GITIGNORE_ENTRIES[@]}"; do
    if ! grep -qF "$entry" .gitignore 2>/dev/null; then
        echo "$entry" >> .gitignore
        echo "   ✅ 已添加: $entry"
    fi
done

#-------------------------------------------------------------------------------
# 完成
#-------------------------------------------------------------------------------
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         ✅ 安装完成！                                        ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║                                                              ║"
echo "║  现在每次 git commit 后会自动记录提交信息                      ║"
echo "║  每次 git push 前会自动生成功能文档                            ║"
echo "║                                                              ║"
echo "║  测试命令:                                                    ║"
echo "║    git commit -m \"test: 测试 hook\"                          ║"
echo "║    cat .git/commit-accumulator/*.json                       ║"
echo "║                                                              ║"
echo "║  查看日志:                                                    ║"
echo "║    cat .git/hooks.log                                       ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
