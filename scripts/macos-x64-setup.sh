#!/usr/bin/env bash
set -euo pipefail

# macOS Intel x64 one-click setup for mcp-router
# - Verifies macOS (Darwin) and x86_64 architecture
# - Ensures Xcode Command Line Tools are installed
# - Installs Homebrew (if missing)
# - Installs Node.js (>= 20), pnpm via corepack
# - Clones the repository (or updates if already present)
# - Installs dependencies and builds the project
#
# Usage:
#   bash macos-x64-setup.sh [destination_dir] [branch]
# Env:
#   MCP_ROUTER_DIR    Destination directory (default: "$HOME/mcp-router")
#   MCP_ROUTER_BRANCH Git branch to use (default: "main")
#
# Example (one-liner):
#   curl -fsSL https://raw.githubusercontent.com/miaoronghua/mcp-router/HEAD/scripts/macos-x64-setup.sh | bash

PROJECT_REPO_URL="https://github.com/miaoronghua/mcp-router.git"
DEFAULT_DIR="${HOME}/mcp-router"
DEFAULT_BRANCH="main"

DEST_DIR="${1:-${MCP_ROUTER_DIR:-${DEFAULT_DIR}}}"
BRANCH="${2:-${MCP_ROUTER_BRANCH:-${DEFAULT_BRANCH}}}"

log() { printf "\033[1;32m[INFO]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[ERROR]\033[0m %s\n" "$*"; }

require_darwin_x64() {
  if [ "$(uname -s)" != "Darwin" ]; then
    err "This script is intended for macOS (Darwin)."
    exit 1
  fi
  ARCH="$(uname -m)"
  if [ "${ARCH}" != "x86_64" ]; then
    err "This script targets macOS Intel x64 (x86_64). Detected: ${ARCH}."
    err "If you're on Apple Silicon (arm64), please use a dedicated arm64 setup or run under Rosetta with an x64 Homebrew."
    exit 1
  fi
}

ensure_xcode_clt() {
  if xcode-select -p >/dev/null 2>&1; then
    log "Xcode Command Line Tools detected."
  else
    warn "Xcode Command Line Tools not found. Attempting to start installation..."
    # This will open a GUI installer and requires user confirmation.
    # We exit afterwards and ask the user to rerun the script when done.
    if xcode-select --install >/dev/null 2>&1; then
      :
    else
      :
    fi
    cat <<'EOF'
Please complete the Xcode Command Line Tools installation in the GUI prompt, then rerun this script.
If the installer did not appear, you can try:
  sudo rm -rf /Library/Developer/CommandLineTools
  xcode-select --install
EOF
    exit 1
  fi
}

ensure_brew() {
  if command -v brew >/dev/null 2>&1; then
    log "Homebrew detected: $(brew --version | head -n1)"
    return
  fi
  warn "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Load brew into current shell for Intel macs (default path)
  if [ -x "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  elif [ -x "/opt/homebrew/bin/brew" ]; then
    # In case of Rosetta/x64 brew path is different, but allow it if present
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    # Fallback to whatever brew is on PATH
    if command -v brew >/dev/null 2>&1; then
      eval "$(brew shellenv)"
    fi
  fi

  log "Homebrew installed: $(brew --version | head -n1)"
}

brew_install_prereqs() {
  log "Updating Homebrew and installing prerequisites..."
  brew update
  # Install a minimal set of tools commonly needed for native builds
  brew install git python@3.11 pkg-config make gcc || true
}

ensure_node_20() {
  if command -v node >/dev/null 2>&1; then
    NODE_VER="$(node -v | sed 's/^v//')"
    NODE_MAJOR="${NODE_VER%%.*}"
    if [ "${NODE_MAJOR}" -ge 20 ]; then
      log "Detected Node.js v${NODE_VER} (>=20), skipping Node installation."
      return
    else
      warn "Detected Node.js v${NODE_VER} (<20). Will install Node.js 20.x via Homebrew."
    fi
  else
    log "Node.js not found. Will install Node.js 20.x via Homebrew."
  fi

  # Prefer node@20 if available, fall back to node (latest)
  if brew info node@20 >/dev/null 2>&1; then
    brew install node@20 || true
    # Link node@20 (force overwrite if needed)
    if brew list node@20 >/dev/null 2>&1; then
      brew link --overwrite --force node@20 || true
    fi
  else
    warn "Homebrew formula node@20 not found. Installing latest node instead."
    brew install node || true
  fi
  log "Installed Node.js $(node -v)"
}

ensure_pnpm() {
  # Use corepack to ensure the exact pnpm version required by the repo
  if ! command -v corepack >/dev/null 2>&1; then
    warn "corepack not found; installing via npm (fallback)."
    npm install -g corepack || true
  fi
  if command -v corepack >/dev/null 2>&1; then
    log "Enabling corepack and activating pnpm@8.15.6..."
    corepack enable || true
    corepack prepare pnpm@8.15.6 --activate
  else
    warn "corepack still unavailable; installing pnpm globally via npm."
    npm install -g pnpm@8.15.6 || true
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
✅ Setup complete (macOS Intel x64)!

Location: ${DEST_DIR}
Node:    $(node -v)
PNPM:    $(pnpm -v)

Next steps:
- Start development:           pnpm dev
- Build macOS x64 app locally: pnpm make:mac:x64
- Publish macOS x64 release:   pnpm publish:mac:x64

Troubleshooting tips:
- If native module rebuild fails, ensure Xcode Command Line Tools are installed:
  xcode-select -p  # should print a path
  # If missing, run (requires GUI confirmation):
  xcode-select --install
- If network is slow (e.g., in mainland China), consider setting registries:
  pnpm config set registry https://registry.npmmirror.com
  export ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/
============================================================
EOF
}

main() {
  require_darwin_x64
  ensure_xcode_clt
  ensure_brew
  brew_install_prereqs
  ensure_node_20
  ensure_pnpm
  clone_or_update_repo
  install_and_build
  print_success
}

main "$@"
