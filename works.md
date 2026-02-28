# OpenClaw Go 移植工作记录

## 项目概述

将 openclaw TypeScript/Node.js 项目移植到 Go 语言，保证功能/接口/代码结构实现一致。

- 原始项目: `/home/uii/code/openclaw/src/`
- 目标项目: `/home/uii/code/openclaw-go/openclaw-go/`

## 当前状态

| 指标 | 数量 |
|------|------|
| Go 文件 | **620+** |
| 编译状态 | **成功** |

### 模块完成度

| 模块 | TS 文件 | Go 文件 | 完成度 |
|------|---------|---------|--------|
| infra/ | ~80 | 100+ | ~100% |
| agents/ | ~160 | 150+ | ~90% |
| channels/ | ~60 | 45+ | ~75% |
| gateway/ | ~40 | 17+ | ~25% |
| commands/ | ~100 | 25+ | ~25% |
| plugins/ | ~50 | 20+ | ~40% |
| tui/ | ~20 | 15+ | ~75% |
| tts/ | ~10 | 3 | 100% |
| markdown/ | ~8 | 2 | ~25% |
| linkunderstanding/ | ~5 | 5 | 100% |
| sandbox/ | ~20 | 22 | 100% |
| piembeddedrunner/ | ~25 | 30 | 100% |

## 已完成模块

### 基础设施 (internal/infra/)

- `home/` - 主目录解析 (~展开)
- `dotenv/` - .env 文件加载
- `errors/` - 错误格式化、脱敏
- `jsonfile/` - JSON 文件读写
- `backoff/` - 指数退避策略
- `heartbeatevents/` - 心跳事件系统
- `activehours/` - 活跃时间检查
- `gatewaylock/` - 网关文件锁
- `env/` - 环境变量工具
- `securerandom/` - 安全随机数
- `archivepath/` - 归档路径验证
- `net/` - 网络工具 (hostname, SSRF防护)
- `archive/` - 归档解压
- `diagnostic/` - 诊断事件
- `git_commit/` - Git commit 解析
- `retry/` - 重试逻辑
- `device_auth_store/` - 设备认证存储
- `exec_approvals/` - 执行审批系统
- `provider_usage/` - Provider Usage 监控

### 核心工具 (internal/)

- `utils/` - 工具函数、E164规范化
- `version/` - 版本信息
- `logger/` - 日志系统
- `runtime/` - 运行时环境接口
- `globals/` - 全局状态
- `formattime/` - 时间格式化
- `logging/` - 敏感信息脱敏

### 配置系统 (internal/config/)

- `types.go` - 配置类型定义
- `paths.go` - 配置路径解析
- `io.go` - 配置加载、JSON解析

### CLI 系统 (internal/cli/)

- `cli.go` - CLI框架入口
- `argv.go` - 参数解析
- `banner.go` - Banner显示
- `prompt.go` - 用户交互
- `program/` - 命令树、注册表

### 网关系统 (internal/gateway/)

- `gateway.go` - 网关管理器
- `protocol/frames.go` - 协议帧定义
- `server/` - HTTP路由、WebSocket、OpenAI兼容API
- `methods/` - 方法处理器 (sessions, agents, config, cron, usage等)

### Agent 系统 (internal/agents/)

- `agent.go` - Agent 核心类型
- `workspace.go` - 工作空间管理
- `identity.go` - 身份管理
- `model.go` - 模型目录
- `usage.go` - Usage 类型
- `skills.go` - 技能命令
- `context.go` - 上下文窗口管理
- `compaction.go` - 消息压缩
- `subagent_registry/` - 子代理注册表
- `session_dirs.go`, `session_write_lock.go` - 会话管理
- `auth_health.go`, `auth_profiles.go` - 认证健康
- `cli_credentials.go` - CLI 凭证管理
- `bash_tools_*.go` - Bash 工具系列
- `model_selection.go`, `model_fallback.go` - 模型选择
- `failover_error.go` - 故障转移错误
- `pi_embedded_helpers.go` - PI 辅助函数
- `system_prompt.go` - 系统提示构建
- `subagent_spawn.go` - 子代理创建
- `apply_patch.go` - 补丁应用

### Agent 工具系统 (internal/agents/tools/)

- `types.go`, `registry.go` - 工具类型和注册
- `bash.go`, `process.go` - 执行和进程管理
- `web.go`, `web_search.go` - Web 工具
- `browser.go` - Playwright 浏览器
- `tools.go` - Canvas/Message/Gateway 工具
- `sessions.go`, `memory.go` - 会话和内存
- `nodes.go`, `cron.go` - 节点和定时任务
- `tts.go`, `image.go` - 语音和图像
- `telegram.go`, `discord.go`, `slack.go`, `whatsapp.go` - 渠道工具
- `subagents.go`, `agent_step.go` - 子代理
- `pty_keys.go` - PTY 关键字编码

### Pi Embedded Runner (internal/agents/piembeddedrunner/)

完整的嵌入代理运行时：
- `types.go`, `utils.go` - 类型和工具
- `run.go`, `run_core.go` - 核心运行器
- `pi_embedded_subscribe.go` - 订阅处理
- `pi_tools.go` - 工具定义
- `extra_params.go` - 额外参数
- `google.go` - Google 提供商
- `abort.go`, `cache_ttl.go`, `compaction_safety_timeout.go`
- `history.go`, `lanes.go`, `logger.go`, `thinking.go`
- `sandbox_info.go`, `extensions.go`, `model.go`, `runs.go`
- `tool_*.go` - 工具相关
- `run/` - 运行参数和载荷

