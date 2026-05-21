# Platform Setup — One-Time Vercel/Supabase vs Hostinger VPS Picker

One-time setup walkthrough. Takes about 5 minutes.

The kit ships with two deployment workflow variants:

- **Vercel + Supabase** — hosted Next.js (or similar) on Vercel with Supabase Postgres + Auth. Auto-deploy on git push. Best for fast iteration, low ops overhead.
- **Hostinger VPS** — self-hosted on a Hostinger VPS (Ubuntu 22/24) with PostgreSQL on the same VPS, deployed via git-pull + PM2 + nginx + Let's Encrypt. Best for cost control, full server access, long-running background workers.

You pick one. The picked variant becomes your canonical `DEPLOYMENT-WORKFLOW.md`. The other is deleted from your project so there's no ambiguity.

---

## Step 1 — Choose your platform

Answer this question for your project:

> **Will this project deploy to Vercel + Supabase, or to a Hostinger VPS?**

The choice depends on:

| Factor | Vercel + Supabase | Hostinger VPS |
|---|---|---|
| Speed to first deploy | Very fast (git push = deploy) | Moderate (one-time server setup) |
| Monthly cost (small project) | ~$0–$25 (free tier covers a lot) | ~$5–$15 VPS + $0 database (same server) |
| Ops overhead | Near-zero | Real — you manage Ubuntu, nginx, certbot, backups |
| Long-running background workers | Limited (Edge runtime constraints, function timeouts) | Full Node.js / Python / Ruby process control |
| Database under your control | No (Supabase managed) | Yes (PostgreSQL on the VPS) |
| Auto preview URLs per PR | Yes (Vercel does this automatically) | Manual setup (separate VPS or subdomain config) |
| Real-time / WebSockets | Supabase Realtime handles it | You set up your own (Socket.io, etc.) |
| Vendor lock-in concerns | Moderate (Vercel + Supabase APIs) | Low (everything is open infrastructure) |

**Common choice:** if you're solo or small team building a SaaS / web app and want to ship fast, **Vercel + Supabase**. If you need a long-running background worker, full server access, or have strict cost limits at scale, **Hostinger VPS**.

If you're unsure, default to **Vercel + Supabase**. Migrating later is doable; starting simple is cheaper than over-engineering.

---

## Step 2A — IF you chose Vercel + Supabase

Run these commands from inside `cowork-app-starter/` (or wherever the kit lives in your project):

```bash
# 1. Rename the Vercel variant to the canonical name
mv STARTER-DEPLOYMENT-WORKFLOW-vercel-supabase.md DEPLOYMENT-WORKFLOW.md

# 2. Delete the Hostinger variant (you won't need it)
rm STARTER-DEPLOYMENT-WORKFLOW-hostinger-vps.md

# 3. (Optional) Verify
ls -la *DEPLOYMENT-WORKFLOW*
# Should show ONLY: DEPLOYMENT-WORKFLOW.md
```

**Then complete the Vercel + Supabase initial setup:**

1. Create a Vercel account and project at https://vercel.com.
2. Create a Supabase project (one for staging, one for production) at https://supabase.com.
3. Connect your git repo to Vercel.
4. Add environment variables to Vercel:
   - `DATABASE_URL` (Supabase pooled connection)
   - `DIRECT_URL` (Supabase direct connection — for migrations)
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `SUPABASE_SERVICE_ROLE_KEY`
5. Read the now-renamed `DEPLOYMENT-WORKFLOW.md` for the full conventions (branch strategy, release Q&A, post-deploy verification, rollback). You'll come back to it every release.

**Cross-references to delete or fix:**
- Cowork may have generated cross-references to `STARTER-DEPLOYMENT-WORKFLOW-vercel-supabase.md` in other kit files. After rename, do a project-wide find-replace:
  - `STARTER-DEPLOYMENT-WORKFLOW-vercel-supabase.md` → `DEPLOYMENT-WORKFLOW.md`
  - `STARTER-DEPLOYMENT-WORKFLOW-hostinger-vps.md` → (remove the reference; this variant is gone)

```bash
# Find any remaining references that need updating
grep -r "STARTER-DEPLOYMENT-WORKFLOW" . --include="*.md"
```

---

## Step 2B — IF you chose Hostinger VPS

Run these commands from inside `cowork-app-starter/` (or wherever the kit lives):

```bash
# 1. Rename the Hostinger variant to the canonical name
mv STARTER-DEPLOYMENT-WORKFLOW-hostinger-vps.md DEPLOYMENT-WORKFLOW.md

# 2. Delete the Vercel variant
rm STARTER-DEPLOYMENT-WORKFLOW-vercel-supabase.md

# 3. (Optional) Verify
ls -la *DEPLOYMENT-WORKFLOW*
# Should show ONLY: DEPLOYMENT-WORKFLOW.md
```

**Then complete the Hostinger VPS initial setup:**

1. Provision a Hostinger VPS (Ubuntu 22.04 or 24.04 recommended).
2. SSH into the VPS as root or a sudo user.
3. Install foundational tools:
   ```bash
   apt update && apt upgrade -y
   apt install -y curl git build-essential nginx certbot python3-certbot-nginx
   curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
   apt install -y nodejs postgresql postgresql-contrib
   npm install -g pm2
   ```
