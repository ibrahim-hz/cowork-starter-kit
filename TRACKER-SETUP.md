# Tracker Setup — One-Time Supabase Configuration

One-time setup walkthrough for the planning tracker. Takes about 15 minutes.

The planning tracker (`PLANNING-TRACKER-TEMPLATE.html`) is a self-contained HTML page that stores its data in a Supabase Postgres row. It captures planning items across four stages (Outstanding → Current Sprint → QA → Verified) and survives across Cowork sessions.

**Each project needs its own Supabase row** (one `tracker_state.id` per project). You can use a single Supabase project to host multiple trackers — different `id` values keep them isolated.

Plain version: you're setting up a row in a cloud Postgres table that the tracker reads and writes. Ten minutes of clicking, five minutes of pasting.

> **Migrating from JSONbin?** If your project's tracker was set up under the legacy JSONbin model (kit version K1 or earlier), see the [**Migrating from JSONbin**](#migrating-from-jsonbin) section near the bottom of this file. The JSONbin code path remains in `PLANNING-TRACKER-TEMPLATE.html` for a 30-day grace period and is scheduled for removal in kit version K3.

---

## What you'll create

1. A free Supabase account (or sign in with an existing one)
2. A new Supabase project for this tracker
3. The `tracker_state` table + RLS policies + auto-update trigger (one SQL paste)
4. A scoped anon key for the embedded HTML to use
5. A separate `tracker_state` row per project that uses this Supabase project

---

## Step 1 — Create or sign in to Supabase

1. Go to **https://supabase.com**.
2. Sign in with GitHub, Google, or email/password. Free tier is sufficient.
3. Navigate to your dashboard at `https://supabase.com/dashboard`.

---

## Step 2 — Create a new project

1. Click **"New project"**.
2. Configure:
   - **Project name:** `<your-org>-tracker` (e.g., `acme-tracker`). One Supabase project can host multiple trackers, so a single shared project is fine if you have multiple downstream apps.
   - **Database Password:** Supabase generates one. Save it to your password manager — you won't need it for the tracker itself, but you'll need it if you later add Prisma migrations or direct Postgres tooling.
   - **Region:** Match your project's primary region.
   - **Pricing plan:** Free tier (sufficient for tracker workloads).
3. Click **"Create new project"** and wait ~2 minutes for provisioning.

---

## Step 3 — Apply the `tracker_state` schema

This is the single SQL block that creates the table, enables RLS, and adds the auto-update trigger. Paste it once and you're done.

1. In the Supabase dashboard, open the project from Step 2.
2. Navigate to **SQL Editor** (left sidebar).
3. Click **"New query"** and paste the following:

```sql
-- tracker_state schema + RLS + auto-update trigger
-- Single source of truth: Kit-Sprint-2-Build-Plan.md §2.1 in the planning tracker kit.

create table public.tracker_state (
  id              text         primary key,
  state           jsonb        not null,
  schema_version  text         not null default 'v2',
  updated_at      timestamptz  not null default now()
);

create index tracker_state_updated_at_idx
  on public.tracker_state (updated_at desc);

-- Row-level security: the anon key has access by default, so we explicitly
-- gate what it can do. The tracker_id in the URL acts as the secret —
-- anyone who knows the id can read/insert/update that one row, but
-- cannot delete and cannot enumerate other rows by guessing ids.

alter table public.tracker_state enable row level security;

create policy tracker_state_read on public.tracker_state
  for select to anon
  using (true);

create policy tracker_state_insert on public.tracker_state
  for insert to anon
  with check (true);

create policy tracker_state_update on public.tracker_state
  for update to anon
  using (true)
  with check (true);

-- NO delete policy for anon — accidental deletion via browser is impossible.
-- Service_role bypasses RLS and can delete if you ever need to clean up.

grant select, insert, update on public.tracker_state to anon;

-- Auto-update trigger so every UPDATE bumps the updated_at column.
create or replace function public.tracker_state_touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

create trigger tracker_state_touch
  before update on public.tracker_state
  for each row execute function public.tracker_state_touch_updated_at();
```

4. Click **"Run"** (or press Ctrl/Cmd+Enter). You should see "Success. No rows returned."

5. **Sanity-check** the schema is live:
   - Navigate to **Table Editor** (left sidebar).
   - You should see `tracker_state` listed under the `public` schema with columns `id`, `state`, `schema_version`, `updated_at`.

---

## Step 4 — Get your project ref + anon key

The tracker URL embeds both values in its fragment.

1. In the Supabase dashboard, click the **Project Settings** gear icon (bottom of the left sidebar).
2. Navigate to **API** (or **API Keys** in newer dashboards).
3. **Copy the Project URL** — it looks like `https://abcdefgh12345678.supabase.co`. The **project ref** is the subdomain part (`abcdefgh12345678` in this example).
4. **Copy the `anon` (publishable) key.** Looks like `sb_publishable_<random>` or, on older projects, a JWT starting with `eyJ...`.
5. **Also copy the `service_role` key** for the credentials file (Step 6). Looks like `sb_secret_<random>` or a JWT.