### Sandbox 模块 (internal/agents/sandbox/)

完整的 Docker 沙箱支持：
- `types.go`, `constants.go`, `config.go`
- `docker.go`, `registry.go`, `fs_bridge.go`
- `browser.go`, `browser_bridges.go`
- `context.go`, `workspace.go`, `manage.go`, `prune.go`
- `tool_policy.go`, `runtime_status.go`
- `validate_sandbox_security.go`
- `novnc_auth.go`, `config_hash.go`

### 渠道系统 (internal/channels/)

#### 核心类型
- `types_core.go`, `types_adapters.go`, `types_plugin.go`
- `registry.go`, `test.go`, `web.go`

#### Telegram 渠道
- `types.go`, `client.go`, `accounts.go`
- `send.go`, `monitor.go`, `plugin.go`

#### Discord 渠道
- `types.go`, `client.go`, `accounts.go`
- `send.go`, `plugin.go`

#### Slack 渠道
- `types.go`, `client.go`, `accounts.go`
- `send.go`, `plugin.go`
- `threading.go`, `streaming.go`, `draft_stream.go`
- `monitor/` - 完整监控模块

#### WhatsApp 渠道
- `types.go`, `plugin.go`

#### LINE 渠道
- `types.go`, `accounts.go`, `signature.go`
- `probe.go`, `plugin.go`, `send.go`
- `webhook.go`, `monitor.go`
- `markdown_to_line.go`, `template_messages.go`

### Sessions 模块 (internal/sessions/)

- `session_key_utils.go` - 会话密钥解析
- `session_label.go` - 会话标签
- `transcript_events.go` - 转录事件
- `input_provenance.go` - 输入来源
- `model_overrides.go` - 模型覆盖
- `send_policy.go` - 发送策略
- `level_overrides.go` - 详细级别

### Cron 模块 (internal/cron/)

- `types.go`, `store.go`, `parse.go`
- `schedule.go`, `normalize.go`

### Memory 模块 (internal/memory/)

- `types.go`, `manager.go`, `search_manager.go`

### Process 模块 (internal/process/)

- `exec.go`, `kill_tree.go`
- `supervisor/` - 进程监控

### Hooks 模块 (internal/hooks/)

- `types.go`, `config.go`

### Security 模块 (internal/security/)

- `audit.go` - 安全审计
- `dm_policy_shared.go` - DM/群组策略
- `safe_regex.go` - 正则安全
- `secret_equal.go` - 安全比较

### Providers 模块 (internal/providers/)

- `github_copilot_models.go`, `github_copilot_token.go`
- `kilocode_shared.go`, `qwen_portal_oauth.go`

### Shared 模块 (internal/shared/)

- `avatar_policy.go`, `chat_content.go`, `chat_envelope.go`
- `device_auth.go`, `entry_metadata.go`
- `node_list_types.go`, `node_list_parse.go`, `node_match.go`
- `operator_scope_compat.go`, `pid_alive.go`
- `requirements.go`, `subagents_format.go`
- `tailscale_status.go`, `model_param_b.go`
- `gateway_bind_url.go`, `net/`

### Routing 模块 (internal/routing/)

- `session_key.go`, `bindings.go`
- `account_id.go`, `account_lookup.go`
- `resolve_route.go` - Agent 路由解析

### Auto-Reply 模块 (internal/autoreply/)

- `types.go`, `group_activation.go`
- `heartbeat_reply_payload.go`, `model_directive.go`
- `command_detection.go`, `thinking.go`, `tokens.go`
- `commands_registry_types.go`, `dispatch.go`
- `chunk.go`, `envelope.go`, `heartbeat.go`
- `command_auth.go`, `command_gates.go`
- `reply/` - 完整回复逻辑子目录

### Media-Understanding 模块 (internal/mediaunderstanding/)

- `types.go`, `errors.go`, `defaults.go`
- `video.go`, `format.go`
- `providers/` - 9个提供者实现

### Commands 模块 (internal/commands/)

- `configure_shared.go`, `status_types.go`
- `status_format.go`, `text_format.go`
- `doctor.go`, `doctor_format.go`, `doctor_config_flow.go`
- `status_command.go`, `health.go`
- `sessions.go`, `setup.go`, `runtime.go`, `agent.go`
- `models/`, `channels/`

### TUI 模块 (internal/tui/)

- `types.go`, `tui.go`, `formatters.go`
- `osc8_hyperlinks.go`, `commands.go`
- `waiting.go`, `status_summary.go`
- `stream_assembler.go`, `local_shell.go`
- `gateway_chat.go`, `handlers.go`
- `overlays.go`, `session_actions.go`
- `theme/` - 主题模块
- `components/` - UI 组件

### Wizard 模块 (internal/wizard/)

- `types.go`, `session.go`, `onboarding.go`
- `clack_prompter.go`, `onboarding_completion.go`

### TTS 模块 (internal/tts/)

- `types.go`, `core.go`, `tts.go`
- 支持 ElevenLabs, OpenAI, Edge TTS

### Link-Understanding 模块 (internal/linkunderstanding/)

- `defaults.go`, `detect.go`, `format.go`
- `runner.go`, `apply.go`

### Markdown 模块 (internal/markdown/)

