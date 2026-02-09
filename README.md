# 🦞 OpenClaw Tools

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/czaku)

> Interactive TUI for managing [OpenClaw](https://openclaw.ai) on macOS and Linux — multi-user setups, profiles, backups, migrations, and clean uninstalls.

## Just run it

```bash
./openclaw-tools
```

No flags, no subcommands, no docs to read. Arrow keys to navigate, Enter to select. Powered by [gum](https://github.com/charmbracelet/gum).

```
  ╭──────────────────────────────────────────────╮
  │              OpenClaw Tools                   │
  │                                               │
  │  This Mac:                                    │
  │    ● ted — port 18728 (running)               │
  │    ● kev — port 18828 (running)               │
  ╰──────────────────────────────────────────────╯

  > Set up OpenClaw
    Status & profiles
    Backup
    Fix paths after home rename
    Clean uninstall
    Exit
```

---

## Install

**One line** (installs [gum](https://github.com/charmbracelet/gum) automatically):

```bash
curl -sL https://raw.githubusercontent.com/czaku/openclaw-tools/main/install.sh | bash
```

<details>
<summary>Other install methods</summary>

**Clone and install:**

```bash
git clone https://github.com/czaku/openclaw-tools.git
cd openclaw-tools
./install.sh    # installs gum + symlinks to /usr/local/bin/
```

**Just grab the script** — no install needed:

```bash
curl -sL https://raw.githubusercontent.com/czaku/openclaw-tools/main/openclaw-tools -o openclaw-tools
chmod +x openclaw-tools
./openclaw-tools
```

**Multi-user machines** — copy to a shared location:

```bash
# macOS:
sudo cp openclaw-tools /Users/Shared/openclaw-tools

# Linux:
sudo cp openclaw-tools /usr/local/share/openclaw-tools

# Then from any account:
/Users/Shared/openclaw-tools       # macOS
/usr/local/share/openclaw-tools    # Linux
```

</details>

---

## What it does

### Set up OpenClaw

The setup wizard auto-detects your situation and adapts:

<table>
<tr><td>

**New user on this machine** — goes straight to port selection, writes config, starts daemon:

```
You (kev) don't have OpenClaw configured yet.
Let's set it up!

Ports on this machine:
  18728 — in use by ted
  18828 — available
Pick a port: 18828

✓ Config written (port=18828, mode=local)
✓ Gateway auth token generated
✓ Daemon installed
✓ Gateway listening on port 18828
```

</td></tr>
<tr><td>

**Already set up, want another bot** — creates a named profile with its own port, API keys, Slack bot, and dashboard:

```
Name for this bot: vi

Copy API keys from your main OpenClaw:
> [x] anthropic (default, secondary)
  [ ] minimax (production)

✓ Config written with anthropic key
✓ Daemon ai.openclaw.vi installed
✓ Gateway listening on port 18928
```

</td></tr>
<tr><td>

**Already set up, want to reconfigure** — change port, reset config, reinstall daemon, or regenerate auth token.

</td></tr>
<tr><td>

**Different user account** — prints instructions to log into that account and run the tool from there.

</td></tr>
</table>

### Status & profiles

Shows all profiles on your account with running state, port, API keys, channels, and dashboard URLs. Also detects other users' instances on the machine.

### Backup

Creates a timestamped tarball of your config, sessions, and workspace on the Desktop. Also backs up named profiles.

### Fix paths after home rename

When you rename your user account (e.g. `clawsy` -> `ted`), hundreds of config entries still point to the old home path. This scans OpenClaw, Claude Code, and related configs, backs up each file, and fixes all paths.

### Clean uninstall

Stops the daemon, removes the service, and optionally wipes all data. Creates a safety backup first. Handles both default and named profiles. Type `NUKE` to confirm data deletion.

---

## The problem this solves

OpenClaw wasn't designed for multiple users on one machine. Out of the box:

| Problem | What happens |
|---------|-------------|
| **Port clash** | Every user's gateway binds to the same default port |
| **Permission lockout** | `/tmp/openclaw/` created by the first user blocks everyone else |
| **Config bleed** | Copying config between users leaks Slack tokens and API keys |
| **Silent crashes** | The gateway dies without logging anything useful |
| **Auth confusion** | Dashboard shows "unauthorized" — token wasn't in the URL |

This tool handles all of it — unique ports, clean configs, auth tokens, permissions, and daemon management.

---

## Profiles vs Separate Accounts

| | Profiles (same user account) | Separate Accounts |
|--|:---:|:---:|
| **What** | `~/.openclaw-{name}/` per bot | `~/.openclaw/` per user account |
| **Privacy** | Same user can read all profiles | OS-level file isolation |
| **Day-to-day** | `openclaw --profile X` on every command | Just `openclaw` |
| **Use case** | One person, multiple bots | Multiple people sharing a machine |
| **Separate Slack bot?** | Yes | Yes |

Both approaches need unique ports. Neither is handled by OpenClaw's onboarding. This tool handles both.

---

## Prerequisites

| | macOS | Linux |
|--|-------|-------|
| **gum** | Installed automatically by `install.sh` | Installed automatically by `install.sh` |
| **Node.js** | `brew install node` | `sudo apt install nodejs` |
| **OpenClaw** | `npm install -g openclaw` | `npm install -g openclaw` |
| **python3** | Ships with macOS | `sudo apt install python3` |

---

## License

MIT

---

<p align="center">
  <a href="https://buymeacoffee.com/czaku">
    <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" width="217" />
  </a>
</p>
