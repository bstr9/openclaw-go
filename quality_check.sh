#!/bin/bash
# 快速代码质量检查 (不依赖 SonarQube)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/openclaw-go"

echo "========================================"
echo "代码质量快速检查"
echo "========================================"
echo ""

cd "$PROJECT_DIR"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ISSUES=0

# 1. 编译检查
echo "[1/6] 编译检查..."
if go build ./...; then
    echo -e "${GREEN}✓ 编译通过${NC}"
else
    echo -e "${RED}✗ 编译失败${NC}"
    ISSUES=$((ISSUES + 1))
fi
echo ""

# 2. go vet
echo "[2/6] go vet 静态分析..."
if go vet ./... 2>&1; then
    echo -e "${GREEN}✓ go vet 通过${NC}"
else
    echo -e "${YELLOW}⚠ go vet 发现问题${NC}"
    ISSUES=$((ISSUES + 1))
fi
echo ""

# 3. 测试
echo "[3/6] 单元测试..."
if go test ./... -count=1 2>&1; then
    echo -e "${GREEN}✓ 测试通过${NC}"
else
    echo -e "${YELLOW}⚠ 部分测试失败${NC}"
    ISSUES=$((ISSUES + 1))
fi
echo ""

# 4. 测试覆盖率
echo "[4/6] 测试覆盖率..."
go test -coverprofile=coverage.out -covermode=atomic ./... 2>/dev/null || true
if [ -f coverage.out ]; then
    COVERAGE=$(go tool cover -func=coverage.out | tail -1 | awk '{print $3}' | sed 's/%//')
    echo "  总覆盖率: ${COVERAGE}%"
    if (( $(echo "$COVERAGE >= 50" | bc -l) )); then
        echo -e "${GREEN}✓ 覆盖率达标 (≥50%)${NC}"
    else
        echo -e "${YELLOW}⚠ 覆盖率偏低 (<50%)${NC}"
    fi
else
    echo -e "${YELLOW}⚠ 无法生成覆盖率报告${NC}"
fi
echo ""

# 5. 代码格式
echo "[5/6] 代码格式检查..."
if [ -z "$(gofmt -l .)" ]; then
    echo -e "${GREEN}✓ 代码格式正确${NC}"
else
    echo -e "${YELLOW}⚠ 以下文件需要格式化:${NC}"
    gofmt -l .
    ISSUES=$((ISSUES + 1))
fi
echo ""

# 6. 检查 TODO/FIXME
echo "[6/6] TODO/FIXME 统计..."
TODOS=$(grep -r "TODO" --include="*.go" . 2>/dev/null | wc -l || echo 0)
FIXMES=$(grep -r "FIXME" --include="*.go" . 2>/dev/null | wc -l || echo 0)
echo "  TODO: $TODOS 个"
echo "  FIXME: $FIXMES 个"
echo ""

# 总结
echo "========================================"
echo "检查完成"
echo "========================================"
if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✓ 所有检查通过${NC}"
else
    echo -e "${YELLOW}⚠ 发现 $ISSUES 个问题需要关注${NC}"
fi
echo ""

# 清理
rm -f coverage.out