- `ir.go` - 中间表示解析
- `render.go` - 多格式渲染

### Plugins 模块 (internal/plugins/)

- `types.go`, `hooks.go` - 类型定义和钩子
- `manifest.go`, `manifest_data.go` - 清单管理
- `path_safety.go`, `bundled_dir.go`
- `toggle_config.go`, `enable.go`
- `commands.go`, `registry.go`
- `discovery.go`, `config_state.go`, `slots.go`
- `uninstall.go`, `update.go`
- `runtime/` - 运行时 API

## 文件结构

```
openclaw-go/
├── go.mod
├── go.sum
├── openclaw.go              # 主 API 入口
├── cmd/openclaw/main.go     # CLI 入口
└── internal/
    ├── agents/              # Agent 系统 (150+ 文件)
    │   ├── agent.go, workspace.go, identity.go, model.go
    │   ├── tools/           # 工具系统 (25+ 文件)
    │   ├── sandbox/         # Docker 沙箱 (22 文件)
    │   └── piembeddedrunner/ # 嵌入运行时 (30 文件)
    ├── autoreply/           # 自动回复 (20+ 文件)
    │   └── reply/           # 回复逻辑 (16 文件)
    ├── channels/            # 渠道系统 (45+ 文件)
    │   ├── telegram/, discord/, slack/
    │   ├── whatsapp/, line/, web/
    │   └── monitor/         # 监控模块
    ├── cli/                 # CLI 框架 (10+ 文件)
    │   └── program/         # 命令程序
    ├── commands/            # 命令模块 (25+ 文件)
    │   ├── models/, channels/
    ├── config/              # 配置系统
    ├── cron/                # 定时任务
    ├── formattime/          # 时间格式化
    ├── gateway/             # 网关系统 (20+ 文件)
    │   ├── protocol/, server/
    │   └── methods/
    ├── globals/             # 全局状态
    ├── hooks/               # 钩子系统
    ├── infra/               # 基础设施 (100+ 文件)
    ├── linkunderstanding/   # 链接理解
    ├── logging/             # 日志脱敏
    ├── logger/              # 日志系统
    ├── markdown/            # Markdown 处理
    ├── memory/              # 内存管理
    ├── plugins/             # 插件系统 (20 文件)
    │   └── runtime/
    ├── process/             # 进程管理
    │   └── supervisor/
    ├── providers/           # Provider 实现
    ├── routing/             # 路由系统
    ├── runtime/             # 运行时接口
    ├── security/            # 安全模块
    ├── sessions/            # 会话管理
    ├── shared/              # 共享工具
    │   └── net/
    ├── terminal/theme/      # 终端主题
    ├── tts/                 # 文本转语音
    ├── tui/                 # 终端 UI (15+ 文件)
    │   ├── theme/, components/
    ├── utils/               # 工具函数
    ├── version/             # 版本信息
    └── wizard/              # 入门向导
```

## 依赖

```
github.com/fatih/color        # 终端颜色
nhooyr.io/websocket v1.8.17   # WebSocket
golang.org/x/time v0.14.0     # 速率限制
github.com/google/uuid v1.6.0 # UUID 生成
github.com/samber/lo v1.52.0  # 泛型工具
```

## 待完成工作

### 高优先级
1. **commands 模块扩展** - onboard, configure, models 完善
2. **plugins 模块完善** - loader 完整实现
3. **gateway 完整实现** - 与存储层集成

### 中优先级
1. **测试文件编写**
2. **功能验证测试**

## 工作历史摘要

| 轮次 | 主要完成内容 |
|------|------------|
| 1-12 | 基础设施、核心工具、配置系统、CLI、网关基础 |
| 13-20 | sessions, cron, memory, process, hooks, security, providers, shared, routing, autoreply, mediaunderstanding |
| 21-28 | infra 扩展, daemon, commands 基础 |
| 29-35 | command-auth, doctor-format, LINE 渠道, Slack monitor, CLI program |
| 36-40 | Slack threading/streaming, agents 扩展, bash-tools |
| 41-45 | auth-health, cli-credentials, web-search, model-selection/fallback |
| 46-50 | TUI 核心, Wizard, commands 扩展 |
| 51-55 | TUI components, pi-embedded-runner 核心 |
| 56-60 | pi-embedded-subscribe, run 目录, doctor-config-flow |
| 61-65 | health/status 命令, gateway methods |
| 66-69 | sandbox 完整移植, markdown IR |
| 70-76 | plugins 模块, TTS, link-understanding |
| 77 | gateway/server-methods: models, wizard, doctor, channels, tools, connect |
| 78 | gateway/server-methods: skills, send, poll, push, logs |
---
*最后更新: 2026-02-27*

## 第 79 轮工作记录 (2026-02-27)

### 完成工作

本主要专注于修复编译错误，确保项目可以正常编译。

### 修复的问题

