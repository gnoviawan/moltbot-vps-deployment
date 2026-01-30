# Deploy Clawdbot with Dokploy

Complete guide for deploying Clawdbot Gateway on VPS using Dokploy.

## Prerequisites

- VPS with Docker installed
- Dokploy installed on VPS
- Git repository with Clawdbot code

## Deployment Options

### Option 1: Direct Docker Compose (Quickest)

1. **Upload files to VPS**

   ```bash
   # Via SCP from your local machine
   scp docker-compose.prod.yml root@YOUR_VPS:/opt/clawdbot/
   scp Dockerfile root@YOUR_VPS:/opt/clawdbot/
   scp .env.production root@YOUR_VPS:/opt/clawdbot/.env
   ```

2. **Configure environment**

   SSH into VPS:

   ```bash
   ssh root@YOUR_VPS
   cd /opt/clawdbot

   # Edit .env with your credentials
   nano .env
   ```

   Update at minimum:
   - `CLAWDBOT_GATEWAY_TOKEN` (generate with `openssl rand -hex 32`)
   - `GOG_KEYRING_PASSWORD` (generate with `openssl rand -hex 32`)
   - Any provider API keys you need

3. **Start with Docker Compose**

   ```bash
   docker compose -f docker-compose.prod.yml build
   docker compose -f docker-compose.prod.yml up -d
   ```

4. **Configure Dokploy (Optional)**

   If you want Dokploy to manage it:

   - Open Dokploy Dashboard
   - Create New Application → Docker Compose
   - Point to `/opt/clawdbot/docker-compose.prod.yml`
   - Add environment variables
   - Deploy

### Option 2: Git Repository (Recommended)

1. **Push to Git**

   ```bash
   git add docker-compose.prod.yml Dockerfile .env.production DEPLOYMENT.md
   git commit -m "Add Docker deployment files"
   git push origin main
   ```

2. **Configure Dokploy**

   - Open Dokploy Dashboard
   - Create New Application → From Git Repository
   - Select your repository
   - Configure build settings:
     - Build Context: `.`
     - Docker Compose File: `docker-compose.prod.yml`
   - Add environment variables in Dokploy UI
   - Deploy

3. **Set up persistent volumes**

   In Dokploy, configure volume mounts:
   - `/opt/clawdbot/config` → `/home/node/.clawdbot`
   - `/opt/clawdbot/workspace` → `/home/node/clawd`

   Or create these directories before deploy:

   ```bash
   mkdir -p /opt/clawdbot/config
   mkdir -p /opt/clawdbot/workspace
   chown -R 1000:1000 /opt/clawdbot
   ```

## Accessing Gateway

### With Reverse Proxy (Recommended)

Set up Nginx or Traefik in Dokploy:

**Nginx Example:**

```nginx
server {
    listen 80;
    server_name clawbot.yourdomain.com;

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

Then access at: `https://clawbot.yourdomain.com`

### With SSH Tunnel (Development)

```bash
ssh -N -L 18789:127.0.0.1:18789 root@YOUR_VPS_IP
```

Then access at: `http://localhost:18789/`

## Updating Deployment

### From Git (Dokploy)

1. Push changes to Git
2. In Dokploy: Click "Deploy" button
3. Dokploy will pull, build, and restart

### Manual (SSH into VPS)

```bash
cd /opt/clawdbot
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d
```

## Monitoring

### Check logs in Dokploy

- Open Application → Logs tab

### Check logs via SSH

```bash
docker compose -f /opt/clawdbot/docker-compose.prod.yml logs -f clawdbot-gateway
```

### Check container status

```bash
docker compose -f /opt/clawdbot/docker-compose.prod.yml ps
```

## Backup Strategy

### Automatic Backup (Dokploy)

Configure Dokploy to backup `/opt/clawdbot` to external storage.

### Manual Backup

```bash
# SSH into VPS
cd /opt
tar -czf clawdbot-backup-$(date +%Y%m%d-%H%M%S).tar.gz clawdbot/

# Download to local machine
scp root@YOUR_VPS:/opt/clawdbot-backup-*.tar.gz ./
```

## Troubleshooting

### Container won't start

```bash
# Check logs
docker compose -f /opt/clawdbot/docker-compose.prod.yml logs clawdbot-gateway

# Check port conflicts
netstat -tlnp | grep 18789
```

### Permission denied errors

```bash
# Fix permissions
sudo chown -R 1000:1000 /opt/clawdbot
```

### Environment variables not loading

In Dokploy:
- Check environment variables are properly set
- Ensure `.env` file exists in deployment directory

### Database connection issues

If using Redis:
```bash
docker compose -f /opt/clawdbot/docker-compose.prod.yml logs redis
```

## Security Checklist

- [ ] Gateway token is random 32+ chars
- [ ] `CLAWDBOT_GATEWAY_BIND=loopback` (not public)
- [ ] HTTPS enabled (reverse proxy)
- [ ] Firewall configured (allow only 80/443)
- [ ] Regular backups configured
- [ ] Container running as non-root user
- [ ] Read-only filesystem enabled (except data dirs)
- [ ] Resource limits set
- [ ] Health checks enabled
- [ ] Log rotation configured

## Support

- Dokploy: https://dokploy.com/docs
- Clawdbot: https://docs.clawd.bot
- GitHub Issues: https://github.com/clawdbot/clawdbot/issues
