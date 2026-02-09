#!/bin/bash
set -euo pipefail

# Install openclaw-tools and its dependency (gum)
# Works two ways:
#   1. From a git clone:  ./install.sh  →  symlinks to /usr/local/bin/
#   2. One-liner:         curl -sL .../install.sh | bash  →  downloads + installs

REPO="czaku/openclaw-tools"
INSTALL_DIR="/usr/local/bin"
TOOL_NAME="openclaw-tools"

install_to() {
    local src="$1"
    local method="$2"  # "symlink" or "move"

    if [[ "$method" == "symlink" ]]; then
        if [[ -w "$INSTALL_DIR" ]]; then
            ln -sf "$src" "$INSTALL_DIR/$TOOL_NAME"
        else
            sudo ln -sf "$src" "$INSTALL_DIR/$TOOL_NAME"
        fi
    else
        if [[ -w "$INSTALL_DIR" ]]; then
            mv "$src" "$INSTALL_DIR/$TOOL_NAME"
        else
            sudo mv "$src" "$INSTALL_DIR/$TOOL_NAME"
        fi
    fi
}

# ── Install gum if missing ────────────────────────────────────────────────
install_gum() {
    if command -v gum &>/dev/null; then
        echo "✓ gum already installed"
        return 0
    fi

    echo "Installing gum (TUI framework)..."
    local platform
    platform="$(uname -s)"

    if [[ "$platform" == "Darwin" ]]; then
        if command -v brew &>/dev/null; then
            brew install gum
        else
            echo "Error: Homebrew required to install gum on macOS"
            echo "  Install brew: https://brew.sh"
            echo "  Then run this installer again"
            exit 1
        fi
    elif [[ "$platform" == "Linux" ]]; then
        if command -v apt-get &>/dev/null; then
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg 2>/dev/null
            echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list >/dev/null
            sudo apt-get update -qq
            sudo apt-get install -y gum
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y gum 2>/dev/null || {
                echo "Installing gum from Charm repo..."
                echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo >/dev/null
                sudo dnf install -y gum
            }
        elif command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm gum
        else
            echo "Error: No supported package manager found (apt, dnf, pacman)"
            echo "  Install gum manually: https://github.com/charmbracelet/gum#installation"
            exit 1
        fi
    else
        echo "Error: Unsupported OS for auto-install"
        exit 1
    fi

    if command -v gum &>/dev/null; then
        echo "✓ gum installed"
    else
        echo "Error: gum installation failed"
        exit 1
    fi
}

# ── Install gum first ────────────────────────────────────────────────────
install_gum

# ── Local clone mode ─────────────────────────────────────────────────────
# If openclaw-tools exists next to this script, symlink it
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"

if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/$TOOL_NAME" ]]; then
    echo "Found $TOOL_NAME in $SCRIPT_DIR — symlinking..."
    chmod +x "$SCRIPT_DIR/$TOOL_NAME"
    install_to "$SCRIPT_DIR/$TOOL_NAME" "symlink"
    echo "✓ Installed! Run: openclaw-tools"
    exit 0
fi

# ── Remote download mode ─────────────────────────────────────────────────
# No local copy found — download from GitHub
echo "Downloading $TOOL_NAME from GitHub..."
DOWNLOAD_URL="https://raw.githubusercontent.com/$REPO/main/$TOOL_NAME"

TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

if command -v curl &>/dev/null; then
    curl -fsSL "$DOWNLOAD_URL" -o "$TMP_FILE"
elif command -v wget &>/dev/null; then
    wget -qO "$TMP_FILE" "$DOWNLOAD_URL"
else
    echo "Error: curl or wget required" >&2
    exit 1
fi

chmod +x "$TMP_FILE"
install_to "$TMP_FILE" "move"
trap - EXIT  # file moved, don't try to delete it

echo "✓ Installed! Run: openclaw-tools"
