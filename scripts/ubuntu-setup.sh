#!/usr/bin/env bash
set -euo pipefail

# Ubuntu one-click setup for mcp-router
# - Installs system prerequisites (git, curl, build tools, python3)
# - Installs Node.js >= 20 via NodeSource if needed
# - Enables corepack and activates pnpm@8.15.6
# - Clones the repository (or updates if already present)
# - Installs dependencies and builds the project
#
# Usage:
#   bash ubuntu-setup.sh [destination_dir] [branch]
# Env:
#   MCP_ROUTER_DIR    Destination directory (default: "$HOME/mcp-router")
#   MCP_ROUTER_BRANCH Git branch to use (default: "main")
#
# Example (one-liner):
#   curl -fsSL https://raw.githubusercontent.com/miaoronghua/mcp-router/HEAD/scripts/ubuntu-setup.sh | bash

PROJECT_REPO_URL="https://github.com/miaoronghua/mcp-router.git"
DEFAULT_DIR="${HOME}/mcp-router"
DEFAULT_BRANCH="main"

DEST_DIR="${1:-${MCP_ROUTER_DIR:-${DEFAULT_DIR}}}"
BRANCH="${2:-${MCP_ROUTER_BRANCH:-${DEFAULT_BRANCH}}}"

# Determine sudo availability
if [ "${EUID}" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    echo "This script requires root privileges to install system packages. Please run as root or install sudo."
    exit 1
  fi
else
  SUDO=""
fi

log() { printf "\033[1;32m[INFO]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[ERROR]\033[0m %s\n" "$*"; }

require_apt() {
  if ! command -v apt-get >/dev/null 2>&1; then
    err "This script is intended for Ubuntu/Debian systems (apt-get not found)."
    exit 1
  fi
}

install_system_prereqs() {
  log "Updating package index and installing prerequisites..."
  ${SUDO} apt-get update -y
  ${SUDO} apt-get install -y \
    git curl ca-certificates gnupg \
    build-essential python3 make g++ pkg-config
}

ensure_node_20() {
  if command -v node >/dev/null 2>&1; then
    NODE_VER="$(node -v | sed 's/^v//')"
    NODE_MAJOR="${NODE_VER%%.*}"
    if [ "${NODE_MAJOR}" -ge 20 ]; then
      log "Detected Node.js v${NODE_VER} (>=20), skipping Node installation."
      return
    else
      warn "Detected Node.js v${NODE_VER} (<20). Will install Node.js 20.x via NodeSource."
    fi
  else
    log "Node.js not found. Will install Node.js 20.x via NodeSource."
  fi

  # Install Node.js 20.x using NodeSource
  log "Installing Node.js 20.x (NodeSource)..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | ${SUDO} -E bash -
  ${SUDO} apt-get install -y nodejs
  log "Installed Node.js $(node -v)"
}

ensure_pnpm() {
  # Use corepack to ensure the exact pnpm version required by the repo
  if ! command -v corepack >/dev/null 2>&1; then
    warn "corepack not found; installing via npm (fallback)."
    ${SUDO} npm install -g corepack || true
  fi
  if command -v corepack >/dev/null 2>&1; then
    log "Enabling corepack and activating pnpm@8.15.6..."
    corepack enable || true
    corepack prepare pnpm@8.15.6 --activate
  else
    warn "corepack still unavailable; installing pnpm globally via npm."
    ${SUDO} npm install -g pnpm@8.15.6
  fi
  log "Using pnpm $(pnpm -v)"
}

clone_or_update_repo() {
  if [ -d "${DEST_DIR}/.git" ]; then
    log "Repository already exists at ${DEST_DIR}. Updating..."
    git -C "${DEST_DIR}" fetch origin
    if git -C "${DEST_DIR}" rev-parse --verify "origin/${BRANCH}" >/dev/null 2>&1; then
      git -C "${DEST_DIR}" checkout "${BRANCH}"
      git -C "${DEST_DIR}" pull --ff-only origin "${BRANCH}"
    else
      warn "Branch ${BRANCH} not found on remote. Keeping current branch."
      git -C "${DEST_DIR}" pull --ff-only || true
    fi
  else
    log "Cloning ${PROJECT_REPO_URL} (branch: ${BRANCH}) into ${DEST_DIR}..."
    git clone -b "${BRANCH}" --depth 1 "${PROJECT_REPO_URL}" "${DEST_DIR}" || {
      warn "Failed to clone branch ${BRANCH}. Cloning default branch instead."
      git clone --depth 1 "${PROJECT_REPO_URL}" "${DEST_DIR}"
    }
  fi
}

install_and_build() {
  cd "${DEST_DIR}"
  log "Installing dependencies with pnpm..."
  pnpm install
  log "Building project with pnpm build..."
  pnpm build
}

print_success() {
  cat <<EOF

============================================================
✅ Setup complete!

Location: ${DEST_DIR}
Node:    $(node -v)
PNPM:    $(pnpm -v)

Next steps:
- Start development:   pnpm dev
- Build desktop app:   pnpm --filter @mcp_router/electron run make

Troubleshooting tips:
- If native module rebuild fails, ensure build tools are installed:
  sudo apt-get install -y build-essential python3 make g++ pkg-config
- If network is slow (e.g., in mainland China), consider setting registries:
  pnpm config set registry https://registry.npmmirror.com
  export ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/
============================================================
EOF
}

main() {
  require_apt
  install_system_prereqs
  ensure_node_20
  ensure_pnpm
  clone_or_update_repo
  install_and_build
  print_success
}

main "$@"