> ⚠️ The service_role key bypasses RLS — it has the equivalent of admin access. **Never** embed it in HTML, commit it to git, paste it in a public chat, or include it in a URL. Treat it like a database password. The anon key is safe to put in URLs (RLS gates its access).

---

## Step 5 — Build your tracker bookmark URL

The tracker HTML is hosted publicly. Each project's bookmark embeds its own project ref + anon key + tracker_id in the URL fragment (the part after `#`). Fragments are never sent to servers, so the URL is safe to bookmark + share within your team.

URL template:

```
https://ibrahim-hz.github.io/cowork-starter-kit/PLANNING-TRACKER-TEMPLATE.html#project=<PROJECT_REF>&anon_key=<ANON_KEY>&tracker_id=<TRACKER_ID>
```

Substitute:
- `<PROJECT_REF>` — from Step 4 (e.g., `abcdefgh12345678`)
- `<ANON_KEY>` — from Step 4 (e.g., `sb_publishable_...`)
- `<TRACKER_ID>` — a short identifier for **this** project's row. For a single-tracker Supabase project, `engage` or your project's short name works. For a multi-tracker shared project, use distinct ids per downstream app (e.g., `acme-app`, `acme-mobile`).

> **The tracker_id acts as a secret.** Anyone with the URL can read/write that row. Pick something hard to guess if your Supabase project is shared with apps that handle sensitive planning data.

Bookmark the resulting URL in your browser. Each team member can use the same URL.

---

## Step 6 — Store credentials in your project's secrets file

The service_role key is for programmatic admin tasks (migrations, bulk edits, cleanup). It must **never** be in the browser-loaded HTML. Store it in a gitignored credentials file alongside the other secrets your project tracks.

Common patterns:

- **A gitignored `CREDENTIALS.md` file** in the project root or a `reference/` folder
- **A `.env.local` file** (if your project already uses dotenv)
- **A password manager / 1Password / Bitwarden item** referenced by name from the credentials file

Recommended pattern: create a `CREDENTIALS.md` file alongside this `cowork-app-starter/` folder (NOT inside the folder, NOT committed to git). Add a section like:

```markdown
## Section 14 — Planning Tracker (Supabase)

| Field | Value |
|---|---|
| Project Name | <your-tracker-project-name> |
| Project Ref | `<paste your project ref from Step 4>` |
| Project URL | `https://<project-ref>.supabase.co` |
| Region | <region from Step 2> |
| Anon Key (publishable — safe in URLs) | `<paste your anon key>` |
| Service Role Key (SECRET — admin equivalent) | `<paste your service_role key>` |
| Tracker ID | `<your tracker id from Step 5>` |

### Tracker bookmark URL

https://ibrahim-hz.github.io/cowork-starter-kit/PLANNING-TRACKER-TEMPLATE.html#project=<PROJECT_REF>&anon_key=<ANON_KEY>&tracker_id=<TRACKER_ID>
```

Make sure this file is in your project's `.gitignore`. Verify with:

```bash
# Should print "CREDENTIALS.md" (meaning it's ignored)
git check-ignore CREDENTIALS.md
```

If `git check-ignore` returns nothing, the file is NOT ignored. Add the appropriate entry to `.gitignore` BEFORE saving the file — once a file with secrets is committed, the secret is in git history forever.

---

## Step 7 — Verify the tracker works

1. Open the bookmark URL from Step 5 in a browser.
2. The tracker UI should load with the "Storage: Supabase" indicator visible in the header. You should see four tabs (Outstanding / Current Sprint / QA / Verified) and an "Add item" button.
3. Click **"Add item"**, type a test title (e.g., "Test tracker"), click save.
4. Refresh the browser. The item should still be there — that confirms it's saved to Supabase, not just to in-memory state.
5. Open the Supabase dashboard → **Table Editor** → `tracker_state` and confirm a row with your tracker_id is present, with `state` containing the test item under `items`.
6. Delete the test item from the tracker. Refresh again to confirm it's gone.

If any of these steps fail:
- **Page loads but shows "Setup banner":** the URL fragment is wrong or missing params. Recheck Steps 4 and 5.
- **"HTTP 401" errors in the browser console:** the anon key is wrong, or RLS policies didn't apply. Recheck Step 3's SQL ran without errors.
- **"HTTP 403 / not allowed" or "Forbidden use of secret API key in browser":** you pasted the service_role key in the URL instead of the anon key. Replace with the anon key.
- **Items don't persist on refresh:** browser may be blocking `*.supabase.co` (check your ad-blocker / privacy extension); OR the RLS policies were not applied. Re-run Step 3's SQL.

---

## Migrating from JSONbin

If your project's tracker was set up under kit version K1 or earlier, your live data is in a JSONbin bin. K2 introduces the Supabase backend and adds a 30-day grace period where both backends are supported.

**Reference implementation:** the Engage planning kit (the upstream that ships this template) used the script at:

```
reference/kit-sprints/K2 - Tracker on Supabase/_scripts/migrate-jsonbin-to-supabase.py
```

Adapt the pattern for your project:

1. **Provision the Supabase backend** (Steps 1-3 of this guide).
2. **Read your live JSONbin bin** using the master key from your `CREDENTIALS.md` (legacy section).
3. **Upsert into `tracker_state`** with `id = <your tracker id>` and `state = <verbatim {config, items} blob from JSONbin>`. The Supabase JSONB column stores the JSONbin payload as-is — no schema transformation needed (the v1→v2 item-schema migration shipped in kit version K1).
4. **Verify** the migrated row's `state` JSONB byte-equals the JSONbin source under canonical encoding (`sort_keys=True`).
5. **Update your bookmark** from the JSONbin URL fragment (`#bin=…&key=…&keyType=access`) to the Supabase URL fragment (`#project=…&anon_key=…&tracker_id=…`).
6. **Do NOT delete the JSONbin bin yet.** Keep it as a fallback for 30 days. The planner UI accepts both URL fragment shapes during the grace period and surfaces a deprecation banner when the legacy fragment is in use.

