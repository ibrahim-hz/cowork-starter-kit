# Deployment Workflow — Hostinger VPS

> Rename to `DEPLOYMENT-WORKFLOW.md` after running `PLATFORM-SETUP.md`. Delete the Vercel + Supabase variant.

This file instructs Claude Code on how to handle releases, uploads, branching, and commits for projects deployed to a **Hostinger VPS** with PostgreSQL on the same VPS, Node.js (or Python/Ruby) process management via PM2, nginx as reverse proxy + SSL terminator, and Let's Encrypt for certificates.

Deployment is via **SSH + git-pull + restart pattern**: push to GitHub, SSH into the VPS, pull, run migrations, restart the app process.

Always follow these instructions before executing any release workflow or code upload.

---

## Architecture

| Environment | Git Branch | VPS deployment | Database |
|---|---|---|---|
| **Production** | `main` | Production VPS (Hostinger) | PostgreSQL on same VPS |
| **Staging** | `develop` | Staging VPS OR staging subdomain on production VPS | Separate database on same VPS, OR separate VPS |
| **Local dev** | feature/* branches | Developer machine | Local PostgreSQL or Docker |

**Why this topology:**
- Hostinger VPS provides full Ubuntu server access at low cost ($5–$15/month range)
- Co-locating PostgreSQL on the same VPS keeps latency near-zero and avoids managed-database costs
- PM2 keeps the app process alive across reboots + provides log rotation + cluster mode
- nginx provides SSL termination, reverse-proxy, and serves static assets
- Let's Encrypt + certbot auto-renew SSL certificates every 90 days

**Credentials location:** wherever your project documents secrets (see `PROJECT-PLANNING.md` § "Credentials location"). SSH keys, database passwords, and API tokens all live there — never committed.

---

## Load-bearing VPS invariants — do NOT change without a retro

These configurations are load-bearing. Drift breaks production.

1. **PM2 ecosystem file (`ecosystem.config.js` or equivalent) is the source of truth for process configuration.** Do NOT manually start the app via `node` or `npm` for production — always via `pm2 start ecosystem.config.js`.
2. **nginx config lives at `/etc/nginx/sites-available/<your-domain>` and is symlinked to `sites-enabled/`.** Editing live config without test-then-reload risks taking the server down.
3. **Database backups MUST be automated.** A daily `pg_dump` cron job to a backup volume (or off-VPS storage via rsync/rclone) is non-negotiable.
4. **Firewall (ufw or iptables) allows only ports 22 (SSH), 80 (HTTP), 443 (HTTPS).** PostgreSQL port 5432 is bound to localhost ONLY — never exposed publicly.
5. **certbot auto-renewal cron is active.** Verify with `certbot renew --dry-run`. If certificates expire, all HTTPS traffic breaks at 90-day intervals.

---

## Repo prerequisites — one-time setup

### GitHub repo settings

- [x] **Default branch: `develop`** — feature branches fork from here
- [ ] **Allow auto-merge** — plan-gated; if unavailable, compensating control is the hardcoded merge step in §3.6.1
- [x] **Delete branches automatically: OFF** — per-PR `--delete-branch` covers explicit cleanup; the repo-level toggle would force the same behavior on `main` and `develop` where it's not wanted

### VPS-side one-time setup

After provisioning the VPS, complete these steps (see `PLATFORM-SETUP.md` Step 2B for the full walkthrough). Summary:

1. **Base packages installed:** `curl`, `git`, `nodejs` (or your language runtime), `postgresql`, `nginx`, `certbot`, `pm2`, `build-essential`
2. **PostgreSQL configured:** dedicated user + database created, password stored in credentials file, `listen_addresses` confirmed as `localhost` only
3. **App cloned to `/var/www/<project>/` (or your chosen path)**
4. **Dependencies installed:** `npm install` (or `pip install -r requirements.txt`, `bundle install`, etc.)
5. **Initial migration applied:** project-specific migration command
6. **PM2 process started + `pm2 startup` + `pm2 save`** so the app survives reboots
7. **nginx reverse-proxy configured** for your domain
8. **SSL certificate via certbot** for HTTPS

### SSH access conventions

- Production VPS: each developer has their own SSH key registered in `/home/<deploy-user>/.ssh/authorized_keys` (NOT shared accounts)
- `deploy-user` should be a non-root user with `sudo` for nginx + pm2 operations (NOT full root)
- Use SSH config aliases in `~/.ssh/config` for shorter commands: `Host prod-vps  HostName <ip>  User <deploy-user>  IdentityFile ~/.ssh/id_ed25519_prod`

### Database password discipline

The PostgreSQL password for the app user is the most security-sensitive secret in this topology:

- Stored in credentials file (gitignored)
- Stored in PM2 environment via `ecosystem.config.js` `env` block (with the config file gitignored, OR using PM2's env variable interpolation from a secrets file)
- Should be 24+ characters, fully random (e.g., `openssl rand -base64 24`)
- Rotated at minimum every 12 months, or when any team member with access leaves

---

## CI/CD pipeline

Deployment is **NOT automatic on git push** (unlike Vercel). The pattern is git-pull + restart, triggered by Claude Code via SSH.

### GitHub Actions workflows (this repo)

These run on `pull_request` and `push` to `develop` and `main`. They do NOT deploy — they verify:

- **Lint** — runs your project's linter
- **Test** — runs unit tests
- **Build** — verifies the build succeeds (catches type errors, compile errors)
- **E2E** (optional) — runs Playwright against a staging URL (configure when staging is reachable)

### Deploy step (manual, via SSH)

After CI is green and the merge to `main` (production) or `develop` (staging) is complete, Claude Code SSHes into the VPS and runs the deploy:

```bash
ssh deploy-user@prod-vps "cd /var/www/<project> && \
  git fetch origin && \
  git reset --hard origin/main && \
  <package-install-command> && \
  <build-command> && \
  <migration-command> && \
  pm2 restart <app-name> && \
  pm2 logs <app-name> --lines 20 --nostream"
```

Adapt to your stack:

- Node.js: `npm install && npm run build && npx prisma migrate deploy && pm2 restart <app>`
- Django: `pip install -r requirements.txt && python manage.py collectstatic --noinput && python manage.py migrate && pm2 restart <app>`
- Rails: `bundle install && bundle exec rails assets:precompile && bundle exec rails db:migrate && pm2 restart <app>`

### Deploy script pattern

For repeatability, codify the deploy command in `scripts/deploy.sh` (committed to the repo):

```bash
#!/bin/bash
# scripts/deploy.sh — deploys current branch to the specified environment
# Usage: ./scripts/deploy.sh prod
#        ./scripts/deploy.sh staging

set -euo pipefail
ENV="${1:?usage: deploy.sh <prod|staging>}"

case "$ENV" in
  prod)    SSH_HOST="prod-vps";    BRANCH="main";    APP="<your-app-prod>"    ;;
  staging) SSH_HOST="staging-vps"; BRANCH="develop"; APP="<your-app-staging>" ;;
  *) echo "unknown env: $ENV"; exit 1 ;;
esac

ssh "$SSH_HOST" "cd /var/www/<project> && \
  git fetch origin && \
  git reset --hard origin/$BRANCH && \
  <install-deps> && \
  <build-cmd> && \
  <migrate-cmd> && \
  pm2 restart $APP && \
  pm2 logs $APP --lines 20 --nostream"
```

Claude Code invokes `./scripts/deploy.sh prod` (or staging) during the release flow.

---

## Self-service tokens / credentials

Tokens needed for the deployment workflow:

- SSH key(s) for production + staging VPS access (in `~/.ssh/`)
- PostgreSQL database password (in credentials file, NOT committed)
- Any third-party API keys your app uses (Stripe, SendGrid, OAuth providers, etc. — in `ecosystem.config.js` env block or in `.env.production` on the VPS)
- `SENTRY_DSN` and `SENTRY_AUTH_TOKEN` if you ship Sentry

Resolve via env-first (in PM2's env block on the VPS), credentials-file-second (locally). Tokens NEVER echo to stderr or log files.

---

## Auth provider redirect allow-list (if using Supabase Auth or similar)

Even on a self-hosted Hostinger VPS, you may still use a hosted auth provider (Supabase Auth, Auth0, Clerk, etc.). If so:

Any new auth-redirect destination — any new `redirectTo` argument value — MUST be added to the auth provider's allowed redirect URL list before traffic hits the new redirect. The procedure depends on the provider:

- **Supabase Auth:** PATCH `https://api.supabase.com/v1/projects/$SUPABASE_REF/config/auth` with updated `uri_allow_list`
- **Auth0:** update Application's "Allowed Callback URLs" list in the dashboard
- **Clerk:** update redirect URLs in the dashboard

Add an end-to-end test asserting the new redirect target actually lands the user on the intended page.

If your auth is fully self-hosted (rolled your own JWT, no third-party auth provider), this section doesn't apply — you can delete it.

---

## Release process — information gathering

Before ANY deployment, follow the release Q&A. Read this entire section before starting.

### Pre-question code analysis

Before asking any questions, Claude Code must first analyze the code being deployed:

1. **Run `git diff develop...HEAD`** (or `git status`) — identify all files changed, added, deleted
2. **Review project state** — check `package.json` (or equivalent) version, review schema for changes, look at recent commits
3. **Classify features** — mark each as COMPLETE or WIP
4. **Flag risks** — schema migrations, breaking changes, secrets accidentally included
5. **Present findings** to the user in a clear summary before proceeding to questions

### Questions 0-6 (ask in order, wait for answers)

| # | Question |
|---|----------|
| 0 | **Is this release for STAGING or PRODUCTION?** |
| 1 | **What type of release is this?** (Alpha / Beta / Feature / Patch / Hotfix) |
| 2 | **What is the target version number?** |
| 3 | **Write a brief summary of what changed** |
| 4 | **List the major features and fixes** |
| 5 | **Are there any BREAKING CHANGES?** |
| 6 | **Should this be merged back to develop?** |

### Execution steps (after all questions answered)

**CRITICAL: Follow the correct path based on Question 0. NEVER merge to `main` for a staging release.**

**If Question 0 = STAGING:**

1. Ensure all work is committed and pushed to `develop`
2. Update `package.json` (or equivalent) version to the pre-release version
3. Commit: `chore(release): bump version to vX.Y.Z-alpha.N`
4. Push to `develop`
5. Wait for CI (GitHub Actions) to pass
6. Run `./scripts/deploy.sh staging` (or equivalent SSH-based deploy)
7. Create a GitHub Pre-release from the `develop` branch with the pre-release tag
8. Run post-deploy verification (next section)
9. Print the GitHub Release URL and the staging URL

**DO NOT** create a release branch. **DO NOT** merge to `main`. Staging releases never touch production.

**If Question 0 = PRODUCTION:**

The code MUST have been tested on staging first.

1. Checkout `develop`, create `release/vX.Y.Z` branch
2. Update version to the production version
3. Commit: `chore(release): bump version to vX.Y.Z`
4. Create PR from `release/vX.Y.Z` → `main` with changelog body
5. Wait for CI to pass
6. Merge PR with merge commit (no squash)
7. Tag `main` with `vX.Y.Z`, push tag
8. Delete the release branch (local + remote)
9. Run `./scripts/deploy.sh prod` (SSH-based deploy to production VPS)
10. Create GitHub Release from the tag
11. Back-merge `main` → `develop` (mandatory; see PROJECT-PLANNING.md §3.7)
12. Run post-deploy verification (next section)
13. Print the GitHub Release URL and the production URL

---

## Post-deployment verification

After the deploy command completes, Claude Code must verify:

### 1. PM2 process is running

```bash
ssh prod-vps "pm2 list"
# Should show your app process with status "online" and 0 restarts since last deploy
```

### 2. App responds on the production URL

```bash
curl -sSI https://<your-prod-domain>/ | head -1
# Expect: HTTP/2 200 (or HTTP/1.1 200 OK)

curl -sS https://<your-prod-domain>/api/health
# If your app has a /api/health endpoint, expect a 200 with success status
```

### 3. Critical routes respond

```bash
# Adapt to your app's critical routes
curl -s -o /dev/null -w "%{http_code}\n" https://<your-prod-domain>/login      # 200 expected
curl -s -o /dev/null -w "%{http_code}\n" https://<your-prod-domain>/dashboard  # 200 or 302 expected
```

### 4. No new errors in app logs

```bash
ssh prod-vps "pm2 logs <app-name> --lines 50 --nostream | grep -iE 'error|fatal|exception'"
# Should return empty (or only known-benign warnings)
```

### 5. Database connection healthy

```bash
ssh prod-vps "sudo -u postgres psql -d <your-app-db> -c '\dt' | head -5"
# Should list tables — confirms DB is reachable from the VPS
```

### 6. SSL certificate is valid

```bash
echo | openssl s_client -servername <your-prod-domain> -connect <your-prod-domain>:443 2>/dev/null \
  | openssl x509 -noout -dates
# Should show notAfter date at least 30 days in the future
```

### 7. Report

Print a deployment confirmation:

```
═══════════════════════════════════════
DEPLOYMENT COMPLETE
═══════════════════════════════════════
Version: vX.Y.Z
Environment: [Staging / Production]
URL: [URL]
Tag: vX.Y.Z
GitHub Release: [URL]
PM2 process: ✅ online (0 restarts)
Critical routes: ✅ all responding
Database: ✅ connected
SSL: ✅ valid until <date>
═══════════════════════════════════════
```

---

## Rollback

If a deployment causes issues:

### Staging rollback

Push a revert commit to `develop`:

```bash
git revert <bad-commit-sha>
git push origin develop
./scripts/deploy.sh staging
```

### Production rollback

Two options, in order of preference:

**Option 1: git revert + redeploy** (cleanest)

```bash
git checkout main
git revert <bad-commit-sha>
git push origin main
./scripts/deploy.sh prod
```

**Option 2: deploy a prior commit directly** (faster but messier)

```bash
# Find the last known-good commit SHA
git log --oneline main

# Deploy that specific commit
ssh prod-vps "cd /var/www/<project> && \
  git fetch origin && \
  git reset --hard <good-commit-sha> && \
  <install-deps> && \
  <build-cmd> && \
  pm2 restart <app-name>"

# Then follow up with a proper git revert on main so source-of-truth matches deploy
```

### Database rollback

PostgreSQL migrations don't auto-rollback. If schema rollback is needed:

1. Write the inverse migration manually (each migration commit should include a comment with the rollback SQL — see QA-STANDARDS.md §4)
2. Apply via psql:
   ```bash
   ssh prod-vps "sudo -u postgres psql -d <your-app-db> -c '<inverse-SQL>'"
   ```
3. As a last resort: restore from the most recent backup:
   ```bash
   ssh prod-vps "sudo -u postgres psql -d <your-app-db> < /backups/<your-app-db>-<date>.sql"
   ```
   This will lose any data written since the backup. Coordinate with users if data loss is non-trivial.

---

## Database backups

Critical for VPS-hosted databases. Set up ONCE during initial server setup, verify monthly.

### Automated daily backup

Add to deploy-user's crontab (`crontab -e`):

```bash
# Daily PostgreSQL dump at 03:00 UTC
0 3 * * * sudo -u postgres pg_dump <your-app-db> | gzip > /backups/<your-app-db>-$(date +\%Y\%m\%d).sql.gz

# Retention: keep last 30 daily backups, prune older
0 4 * * * find /backups -name "<your-app-db>-*.sql.gz" -mtime +30 -delete
```

### Off-VPS backup (recommended)

Daily local backup is good; off-VPS is better (protects against VPS-level failures). Common patterns:

- **rsync to a separate VPS** in a different region
- **rclone to S3 / Backblaze B2 / Google Drive** ($1–$5/month)
- **Hostinger's own backup service** if available on your plan

### Verify the backup actually restores

Monthly drill: spin up a temporary database, restore from the most recent backup, verify a few key tables have expected data. A backup you've never tested is not a backup.

---

## Monitoring

Hostinger VPS doesn't include automatic monitoring. Set up:

### Process monitoring (PM2)

```bash
pm2 monitor          # Real-time process status
pm2 logs <app>       # Live log tail
```

For longer-term: `pm2 install pm2-logrotate` rotates logs daily so the VPS disk doesn't fill up.

### Server resource monitoring

```bash
# Basic CPU + memory + disk:
ssh prod-vps "top -bn1 | head -20; echo; df -h; echo; free -h"
```

For longer-term: install `htop`, `vnstat` for network, and consider lightweight monitoring like Netdata (`apt install netdata`) for a self-hosted dashboard.

### Application error tracking (Sentry, if wired)

Configure Sentry's Node/Python/Ruby SDK in your app code. Configure `SENTRY_DSN` in PM2's env block. Errors are sent to Sentry without VPS-side configuration.

---

## Sprint Completion ceremony

After all prompts complete and the final test runs are green, Sprint Completion produces FIVE canonical deliverables:

1. `.claude-code-status/last-response.md` — mid-cutover scratchpad with full evidence trail + final summary
2. `.claude-code-status/sprint-progress.json` — structured handoff with `current_prompt`, `prompts[]` array, `completion_state`, `prod_cutover` block (if cutover ran), `sprint_<N+1>_carryovers[]` array
3. `<N> - <theme>/RETRO.md` — canonical retrospective
4. `<N> - <theme>/CARRYOVER.md` — canonical carryover (only if anything deferred)
5. `C - Bugs/BACKLOG.md` — updated to reflect any newly-filed BUGs (status: open) + any newly-fixed BUGs (moved to Recently-fixed table)

### Direct-DB verification gate for prod-side mutation claims

Any `.claude-code-status/sprint-progress.json` write claiming a prod-side mutation succeeded MUST be gated on direct-DB verification. Two fields make the gate auditable:

1. **`verified_via`** — names the verification mechanism (e.g., `"ssh-pg-query"`, `"prisma-prod.sh-validate"`).
2. **`verification_response`** — the raw query output, captured verbatim (truncated only if response exceeds ~4 KB).

The verification query MUST be a **positive-presence check**. Negative-absence checks ("the migration command returned no error") are NOT sufficient.

If verification fails, the closure ceremony **halts**. Resolve drift before STEP 16 can produce its 5 deliverables.

### Sentry sanity ceremony (if Sentry is wired)

After production deploy, query Sentry API directly for issues matching the just-deployed release SHA. The verification mechanism is `Sentry-API-direct`. The strong-verification assertion is `latestEvent.release === <merge-sha>` (exact match against the just-merged main SHA).

This is positive-presence: PASSES when API response contains an issue with matching release tag, FAILS when response is empty or release doesn't match.

---

## Cross-reference

- `PROJECT-PLANNING.md` Phase 3 — high-level deployment orchestration
- `QA-STANDARDS.md` — per-prompt + per-sprint QA discipline
- `BEFORE-LAUNCH-CHECKLIST.md` — operational items that must close before public launch
- `CLAUDE-CODE-RUNBOOK.md` — production incident triage table
- `_sprint-templates/KICKOFF-PROMPT.md` — Claude Code build-phase kickoff that references this file
- `PLATFORM-SETUP.md` (deleted after install) — original platform picker
