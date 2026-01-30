# Dokploy + Traefik Deployment Guide

Complete guide for deploying Clawdbot with custom domain and password protection using Dokploy's Traefik.

## Prerequisites

- Dokploy installed with Traefik enabled
- Custom domain pointed to your VPS IP
- Traefik configured with Let's Encrypt (default in Dokploy)

## Quick Start

### 1. Update docker-compose.prod.yml

The file now includes Traefik labels for:
- ✅ HTTP to HTTPS automatic redirect
- ✅ Custom domain routing
- ✅ WebSocket support (required for Clawdbot)
- ✅ Optional basic auth password protection
- ✅ Automatic SSL via Let's Encrypt

### 2. Configure Environment Variables

In Dokploy, add these environment variables:

#### Required:

```bash
# Gateway authentication
CLAWDBOT_GATEWAY_TOKEN=<generate with openssl rand -hex 32>
GOG_KEYRING_PASSWORD=<generate with openssl rand -hex 32>

# Your custom domain
TRAEFIK_DOMAIN=clawbot.yourdomain.com
```

#### Optional (Password Protection):

Enable basic auth by uncommenting in docker-compose.prod.yml:

```yaml
labels:
  # Uncomment these lines:
  - "traefik.http.routers.clawdbot-gateway-https.middlewares=clawdbot-auth"
  - "traefik.http.middlewares.clawdbot-auth.basicauth.users=${TRAEFIK_BASIC_AUTH}"
```

Then add environment variable:

```bash
# Generate with: htpasswd -nb admin yourpassword
# Or use: https://hostingcanada.org/htpasswd-generator
TRAEFIK_BASIC_AUTH=admin:$apr1$generatedhashhere
```

**Example htpasswd generation:**

```bash
# Install apache2-utils
apt-get install apache2-utils

# Generate password for user "admin"
htpasswd -nb admin securepassword123

# Output: admin:$apr1$hashhashhash...
```

Or use online generator:
https://hostingcanada.org/htpasswd-generator

## Step-by-Step Deployment

### Step 1: Push Updated Files

```bash
cd /home/lthio/moltbot-vps-deployment
git add .
git commit -m "feat: Add Traefik labels for custom domain and password protection"
git push origin master
```

### Step 2: Configure in Dokploy

1. **Open Dokploy Dashboard**
2. **Go to your application** → Settings
3. **Add Environment Variables:**

```bash
# Required
CLAWDBOT_GATEWAY_TOKEN=<your-token>
GOG_KEYRING_PASSWORD=<your-password>
TRAEFIK_DOMAIN=clawbot.yourdomain.com

# Provider keys (as needed)
ANTHROPIC_API_KEY=sk-ant-...
DISCORD_TOKEN=...
# etc...

# Optional (enable password protection)
TRAEFIK_BASIC_AUTH=admin:$apr1$hashhere
```

4. **Redeploy application**

### Step 3: Configure DNS

Point your custom domain to VPS IP:

```
clawbot.yourdomain.com → YOUR_VPS_IP
```

Wait for DNS propagation (usually 5-15 minutes).

### Step 4: Verify Deployment

