#!/bin/bash
# SonarQube 代码质量扫描环境安装脚本
# 用于 openclaw-go 项目

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/openclaw-go"

echo "========================================"
echo "SonarQube 代码质量扫描环境安装"
echo "========================================"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查 Docker
check_docker() {
    echo "[1/5] 检查 Docker..."
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker 未安装${NC}"
        exit 1
    fi
    if ! docker ps &> /dev/null; then
        echo -e "${RED}❌ Docker 未运行或权限不足${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Docker 可用${NC}"
    echo ""
}

# 检查并启动 SonarQube 容器
setup_sonarqube() {
    echo "[2/5] 设置 SonarQube 容器..."
    
    # 检查是否已存在 sonarqube 容器
    if docker ps -a --format '{{.Names}}' | grep -q '^sonarqube$'; then
        echo "  SonarQube 容器已存在"
        if docker ps --format '{{.Names}}' | grep -q '^sonarqube$'; then
            echo -e "${GREEN}✓ SonarQube 已在运行${NC}"
        else
            echo "  启动已存在的容器..."
            docker start sonarqube
            echo -e "${GREEN}✓ SonarQube 已启动${NC}"
        fi
    else
        echo "  创建新的 SonarQube 容器..."
        docker run -d --name sonarqube \
            -p 9000:9000 \
            -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
            -v sonarqube_data:/opt/sonarqube/data \
            -v sonarqube_logs:/opt/sonarqube/logs \
            -v sonarqube_extensions:/opt/sonarqube/extensions \
            sonarqube:community
        
        echo -e "${GREEN}✓ SonarQube 容器已创建${NC}"
    fi
    
    echo ""
    echo "  等待 SonarQube 启动 (可能需要 1-2 分钟)..."
    
    # 等待 SonarQube 就绪
    for i in {1..60}; do
        if curl -s http://localhost:9000/api/system/status 2>/dev/null | grep -q '"status":"UP"'; then
            echo -e "${GREEN}✓ SonarQube 已就绪${NC}"
            break
        fi
        if [ $i -eq 60 ]; then
            echo -e "${YELLOW}⚠ 等待超时，请手动检查 http://localhost:9000${NC}"
        fi
        sleep 2
    done
    
    echo ""
}

# 安装 sonar-scanner
install_scanner() {
    echo "[3/5] 安装 sonar-scanner..."
    
    if command -v sonar-scanner &> /dev/null; then
        echo -e "${GREEN}✓ sonar-scanner 已安装${NC}"
    else
        echo "  下载 sonar-scanner..."
        SCANNER_VERSION="5.0.1.3006"
        SCANNER_DIR="/opt/sonar-scanner"
        
        if [ ! -d "$SCANNER_DIR" ]; then
            cd /tmp
            wget -q "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SCANNER_VERSION}-linux.zip"
            sudo unzip -q "sonar-scanner-cli-${SCANNER_VERSION}-linux.zip" -d /opt
            sudo mv "/opt/sonar-scanner-${SCANNER_VERSION}-linux" "$SCANNER_DIR"
            rm "sonar-scanner-cli-${SCANNER_VERSION}-linux.zip"
        fi
        
        # 添加到 PATH
        if ! grep -q "sonar-scanner" ~/.bashrc 2>/dev/null; then
            echo 'export PATH="$PATH:/opt/sonar-scanner/bin"' >> ~/.bashrc
        fi
        
        export PATH="$PATH:/opt/sonar-scanner/bin"
        echo -e "${GREEN}✓ sonar-scanner 安装完成${NC}"
    fi
    
    echo ""
}

# 创建 sonar-project.properties
create_config() {
    echo "[4/5] 创建 sonar-project.properties..."
    
    cat > "$PROJECT_DIR/sonar-project.properties" << 'EOF'
# SonarQube 项目配置
# 项目基本信息
sonar.projectKey=openclaw-go
sonar.projectName=OpenClaw Go
sonar.projectVersion=1.0

# 源代码路径
sonar.sources=.
sonar.sources.inclusions=**/*.go
sonar.exclusions=**/*_test.go,**/vendor/**,**/dist/**

# 测试路径
sonar.tests=.
sonar.test.inclusions=**/*_test.go

# Go 测试覆盖率
sonar.go.coverage.reportPaths=coverage.out

# 源码编码
sonar.sourceEncoding=UTF-8

# 分析范围
sonar.coverage.exclusions=**/*_test.go,**/cmd/**,**/test/**

# 忽略重复代码检测的文件
sonar.cpd.exclusions=**/*_test.go

# 代码复杂度阈值
sonar.metric.threshold=80
EOF

    echo -e "${GREEN}✓ sonar-project.properties 已创建${NC}"
    echo ""
}

# 创建扫描脚本
create_scan_script() {
    echo "[5/5] 创建扫描脚本..."
    
    cat > "$SCRIPT_DIR/scan.sh" << 'SCRIPT'
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
        -Dsonar.token=${SONAR_TOKEN:-} \
        -X
    
    echo ""
    echo "========================================"
    echo "扫描完成！"
    echo "========================================"
    echo ""
    echo "查看报告: http://localhost:9000/dashboard?id=openclaw-go"
    echo ""
    echo "默认账号: admin / admin"
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
SCRIPT

    chmod +x "$SCRIPT_DIR/scan.sh"
    echo -e "${GREEN}✓ scan.sh 已创建${NC}"
    echo ""
}

# 创建快速质量检查脚本
create_quality_check() {
    cat > "$SCRIPT_DIR/quality_check.sh" << 'SCRIPT'
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
SCRIPT

    chmod +x "$SCRIPT_DIR/quality_check.sh"
    echo -e "${GREEN}✓ quality_check.sh 已创建${NC}"
}

# 主流程
main() {
    check_docker
    setup_sonarqube
    install_scanner
    create_config
    create_scan_script
    create_quality_check
    
    echo "========================================"
    echo "安装完成！"
    echo "========================================"
    echo ""
    echo "可用命令:"
    echo ""
    echo "  ./quality_check.sh  - 快速代码质量检查 (无需 SonarQube)"
    echo "  ./scan.sh           - 完整 SonarQube 扫描"
    echo ""
    echo "SonarQube 界面: http://localhost:9000"
    echo "默认账号: admin / admin"
    echo ""
}

main "$@"
