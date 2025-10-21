# Ubuntu 一键拉取、安装依赖与编译脚本

本文档介绍如何在 Ubuntu 系统上一键拉取本项目（mcp-router），安装依赖并完成编译。

适用环境：
- Ubuntu 20.04/22.04/24.04（或其它基于 APT 的 Debian 系）
- 具备 sudo 权限的用户

脚本文件：`scripts/ubuntu-setup.sh`

## 一键使用（推荐）

无需预先克隆仓库，可直接执行以下命令：

```bash
curl -fsSL https://raw.githubusercontent.com/mcp-router/mcp-router/main/scripts/ubuntu-setup.sh | bash
```

可选参数/环境变量：
- 目标目录：
  - 作为第 1 个位置参数：`bash ubuntu-setup.sh /path/to/mcp-router`
  - 或使用环境变量：`MCP_ROUTER_DIR=/path/to/mcp-router`
  - 默认：`$HOME/mcp-router`
- 分支：
  - 作为第 2 个位置参数：`bash ubuntu-setup.sh "$HOME/mcp-router" main`
  - 或使用环境变量：`MCP_ROUTER_BRANCH=main`
  - 默认：`main`

示例：
```bash
# 指定目录与分支
curl -fsSL https://raw.githubusercontent.com/mcp-router/mcp-router/main/scripts/ubuntu-setup.sh | \
  MCP_ROUTER_DIR="$HOME/mcpr" MCP_ROUTER_BRANCH=main bash
```

## 脚本做了什么

`scripts/ubuntu-setup.sh` 将按以下步骤自动执行：
1. 安装系统依赖：`git`、`curl`、`build-essential`、`python3`、`g++`、`pkg-config` 等
2. 检查 Node.js 版本：若未安装或 < 20，则通过 NodeSource 安装 Node.js 20.x
3. 启用 Corepack 并激活 `pnpm@8.15.6`
4. 克隆本项目（或在已有仓库中切换/更新对应分支）
5. 在仓库根目录执行 `pnpm install` 安装依赖
6. 执行 `pnpm build` 完成编译

执行完成后，脚本会输出下一步建议（启动开发、打包桌面应用等）。

## 手动步骤（可选）

如需手动执行，等价步骤如下：
```bash
# 1) 系统依赖
sudo apt-get update -y
sudo apt-get install -y git curl ca-certificates gnupg build-essential python3 make g++ pkg-config

# 2) Node.js 20（若本机未满足 >=20）
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# 3) pnpm（通过 Corepack 激活指定版本）
corepack enable || true
corepack prepare pnpm@8.15.6 --activate

# 4) 克隆仓库
git clone -b main --depth 1 https://github.com/mcp-router/mcp-router.git "$HOME/mcp-router"
cd "$HOME/mcp-router"

# 5) 安装依赖 & 构建
pnpm install
pnpm build
```

## 常见问题与排查

- 构建本机原生模块（electron-rebuild）失败
  - 确保已安装构建工具：
    ```bash
    sudo apt-get install -y build-essential python3 make g++ pkg-config
    ```
- 国内网络较慢
  - 可尝试：
    ```bash
    pnpm config set registry https://registry.npmmirror.com
    export ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/
    ```
- 没有 sudo 权限
  - 请在 root 环境下执行或联系系统管理员安装系统依赖。

## 后续操作

- 启动开发：
  ```bash
  pnpm dev
  ```
- 构建桌面应用（Electron Forge）：
  ```bash
  pnpm --filter @mcp_router/electron run make
  ```

## 参考
- Node.js >= 20
- pnpm 8.x（本项目通过 Corepack 固定为 `pnpm@8.15.6`）
- Turborepo（`pnpm build` 会触发 `turbo run build`）