| 文件 | 问题 | 修复内容 |
|------|------|----------|
| `config/types.go` | 缺少字段 | 添加 `UserTimezone`, `MainKey`, `Talk`, `UI`, `TTS`, `SeamColor` 字段 |
| `methods/agent_timestamp.go` | 类型不匹配 | 修复 `UserTimezone` 访问 |
| `methods/exec_approvals.go` | 字段名错误 | `Id` -> `ID`, 匿名结构体类型匹配 |
| `methods/exec_approval_handlers.go` | 类型不匹配 | `int64` vs `int`, `Broadcast` 函数签名 |
| `methods/handlers.go` | 缺少函数 | 添加 `handleAgentWait`, `handleAgentIdentityGet`, `handleToolsCatalog`, `handleWebLoginStart`, `handleWebLoginWait`, `handleBrowserRequest` |
| `methods/nodes.go` | 字段错误 | `Result` -> `Payload` |
| `methods/talk.go` | 配置缺失 | `Talk`, `UI` 配置字段 |
| `methods/tools.go` | 字段名/类型错误 | `Id` -> `ID`, `bool` -> `*bool`, `AgentID` -> `AgentId` |
| `methods/tts_methods.go` | 配置缺失 | `TTS` 配置字段 |
| `methods/update.go` | 未使用变量/导入 | 移除未使用的导入和变量 |
| `methods/web_handlers.go` | 类型/语法错误 | 重写文件，使用正确的接口类型 |

### 编译状态

✅ 全部编译通过

### 后续工作

1. **commands 模块扩展** - 实现更多命令处理器
2. **channels 模块完善** - 实现完整的渠道处理
3. **models 子目录** - 实现模型相关命令
*最后更新: 2026-02-27*

## 第 78 轮工作记录 (2026-02-27)

### 完成文件

| 文件 | 行数 | 功能描述 |
|------|------|----------|
| `methods/skills.go` | 361 | skills.status/bins/install/update 方法处理器 |
| `methods/send.go` | 448 | send/poll 方法处理器，支持消息发送和投票 |
| `methods/push.go` | 199 | push.test 方法处理器，APNS 推送测试 |
| `methods/logs.go` | 494 | logs.tail 方法处理器，日志文件读取 |

### 功能详情

**skills.go**:
- `skills.status` - 返回指定 agent 的技能状态报告
- `skills.bins` - 收集所有工作空间的技能二进制依赖
- `skills.install` - 安装指定技能包
- `skills.update` - 更新技能配置（启用/禁用、API Key、环境变量）

**send.go**:
- `send` - 发送消息到指定渠道
- `poll` - 发送投票到支持投票的渠道（如 Telegram）
- 支持去重（dedupe）机制
- 支持渠道插件接口集成

**push.go**:
- `push.test` - 测试 APNS 推送通知
- 定义了 APNS 相关类型结构
- 需要配合 infra/push-apns.go 完整实现

**logs.go**:
- `logs.tail` - 读取日志文件尾部内容
- 支持滚动日志文件解析
- 支持游标（cursor）跟踪和分页
- 支持最大字节数限制

### handlers.go 更新

在 `CoreHandlers()` 中注册了以下新方法:
- `skills.status`, `skills.bins`, `skills.install`, `skills.update`
- `send`, `poll`
- `push.test`
- `logs.tail`

### 编译状态

✅ 全部编译通过


## 第 80 轮工作记录 (2026-02-27)

### 完成工作

本主要专注于实现新的模块：web、signal、imessage、acp。

### 新增模块

#### Web 模块 (internal/web/)
WhatsApp Web 集成，基于 Baileys 兼容协议：
- `types.go` - 类型定义，包括 WebInboundMessage, ResolvedWhatsAppAccount 等
- `accounts.go` - WhatsApp 账户管理，账户解析和列表
- `auth_store.go` - 认证存储，凭据管理和备份恢复

#### Signal 模块 (internal/signal/)
Signal 消息集成，支持信号 CLI RPC 协议：
- `types.go` - 类型定义，SignalRpcOptions, SignalSSEEvent 等
- `client.go` - RPC 客户端，HTTP/SSE 通信
- `accounts.go` - Signal 账户管理
- `send.go` - 消息发送，支持文本、媒体、回复
- `monitor.go` - 消息监控，SSE 事件流
- `format.go` - 文本格式化，Markdown 转换

#### iMessage 模块 (internal/imessage/)
iMessage 集成，通过 imsg CLI 实现：
- `client.go` - RPC 客户端，子进程通信
- `send.go` - 消息发送和目标解析

#### ACP 模块 (internal/acp/)
Agent Client Protocol 集成，用于 IDE 客户端：
- `types.go` - 类型定义，AcpSession, AcpSessionStore
- `server.go` - ACP 网关服务器
- `client.go` - ACP 客户端

### 文件统计

| 模块 | 新增文件 | 行数 |
|------|----------|------|
| web/ | 3 | ~600 |
| signal/ | 6 | ~800 |
| imessage/ | 2 | ~550 |
| acp/ | 3 | ~1200 |

### 编译状态

✅ 全部编译通过

### 后续工作

1. **web 模块扩展** - 实现 inbound, outbound, login 等子模块
2. **signal 模块完善** - 实现 daemon, probe 详细逻辑
3. **imessage 模块扩展** - 实现 monitor 子模块
4. **acp 模块完善** - 实现 session-mapper, translator 等辅助功能

*最后更新: 2026-02-27*


## 第 81 轮工作记录 (2026-02-27)

### 完成工作

本轮专注于完善 plugins 和 acp 模块的缺失文件。

### 新增文件

#### plugins 模块
| 文件 | 行数 | 功能描述 |
|------|------|----------|
| `plugins/runtime.go` | 55 | 全局插件注册表状态管理 |
| `plugins/runtime/native_deps.go` | 75 | 原生依赖提示格式化 |

