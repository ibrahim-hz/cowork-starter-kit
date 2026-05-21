# Tracker Setup — One-Time JSONbin Configuration

One-time setup walkthrough for the planning tracker. Takes about 10 minutes.

The planning tracker (`PLANNING-TRACKER-TEMPLATE.html`) is a self-contained HTML page that stores its data in a JSONbin.io bin. It captures planning items across four stages (Outstanding → Current Sprint → QA → Verified) and survives across Cowork sessions.

**Each project needs its own JSONbin bin.** Do NOT reuse a bin across projects — items will collide and overwrite each other.

Plain version: you're setting up a tiny cloud-hosted JSON file that the tracker reads and writes. Five minutes of clicking, five minutes of pasting.

---

## What you'll create

1. A free JSONbin.io account (or sign in with an existing one)
2. A new private bin for this project's tracker data
3. A scoped Access Key (Read + Update only) for the embedded HTML to use
4. The Master Key (full account access) for Claude Cowork / Claude Code to use programmatically

---

## Step 1 — Create or sign in to JSONbin.io

1. Go to **https://jsonbin.io**.
2. Sign in with Google, GitHub, or email/password. Free tier is sufficient.
3. Navigate to your account dashboard.

---

## Step 2 — Get your Master Key

1. In the JSONbin dashboard, find the **"API Keys"** section.
2. Locate the **Master Key** (usually starts with `$2a$10$...`).
3. **Copy it.** You'll paste it into your project's credentials file in Step 6.

> ⚠️ The Master Key has full access to your entire JSONbin account. Do NOT embed it in the HTML or commit it to git. Treat it like a database password.

---

## Step 3 — Create a new bin for this project

1. In the JSONbin dashboard, click **"Create Bin"** (or **"+ New Bin"**).
2. Paste this **initial empty payload** into the bin body:

```json
{
  "config": {
    "roles": ["User", "Admin"],
    "pages": [],
    "features": [],
    "types": ["Bug", "Feature", "Polish", "Refactor"],
    "priorities": ["Yes", "No"],
    "statuses": ["Outstanding", "Current Sprint", "QA", "Verified"],
    "nextSprintNumber": 1
  },
  "items": []
}
```

