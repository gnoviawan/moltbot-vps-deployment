# Clawdbot VPS Deployment Files

This directory contains all files needed to deploy Clawdbot Gateway to a VPS using Docker Compose and Dokploy.

## Files Created

### Core Files

| File | Purpose |
|-------|---------|
| `docker-compose.yml` | Standard Docker Compose configuration for development/testing |
| `docker-compose.prod.yml` | Production-ready configuration with security hardening |
| `Dockerfile` | Container image build instructions with baked-in binaries |
| `.env.example` | Environment variable template |
| `.env.production` | Production environment variables template |

### Documentation

| File | Purpose |
|-------|---------|
| `DEPLOYMENT.md` | General VPS deployment guide |
| `DOKPLOY.md` | Specific guide for Dokploy deployment |
| `VPS-DEPLOYMENT-FILES.md` | This file - overview of all deployment files |

### Scripts

| File | Purpose |
|-------|---------|
| `setup-vps.sh` | Automated setup script for VPS (creates dirs, generates tokens) |

### Config Files

| File | Purpose |
|-------|---------|
| `.dockerignore` | Files to exclude from Docker build |

## Quick Start

### For Dokploy Deployment

1. Read `DOKPLOY.md` for complete instructions
2. Use `docker-compose.prod.yml` for production
3. Configure environment variables in `.env.production`
4. Deploy via Dokploy

### For Manual VPS Deployment

1. SSH into VPS
2. Clone repository or upload files
3. Run setup script: `bash setup-vps.sh`
4. Configure `.env` with your credentials
5. Build and start: `docker compose build && docker compose up -d`

## Key Differences: Standard vs Production

### docker-compose.yml
- Development-oriented
- Minimal resource limits
- Basic logging configuration
- Good for testing

### docker-compose.prod.yml
- Production-hardened
- Resource limits (2 CPU, 2GB RAM)
- Security settings (read-only filesystem, no-new-privileges)
- Health checks enabled
- Log rotation (5 files, 10MB each)
- Recommended for Dokploy

## Directory Structure After Deployment

```
/opt/clawdbot/
├── docker-compose.prod.yml
├── Dockerfile
├── .env
├── data/
│   ├── config/          # Gateway configuration (persistent)
│   │   ├── clawdbot.json
│   │   ├── credentials/
│   │   └── skills/
│   ├── workspace/       # Agent workspace (persistent)
│   │   ├── AGENTS.md
│   │   ├── MEMORY.md
│   │   └── memory/
│   └── skills/         # Skill-specific data (persistent)
└── logs/              # Container logs
```

## Environment Variables Reference

### Required

| Variable | Description | Example |
|-----------|-------------|---------|
| `CLAWDBOT_GATEWAY_TOKEN` | Authentication token | Random 32-char hex |
| `GOG_KEYRING_PASSWORD` | Gmail keyring password | Random 32-char hex |
| `CLAWDBOT_GATEWAY_BIND` | Bind mode | `loopback`, `lan`, `0.0.0.0` |
| `CLAWDBOT_GATEWAY_PORT` | Gateway port | `18789` |
| `CLAWDBOT_CONFIG_DIR` | Config directory path | `/opt/clawdbot/config` |
| `CLAWDBOT_WORKSPACE_DIR` | Workspace directory path | `/opt/clawdbot/workspace` |

### Optional (Provider Keys)

| Variable | Provider |
|-----------|----------|
| `ANTHROPIC_API_KEY` | Anthropic (Claude) |
| `OPENAI_API_KEY` | OpenAI |
| `GOOGLE_API_KEY` | Google AI |
| `ZAI_API_KEY` | Z.AI (GLM) |
| `OPENROUTER_API_KEY` | OpenRouter |

### Optional (Channels)

| Variable | Channel |
|-----------|---------|
| `DISCORD_TOKEN` | Discord bot token |
| `TELEGRAM_TOKEN` | Telegram bot token |
| `WACLI_ACCOUNT` | WhatsApp email |

## Security Features in Production

### docker-compose.prod.yml includes:

✅ **Read-only root filesystem** (except tmpfs)
✅ **No new privileges** security option
✅ **Non-root container user** (uid 1000)
✅ **Resource limits** (CPU: 2, RAM: 2GB)
✅ **Health checks** (every 30s)
✅ **Log rotation** (max 5 files, 10MB each)
✅ **Bind to localhost only** (by default)
✅ **Volume mounts for persistence**

## Backup Strategy

### What to backup:

- `/opt/clawdbot/data/config/` - Gateway config & credentials
- `/opt/clawdbot/data/workspace/` - Agent workspace & memory
- `.env` - Environment variables (encrypt this!)

### How to backup:

```bash
tar -czf clawdbot-backup-$(date +%Y%m%d).tar.gz \
    /opt/clawdbot/data/ \
    /opt/clawdbot/.env
```

### Restore:

```bash
tar -xzf clawdbot-backup-YYYYMMDD.tar.gz -C /opt/
docker compose -f /opt/clawdbot/docker-compose.prod.yml restart
```

## Next Steps

1. **Choose deployment method**: Dokploy vs manual
2. **Read appropriate guide**: `DOKPLOY.md` or `DEPLOYMENT.md`
3. **Configure environment**: Update `.env` with your values
4. **Deploy**: Use Dokploy or run setup script
5. **Set up reverse proxy**: Nginx/Traefik for HTTPS
6. **Configure backups**: Automatic or manual
7. **Monitor**: Check logs and health status

## Support Links

- **Dokploy**: https://dokploy.com/docs
- **Clawdbot Docs**: https://docs.clawd.bot
- **Clawdbot GitHub**: https://github.com/clawdbot/clawdbot
- **Community**: https://discord.gg/clawd

---

Generated for Clawdbot VPS deployment
