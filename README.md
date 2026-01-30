# Clawdbot VPS Deployment

Complete Docker Compose deployment files for Clawdbot Gateway, optimized for **Dokploy**.

## 🚀 Quick Start

For password protection setup, read:
**[PASSWORD-PROTECTION.md](PASSWORD-PROTECTION.md)** ← Password protection guide!

Dokploy handles:
- ✅ Custom domain routing
- ✅ HTTPS/SSL certificates (Let's Encrypt)
- ✅ HTTP to HTTPS redirect

This repository adds:
- 🔐 Password protection for dashboard access

## 📋 Files Overview

### Docker Configuration

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Standard Docker Compose (development/testing) |
| `docker-compose.prod.yml` | Production with **password protection** (minimal Traefik) |
| `Dockerfile` | Build image with baked-in binaries |

### Environment Templates

| File | Purpose |
|------|---------|
| `.env.example` | Basic environment template |
| `.env.production` | Production environment template |
| `.env.traefik` | Environment with password protection variable |

### Documentation

| File | Purpose |
|------|---------|
| `PASSWORD-PROTECTION.md` | 📖 **Password protection guide** ← Read this! |
| `QUICK-START.md` | Quick deployment overview |
| `DOKPLOY.md` | General Dokploy guide |
| `DEPLOYMENT.md` | General VPS deployment guide |
| `VPS-DEPLOYMENT-FILES.md` | Complete file overview |

### Scripts & Config

| File | Purpose |
|------|---------|
| `setup-vps.sh` | Automated VPS setup script |
| `.dockerignore` | Clean Docker builds |

## 🔐 Password Protection

Dokploy automatically configures domain and HTTPS. This repository adds:

**Optional basic auth password protection** to prevent unauthorized dashboard access.

### Setup Steps:

1. **Generate password hash:**
   ```bash
   htpasswd -nb admin yourpassword
   # Or use: https://hostingcanada.org/htpasswd-generator
   ```

2. **Enable in docker-compose.prod.yml:**
   ```yaml
   labels:
     # Uncomment these lines:
     - "traefik.http.routers.clawdbot-gateway.middlewares=clawdbot-auth"
     - "traefik.http.middlewares.clawdbot-auth.basicauth.users=${TRAEFIK_BASIC_AUTH}"
   ```

3. **Add to Dokploy environment:**
   ```bash
   TRAEFIK_BASIC_AUTH=admin:$apr1$hashhashhash...
   ```

4. **Redeploy**

Complete guide: **[PASSWORD-PROTECTION.md](PASSWORD-PROTECTION.md)**

## ✨ Features

### docker-compose.prod.yml Includes:

✅ **Minimal Traefik Labels**
- Only password protection (domain/HTTPS handled by Dokploy)
- WebSocket support (required for Clawdbot)
- Simple enable/disable

✅ **Production Hardened**
- Security settings (read-only, no-new-privileges)
- Resource limits (2 CPU, 2GB RAM)
- Health checks
- Log rotation
- Non-root container user

✅ **Baked-in Binaries**
- gog (Gmail/Calendar/Drive/Sheets)
- mcporter (MCP)

## 🛡️ Security Layers

With password protection enabled:

1. **Basic Auth** (username + password)
2. **Gateway Token** (API access)

Without password protection:
- Gateway token only (single layer)

## 🔗 Repository

**GitHub:** https://github.com/gnoviawan/moltbot-vps-deployment

## 📝 Environment Variables

### Required

```bash
CLAWDBOT_GATEWAY_TOKEN=<random-32-char-hex>
GOG_KEYRING_PASSWORD=<random-32-char-hex>
CLAWDBOT_GATEWAY_BIND=lan
CLAWDBOT_GATEWAY_PORT=18789
CLAWDBOT_CONFIG_DIR=/opt/clawdbot/config
CLAWDBOT_WORKSPACE_DIR=/opt/clawdbot/workspace
```

### Optional (Password Protection)

```bash
# Generate with: htpasswd -nb admin password
TRAEFIK_BASIC_AUTH=admin:$apr1$generatedhashhere
```

### Provider Keys

```bash
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...
DISCORD_TOKEN=...
# etc...
```

## 🚀 Deployment Steps

### Via Dokploy

1. Create application from Git repository
2. Configure environment variables
3. (Optional) Enable password protection: See [PASSWORD-PROTECTION.md](PASSWORD-PROTECTION.md)
4. Deploy!

### Manual

```bash
git clone https://github.com/gnoviawan/moltbot-vps-deployment.git
cd moltbot-vps-deployment
cp .env.traefik .env
# Edit .env with your values
docker compose -f docker-compose.prod.yml build
docker compose -f docker-compose.prod.yml up -d
```

## 📚 Documentation Guide

- **[PASSWORD-PROTECTION.md](PASSWORD-PROTECTION.md)** ← Start here! Password protection
- **[QUICK-START.md](QUICK-START.md)** - Quick deployment overview
- **[DOKPLOY.md](DOKPLOY.md)** - General Dokploy guide
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - General VPS deployment
- **[VPS-DEPLOYMENT-FILES.md](VPS-DEPLOYMENT-FILES.md)** - File overview

## 🆘 Support

- **Dokploy:** https://dokploy.com/docs
- **Clawdbot:** https://docs.clawd.bot
- **GitHub Issues:** https://github.com/clawdbot/clawdbot/issues
- **Community:** https://discord.gg/clawd

---

**Happy deploying!** 🎉

For questions or issues, please check the documentation files.
