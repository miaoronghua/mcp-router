<h1 align="center">MCP Router</h1>
<h3 align="center">统一的 MCP 服务器管理应用</h3>

<div align="center">

[![GitHub stars](https://img.shields.io/github/stars/mcp-router/mcp-router?style=flat&logo=github&label=Star)](https://github.com/mcp-router/mcp-router)
[![Discord](https://img.shields.io/badge/Discord-加入我们-7289DA?style=flat&logo=discord)](https://discord.com/invite/dwG9jPrhxB)
[![X](https://img.shields.io/badge/X(Twitter)-@mcp__router-1DA1F2?style=flat&logo=x)](https://x.com/mcp_router)

[[English](https://github.com/mcp-router/mcp-router/blob/main/README.md) | [日本語](https://github.com/mcp-router/mcp-router/blob/main/README_ja.md) | 中文]

</div>

## 🎯 概览

**MCP Router** 是一款用于简化 Model Context Protocol (MCP) 服务器管理的桌面应用。

### ✨ 核心特性

- 🌐 **通用连接** - 支持接入任意 MCP 服务器
  - 既可连接远程服务器，也支持本地服务器
  - 兼容 DXT、JSON、Manual 等多种协议
- 🖥️ **跨平台** - 提供 Windows 与 macOS 版本
- 🔒 **隐私保障** - 所有数据均在本地设备存储
- ⬆️ **数据迁移** - 轻松导出与导入 MCP 配置

## 🔒 隐私与安全

### 数据完全本地
- ✅ **数据始终保存在本地** —— 请求日志、配置与服务器数据均存放于本地设备
- ✅ **凭据安全** —— API 密钥与认证信息不会外传
- ✅ **完全掌控** —— 您完全掌控 MCP 服务器连接与数据

### 透明可信
- 🔍 **可审计** —— 桌面应用源代码公开托管在 GitHub
- 🛡️ **可验证隐私** —— 您可以直接查阅代码，验证数据确实仅在本地保存
- 🤝 **社区驱动** —— 欢迎在 [社区](https://discord.com/invite/dwG9jPrhxB) 中贡献安全改进与审计

## 📥 安装

可在 [GitHub 发布页](https://github.com/mcp-router/mcp-router/releases) 获取最新版本。

## 🚀 功能亮点

### 📊 集中式服务器管理
在单一控制面板中轻松切换 MCP 服务器的启用状态

<img src="https://raw.githubusercontent.com/mcp-router/mcp-router/main/public/images/readme/toggle.png" alt="服务器管理" width="600">

### 🌐 通用连接能力
支持添加与连接任意 MCP 服务器，无论是本地还是远程环境

<img src="https://raw.githubusercontent.com/mcp-router/mcp-router/main/public/images/readme/add-mcp-manual.png" alt="通用连接" width="600">

### 🔗 一键集成
与 Claude、Cline、Windsurf、Cursor 等常见 AI 工具或自定义客户端无缝接入

<img src="https://raw.githubusercontent.com/mcp-router/mcp-router/main/public/images/readme/token.png" alt="一键集成" width="600">

### 📈 全面的日志与分析
监控并展示详细的请求日志与统计信息

<img src="https://raw.githubusercontent.com/mcp-router/mcp-router/main/public/images/readme/stats.png" alt="日志与统计" width="600">

## 🏗️ 构建与发布（macOS Intel x64）

在本仓库中，已为 macOS Intel x64 准备好构建与发布脚本：

- 本地打包（生成 DMG/ZIP）
  - 安装依赖：`pnpm install`
  - 运行：`pnpm make:mac:x64`
- 直接发布到 GitHub Release（需提供 `GITHUB_TOKEN`）
  - 运行：`pnpm publish:mac:x64`

GitHub Actions 工作流：
- 已新增 `.github/workflows/release-macos-x64.yml`
- 触发方式：
  - 推送以 `v` 开头的标签（例如 `v0.5.5`），或
  - 在 GitHub Actions 页面手动触发 `workflow_dispatch`
- 工作流会在 `macos-13`（Intel）运行器上构建 x64 产物，并通过 electron-forge 的 GitHub 发布器上传为 Draft/Pre-release。

如需代码签名/公证，可在 CI 环境提供以下变量（可选）：
- `PUBLIC_IDENTIFIER`（Apple Developer 签名身份）
- `APPLE_API_KEY`、`APPLE_API_KEY_ID`、`APPLE_API_ISSUER`（Apple Notary 公证）

## 🐧 Ubuntu 一键构建

- 脚本位置：`scripts/ubuntu-setup.sh`
- 文档说明：参见 [docs/ubuntu-setup.md](./docs/ubuntu-setup.md)

一键命令（无需预先克隆仓库）：
```bash
curl -fsSL https://raw.githubusercontent.com/mcp-router/mcp-router/main/scripts/ubuntu-setup.sh | bash
```

可通过 `MCP_ROUTER_DIR` / `MCP_ROUTER_BRANCH` 自定义目录与分支。

## 🤝 社区

欢迎加入社区，获取帮助、分享想法并获取最新动态：

- 💬 [Discord 社区](https://discord.com/invite/dwG9jPrhxB)
- 🐦 [在 X (Twitter) 关注我们](https://x.com/mcp_router)
- ⭐ [在 GitHub 上为我们加星](https://github.com/mcp-router/mcp-router)

## 📝 许可证

本项目采用 Sustainable Use License 授权，详情请参阅 [LICENSE.md](LICENSE.md)。