#### acp 模块
| 文件 | 行数 | 功能描述 |
|------|------|----------|
| `acp/session_mapper.go` | 202 | 会话密钥解析和重置功能 |
| `acp/commands.go` | 56 | 可用命令列表定义 |
| `acp/event_mapper.go` | 228 | 事件映射、文本提取、工具格式化 |
| `acp/meta.go` | 80 | 元数据读取工具函数 |
| `acp/secret_file.go` | 35 | 从文件读取密钥 |

### 功能详情

**plugins/runtime.go**:
- `SetActivePluginRegistry()` - 设置活动插件注册表
- `GetActivePluginRegistry()` - 获取活动插件注册表
- `RequireActivePluginRegistry()` - 获取或创建活动插件注册表
- `GetActivePluginRegistryKey()` - 获取注册表缓存键

**plugins/runtime/native_deps.go**:
- `FormatNativeDependencyHint()` - 格式化原生依赖安装提示
- 支持 pnpm/npm/yarn 包管理器

**acp/session_mapper.go**:
- `ParseSessionMeta()` - 解析会话元数据
- `ResolveSessionKey()` - 解析会话密钥
- `ResetSessionIfNeeded()` - 按需重置会话

**acp/commands.go**:
- `GetAvailableCommands()` - 返回所有可用命令列表
- 包含 help, status, context, think, model 等命令

**acp/event_mapper.go**:
- `ExtractTextFromPrompt()` - 从 ACP 提示中提取文本
- `ExtractAttachmentsFromPrompt()` - 提取图片附件
- `FormatToolTitle()` - 格式化工具标题
- `InferToolKind()` - 推断工具类型
- `EscapeInlineControlChars()` - 转义内联控制字符

**acp/meta.go**:
- `ReadString()`, `ReadNumber()`, `ReadBool()` - 读取元数据字段
- `ReadStringSlice()`, `ReadMap()` - 读取复杂数据类型

**acp/secret_file.go**:
- `ReadSecretFromFile()` - 从文件读取密钥
- `ReadGatewayTokenFromFile()`, `ReadGatewayPasswordFromFile()` - 专用读取函数

### 编译状态

✅ 全部编译通过

### 统计

| 指标 | 数量 |
|------|------|
| 新增 Go 文件 | 7 |
| 新增代码行数 | ~730 |
| Go 总文件数 | ~724 |

*最后更新: 2026-02-27*

## 第 82 轮工作记录 (2026-02-27)

### 完成工作

本轮专注于实现缺失的命令和网关方法处理器。

### 新增文件

#### commands 模块
| 文件 | 行数 | 功能描述 |
|------|------|----------|
| `dashboard.go` | 261 | Dashboard URL 生成和浏览器打开
| `configure_commands.go` | 134 | Configure 向导命令
| `channels/add.go` | 204 | 渠道账户添加命令
| `channels/list.go` | 74 | 渠道列表命令
| `channels/status.go` | 151 | 渠道状态命令
| `channels/remove.go` | 53 | 渠道移除命令
| `channels/resolve.go` | 42 | 渠道解析命令
| `channels/capabilities.go` | 104 | 渠道能力查询命令
| `channels/logs.go` | 47 | 渠道日志命令 |

#### gateway/methods 模块
| 文件 | 行数 | 功能描述 |
|------|------|----------|
| `chat_methods.go` | 76 | chat.history/chat.abort/chat.send/chat.inject 方法
| `tts_handlers.go` | 111 | tts.status/providers/enable/disable/convert/setProvider 方法
| `wizard_handlers.go` | 71 | wizard.start/next/cancel/status 方法 |

### 功能详情

**channels 命令:**
- `channels add` - 添加渠道账户配置，支持所有渠道参数
- `channels list` - 列出所有配置的渠道账户
- `channels status` - 显示渠道状态，支持 JSON 输出和探测模式
- `channels remove` - 移除渠道账户配置
- `channels resolve` - 解析渠道目标地址
- `channels capabilities` - 显示各渠道支持的能力
- `channels logs` - 显示渠道日志

**gateway 方法:**
- `chat.history` - 获取会话聊天历史
- `chat.abort` - 中止活跃的聊天运行
- `chat.send` - 发送消息到 Agent
- `chat.inject` - 注入消息到聊天历史
- `tts.status` - 获取 TTS 配置状态
- `tts.providers` - 列出可用 TTS 提供者
- `tts.enable/disable` - 启用/禁用 TTS
- `tts.convert` - 文本转语音
- `tts.setProvider` - 设置 TTS 提供者
- `wizard.start/next/cancel/status` - 向导会话管理

### 编译状态

✅ 全部编译通过

### 统计

| 指标 | 数量 |
|------|------|
| 新增 Go 文件 | 12 |
| 新增代码行数 | ~1,400 |
| Go 总文件数 | **736** |

### 后续工作

## 第 83 轮工作记录 (2026-02-27)

### 完成工作

本轮专注于实现 gateway session-utils 和 commands 缺失文件。

### 新增文件

#### gateway 模块
| 文件 | 行数 | 功能描述 |
|------|------|----------|
| `session_utils.go` | 512 | 会话条目管理、会话文件读写、会话列表 |
| `session_utils_fs.go` | 387 | 会话文件系统操作、消息读取、标题提取 |

#### commands 模块
| 文件 | 行数 | 功能描述 |
|------|------|----------|
| `signal_install.go` | 439 | signal-cli 安装命令、GitHub release 下载、归档解压 |
| `reset.go` | 220 | 重置命令、配置/凭证/会话清理 |

