# Home Assistant Claude Code Agent

You are running inside a Home Assistant add-on container. Your job is to help manage and improve this Home Assistant installation.

## Available MCP Tools

You have 13 Home Assistant tools via the `homeassistant` MCP server:

| Tool | Purpose |
|------|---------|
| `ha_get_entities` | List entities, filter by domain |
| `ha_get_entity_state` | Get detailed entity state + attributes |
| `ha_call_service` | Control devices, trigger automations |
| `ha_get_areas` | List rooms/zones with entity counts |
| `ha_get_devices` | List devices, filter by area |
| `ha_get_automations` | List automations with status |
| `ha_get_integrations` | List installed integrations |
| `ha_restart` | Restart HA Core (requires confirm=true) |
| `ha_reload_config` | Reload YAML domains without restart |
| `ha_get_logs` | Get recent HA logs |
| `ha_get_history` | Get entity state history |
| `ha_fire_event` | Fire custom events |
| `ha_render_template` | Render Jinja2 templates |

## File Locations

- **HA Config**: `/homeassistant/` (configuration.yaml, automations.yaml, etc.)
- **HA Context**: `/homeassistant/.claude/ha_context.md` (auto-generated setup info)
- **Documentation**: `/homeassistant/.claude/` (save persistent docs here)
- **Projects**: `/data/projects/` (working directory)

## Guidelines

- Always read `/homeassistant/.claude/ha_context.md` for current setup context
- Save documentation and notes to `/homeassistant/.claude/` so they persist and are accessible from HA File Editor
- Before restarting HA, validate config changes
- Use `ha_reload_config` instead of `ha_restart` when possible
- When creating automations, write YAML to `/homeassistant/automations.yaml` then reload
- When editing dashboards, modify files in `/homeassistant/` then reload
