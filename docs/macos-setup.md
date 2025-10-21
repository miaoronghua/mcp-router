# macOS（Intel x64）一键拉取、安装依赖与编译脚本

本文档介绍如何在 macOS（Intel x64）系统上一键拉取本项目（mcp-router），安装依赖并完成编译。

适用环境：
- macOS 12/13/14（Intel x64）
- 已安装 Xcode Command Line Tools（首次执行脚本会自动检测并提示安装）

脚本文件：`scripts/macos-x64-setup.sh`

## 一键使用（推荐）

无需预先克隆仓库，可直接执行以下命令：

```bash
echo "This script targets macOS Intel x64." && \
curl -fsSL https://raw.githubusercontent.com/miaoronghua/mcp-router/HEAD/scripts/macos-x64-setup.sh | bash
```

可选参数/环境变量：
- 目标目录：
  - 作为第 1 个位置参数：`bash macos-x64-setup.sh /path/to/mcp-router`
  - 或使用环境变量：`MCP_ROUTER_DIR=/path/to/mcp-router`
  - 默认：`$HOME/mcp-router`
- 分支：
  - 作为第 2 个位置参数：`bash macos-x64-setup.sh "$HOME/mcp-router" main`
  - 或使用环境变量：`MCP_ROUTER_BRANCH=main`
  - 默认：`main`

示例：
```bash
# 指定目录与分支
curl -fsSL https://raw.githubusercontent.com/miaoronghua/mcp-router/HEAD/scripts/macos-x64-setup.sh | \
  MCP_ROUTER_DIR="$HOME/mcpr" MCP_ROUTER_BRANCH=main bash
```

## 脚本做了什么

`scripts/macos-x64-setup.sh` 将按以下步骤自动执行：
1. 检查系统是否为 macOS 且架构为 x86_64（Intel）
2. 检查并提示安装 Xcode Command Line Tools
3. 检查并安装 Homebrew（如果缺失）
4. 通过 Homebrew 安装系统依赖（git、python、pkg-config、make、gcc 等）
5. 检查 Node.js 版本：若未安装或 < 20，则通过 Homebrew 安装 `node@20`（或回退到最新 `node`）
6. 启用 Corepack 并激活 `pnpm@8.15.6`
7. 克隆本项目（或在已有仓库中切换/更新对应分支）
8. 在仓库根目录执行 `pnpm install` 安装依赖
9. 执行 `pnpm build` 完成编译

执行完成后，脚本会输出下一步建议（启动开发、打包 macOS x64、发布等）。

## 手动步骤（可选）

如需手动执行，等价步骤如下：
```bash
# 0) Xcode Command Line Tools（如未安装会弹出 GUI 提示）
xcode-select -p || xcode-select --install

# 1) 安装 Homebrew（如已安装可跳过）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Intel 默认路径：/usr/local/bin/brew
eval "$([ -x /usr/local/bin/brew ] && /usr/local/bin/brew shellenv || /opt/homebrew/bin/brew shellenv)"

# 2) 系统依赖
brew update
brew install git python@3.11 pkg-config make gcc

# 3) Node.js 20（若本机未满足 >=20）
brew install node@20 || brew install node
brew link --overwrite --force node@20 || true

# 4) pnpm（通过 Corepack 激活指定版本）
corepack enable || true
corepack prepare pnpm@8.15.6 --activate

# 5) 克隆仓库
git clone -b main --depth 1 https://github.com/miaoronghua/mcp-router.git "$HOME/mcp-router"
cd "$HOME/mcp-router"

# 6) 安装依赖 & 构建
pnpm install
pnpm build
```

## 常见问题与排查

- 原生模块（electron-rebuild）构建失败
  - 确保已安装 Xcode Command Line Tools：
    ```bash
    xcode-select -p || xcode-select --install
    ```
- 国内网络较慢
  - 可尝试：
    ```bash
    pnpm config set registry https://registry.npmmirror.com
    export ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/
    ```

## 后续操作

- 启动开发：
  ```bash
  pnpm dev
  ```
- 打包 macOS x64 桌面应用（Electron Forge）：
  ```bash
  pnpm make:mac:x64
  ```
- 直接发布到 GitHub Release（需提供 `GITHUB_TOKEN`）：
  ```bash
  pnpm publish:mac:x64
  ```

## 参考
- Node.js >= 20
- pnpm 8.x（本项目通过 Corepack 固定为 `pnpm@8.15.6`）
- Turborepo（`pnpm build` 会触发 `turbo run build`）