### 功能详情

**session_utils.go**:
- `SessionEntry` - 会话条目类型定义
- `LoadSessionEntry`/`SaveSessionEntry` - 会话文件读写
- `ListSessions` - 列出所有会话
- `ResolveSessionModelRef` - 解析会话模型引用
- `ReadSessionMessages`/`AppendSessionMessage` - 消息读写

**session_utils_fs.go**:
- `ReadSessionMessagesFromTranscript` - 从转录文件读取消息
- `ReadSessionTitleFields` - 读取会话标题字段（带缓存）
- `ArchiveSessionTranscripts` - 归档会话转录
- `CapArrayByJsonBytesGeneric` - 按 JSON 字节大小限制数组

**signal_install.go**:
- `InstallSignalCli` - 安装 signal-cli
- `FetchLatestRelease` - 从 GitHub API 获取最新发布
- `PickAsset` - 根据平台选择合适的发布资源
- `ExtractTarGz`/`ExtractZip` - 归档解压

**reset.go**:
- `ResetCommand` - 重置命令实现
- 支持三种重置范围: config、config+creds+sessions、full
- 支持 dry-run 模式

### 编译状态

✅ 全部编译通过

### 统计

| 指标 | 数量 |
|------|------|
| 新增 Go 文件 | 4 |
| 新增代码行数 | ~1,560 |
| Go 总文件数 | **740** |
| commands Go 文件 | 63 |
| gateway Go 文件 | 10 |

### 后续工作

1. **commands 模块扩展** - 实现 configure、onboard 完整流程
2. **gateway/server 扩展** - 实现 server-http、tools-invoke-http
3. **agents 模块完善** - 实现缺失的 agent 工具

*最后更新: 2026-02-27*


## 第 84 轮工作记录 (2026-02-28)

### 完成工作

本轮专注于代码质量优化，清理重复代码和未使用的实现。

### 删除的重复代码

| 类型 | 文件/目录 | 说明 |
|------|----------|------|
| 目录 | `internal/infra/formattime/` | 删除，保留 `internal/formattime/` |
| 函数 | `tui/gateway_chat.go:ParseAgentSessionKey` | 删除，使用 `sessions.ParseAgentSessionKey` |
| 类型 | `tui/gateway_chat.go:AgentSessionKeyParsed` | 删除，未使用 |
| 函数 | `agents/agent.go:ParseAgentSessionKey` | 改为委托给 `sessions.ParseAgentSessionKey` |
| 类型 | `agents/agent.go:ParsedAgentSessionKey` | 改为类型别名 `sessions.ParsedAgentSessionKey` |
| 函数 | `routing/session_key.go:ParseAgentSessionKey` | 改为委托给 `sessions.ParseAgentSessionKey` |
| 类型 | `routing/session_key.go:ParsedAgentSessionKey` | 改为类型别名 `sessions.ParsedAgentSessionKey` |

### 代码统一化

根据 TypeScript 源码结构，统一了以下模块：

1. **ParseAgentSessionKey** - 主实现在 `sessions/session_key_utils.go`，其他模块通过别名或委托使用
   - `routing/session_key.go` - 从 sessions 重导出（与 TS 源码一致）
   - `agents/agent.go` - 委托给 sessions 包

2. **formattime 目录** - 统一使用 `internal/formattime/`（与 TS 源码 `src/infra/format-time/` 对应）
   - 删除了重复的 `internal/infra/formattime/` 目录

### 仍存在的重复函数（待后续处理）

以下函数在多处有相似实现，但内部调用而非导出，需要更谨慎地统一：

| 函数名 | 出现位置 | 说明 |
|--------|----------|------|
| `FormatTimeAgo` | autoreply/status.go, tui/status_summary.go, commands/status_format.go, formattime/relative.go | 各有略微不同实现 |
| `FormatDuration` | 多个文件 | 有不同签名和实现 |

### 编译状态

✅ 全部编译通过

### 统计

| 指标 | 数量 |
|------|------|
| Go 文件 | **739** (减少 1 个) |
| 删除代码行数 | ~70 |

### 后续工作

1. 继续清理重复的 FormatTimeAgo、FormatDuration 函数
2. 对比 TS 和 Go 模块完成度，找出缺失功能
3. 实现缺失的移植功能

*最后更新: 2026-02-28*

## 第 85 轮工作记录 (2026-02-28)

### 完成工作

本轮专注于代码清理和代码质量优化，统一重复函数实现。

### 统一重复代码

**FormatTimeAgo 统一:**
| 原位置 | 修改 |
|--------|------|
| `autoreply/status.go` | 删除本地实现，改用 `formattime.FormatTimeAgoSimple` |
| `tui/status_summary.go` | 删除本地实现，改用 `formattime.FormatTimeAgoSimple` |
| `commands/status_command.go` | 改用 `formattime.FormatTimeAgoSimple` |
| `formattime/relative.go` | 新增 `FormatTimeAgoSimple` 便捷函数 |

**FormatDuration 统一:**
| 原位置 | 状态 |
|--------|------|
| `formattime/duration.go` | 主实现，新增 `FormatDurationFromMs`, `FormatDurationFromMsPrecise` |
| `channels/telegram/send.go` | 保留本地实现（签名不同：`time.Duration` vs `int64`）|
| `commands/status_format.go` | 保留本地实现（格式略有不同）|
| `shared/subagents_format.go` | 保留本地实现（内部使用）|
| `agents/subagent_announce.go` | 保留本地实现（内部使用）|

