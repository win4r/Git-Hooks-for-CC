#!/bin/bash
#===============================================================================
# Claude Git Hooks AutoDoc - 卸载脚本
#===============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TARGET_DIR="${1:-$(pwd)}"

echo ""
echo -e "${YELLOW}🗑️  Claude Git Hooks AutoDoc 卸载程序${NC}"
echo ""
echo "目标目录: $TARGET_DIR"
echo ""

read -p "确认卸载？(y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "已取消"
    exit 0
fi

cd "$TARGET_DIR"

# 恢复默认 hooks 路径
git config --unset core.hooksPath 2>/dev/null || true
echo -e "${GREEN}✓${NC} Git hooks 路径已恢复默认"

# 删除 hooks 目录
rm -rf .githooks
echo -e "${GREEN}✓${NC} .githooks 目录已删除"

# 删除 Claude commands
rm -rf .claude/commands
rmdir .claude 2>/dev/null || true
echo -e "${GREEN}✓${NC} Claude commands 已删除"

# 清理累积文件
rm -rf .git/commit-accumulator
rm -f .git/hooks.log
echo -e "${GREEN}✓${NC} 累积文件已清理"

echo ""
echo -e "${GREEN}✅ 卸载完成！${NC}"
echo ""
echo "注意：docs/features/ 目录中的文档已保留，如需删除请手动处理"
