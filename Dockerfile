FROM node:22-bookworm

LABEL maintainer="Clawdbot VPS Setup"
LABEL description="Clawdbot Gateway with baked-in binaries"

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    socat \
    && rm -rf /var/lib/apt/lists/*

# Create node user with home directory
RUN useradd -m -u 1000 -s /bin/bash node

# === BAKE IN EXTERNAL BINARIES (Required by skills) ===
# These must be installed at build time to survive container restarts

# Gmail CLI (gog) - for gog skill
# Used for: Gmail, Calendar, Drive, Sheets, Docs
RUN curl -L https://github.com/steipete/gog/releases/latest/download/gog_Linux_x86_64.tar.gz \
    | tar -xz -C /usr/local/bin && \
    chmod +x /usr/local/bin/gog

# Google Places CLI (goplaces) - optional, for location-based skills
# Uncomment if needed:
# RUN curl -L https://github.com/steipete/goplaces/releases/latest/download/goplaces_Linux_x86_64.tar.gz \
#     | tar -xz -C /usr/local/bin && \
#     chmod +x /usr/local/bin/goplaces

# WhatsApp CLI (wacli) - for WhatsApp integration
# Uncomment if needed:
# RUN curl -L https://github.com/steipete/wacli/releases/latest/download/wacli_Linux_x86_64.tar.gz \
#     | tar -xz -C /usr/local/bin && \
#     chmod +x /usr/local/bin/wacli

# X/Twitter CLI (bird) - for Twitter integration
# Uncomment if needed:
# RUN curl -L https://github.com/steipete/bird/releases/latest/download/bird_Linux_x86_64.tar.gz \
#     | tar -xz -C /usr/local/bin && \
#     chmod +x /usr/local/bin/bird

# Add more binaries below using the same pattern as above
# Example for MCP (mcporter):
# RUN npm install -g mcporter

# === CLAWDBOT BUILD ===

WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
COPY ui/package.json ./ui/package.json
COPY scripts ./scripts

# Enable pnpm and install dependencies
RUN corepack enable && \
    pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Build Clawdbot
RUN pnpm build

# Install UI dependencies and build
RUN pnpm ui:install
RUN pnpm ui:build

# Switch to node user for running the app
USER node

# Environment variables
ENV NODE_ENV=production
ENV HOME=/home/node

# Default command (can be overridden in docker-compose)
CMD ["node", "dist/index.js"]
