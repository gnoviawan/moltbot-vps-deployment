# Quick Start: Dokploy + Traefik with Custom Domain

Fast-track guide to deploy Clawdbot with your custom domain and optional password protection.

## 🎯 What You Need to Do

### 1. Generate Secure Tokens

```bash
# Generate Gateway token
openssl rand -hex 32
# Output: <32-char-hex-token> - save this!

# Generate Gmail keyring password
openssl rand -hex 32
# Output: <32-char-hex-password> - save this!

# Generate basic auth password (optional)
htpasswd -nb admin yourpassword
# Output: admin:$apr1$hash - save this!
```

Or use online generator for basic auth:
https://hostingcanada.org/htpasswd-generator

### 2. Configure DNS

Point your domain to VPS IP:

```
clawbot.yourdomain.com → YOUR_VPS_IP
```

Wait 5-15 minutes for DNS propagation.

### 3. Update Dokploy Environment Variables

Go to Dokploy → Your Application → Settings → Add these:

```bash
# Required
CLAWDBOT_GATEWAY_TOKEN=<your-32-char-hex>
GOG_KEYRING_PASSWORD=<your-32-char-hex>
TRAEFIK_DOMAIN=clawbot.yourdomain.com

# Optional: Password protection
TRAEFIK_BASIC_AUTH=admin:$apr1$hashhere

# Provider keys (as needed)
ANTHROPIC_API_KEY=sk-ant-...
DISCORD_TOKEN=...
```

### 4. Enable Password Protection (Optional)

In `docker-compose.prod.yml`, uncomment these lines:

```yaml
labels:
  # Uncomment these:
  - "traefik.http.routers.clawdbot-gateway-https.middlewares=clawdbot-auth"
  - "traefik.http.middlewares.clawdbot-auth.basicauth.users=${TRAEFIK_BASIC_AUTH}"
```

### 5. Deploy

In Dokploy: Click **Deploy** or **Redeploy**

## ✅ Verify

1. Open browser: `https://clawbot.yourdomain.com`
2. Check:
   - 🔒 HTTPS certificate (green lock)
   - 🔐 Basic auth prompt (if enabled)
   - 📱 Gateway login page
3. Login with: `CLAWDBOT_GATEWAY_TOKEN`

## 🔧 Files Updated

| File | Changes |
|------|---------|
| `docker-compose.prod.yml` | Added Traefik labels + WebSocket support |
| `.env.traefik` | Traefik environment template |
| `TRAefIK.md` | Complete Traefik guide |

## 📚 Full Documentation

- **TRAEFIL.md** - Complete Traefik deployment guide
- **DOKPLOY.md** - General Dokploy guide
- **VPS-DEPLOYMENT-FILES.md** - File overview

## 🎉 That's It!

Your Clawdbot will be:
- ✅ Accessible via custom domain
- ✅ Protected with HTTPS (Let's Encrypt)
- ✅ Optionally password protected
- ✅ WebSocket compatible (real-time features)
- ✅ Production hardened

---

Generated for quick deployment with Dokploy + Traefik
