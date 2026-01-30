# Password Protection Guide for Dokploy

Simple guide to add password protection to Clawdbot Gateway when using Dokploy.

Dokploy handles:
- ✅ Custom domain routing
- ✅ HTTPS/SSL certificates (Let's Encrypt)
- ✅ HTTP to HTTPS redirect

This guide only covers:
- 🔐 Password protection for the dashboard

## Quick Start

### 1. Generate Password Hash

Choose one of these methods:

#### Method A: Command Line (Recommended)

```bash
# Install apache2-utils
apt-get install apache2-utils

# Generate password for user "admin"
htpasswd -nb admin yourpassword

# Output: admin:$apr1$hashhashhash...
```

#### Method B: Online Generator

1. Go to: https://hostingcanada.org/htpasswd-generator
2. Enter:
   - Username: `admin` (or your preferred username)
   - Password: your secure password
3. Click "Generate"
4. Copy the output: `admin:$apr1$hashhashhash...`

### 2. Enable Password Protection

In `docker-compose.prod.yml`, uncomment these lines:

```yaml
labels:
  # Uncomment these lines to enable password protection:
  - "traefik.http.routers.clawdbot-gateway.middlewares=clawdbot-auth"
  - "traefik.http.middlewares.clawdbot-auth.basicauth.users=${TRAEFIK_BASIC_AUTH}"
```

### 3. Add Environment Variable in Dokploy

```bash
# Use the hash generated in step 1
TRAEFIK_BASIC_AUTH=admin:$apr1$hashhashhash...
```

### 4. Redeploy in Dokploy

Click **Redeploy** or **Deploy** button.

## How It Works

### Without Password Protection (Default)

1. User visits: `https://clawbot.yourdomain.com`
2. Direct access to Clawdbot Gateway dashboard
3. Login with: `CLAWDBOT_GATEWAY_TOKEN`

### With Password Protection

1. User visits: `https://clawbot.yourdomain.com`
2. **Password prompt appears** (basic auth)
3. User enters: `admin` + `yourpassword`
4. Then access to Clawdbot Gateway dashboard
5. Login with: `CLAWDBOT_GATEWAY_TOKEN`

**Two layers of security:**
1. Basic auth (username + password)
2. Gateway token (for API access)

## Disable Password Protection

To remove password protection:

1. Comment out lines in `docker-compose.prod.yml`:

```yaml
labels:
  # Comment out these lines:
  # - "traefik.http.routers.clawdbot-gateway.middlewares=clawdbot-auth"
  # - "traefik.http.middlewares.clawdbot-auth.basicauth.users=${TRAEFIK_BASIC_AUTH}"
```

2. Remove environment variable (optional)

3. Redeploy

## Change Password

To change password:

1. Generate new hash:
   ```bash
   htpasswd -nb admin newpassword
   ```

2. Update `TRAEFIK_BASIC_AUTH` environment variable in Dokploy

3. Redeploy

## Multiple Users

To add multiple users, generate hashes for each:

```bash
htpasswd -nb admin password1
htpasswd -nb user2 password2
```

Add to environment variable:
```bash
TRAEFIK_BASIC_AUTH=admin:$apr1$hash1...:user2:$apr1$hash2...
```

## Troubleshooting

### Password Not Working

**Check 1:** Verify hash format
```
✅ Correct: admin:$apr1$hashhashhash...
❌ Wrong: admin:plaintextpassword
❌ Wrong: admin:$2a$hashhashhash... (wrong hash type)
```

**Check 2:** Verify labels are uncommented
```yaml
# Must be uncommented (no # at start)
- "traefik.http.routers.clawdbot-gateway.middlewares=clawdbot-auth"
```

**Check 3:** Environment variable set
- Verify `TRAEFIK_BASIC_AUTH` is added in Dokploy
- Verify it has the correct hash value

### Still Can Access Without Password

1. Check if labels are properly uncommented
2. Redeploy (not just restart)
3. Clear browser cache
4. Try in incognito/private window

### Wrong Credentials Error

1. Verify username matches (default: `admin`)
2. Regenerate hash with correct password
3. Update environment variable
4. Redeploy

## Security Best Practices

- [ ] Use strong password (12+ characters, mixed case, numbers, symbols)
- [ ] Change password regularly
- [ ] Don't share `TRAEFIK_BASIC_AUTH` value (it contains hash)
- [ ] Keep `CLAWDBOT_GATEWAY_TOKEN` separate and strong
- [ ] Use different passwords for basic auth and gateway token
- [ ] Monitor access logs in Dokploy

## Complete Example

### docker-compose.prod.yml (password enabled)

```yaml
services:
  clawdbot-gateway:
    # ... (other config)

    labels:
      # Traefik enable
      - "traefik.enable=true"

      # Service config
      - "traefik.http.services.clawdbot-gateway.loadbalancer.server.port=18789"
      - "traefik.http.services.clawdbot-gateway.loadbalancer.server.scheme=http"

      # Password protection (ENABLED)
      - "traefik.http.routers.clawdbot-gateway.middlewares=clawdbot-auth"
      - "traefik.http.middlewares.clawdbot-auth.basicauth.users=${TRAEFIK_BASIC_AUTH}"
```

### Environment Variables in Dokploy

```bash
# Required
CLAWDBOT_GATEWAY_TOKEN=<random-32-char-hex>
GOG_KEYRING_PASSWORD=<random-32-char-hex>

# Password protection
TRAEFIK_BASIC_AUTH=admin:$apr1$hashhashhash...

# Provider keys
# ANTHROPIC_API_KEY=sk-ant-...
# DISCORD_TOKEN=...
```

## Support

- Dokploy: https://dokploy.com/docs
- htpasswd: https://httpd.apache.org/docs/current/programs/htpasswd.html
- Clawdbot: https://docs.clawd.bot