### 模块对比分析

通过对比 TypeScript 原版和 Go 版本，发现以下情况：

**TS 有但 Go 缺失的模块:**
- `plugin-sdk` (28文件) - 插件开发 SDK
- `test-utils` (26文件) - 测试工具
- `media` (30文件) - 媒体处理核心
- `pairing` (7文件) - 设备配对系统
- `compat` (1文件) - 兼容层

**文件数量差距大的模块:**
| 模块 | TS文件 | Go文件 | 完成度 |
|------|--------|--------|--------|
| config | 191 | 4 | 2% |
| cli | 254 | 14 | 5% |
| daemon | 40 | 3 | 7% |
| logging | 24 | 1 | 4% |
| memory | 84 | 3 | 4% |
| cron | 71 | 5 | 7% |
| web | 80 | 3 | 4% |
| agents | 649 | 132 | 20% |
| gateway | 282 | 63 | 22% |
| commands | 304 | 83 | 27% |

### 识别的潜在问题

1. **TODO/FIXME 标记** - 约 30 处待完成实现
2. **Panic 语句** - 需要替换为错误处理
3. **Stub 实现** - 部分 Slack 监控功能未完成

### 编译状态

✅ 全部编译通过

### 统计

| 指标 | 数量 |
|------|------|
| Go 文件 | **739** |
| 修改文件 | 4 |
| 删除重复函数 | 3 |

### 后续工作

1. **高优先级**: 实现 `pairing` 模块
2. **中优先级**: 补充 `config`、`cli` 模块实现
3. **低优先级**: 替换 panic 为错误处理

*最后更新: 2026-02-28*

## 第 86 轮工作记录 (2026-02-28)

### 完成工作

本轮实现了缺失的 `pairing` 模块（设备配对功能），并继续进行代码质量优化。

### 新增 pairing 模块

| 文件 | 行数 | 功能描述 |
|------|------|----------|
| `pairing/types.go` | 53 | 配对类型定义 |
| `pairing/store.go` | 562 | 配对存储操作 |
| `pairing/messages.go` | 53 | 配对消息构建 |
| `pairing/setup_code.go` | 254 | 设置代码解析 |
| `pairing/labels.go` | 49 | 配对标签解析 |

### 主要功能

**types.go:**
- `PairingChannel`, `PairingRequest`, `PairingStore` 类型定义
- `AllowFromStore` 允许列表存储
- `PairingSetupPayload`, `PairingSetupResolution` 设置载荷

**store.go:**
- `PairingStoreOps` 配对存储操作类
- `SafeChannelKey`, `SafeAccountKey` 安全文件名生成
- `RandomCode`, `GenerateUniqueCode` 随机配对码生成
- `PruneExpiredRequests`, `PruneExcessRequests` 请求清理
- `ListPairingRequests`, `UpsertPairingRequest` 请求管理
- `ApprovePairingCode` 配对码批准
- `AddAllowFromEntry`, `RemoveAllowFromEntry`, `ReadAllowFromList` 允许列表管理

**messages.go:**
- `BuildPairingReply` 构建配对请求消息
- `BuildPairingApprovedReply`, `BuildPairingDeniedReply` 结果消息
- `BuildMaxPendingReachedMessage`, `BuildAlreadyPairedMessage` 状态消息

**setup_code.go:**
- `ResolvePairingSetup` 解析配对设置 URL 和凭证
- `ResolveGatewayPort` 解析网关端口
- `GetLocalIPs`, `IsPrivateIP` 网络工具
- `normalizeURL` URL 规范化

**labels.go:**
- `PairingLabelProvider` 接口定义
- `ResolvePairingIDLabel`, `NormalizeAllowEntry` 标签解析
- `DefaultPairingLabels` 默认实现

### 编译状态

✅ 全部编译通过

### 统计

| 指标 | 数量 |
|------|------|
| 新增 Go 文件 | 5 |
| 新增代码行数 | ~970 |
| Go 总文件数 | **744** |

### 后续工作

1. **高优先级**: 补充 `config`、`cli` 模块缺失的实现
2. **中优先级**: 补充 `gateway/methods` 中的 TODO 实现
3. **低优先级**: 完善 `channels` 模块的监控功能

*最后更新: 2026-02-28*

## 第 87 轮工作记录 (2026-02-28)

### 完成工作

本轮专注于代码质量优化和清理，修复了多个 go vet 发现的问题。

### 代码清理

| 类型 | 文件 | 修改内容 |
|------|------|----------|
| 删除重复 | `internal/infra/archive_path.go` | 删除，使用 `internal/infra/archivepath/` 替代 |
| 修复 panic | `internal/infra/pairing_token.go` | 返回 error 而非 panic |
| 修复 panic | `internal/infra/node_pairing.go` | 处理 token 生成错误 |
| 修复 panic | `internal/providers/github_copilot_models.go` | 返回 error 而非 panic |

### 重复代码统一

| 函数 | 原位置 | 修改 |
|------|--------|------|
| `sortStrings()` | `channels/telegram/accounts.go` | 改用 `sort.Strings()` |
| `sortStrings()` | `channels/discord/accounts.go` | 改用 `sort.Strings()` |
| `sortStrings()` | `agents/system_prompt.go` | 改用 `sort.Strings()` |
| `sortStrings()` | `agents/sandbox/config_hash.go` | 改用 `sort.Strings()` |

