# Changelog

## 1.1.0 (2026-02-22)

### Fixed - Bad Gateway Error

- **Fixed `ingress_port`**: Changed from hardcoded `7681` to `0` (dynamic). The Supervisor assigns the port and ttyd now reads it via `bashio::addon.ingress_port` at runtime. This was the primary cause of the bad gateway error.
- **Fixed entrypoint**: Removed `ENTRYPOINT []` which was stripping the s6-overlay init system from the HA base image. The container now boots properly through s6.
- **Fixed startup timing**: Changed `startup` from `application` to `services` so the Supervisor API is available when the add-on starts.
- **Switched to Debian base image**: Changed from Alpine (`hassio/aarch64-base`) to the community Debian base (`hassio-addons/debian-base`) which includes bashio and s6-overlay properly configured.
- **Proper s6 service structure**: Replaced inline CMD with `rootfs/etc/services.d/ttyd/run` using bashio for option reading and port discovery.
- **Added service restart on crash**: s6 `finish` script waits 5s and restarts ttyd if it exits unexpectedly.

## 1.0.0 (2026-02-22)

### Initial Release

- Claude Code running in persistent tmux sessions via ttyd
- Auto-reconnect on WebSocket disconnection (10s interval)
- WebSocket keepalive pings (30s interval) to prevent proxy timeout
- Configurable model selection (Sonnet, Opus, Haiku)
- YOLO mode for auto-approving tool use
- Configurable tmux scrollback buffer (default 50,000 lines)
- HA ingress integration (sidebar access, no port forwarding)
- Persistent auth and config across container restarts via /data volume
- Access to HA config, share, media, and SSL directories