1. **Open browser:** `https://clawbot.yourdomain.com`
2. **Check:**
   - ✅ HTTPS certificate (Let's Encrypt)
   - ✅ HTTP redirects to HTTPS automatically
   - ✅ Gateway login page appears
   - ✅ Basic auth prompt (if enabled)
3. **Login with:** `CLAWDBOT_GATEWAY_TOKEN`

## Traefik Labels Explained

### Router Labels (HTTP)

```yaml
- "traefik.http.routers.clawdbot-gateway-http.rule=Host(`${TRAEFIK_DOMAIN}`)"
- "traefik.http.routers.clawdbot-gateway-http.entrypoints=web"
- "traefik.http.routers.clawdbot-gateway-http.middlewares=redirect-to-https"
```

- Routes HTTP requests to your domain
- Redirects to HTTPS automatically

### Router Labels (HTTPS)

```yaml
- "traefik.http.routers.clawdbot-gateway-https.rule=Host(`${TRAEFIK_DOMAIN}`)"
- "traefik.http.routers.clawdbot-gateway-https.entrypoints=websecure"
- "traefik.http.routers.clawdbot-gateway-https.tls=true"
- "traefik.http.routers.clawdbot-gateway-https.tls.certresolver=letsencrypt"
```

- Routes HTTPS requests
- Enables automatic SSL certificate
- Uses Let's Encrypt resolver

### Service Labels

```yaml
- "traefik.http.services.clawdbot-gateway.loadbalancer.server.port=18789"
- "traefik.http.services.clawdbot-gateway.loadbalancer.server.scheme=http"
```

- Connects Traefik to container port 18789
- Uses HTTP scheme (Traefik handles HTTPS)

### WebSocket Support

```yaml
- "traefik.http.routers.clawdbot-gateway-https.middlewares=clawdbot-websocket"
- "traefik.http.middlewares.clawdbot-websocket.headers.customrequestheaders.X-Forwarded-Proto=https"
```

- Required for Clawdbot WebSocket connections
- Passes HTTPS protocol to Gateway

### Basic Auth Labels (Optional)

```yaml
- "traefik.http.routers.clawdbot-gateway-https.middlewares=clawdbot-auth"
- "traefik.http.middlewares.clawdbot-auth.basicauth.users=${TRAEFIK_BASIC_AUTH}"
```

- Adds password protection
- Username: `admin` (or whatever you set)
- Password: from htpasswd hash

### HTTP to HTTPS Redirect

```yaml
- "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"
- "traefik.http.middlewares.redirect-to-https.redirectscheme.permanent=true"
```

- Permanent redirect (301)
- Forces HTTPS

## Enabling/Disabling Password Protection

### Enable Password Protection:

1. **Uncomment** in docker-compose.prod.yml:
```yaml
labels:
  - "traefik.http.routers.clawdbot-gateway-https.middlewares=clawdbot-auth"
  - "traefik.http.middlewares.clawdbot-auth.basicauth.users=${TRAEFIK_BASIC_AUTH}"
```

2. **Add** environment variable:
```bash
TRAEFIK_BASIC_AUTH=admin:$apr1$hashhere
```

3. **Redeploy**

### Disable Password Protection:

1. **Comment out** in docker-compose.prod.yml:
```yaml
labels:
  # - "traefik.http.routers.clawdbot-gateway-https.middlewares=clawdbot-auth"
  # - "traefik.http.middlewares.clawdbot-auth.basicauth.users=${TRAEFIK_BASIC_AUTH}"
```

2. **Remove** environment variable (optional)

3. **Redeploy**

## Troubleshooting

### SSL Certificate Not Issuing

```bash
# Check Traefik logs in Dokploy
# Verify DNS points to correct IP
dig +short clawbot.yourdomain.com
```

### WebSocket Not Working

Ensure these headers are set:
```yaml
- "traefik.http.middlewares.clawdbot-websocket.headers.customrequestheaders.X-Forwarded-Proto=https"
```

### Password Not Working

Check the htpasswd format:
- Must be: `username:$apr1$hash`
- Generate with: `htpasswd -nb admin password`
- Or use: https://hostingcanada.org/htpasswd-generator

### Domain Not Resolving

```bash
# Check DNS propagation
dig +short clawbot.yourdomain.com

# Should return your VPS IP
```

Wait 5-15 minutes after DNS changes.

### Traefik 404 Error

Check:
- Domain name matches exactly (no typos)
- DNS propagated
- Environment variable `TRAEFIK_DOMAIN` is set correctly

## Security Checklist

- [ ] HTTPS enabled (Let's Encrypt)
- [ ] HTTP redirects to HTTPS
- [ ] Gateway token is random 32+ chars
- [ ] Basic auth enabled (if password protection needed)
- [ ] Firewall configured (allow 80, 443)
- [ ] Regular backups configured
- [ ] Container running as non-root user
- [ ] Read-only filesystem enabled
- [ ] Resource limits set

## Multiple Domains (Advanced)

To support multiple domains:

```yaml
labels:
  # Domain 1
  - "traefik.http.routers.clawdbot-gateway-https-1.rule=Host(`domain1.com`)"
  - "traefik.http.routers.clawdbot-gateway-https-1.tls=true"
  - "traefik.http.routers.clawdbot-gateway-https-1.tls.certresolver=letsencrypt"

  # Domain 2
  - "traefik.http.routers.clawdbot-gateway-https-2.rule=Host(`domain2.com`)"
  - "traefik.http.routers.clawdbot-gateway-https-2.tls=true"
  - "traefik.http.routers.clawdbot-gateway-https-2.tls.certresolver=letsencrypt"
```

## Support

- Dokploy: https://dokploy.com/docs
- Traefik: https://doc.traefik.io/traefik
- Clawdbot: https://docs.clawd.bot
