ARG BUILD_FROM
FROM ${BUILD_FROM}

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=xterm-256color

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    git \
    jq \
    tmux \
    coreutils \
    findutils \
    grep \
    sed \
    ca-certificates \
    openssl \
    ripgrep \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20 LTS
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install ttyd static binary
ARG BUILD_ARCH
RUN case "${BUILD_ARCH}" in \
        amd64) TTYD_ARCH="x86_64" ;; \
        aarch64) TTYD_ARCH="aarch64" ;; \
        *) TTYD_ARCH="x86_64" ;; \
    esac && \
    curl -fsSL "https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.${TTYD_ARCH}" -o /usr/bin/ttyd && \
    chmod +x /usr/bin/ttyd

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Build HA MCP server
COPY ha-mcp-server /opt/ha-mcp-server
RUN cd /opt/ha-mcp-server && npm install && npm run build && npm prune --production && npm cache clean --force

# Copy scripts
COPY scripts /opt/scripts
RUN chmod +x /opt/scripts/*.sh

# Copy CLAUDE.md template
COPY CLAUDE.md /opt/CLAUDE.md

# Configure tmux
RUN echo 'set-option -g history-limit 50000' > /root/.tmux.conf && \
    echo 'set-option -g mouse on' >> /root/.tmux.conf && \
    echo 'set-option -g default-terminal "screen-256color"' >> /root/.tmux.conf && \
    echo 'set-option -g status on' >> /root/.tmux.conf && \
    echo 'set-option -g status-position bottom' >> /root/.tmux.conf && \
    echo 'set-option -g status-style "bg=#1a1b26,fg=#a9b1d6"' >> /root/.tmux.conf && \
    echo 'set-option -g status-left " #[fg=#7aa2f7,bold]Claude Code #[fg=#565f89]| "' >> /root/.tmux.conf && \
    echo 'set-option -g status-right "#[fg=#565f89]Session: #[fg=#9ece6a]#{session_name} "' >> /root/.tmux.conf && \
    echo 'set-option -g allow-rename off' >> /root/.tmux.conf && \
    echo 'set-option -sg escape-time 10' >> /root/.tmux.conf

# Copy rootfs overlay (run script)
COPY rootfs /
