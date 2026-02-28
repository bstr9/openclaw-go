#!/bin/bash
# SonarQube 代码扫描脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/openclaw-go"

echo "========================================"
echo "SonarQube 代码扫描"
echo "========================================"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# SonarQube Token
SONAR_TOKEN="sqp_c13fb26463dbc1ddeefc2edb85ac9852f4be27ae"

# 检查 SonarQube 是否运行
check_sonarqube() {
    echo "[1/4] 检查 SonarQube..."
    if ! curl -s http://localhost:9000/api/system/status 2>/dev/null | grep -q '"status":"UP"'; then
        echo -e "${RED}❌ SonarQube 未运行，请先运行 ./setup_sonarqube.sh${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ SonarQube 运行中${NC}"
    echo ""
}

# 生成覆盖率报告
generate_coverage() {
    echo "[2/4] 生成测试覆盖率报告..."
    cd "$PROJECT_DIR"
    
    # 运行测试并生成覆盖率
    go test -coverprofile=coverage.out -covermode=atomic ./... 2>/dev/null || true
    
    if [ -f coverage.out ]; then
        echo -e "${GREEN}✓ 覆盖率报告已生成: coverage.out${NC}"
    else
        echo -e "${YELLOW}⚠ 覆盖率报告生成失败，将跳过覆盖率分析${NC}"
    fi
    echo ""
}

# 运行代码检查
run_linters() {
    echo "[3/4] 运行代码检查..."
    cd "$PROJECT_DIR"
    
    # go vet
    echo "  运行 go vet..."
    go vet ./... 2>&1 || true
    
    # staticcheck (如果安装了)
    if command -v staticcheck &> /dev/null; then
        echo "  运行 staticcheck..."
        staticcheck ./... 2>&1 || true
    fi
    
    echo -e "${GREEN}✓ 代码检查完成${NC}"
    echo ""
}

# 运行 SonarQube 扫描
run_sonar_scan() {
    echo "[4/4] 运行 SonarQube 扫描..."
    cd "$PROJECT_DIR"
    
    # 确保 sonar-scanner 在 PATH 中
    export PATH="$PATH:/opt/sonar-scanner/bin"
    
    # 运行扫描
    sonar-scanner \
        -Dsonar.host.url=http://localhost:9000 \
        -Dsonar.token=$SONAR_TOKEN
    
    echo ""
    echo "========================================"
    echo "扫描完成！"
    echo "========================================"
    echo ""
    echo "查看报告: http://localhost:9000/dashboard?id=openclaw-go"
    echo ""
}

# 主流程
main() {
    check_sonarqube
    generate_coverage
    run_linters
    run_sonar_scan
}

main "$@"
