# Clawdbot VPS Deployment

Complete Docker Compose deployment files for Clawdbot Gateway, optimized for **Dokploy + Traefik**.

## 🚀 Quick Start

For fast deployment with custom domain and password protection, read:
**[QUICK-START.md](QUICK-START.md)** ← Start here!

## 📋 Files Overview

### Docker Configuration

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Standard Docker Compose (development/testing) |
| `docker-compose.prod.yml` | Production with **Traefik labels** ✨ |
| `Dockerfile` | Build image with baked-in binaries |

### Environment Templates

| File | Purpose |
|------|---------|
| `.env.example` | Basic environment template |
| `.env.production` | Production environment template |
| `.env.traefik` | **Traefik-specific** template with password protection 🔐 |

### Documentation

| File | Purpose |
|------|---------|
| `QUICK-START.md` | 🚀 **Start here!** Fast-track guide |
| `TRAEfIK.md` | Complete Traefik deployment guide |
| `DOKPLOY.md` | General Dokploy guide |
| `DEPLOYMENT.md` | General VPS deployment guide |
| `VPS-DEPLOYMENT-FILES.md` | Complete file overview |

### Scripts

| File | Purpose |
|------|---------|
| `setup-vps.sh` | Automated VPS setup script |
| `.dockerignore` | Clean Docker builds |

## ✨ Features

### docker-compose.prod.yml Includes:

✅ **Traefik Integration**
- Automatic HTTPS (Let's Encrypt)
- HTTP to HTTPS redirect
- Custom domain routing
- WebSocket support (required for Clawdbot)

✅ **Password Protection** (Optional)
- Basic auth support
- Easy enable/disable

✅ **Production Hardened**
- Security settings (read-only, no-new-privileges)
- Resource limits (2 CPU, 2GB RAM)
- Health checks
- Log rotation
- Non-root container user

✅ **Baked-in Binaries**
- gog (Gmail/Calendar/Drive/Sheets)
- mcporter (MCP)
- Extensible for more skills

## 🔗 Repository

**GitHub:** https://github.com/gnoviawan/moltbot-vps-deployment

## 📚 Deployment Guides

### 1. Quick Start (Recommended)
Read **[QUICK-START.md](QUICK-START.md)** for step-by-step setup with:
- Custom domain configuration
- Password protection
- Environment variable setup

### 2. Traefik + Custom Domain
Read **[TRAEfIK.md](TRAEfIK.md)** for:
- Complete Traefik configuration
- Enable/disable password protection
- Multiple domains support
- Troubleshooting

### 3. General Dokploy
Read **[DOKPLOY.md](DOKPLOY.md)** for:
- Git repository deployment
- Manual file upload
- Backup configuration

### 4. General VPS
Read **[DEPLOYMENT.md](DEPLOYMENT.md)** for:
- Manual VPS setup
- SSH tunnel access
- Binary installation

## 🛡️ Security Checklist

Before deploying, ensure:

- [ ] Generate strong `CLAWDBOT_GATEWAY_TOKEN` (32+ chars)
- [ ] Generate strong `GOG_KEYRING_PASSWORD` (32+ chars)
- [ ] Point DNS to VPS IP
- [ ] Set `TRAEFIK_DOMAIN` correctly
- [ ] Enable password protection if needed
- [ ] Configure backup strategy
- [ ] Test HTTPS certificate

## 📝 Environment Variables

### Required

```bash
CLAWDBOT_GATEWAY_TOKEN=<random-32-char-hex>
GOG_KEYRING_PASSWORD=<random-32-char-hex>
TRAEFIK_DOMAIN=clawbot.yourdomain.com
```

### Optional (Password Protection)

```bash
TRAEFIK_BASIC_AUTH=admin:$apr1$hash
```

Generate with: `htpasswd -nb admin password` or [online generator](https://hostingcanada.org/htpasswd-generator)

### Provider Keys

```bash
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...
DISCORD_TOKEN=...
# etc...
```

## 🚀 Deployment Steps

### Via Dokploy (Recommended)

1. Create application from Git repository
2. Configure environment variables
3. Deploy!

Full guide: **[QUICK-START.md](QUICK-START.md)**

### Manual

```bash
git clone https://github.com/gnoviawan/moltbot-vps-deployment.git
cd moltbot-vps-deployment
cp .env.traefik .env
# Edit .env with your values
docker compose -f docker-compose.prod.yml build
docker compose -f docker-compose.prod.yml up -d
```

## 📦 What's Included

### Binaries Baked into Image

- **gog** - Gmail CLI (for Sheets/Calendar/Drive)
- **mcporter** - MCP servers

### Volumes (Persistent)

- `/opt/clawdbot/config` - Gateway config & credentials
- `/opt/clawdbot/workspace` - Agent workspace & memory
- `/opt/clawdbot/skills` - Skill-specific data

### Ports

- **18789** - Gateway HTTP/WebSocket (internal, Traefik handles external)

## 🆘 Support

- **Dokploy:** https://dokploy.com/docs
- **Traefik:** https://doc.traefik.io/traefik
- **Clawdbot:** https://docs.clawd.bot
- **GitHub Issues:** https://github.com/clawdbot/clawdbot/issues
- **Community:** https://discord.gg/clawd

## 📄 License

This deployment configuration is for Clawdbot Gateway.

**Clawdbot:** https://github.com/clawdbot/clawdbot

---

**Happy deploying!** 🎉

For questions or issues, please check the documentation files or open a GitHub issue.