3. Set bin metadata:
   - **Name:** `<your-project-name>-planning-tracker` (e.g., `myapp-planning-tracker`)
   - **Private:** YES (toggle to private)
   - **Versioning:** OFF (saves storage; the tracker doesn't need history)

4. Click **Save**.

5. **Copy the Bin ID** that appears in the URL (`https://jsonbin.io/<BIN_ID>` — that 24-char hex string). You'll paste this in Step 5.

---

## Step 4 — Create a scoped Access Key for this bin

The Master Key has full account access — too broad to embed in HTML that runs in a browser. Create a scoped Access Key that can only Read and Update this specific bin.

1. In the JSONbin dashboard, navigate to **"Access Keys"** (different from the API Keys section that holds the Master Key).
2. Click **"Create Access Key"**.
3. Configure:
   - **Name:** `<your-project-name>-tracker-rw`
   - **Permissions:** **Read** ✓ and **Update** ✓ ONLY (do NOT grant Delete, Create, or Versioning)
   - **Scope:** This specific bin (paste the Bin ID from Step 3)
4. Click **Create**.
5. **Copy the Access Key** that appears. Looks similar to the Master Key (`$2a$10$...`) but with restricted permissions.

> The Access Key is safe to embed in the HTML because its blast radius is limited to read+update on this one bin. It can't access other bins or delete anything.

---

## Step 5 — Populate the HTML tracker

1. Open `PLANNING-TRACKER-TEMPLATE.html` in a code editor.
2. Find the `DEFAULT_BIN_CONFIG` block (search for it — should be near the top of the `<script>` section, after the icon definitions).
3. Replace the empty values:

```javascript
// BEFORE
const DEFAULT_BIN_CONFIG = {
  binId:   '',
  apiKey:  '',
  keyType: 'access'
};

// AFTER (paste your values)
const DEFAULT_BIN_CONFIG = {
  binId:   '<paste your Bin ID from Step 3 here>',
  apiKey:  '<paste your Access Key from Step 4 here>',
  keyType: 'access'   // keep as 'access' — the embedded key is the Access Key, not the Master Key
};
```

4. Save the file.
5. (Optional but recommended) Rename `PLANNING-TRACKER-TEMPLATE.html` → `PLANNING-TRACKER.html` (drop the `-TEMPLATE` suffix) so it's clear this is the live tracker, not the template.

---

## Step 6 — Store the Master Key + Bin ID in your project's credentials file

The Master Key is used by Claude Cowork and Claude Code when they need to read or write the tracker programmatically. It should NOT be in the HTML (HTML is read by browsers; Master Key is for trusted server-side use).

Each project has its own conventions for where credentials live. Common options:

- **A gitignored `CREDENTIALS.md` file** in the project root or a `reference/` folder
- **A `.env.local` file** (if your project already uses dotenv)
- **A password manager / 1Password / Bitwarden item** referenced by name from the credentials file

Recommended pattern: create a `CREDENTIALS.md` file alongside this `cowork-app-starter/` folder (NOT inside the folder, NOT committed to git). Add a section like:

```markdown
## Section 14 — Planning Tracker (JSONbin.io)

- Bin ID: <paste your Bin ID from Step 3>
- Master Key (full account access, use for Cowork / Claude Code programmatic reads/writes):
  $2a$10$<paste your Master Key>
- Access Key (Read+Update only, embedded in PLANNING-TRACKER.html):
  $2a$10$<paste your Access Key — same as in DEFAULT_BIN_CONFIG above>
- Bin URL (for direct browser access if needed): https://jsonbin.io/<your-bin-id>
```

Make sure this file is in your project's `.gitignore`. Verify with:

```bash
# Should print "CREDENTIALS.md" (meaning it's ignored)
git check-ignore CREDENTIALS.md
```

If `git check-ignore` returns nothing, the file is NOT ignored. Add the appropriate entry to `.gitignore` BEFORE saving the file — once a file with secrets is committed, the secret is in git history forever.

---

## Step 7 — Verify the tracker works

1. Open the `PLANNING-TRACKER.html` (or `PLANNING-TRACKER-TEMPLATE.html` if you didn't rename) directly in a browser (no server needed — double-click or `open` it).
2. The tracker UI should load. You should see four tabs (Outstanding / Current Sprint / QA / Verified) and an "Add item" button.
3. Click **"Add item"**, type a test title (e.g., "Test tracker"), click save.
4. Refresh the browser. The item should still be there — that confirms it's saved to JSONbin, not just to in-memory state.
5. Open https://jsonbin.io/<your-bin-id> in another tab and confirm the bin's content reflects the new item.
6. Delete the test item from the tracker. Refresh again to confirm it's gone.

If any of these steps fail:
- **Page loads but shows "Setup banner":** the `DEFAULT_BIN_CONFIG` values are wrong or missing. Re-check Step 5.
- **"Auth failed" or 401 errors:** the Access Key is wrong, or the Key Type mismatch (you may have pasted the Master Key but kept `keyType: 'access'`). If you're using the Master Key, set `keyType: 'master'` — but prefer the Access Key for the embedded HTML.
- **Items don't persist on refresh:** browser might be blocking the JSONbin domain (check your ad-blocker / privacy extension), OR the Access Key doesn't have Update permission. Re-check Step 4.

---

## What Cowork and Claude Code do with the tracker

Once the tracker is live:

- **During sprint planning** (Cowork), the `COWORK-PLANNING-KICKOFF.md` prompt reads the tracker via the JSONbin API to derive the sprint number from sprint-locked items and surface the locked-in scope back to you. See `PLANNING-TRACKER-GUIDE.md` for the API details.
- **During sprint execution** (Claude Code), the tracker is generally not read — Claude Code works off the build plan + sprint folder.
- **After sprint planning is done** (Cowork), the kickoff prompt moves the sprint-locked items from Current Sprint → QA in the tracker via a `PUT` to the bin.
- **After QA** (you, manually), you click Approve in the tracker UI for items that passed, or Back-to-sprint for items that need rework.

---

## Cost & quota

JSONbin's free tier includes:
- 10,000 requests/month
- 100KB max bin size
- Versioning available (we turn it off)

For a typical solo dev / small team, the planning tracker's request volume is well under the free tier limit. Each Cowork planning conversation does ~1 read + 1 write. Each tracker UI interaction is one request. Even a busy month (50 conversations + 500 UI interactions) is well under 10,000.

If you exceed the free tier, JSONbin paid plans start at $5/month for 1M requests + larger bin size.

---

## When to rotate keys

Rotate both the Master Key and the Access Key:
- If you suspect either is leaked (committed to git accidentally, pasted in a public chat, exposed in browser DevTools logs by mistake)
- If a team member with access leaves
- At minimum every 12 months as routine hygiene

To rotate: create a new key in the JSONbin dashboard, update `DEFAULT_BIN_CONFIG` (Access Key) and CREDENTIALS.md (Master Key + Access Key copies), test the tracker still works, then delete the old key.

---

## Cross-reference

- [`PLANNING-TRACKER-GUIDE.md`](./PLANNING-TRACKER-GUIDE.md) — how Cowork and Claude Code read/write the tracker (API patterns, field conventions, common workflows)
- [`PLANNING-TRACKER-TEMPLATE.html`](./PLANNING-TRACKER-TEMPLATE.html) — the tracker HTML itself
- [`README.md`](./README.md) § "Tracker setup" — the overview that points here
- [`_sprint-templates/COWORK-PLANNING-KICKOFF.md`](./_sprint-templates/COWORK-PLANNING-KICKOFF.md) — the Cowork planning prompt that reads the tracker

---

## Quick checklist

- [ ] JSONbin account created or signed in
- [ ] Master Key copied (will live in CREDENTIALS.md)
- [ ] Bin created with empty initial payload, named `<project>-planning-tracker`, set to private
- [ ] Bin ID copied
- [ ] Access Key created with Read + Update only, scoped to this bin
- [ ] Access Key copied
- [ ] `DEFAULT_BIN_CONFIG` in HTML populated (Bin ID + Access Key + `keyType: 'access'`)
- [ ] HTML optionally renamed (drop `-TEMPLATE` suffix)
- [ ] CREDENTIALS.md updated with Master Key + Bin ID + Access Key
- [ ] CREDENTIALS.md is gitignored (verified via `git check-ignore`)
- [ ] Tracker opens in browser, shows the four stage tabs
- [ ] Test item adds, persists on refresh, deletes cleanly
