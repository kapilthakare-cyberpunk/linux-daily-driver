#!/bin/bash
# install.sh - Linux Daily Driver setup
# Sets up Chrome remote debugging, Playwright MCP, and AI agent configs
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

echo "=== Linux Daily Driver Setup ==="
echo "Dotfiles dir: $DOTFILES_DIR"

# --- Chrome Remote Debugging ---
echo ""
echo "[1/5] Setting up Chrome remote debugging..."
mkdir -p "$HOME/bin"
mkdir -p "$HOME/.chrome-debug"
mkdir -p "$XDG_DATA_HOME/applications"

cp "$DOTFILES_DIR/chrome-debug/chrome-debug" "$HOME/bin/chrome-debug"
chmod +x "$HOME/bin/chrome-debug"

cp "$DOTFILES_DIR/chrome-debug/google-chrome.desktop" "$XDG_DATA_HOME/applications/google-chrome.desktop"

# systemd user service
mkdir -p "$XDG_CONFIG_HOME/systemd/user"
cp "$DOTFILES_DIR/systemd/user/chrome-debug.service" "$XDG_CONFIG_HOME/systemd/user/chrome-debug.service"
systemctl --user daemon-reload 2>/dev/null || true
systemctl --user enable chrome-debug.service 2>/dev/null || true

echo "  Chrome wrapper: ~/bin/chrome-debug"
echo "  Desktop override: $XDG_DATA_HOME/applications/google-chrome.desktop"
echo "  systemd service: chrome-debug.service (enabled)"

# --- Playwright MCP ---
echo ""
echo "[2/5] Installing Playwright MCP..."
if command -v npm &>/dev/null; then
    npm install -g @playwright/mcp@latest 2>/dev/null || true
    npx playwright install chromium 2>/dev/null || true
    echo "  Playwright MCP installed globally"
elif command -v npx &>/dev/null; then
    echo "  npx available, Playwright MCP will be installed on first use"
else
    echo "  WARNING: npm/npx not found. Install Node.js first."
fi

# --- opencode config ---
echo ""
echo "[3/5] Configuring opencode..."
mkdir -p "$XDG_CONFIG_HOME/opencode"
if [ -f "$DOTFILES_DIR/opencode/opencode.jsonc" ]; then
    cp "$DOTFILES_DIR/opencode/opencode.jsonc" "$XDG_CONFIG_HOME/opencode/opencode.jsonc"
    echo "  opencode config installed"
fi

# --- Claude Code config ---
echo ""
echo "[4/5] Configuring Claude Code MCP..."
if command -v claude &>/dev/null; then
    claude mcp remove playwright 2>/dev/null || true
    claude mcp add --scope user playwright -- npx @playwright/mcp@latest --cdp-endpoint http://127.0.0.1:9222 2>/dev/null || true
    echo "  Claude Code Playwright MCP configured (user scope)"
    if [ -f "$DOTFILES_DIR/claude/mcp-servers.json" ]; then
        echo "  MCP server configs saved at: claude/mcp-servers.json"
    fi
else
    echo "  claude CLI not found, skipping"
fi

# --- Ensure ~/bin is in PATH ---
echo ""
echo "[5/5] Checking PATH..."
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo "  WARNING: ~/bin is not in PATH"
    echo "  Add to ~/.bashrc or ~/.zshrc:"
    echo "    export PATH=\"\$HOME/bin:\$PATH\""
else
    echo "  ~/bin is in PATH"
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "To start Chrome with remote debugging:"
echo "  ~/bin/chrome-debug"
echo "  or log out/in (systemd auto-starts it)"
echo ""
echo "CDP endpoint: http://127.0.0.1:9222"
echo "Playwright MCP: connects via --cdp-endpoint http://127.0.0.1:9222"
