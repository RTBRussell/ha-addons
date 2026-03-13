# Claude Code Terminal

Run Claude Code directly in your Home Assistant with persistent terminal sessions.

## Features

- **Persistent sessions**: Navigate away and come back - your conversation is still there
- **Auto-reconnect**: If the connection drops, it reconnects automatically
- **Configurable model**: Choose between Sonnet, Opus, or Haiku
- **YOLO mode**: Let Claude auto-approve tool use (for trusted environments)
- **Large scrollback**: Configurable history buffer (default 50,000 lines)
- **HA integration**: Access via sidebar, uses ingress (no port forwarding needed)

## Configuration

### Anthropic API Key

Enter your Anthropic API key. Get one at [console.anthropic.com](https://console.anthropic.com/).

### Model

Choose which Claude model to use:
- **sonnet** (default) - Fast and capable, best balance of speed and quality
- **opus** - Most capable, best for complex tasks
- **haiku** - Fastest, best for simple tasks

### YOLO Mode

When enabled, Claude Code will automatically approve all tool use (file reads, writes, bash commands) without asking. Only enable this in trusted environments.

### Scrollback History

Number of lines kept in the tmux scrollback buffer. Default is 50,000. Increase if you have long sessions and want to scroll back further.

### Session Name

Name of the tmux session. Default is "claude". Only change this if you know what you're doing.

## How It Works

The add-on runs Claude Code inside a tmux session, served to your browser via ttyd (a web-based terminal). When you navigate away from the page, the tmux session keeps running in the background. When you come back, you reconnect to the same session.

### What persists across tab changes:
- Your full conversation with Claude
- Any running commands
- Terminal scrollback history

### What persists across add-on restarts:
- Your API key and authentication
- Claude Code settings and preferences
- Files in `/data/projects/`

### What does NOT persist across restarts:
- The active conversation (a new Claude session starts)
- Running processes

## Accessing Files

The add-on maps several HA directories:

| Container Path | HA Path | Access |
|---------------|---------|--------|
| `/homeassistant` | Home Assistant config | Read/Write |
| `/addon_configs` | Add-on configs | Read/Write |
| `/share` | Shared folder | Read/Write |
| `/ssl` | SSL certificates | Read only |
| `/media` | Media folder | Read only |
| `/data/projects` | Persistent project storage | Read/Write |

## Tips

- Use `/data/projects/` for any files you want Claude to work with persistently
- If Claude seems stuck, you can kill the tmux session by restarting the add-on
- The tmux scrollback can be navigated with mouse scroll or `Ctrl+B` then `[` for copy mode
