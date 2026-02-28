#!/bin/bash
# OpenClaw 人工测试脚本
# 用 TypeScript TUI 测试 Go Gateway 服务端

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS_DIR="$SCRIPT_DIR/../openclaw"
GO_DIR="$SCRIPT_DIR/openclaw-go"

GATEWAY_PID=""

# 清理端口上已有的 gateway 进程
cleanup_port() {
    # 先清理占用端口的进程
    local pid=$(lsof -t -i :19001 2>/dev/null)
    if [ ! -z "$pid" ]; then
        echo "  终止占用端口 19001 的进程 (PID: $pid)"
        kill -9 $pid 2>/dev/null || true
    fi
    
    # 清理所有 gateway 相关进程
    local gateway_pids=$(pgrep -f "gateway" 2>/dev/null)
    if [ ! -z "$gateway_pids" ]; then
        echo "  终止其他 gateway 进程: $gateway_pids"
        kill -9 $gateway_pids 2>/dev/null || true
    fi
    
    sleep 1
}
# 清理函数
cleanup() {
    echo ""
    echo "[清理]"
    if [ ! -z "$GATEWAY_PID" ]; then
        kill $GATEWAY_PID 2>/dev/null || true
        echo "  ✓ Gateway 已停止"
    fi
}
# 捕获退出信号
trap cleanup EXIT

# 检查依赖
check_dependencies() {
    echo "========================================"
    echo "OpenClaw Go Gateway + TS TUI 测试"
    echo "========================================"
    echo ""
    echo "[检查依赖]"
    
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js 未安装"
        exit 1
    fi
    echo "  ✓ Node.js: $(node --version)"
    
    if command -v pnpm &> /dev/null; then
        PKG_MANAGER="pnpm"
    elif command -v npm &> /dev/null; then
        PKG_MANAGER="npm"
    else
        echo "❌ pnpm 或 npm 未安装"
        exit 1
    fi
    echo "  ✓ $PKG_MANAGER"
    
    if ! command -v go &> /dev/null; then
        echo "❌ Go 未安装"
        exit 1
    fi
    echo "  ✓ Go: $(go version | awk '{print $3}')"
    
    echo ""
}

# 安装 TypeScript 依赖并构建
install_ts_deps() {
    echo "[检查 TypeScript 依赖]"
    
    if [ ! -d "$TS_DIR/node_modules" ]; then
        echo "  正在安装依赖..."
        cd "$TS_DIR"
        $PKG_MANAGER install
        echo "  ✓ 安装完成"
    else
        echo "  ✓ node_modules 已存在"
    fi
    
    # 检查是否需要构建
    if [ ! -f "$TS_DIR/dist/entry.mjs" ] && [ ! -f "$TS_DIR/dist/entry.js" ]; then
        echo "  正在构建 TypeScript (首次构建可能需要几分钟)..."
        cd "$TS_DIR"
        $PKG_MANAGER run build
        echo "  ✓ 构建完成"
    else
        echo "  ✓ dist/entry 已存在"
    fi
    
    echo ""
}
# 构建 Go Gateway
build_go() {
    echo "[构建 Go Gateway]"
    
    cd "$GO_DIR"
    go build -o gateway ./cmd/gateway
    echo "  ✓ gateway 编译完成"
    echo ""
}

# 启动 Go Gateway
start_go_gateway() {
    echo "[启动 Go Gateway]"
    echo "  端口: 19001"
    echo "  URL: ws://localhost:19001/ws"
    echo ""
    
    cd "$GO_DIR"
    
    # 先清理可能存在的旧进程
    cleanup_port
    
    # 清空日志文件
    > /tmp/openclaw-gateway.log
    
    # 后台启动 gateway
    echo "  执行: ./gateway > /tmp/openclaw-gateway.log 2>&1 &"
    ./gateway > /tmp/openclaw-gateway.log 2>&1 &
    GATEWAY_PID=$!
    echo "  启动中... (PID: $GATEWAY_PID)"
    
    # 等待启动
    sleep 2
    # 检查是否启动成功
    if kill -0 $GATEWAY_PID 2>/dev/null; then
        echo "  ✓ Gateway 已启动 (PID: $GATEWAY_PID)"
        echo "  日志: /tmp/openclaw-gateway.log"
        echo ""
    else
        echo "  ❌ Gateway 启动失败"
        cat /tmp/openclaw-gateway.log
        exit 1
    fi
}

# 启动 TypeScript TUI 连接到 Go Gateway
start_ts_tui() {
    echo "========================================"
    echo "测试说明"
    echo "========================================"
    echo ""
    echo "TypeScript TUI 将连接到 Go Gateway:"
    echo "  URL: ws://localhost:19001/ws"
    echo ""
    echo "预期行为:"
    echo "  ✓ 收到 hello-ok 握手响应"
    echo "  ✓ chat.send 返回 {sent: true}"
    echo "  ✗ 无 AI 流式响应 (待实现)"
    echo ""
    echo "按 Enter 启动 TUI..."
    read
    
    cd "$TS_DIR"
    node openclaw.mjs tui --url ws://localhost:19001/ws --token dev-token
}

# 主流程
main() {
    check_dependencies
    install_ts_deps
    build_go
    start_go_gateway
    start_ts_tui
}

main "$@"
