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
| **WhatsApp MCP** | `@kahflane/whatsapp-mcp` — 87 tools for WhatsApp automation |

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

---

## WhatsApp MCP Server

Full WhatsApp integration for AI agents — 87 tools for messaging, search, groups, status, scheduling, and automation.

### Architecture

```
AI Agent (Claude Code)
  │  stdio (JSON-RPC)
  ▼
┌──────────────────────────────────────────┐
│  whatsapp-mcp (Node/Bun process)         │
│                                           │
│   MCP Server  ◄──►  Baileys socket       │
│        │                     │            │
│        └────────►  SQLite ◄──┘            │
│              (contacts · chats · messages) │
└──────────────────────────────────────────┘
  │
  ▼
~/.whatsapp-mcp/
  ├── auth/        # Session credentials (DO NOT SHARE)
  ├── wa.db        # Message database
  └── media/       # Downloaded media files
```

### Anti-Ban Configuration (CRITICAL)

**This uses your primary work number.** Anti-ban settings are configured conservatively:

| Setting | Value | Purpose |
|---------|-------|---------|
| `WA_DAILY_CAP` | **30** | Max sends per day (hard limit) |
| `WA_MIN_GAP_MS` | **5000** | Minimum 5s between sends |
| `WA_MAX_GAP_MS` | **15000** | Random 5-15s jitter between sends |

**Warm-up schedule for new numbers:**
- Week 1: Max 10 messages/day
- Week 2: Max 15 messages/day
- Week 3: Max 20 messages/day
- Week 4+: Gradually increase to 30/day

**Never do:**
- Send bulk messages to groups
- Send identical messages to many contacts
- Use for marketing or spam
- Send messages at inhuman speeds

**Safe patterns:**
- Reply to existing conversations
- Send to individuals (not groups)
- Use natural language (not templates)
- Vary message timing

### Setup

**1. Restart Claude Code to load the MCP server**

**2. Check connection status:**
Ask: `"Check WhatsApp status"`

**3. Get login QR code:**
Ask: `"Show me the login QR"`

**4. Scan QR in WhatsApp:**
- Open WhatsApp on your phone
- Go to **Settings → Linked Devices → Link a Device**
- Point camera at the QR code

**5. Verify connection:**
Ask: `"Check status again"` — should show `open`

**Auth persists** — you only need to do this once. Session data stored in `~/.whatsapp-mcp/auth/`.

### Available Tools (87 total)

| Category | Tools |
|----------|-------|
| **Read & Search** | `wa_list_chats`, `wa_search_messages`, `wa_get_unread`, `wa_get_messages`, `wa_list_contacts` |
| **Send** | `wa_send_text`, `wa_send_media`, `wa_send_poll`, `wa_send_location`, `wa_send_contact` |
| **Groups** | `wa_create_group`, `wa_groups_list`, `wa_group_participants`, `wa_group_metadata` |
| **Status/Story** | `wa_post_status`, `wa_post_status_to` |
| **Chat Management** | `wa_archive_chat`, `wa_pin_chat`, `wa_mute_chat`, `wa_star_message` |
| **Automation** | `wa_schedule_message`, `wa_autoreply_set`, `wa_send_template`, `wa_create_template` |
| **Profile & Privacy** | `wa_set_name`, `wa_set_status`, `wa_block`, `wa_get_privacy` |
| **Commerce** | `wa_send_product`, `wa_send_order` (Business accounts) |
| **Safety** | `wa_restrict_sending` (kill-switch), `wa_status` (health check) |

### Example Queries

```
"What did the design team say in the group chat today?"
"Send the invoice to +91XXXXXXXXXX with order #4471"
"Schedule a birthday message for 9am tomorrow"
"Who voted for option B in yesterday's poll?"
"Post a status to my close friends with this photo"
```

### Health Monitoring

The existing MCP health check hook (`~/.claude/scripts/hooks/mcp-health-check.js`) automatically monitors WhatsApp server health:
- Probes connection before each tool use
- Marks server unhealthy on failures
- Attempts reconnect with backoff
- Blocks tool use when server is down (or fails open if configured)

### Troubleshooting

**Server won't connect:**
```bash
# Check if WhatsApp MCP is running
ps aux | grep whatsapp-mcp

# Check logs
WA_LOG_LEVEL=debug npx -y @kahflane/whatsapp-mcp 2>&1 | head -50
```

**QR code expired:**
Ask: `"Show me the login QR"` — generates a fresh one

**Messages not syncing:**
Ask: `"Check WhatsApp status"` — verify connection state
Ask: `"Fetch older history"` — pull messages on-demand

**Emergency stop (kill-switch):**
Ask: `"Restrict all sending on WhatsApp"` — blocks ALL outbound messages

### Data Privacy

- **Local-only** — all data stored in `~/.whatsapp-mcp/`
- **No cloud sync** — credentials never leave your machine
- **Encrypted** — WhatsApp E2E encryption maintained
- **Your control** — `wa_logout` wipes local auth completely