4. Configure PostgreSQL:
   ```bash
   sudo -u postgres psql
   # Inside psql:
   CREATE USER <your-app-db-user> WITH PASSWORD '<strong-random-password>';
   CREATE DATABASE <your-app-db> OWNER <your-app-db-user>;
   GRANT ALL PRIVILEGES ON DATABASE <your-app-db> TO <your-app-db-user>;
   \q
   ```
5. Clone your project's repo to the VPS:
   ```bash
   cd /var/www  # or wherever you keep app code
   git clone <your-repo-url> <project-name>
   cd <project-name>
   ```
6. Install dependencies + run initial migration:
   ```bash
   npm install
   # Run your project's migration command (e.g., `npx prisma migrate deploy`, `python manage.py migrate`, `bundle exec rails db:migrate`)
   ```
7. Configure PM2:
   ```bash
   pm2 start npm --name "<project-name>" -- start
   pm2 startup  # enables auto-restart on VPS reboot — follow printed instructions
   pm2 save
   ```
8. Configure nginx as a reverse proxy:
   ```bash
   # Create /etc/nginx/sites-available/<your-domain>:
   server {
     listen 80;
     server_name <your-domain>.com www.<your-domain>.com;

     location / {
       proxy_pass http://localhost:3000;  # or whatever port your app runs on
       proxy_http_version 1.1;
       proxy_set_header Upgrade $http_upgrade;
       proxy_set_header Connection 'upgrade';
       proxy_set_header Host $host;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_cache_bypass $http_upgrade;
     }
   }

   # Then:
   ln -s /etc/nginx/sites-available/<your-domain> /etc/nginx/sites-enabled/
   nginx -t  # verify config
   systemctl reload nginx
   ```
9. Get SSL certificate via Let's Encrypt:
   ```bash
   certbot --nginx -d <your-domain>.com -d www.<your-domain>.com
   # Follow prompts — will auto-update nginx config to serve HTTPS
   ```
10. Verify the app is reachable at https://<your-domain>.com.

11. Read the now-renamed `DEPLOYMENT-WORKFLOW.md` for the full conventions (git-pull deploy flow, release Q&A, post-deploy verification, rollback). You'll come back to it every release.

**Cross-references to delete or fix:**
```bash
grep -r "STARTER-DEPLOYMENT-WORKFLOW" . --include="*.md"
# Update any remaining references:
#   STARTER-DEPLOYMENT-WORKFLOW-hostinger-vps.md → DEPLOYMENT-WORKFLOW.md
#   STARTER-DEPLOYMENT-WORKFLOW-vercel-supabase.md → (remove, this variant is gone)
```

---

## Step 3 — Delete this file (PLATFORM-SETUP.md) after completion

PLATFORM-SETUP.md is a one-time picker. Once you've completed setup, this file's job is done.

```bash
rm PLATFORM-SETUP.md
```

Or keep it as historical reference if you prefer — your call. It doesn't affect anything operational.

---

## Reverse / change platform later

If you initially picked one platform and want to switch:

1. **Don't lose your release history.** Your current `DEPLOYMENT-WORKFLOW.md` has been customized over time. Save a copy before overwriting:
   ```bash
   cp DEPLOYMENT-WORKFLOW.md DEPLOYMENT-WORKFLOW-old-<date>.md.bak
   ```
2. Pull the alternative variant from the kit's git history:
   ```bash
   # Find the original (pre-rename) variant in git history
   git log --all --oneline -- "STARTER-DEPLOYMENT-WORKFLOW-vercel-supabase.md" "STARTER-DEPLOYMENT-WORKFLOW-hostinger-vps.md"
   # Check out the variant you want:
   git show <commit>:cowork-app-starter/STARTER-DEPLOYMENT-WORKFLOW-hostinger-vps.md > DEPLOYMENT-WORKFLOW.md
   ```
   Or download fresh from the kit's source if you can't recover from git history.
3. Reconcile any customizations from the `.bak` file you saved.
4. Update cross-references again.
5. Plan the actual infrastructure migration (database export/import, DNS changes, etc.) — that's substantially more work than swapping the workflow doc.

---

## Cross-reference

- [`README.md`](./README.md) § "Platform setup" — the overview that points here
- After this setup completes, `DEPLOYMENT-WORKFLOW.md` becomes your canonical release-process document for the project
- [`STARTER-PROJECT-PLANNING.md`](./STARTER-PROJECT-PLANNING.md) Phase 3 — references your now-renamed `DEPLOYMENT-WORKFLOW.md`

---

## Quick checklist

- [ ] Platform chosen (Vercel + Supabase OR Hostinger VPS)
- [ ] Correct `STARTER-DEPLOYMENT-WORKFLOW-*.md` renamed to `DEPLOYMENT-WORKFLOW.md`
- [ ] Other `STARTER-DEPLOYMENT-WORKFLOW-*.md` deleted
- [ ] Cross-references in other kit files updated (find-replace)
- [ ] Vercel project + Supabase projects created (if Vercel path) OR VPS provisioned + base packages installed (if Hostinger path)
- [ ] App reachable at production URL (or staging URL initially)
- [ ] `PLATFORM-SETUP.md` deleted (or retained as historical reference)