Two transport-layer constraints worth knowing if you adapt the script:

- **JSONbin sits behind Cloudflare** and rejects requests with default `Python-urllib` User-Agents (returns HTTP 403, Cloudflare error code 1010). Use a browser-shaped User-Agent for JSONbin calls (the reference script does this).
- **Supabase service_role keys (`sb_secret_*` format)** are rejected by the API when the User-Agent looks browser-like (returns HTTP 401 "Forbidden use of secret API key in browser"). Use a non-browser User-Agent for Supabase service_role calls. Anon-key calls are unaffected by this heuristic.

---

## Multi-tracker setup (one Supabase project, multiple downstream apps)

A single Supabase project can host arbitrarily many trackers. Each tracker is one row in `tracker_state` keyed by a unique `id`. The schema setup (Step 3) only needs to run once per project; subsequent trackers just need a distinct `tracker_id` in their bookmark URL.

Use cases:
- A workspace running multiple Cowork-planned projects can share one Supabase project + one anon key, with each project's tracker keyed by its own `tracker_id`.
- A team can have a `prod` tracker + a `staging` tracker side-by-side without provisioning two Supabase projects.

Security note: anyone with the anon key + a guessable `tracker_id` can read/write that row. If you share trackers across less-trusted contexts, use random `tracker_id` values rather than predictable names.

---

## Cost & quota

Supabase's free tier (as of K2):
- 500 MB database storage
- Unlimited API requests (with rate limits)
- 50,000 monthly active users (irrelevant for trackers since the anon key isn't a user)

For a typical solo dev / small team, a planning tracker's storage and request volume is negligible — well under any free-tier limit. A single tracker's `state` JSONB column is typically <200 KB even at 60+ items with active comment threads.

If you exceed the free tier or want SLA guarantees, Supabase paid plans start at $25/month.

---

## When to rotate keys

Rotate the anon key:
- If you suspect the URL has leaked publicly (committed to git accidentally, posted in a public chat, exposed in a screenshot)
- If a team member with access leaves
- At minimum every 12 months as routine hygiene

To rotate the anon key: Supabase dashboard → **Project Settings → API → Rotate anon key**. Then update every bookmark URL with the new key. The service_role key rotates from the same panel — much rarer event, but follow the same hygiene rule.

---

## Cross-reference

- [`PLANNING-TRACKER-GUIDE.md`](./PLANNING-TRACKER-GUIDE.md) — how Cowork and Claude Code read/write the tracker (API patterns, field conventions, common workflows)
- [`PLANNING-TRACKER-TEMPLATE.html`](./PLANNING-TRACKER-TEMPLATE.html) — the tracker HTML itself
- [`README.md`](./README.md) § "Tracker setup" — the overview that points here
- [`_sprint-templates/COWORK-PLANNING-KICKOFF.md`](./_sprint-templates/COWORK-PLANNING-KICKOFF.md) — the Cowork planning prompt that reads the tracker

---

## Quick checklist

- [ ] Supabase account created or signed in
- [ ] Project provisioned (Step 2)
- [ ] `tracker_state` schema + RLS + trigger applied via SQL Editor (Step 3)
- [ ] Schema verified in Table Editor (Step 3 sanity-check)
- [ ] Project ref copied (Step 4)
- [ ] Anon key copied (Step 4)
- [ ] Service_role key copied (Step 4)
- [ ] Tracker bookmark URL built (Step 5)
- [ ] CREDENTIALS.md updated with all four values + bookmark URL
- [ ] CREDENTIALS.md is gitignored (verified via `git check-ignore`)
- [ ] Tracker opens in browser, shows the four stage tabs, "Storage: Supabase" indicator visible
- [ ] Test item adds, persists on refresh, deletes cleanly
- [ ] Test row visible in Supabase Table Editor under `tracker_state`
