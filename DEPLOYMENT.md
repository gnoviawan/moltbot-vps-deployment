# Deploy Clawdbot to VPS with Docker Compose

This guide helps you deploy Clawdbot Gateway on any VPS using Docker Compose, compatible with Dokploy.

## Quick Start

### 1. Prepare Environment

```bash
# Clone the repository (if you haven't already)
cd /path/to/clawdbot

# Copy environment template
cp .env.example .env

# Generate secure tokens
openssl rand -hex 32  # For CLAWDBOT_GATEWAY_TOKEN
openssl rand -hex 32  # For GOG_KEYRING_PASSWORD
```

### 2. Configure Environment

Edit `.env` with your values:

```bash
nano .env
```

**Critical values to update:**
- `CLAWDBOT_GATEWAY_TOKEN` - Random 32-char hex
- `GOG_KEYRING_PASSWORD` - Random 32-char hex
- `CLAWDBOT_CONFIG_DIR` - Host path for persistent config
- `CLAWDBOT_WORKSPACE_DIR` - Host path for workspace

### 3. Build and Start

```bash
# Build the Docker image
docker compose build

# Start the container
docker compose up -d

# View logs
docker compose logs -f clawdbot-gateway
```

## Using with Dokploy

### Option 1: Via Dokploy UI

1. Go to your Dokploy dashboard
2. Create a new **Application** → Select **Docker Compose**
3. Upload these files:
   - `docker-compose.yml`
   - `Dockerfile`
   - `.env.example` (rename to `.env`)
4. Configure environment variables in Dokploy
5. Deploy!

### Option 2: Via Git Repository

1. Push your files to Git repository
2. In Dokploy, create application from Git
3. Select branch and configure build context
4. Add environment variables in Dokploy UI
5. Deploy

## Accessing the Gateway

### Via SSH Tunnel (Recommended)

From your local machine:

```bash
ssh -N -L 18789:127.0.0.1:18789 root@YOUR_VPS_IP
```

Then open: `http://localhost:18789/`

### Via Reverse Proxy (Nginx/Traefik)

Example Nginx configuration:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:18789;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## Persistence Strategy

All important data is stored on the host via volume mounts:

| Component | Host Path | Container Path |
|-----------|-----------|----------------|
| Gateway config | `./data/config` | `/home/node/.clawdbot` |
| Workspace | `./data/workspace` | `/home/node/clawd` |
| Skills config | `./data/skills` | `/home/node/.clawdbot/skills` |

**Backup these directories regularly!**

```bash
tar -czf clawdbot-backup-$(date +%Y%m%d).tar.gz data/
```

## Adding Skills with External Binaries

When adding skills that require external tools:

1. Update `Dockerfile` to install the binary at build time
2. Rebuild the Docker image:
   ```bash
   docker compose build
   docker compose up -d
   ```

**Example: Adding mcporter for MCP**

Edit `Dockerfile`:

```dockerfile
# Add to the "BAKE IN EXTERNAL BINARIES" section
RUN npm install -g mcporter
```

## Troubleshooting

### Gateway not starting

```bash
# Check logs
docker compose logs clawdbot-gateway

# Check if port is in use
netstat -tlnp | grep 18789
```

### Permission issues with volumes

```bash
# Fix permissions
sudo chown -R 1000:1000 ./data/
```

### Container keeps restarting

```bash
# Check resource limits
docker stats

# Adjust limits in docker-compose.yml if needed
```

### Verify external binaries are installed

```bash
docker compose exec clawdbot-gateway which gog
docker compose exec clawdbot-gateway which mcporter
```

## Updating Clawdbot

```bash
# Pull latest code
git pull

# Rebuild and restart
docker compose build
docker compose up -d
```

## Security Best Practices

1. **Never expose Gateway publicly without authentication**
2. Use strong random tokens for `CLAWDBOT_GATEWAY_TOKEN`
3. Keep `.env` file secret (don't commit to Git)
4. Regularly backup `./data/` directories
5. Use SSH tunnels or reverse proxies for remote access
6. Update Clawdbot regularly
7. Monitor container resources and logs

## Resource Requirements

**Minimum:**
- CPU: 1 core
- RAM: 512MB
- Disk: 5GB (for config + workspace)

**Recommended:**
- CPU: 2 cores
- RAM: 2GB
- Disk: 10GB+ (for workspace growth)

## Support

- Documentation: https://docs.clawd.bot
- GitHub Issues: https://github.com/clawdbot/clawdbot/issues
- Community: https://discord.gg/clawd