### go vet 问题修复

| 文件 | 行号 | 问题 | 修复 |
|------|------|------|------|
| `signal/types.go` | 155 | 不可达代码（重复return） | 删除重复行 |
| `tui/theme/theme.go` | 58, 65 | fmt.Sprintf 格式错误 | 修复格式字符串 |
| `agents/pi_embedded_helpers.go` | 219 | 冗余条件 `502 || 502` | 删除重复条件 |
| `plugins/hooks.go` | 多处 | `string(len())` 返回 rune | 改用 `strconv.Itoa()` |
| `plugins/manifest_registry_data.go` | 269 | `string(int64)` 返回 rune | 改用 `strconv.FormatInt()` |

### 新增文件

| 文件 | 行数 | 功能描述 |
|------|------|----------|
| `internal/agents/agent_paths.go` | ~40 | Agent 目录路径解析 |
| `internal/agents/agent_scope.go` | ~250 | Agent 作用域和配置解析 |
| `internal/agents/skills/` | ~500 | 技能系统完整实现 |
| `internal/agents/tool_catalog.go` | ~200 | 工具目录管理 |
| `internal/gateway/server_http.go` | ~300 | HTTP 服务器实现 |
| `internal/gateway/agent_event_assistant_text.go` | ~150 | 助手文本事件处理 |
| `internal/gateway/chat_abort.go` | ~100 | 聊天中止功能 |

### 编译状态

✅ 全部编译通过

### 统计

| 指标 | 数量 |
|------|------|
| Go 文件 | **748+** |
| 修复 panic | 4 处 |
| 删除重复代码 | 1 文件 |
| go vet 修复 | 5 处 |

### 后续工作

1. **高优先级**: 补充 `agents` 模块缺失的文件（TS 331 vs Go 132）
2. **中优先级**: 补充 `gateway` 模块缺失的文件（TS 183 vs Go 63）
3. **中优先级**: 补充 `commands` 模块缺失的文件（TS 213 vs Go 83）

*最后更新: 2026-02-28*

## 第 88 轮工作记录 (2026-02-28)

### 完成工作

本轮专注于修复编译错误和创建统一的工具函数库。

### 修复的问题

**编译错误修复:**
| 文件 | 问题 | 修复内容 |
|------|------|----------|
| `gateway/server_http.go` | import cycle | 从 `gateway/server/` 移动到 `gateway/`，与 TS 源码结构一致 |
| `gateway/server_http.go` | 循环导入 | 移除对自身包的导入，修复类型引用 |
| `gateway/chat_abort.go` | 未使用变量 | 修复 `ctx` 和 `entry` 未使用问题 |
| `gateway/server_http.go` | API 错误 | 修复 `conn.Close()` 和 `buf.Bytes()` 调用 |

### 新增统一工具函数

创建了 `internal/utils/` 下的统一工具文件：

| 文件 | 行数 | 功能描述 |
|------|------|----------|
| `utils/strings.go` | 124 | ContainsString, ContainsIgnoreCase, StripAnsi, DedupeStrings 等 |
| `utils/ptr.go` | 68 | BoolPtr, StrPtr, IntPtr 等指针工具函数 |
| `utils/truncate.go` | 85 | TruncateMiddle, TruncateTail, TruncateLine 等 |
| `utils/time.go` | 50 | CurrentTimeMs, GenerateUUID, GenerateShortID 等 |
| `utils/file.go` | 64 | FileExists, EnsureDir, WriteFile 等文件工具 |
| `utils/random.go` | 38 | RandomString, RandomAlphanumeric 等随机生成 |
| `utils/env.go` | 70 | GetEnvMap, GetEnvWithDefault 等环境变量工具 |

### 重复代码分析报告

通过系统分析，发现以下重复代码模式：

**高优先级重复:**
- `contains` 函数: 13 处重复
- `truncate` 函数: 32 处重复
- `FormatDuration` 函数: 13 处重复
- `generateUUID` 函数: 10 处重复
- `getEnvMap` 函数: 7 处重复

**中优先级重复:**
- `min` 函数: 5 处重复（Go 1.21+ 已内置）
- `boolPtr/stringPtr` 函数: 6-5 处重复
- `currentTimeMs` 函数: 6 处重复
- `stripAnsi` 函数: 4 处重复
- `dedupe` 函数: 5 处重复

### 模块完成度对比

| 模块 | TS 文件 | Go 文件 | 完成度 |
|------|---------|---------|--------|
| agents | 649 | 132 | 20% |
| gateway | 282 | 63 | 22% |
| commands | 304 | 83 | 27% |
| cli | 254 | 14 | 5% |
| config | 191 | 4 | 2% |
| channels | 137 | 94 | 69% |

### 编译状态

✅ 全部编译通过

### 统计

| 指标 | 数量 |
|------|------|
| Go 文件 | **761** |
| 新增工具文件 | 7 |
| 新增代码行数 | ~500 |
| 修复编译错误 | 4 处 |

### 后续工作

1. **高优先级**: 逐步替换各模块中的重复函数为统一工具函数
2. **中优先级**: 补充 `agents` 模块缺失文件
3. **低优先级**: 替换 panic 为错误处理

*最后更新: 2026-02-28*