# Linux Daily Driver

Persistent Chrome remote debugging + Playwright MCP for AI agents.

## What this sets up

| Component | Description |
|-----------|-------------|
| `~/bin/chrome-debug` | Chrome wrapper with `--remote-debugging-port=9222` |
| `google-chrome.desktop` | Desktop override so clicking Chrome always enables debugging |
| `chrome-debug.service` | systemd user service (auto-starts Chrome on login) |
| Playwright MCP | `@playwright/mcp@latest` connecting via CDP to `:9222` |
| opencode config | MCP server config for opencode |
| Claude Code config | MCP server config for Claude Code |

## Quick install

```bash
cd ~/.dotfiles
./install.sh
```

## How it works

1. Chrome launches with `--remote-debugging-port=9222 --user-data-dir=~/.chrome-debug`
2. AI agents (Claude Code, opencode) connect via Playwright MCP using `--cdp-endpoint http://127.0.0.1:9222`
3. Chrome auto-starts on login via systemd

## File layout

```
~/.dotfiles/
├── chrome-debug/
│   ├── chrome-debug              # ~/bin/chrome-debug wrapper
│   └── google-chrome.desktop     # Desktop entry override
├── opencode/
│   └── opencode.jsonc            # opencode MCP config
├── systemd/user/
│   └── chrome-debug.service      # systemd auto-start
├── install.sh                    # One-command setup
└── README.md
```

## Requirements

- Node.js 18+ (for Playwright MCP)
- npm/npx
- Google Chrome
- Linux (tested on Mint/Ubuntu)

## Manual start

```bash
# Start Chrome with debugging
~/bin/chrome-debug

# Or via systemd
systemctl --user start chrome-debug

# Verify CDP is live
curl http://127.0.0.1:9222/json/version
```
