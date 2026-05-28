# Planning Tracker — Guide for Claude Cowork

> How to read, edit, and respect the conventions of the continuous planning tracker.
>
> Plain version: the tracker is a web page backed by a cloud Postgres row. This file tells Cowork exactly how to talk to it without breaking the workflow conventions.

---

## Where things live

The tracker UI lives at `PLANNING-TRACKER-TEMPLATE.html` (or whatever you renamed it to during install). The live data lives in a single row of the `tracker_state` table in your Supabase project — **the HTML is just a shell**. Always read/write through the Supabase REST API (PostgREST), never by modifying the `<script id="tracker-data">` block inside the HTML.

Each tracker is one row keyed by `id` (the `tracker_id` value in the URL fragment). One Supabase project can host arbitrarily many trackers; pick a distinct `tracker_id` per downstream app.

The URL fragment shape (the part after `#` in the bookmark URL) carries everything the planner needs:

```
#project=<PROJECT_REF>&anon_key=<ANON_KEY>&tracker_id=<TRACKER_ID>
```

Fragments are never sent to servers — they're safe places to embed the anon key. RLS policies on `tracker_state` gate what the anon key can do (read/insert/update only; cannot delete, cannot enumerate rows it doesn't know the id of).

Credentials live in your project's secrets file (e.g., `CREDENTIALS.md`) under the tracker section. Two keys are typically listed there:

- **Anon key** (publishable, e.g., `sb_publishable_...`) — scoped by RLS. Embedded in the bookmark URL so first-time visitors auto-connect with no setup banner. Safe to share within a team; treat the URL itself as the secret because the `tracker_id` in it gates row-level access.
- **Service_role key** (secret, e.g., `sb_secret_...`) — bypasses RLS entirely. Use this from Claude Code / trusted server-side tooling that calls Supabase directly (e.g., migrations, bulk cleanups). NEVER paste in URLs, client-side code, chat, or screenshots.

See `TRACKER-SETUP.md` for the one-time Supabase project + schema creation walkthrough. The `tracker_state` table schema (one JSONB column + RLS policies + auto-update trigger) is reproduced in `TRACKER-SETUP.md` Step 3.

> **Using a project that hasn't migrated off JSONbin yet?** The kit's K2 release ships with a 30-day grace period that supports both backends. See the [Legacy JSONbin appendix](#legacy-jsonbin-grace-period) at the bottom of this file. Kit version K3 removes the JSONbin code path entirely.

---

## 1. Reading the tracker

PostgREST exposes the `tracker_state` table via standard REST:

```
GET https://<PROJECT_REF>.supabase.co/rest/v1/tracker_state?id=eq.<TRACKER_ID>&select=state,schema_version,updated_at
Headers:
  apikey:        <ANON_KEY_OR_SERVICE_ROLE_KEY>
  Authorization: Bearer <ANON_KEY_OR_SERVICE_ROLE_KEY>
```

Response is a JSON array. A populated row looks like `[{ "state": {...}, "schema_version": "v2", "updated_at": "2026-05-28T13:33:25Z" }]`. An empty array `[]` means no row with that `tracker_id` exists yet (first-time setup path — the planner falls back to its embedded seed).

The `state` JSONB column holds the same `{ "config": {...}, "items": [...] }` shape that JSONbin used pre-K2. No schema transformation between backends.

From Claude Code, the easiest invocation is `curl` via bash. `WebFetch` works for simple reads too, but `curl` is more reliable for repeated calls and inspecting headers.

Plain: hit the table, get the row, the `state` field is the tracker JSON.

## 2. Writing the tracker

Use PostgREST's upsert directive — Supabase auto-detects whether the row exists and INSERTs or UPDATEs accordingly:

```
POST https://<PROJECT_REF>.supabase.co/rest/v1/tracker_state
Headers:
  apikey:        <ANON_KEY_OR_SERVICE_ROLE_KEY>
  Authorization: Bearer <ANON_KEY_OR_SERVICE_ROLE_KEY>
  Content-Type:  application/json
  Prefer:        resolution=merge-duplicates,return=minimal
Body:
  { "id": "<TRACKER_ID>", "state": { "config": {...}, "items": [...] } }
```

Always read first, modify in place, write the entire `state` object back. The JSONB column gets overwritten atomically on each upsert — partial-update semantics are not supported at this layer, and the planner's storage adapter doesn't use PATCH for the same reason (consistent atomic snapshot per write).

The `updated_at` column auto-bumps on every UPDATE via the `tracker_state_touch` trigger — you don't set it from the client.

If you're scripting a bulk update from inside the running planner (browser DevTools), prefer calling `await loadState()` first to refresh `state` from Supabase, mutating `state.items` / `state.config` directly, then `await saveToCloud()` — that goes through the planner's storage adapter and surfaces network/auth errors loudly via the JS `alert()` path documented in §4b.

Plain: grab the whole row's state, change what you need, upsert the whole state back.

### Service_role caveats for server-side scripts

Supabase service_role keys (`sb_secret_*` format) are rejected when the User-Agent looks browser-like — the API returns HTTP 401 `"Forbidden use of secret API key in browser"`. This is a Supabase-side heuristic to catch accidental key leakage. When calling from Python / Node / curl with the service_role key, send a non-browser User-Agent (e.g., `myscript/1.0`). Anon-key calls are not affected by this heuristic.

---

## 3. Field conventions

Each item in `state.items` is an object with these fields. The notes below describe who is allowed to modify each one.

### Claude-managed fields

- **`claudeResponse`** (string) — Claude's feedback for the user on this item. Free-form text, mockup links can be inline as URLs (auto-linkified in the UI). Updating this is what flips the card to "Awaiting your review" (blue accent) automatically — no flag needed; it's derived from `claudeResponse` being non-empty. The blue/pink color cycle runs in **Outstanding, Current Sprint, and QA** stages.
- **`pendingClaudeReview`** (boolean) — *Claude clears this*. The user sets it to `true` when they edit "Your details" after Claude has responded. After Claude reviews the user's feedback and updates `claudeResponse`, set this back to `false`. Persists across stage moves; clears only when item reaches Verified or when status leaves both QA and Current Sprint.

### User-managed fields (don't touch without explicit instruction)

- **`approvedForBuild`** — user-only. Set/cleared via the Approve / Un-approve button on Current Sprint cards. Required for an item to be eligible for the next Complete Sprint bundle.
- **`sprintLocked`** — user sets it via the Complete Sprint button (on each item that gets bundled into a new sprint group). Claude clears it when moving items from Current Sprint to QA after the build plan is finalized. Items that are sprint-locked but not yet moved to QA stay read-only inside their Sprint N group on the Current Sprint tab.
- **`sprintNumber`** (number | null) — the sprint group an item belongs to. Set by Complete Sprint when an approved item is bundled (e.g., `sprintNumber: 3`). Preserved across stage moves (Current Sprint → QA → Verified) so the item stays visually grouped under "Sprint N" in every tab it appears in. Cleared automatically when the item is bounced back from QA via Back to sprint. Sprint numbers can be manually renamed by the user via the pencil icon on a group header — when that happens, both `sprintNumber` AND `lastSprintNumber` are remapped across all matching items.
- **`lastSprintNumber`** (number | null) — set automatically when `sendBackToSprint` fires (QA → Current Sprint bounce-back). Stores the `sprintNumber` the item had at the moment of bounce, so the QA Failed badge can display "QA Failed · Sprint N". Read-only from Claude's perspective; do not set or clear manually.
- **`qaFailed`** — user-only. Set when the user clicks Back to sprint from QA. Cleared only when the item reaches Verified. Persists across stages; the badge text reads "QA Failed · Sprint N" when `lastSprintNumber` is set.
- **`status`** — Claude may change this in two specific cases:
  1. Moving a Sprint-Locked Current Sprint item to QA after build plan is done. Set `status: "QA"`, `sprintLocked: false`. **Preserve `sprintNumber`** — the item should remain inside its Sprint N group when viewed from the QA tab.
  2. Adding/promoting an Outstanding item into Current Sprint as part of priority review. Leave `sprintNumber: null` so it lands ungrouped (next sprint candidate).
  Otherwise leave it alone.
- **`title`, `userDetails`, `roles`, `type`, `page`, `feature`, `priority`** — user-managed via the UI. Don't modify unless explicitly asked to.

### Immutable / auto fields

- **`id`** — set at creation, never modify.
- **`dateAdded`** — set at creation, never modify.
- **`dateVerified`** — set automatically by the UI when status flips to Verified.

### Config-level fields (live on `state.config`, not on individual items)

- **`state.config.nextSprintNumber`** (number) — the number that will be stamped onto items the next time the user clicks Complete Sprint. Auto-increments after each successful bundle. Manually re-anchored via group-header rename. Default starts at 1 for a fresh starter-kit install; this field may be missing on legacy bins (code falls back to its template default).
- All other config keys (`roles`, `pages`, `features`, `types`, `priorities`, `statuses`) are seeded from the HTML template and rarely change.

### Schema v2 — fields added in K1 (backwards-compat preserved)

K1 introduced six new optional fields per item. Every field is OPTIONAL — readers MUST tolerate items where any of them are missing and fall back to legacy rendering (see "Backwards compatibility" below). The migration script at `reference/kit-sprints/K1 - Planner Improvements/_scripts/migrate-tracker-to-v2.py` upgrades existing items to the v2 shape in one pass and is idempotent — repeated runs are no-ops on already-migrated items.

#### Comment thread (`comments[]`) — replaces single `userDetails` + `claudeResponse` text blocks

```typescript
comments?: Array<{
  author: "user" | "cowork" | "claude-code";  // who posted
  timestamp: string;                            // ISO 8601 — e.g., "2026-05-24T18:55:00Z"
  text: string;                                 // plain text; light markdown auto-rendered
}>
```

- **Author taxonomy.** `"user"` = the human reviewing the item; `"cowork"` = the Cowork planning session that posted the item / addresses user feedback during planning; `"claude-code"` = a Claude Code build session that commented (rare — most Claude Code writes go to commit messages + PR descriptions, not the planner).
- **Append-only.** No editing past comments. New comments append to the array; the planner UI renders them oldest-at-top, newest-at-bottom, with collapse-to-last-3 when the thread exceeds 3 entries.
- **Markdown rendering.** The UI auto-renders `**bold**`, `*italic*`, list bullets, and URLs (URLs route through the K1 `openMockupLink()` handler for `file://` and `engage-mockup://` schemes — see K1-P2 commit).
- **Derives `pendingClaudeReview`.** The planner UI auto-derives the stored `pendingClaudeReview` flag from `comments[last].author === "user"`. The stored field becomes redundant for v2 items but is kept for backwards-compat reads of v1 items.

#### Item-type discriminator (`itemType`)

```typescript
itemType?: "build-plan" | "qa-item";  // defaults to "qa-item" if missing (back-compat)
```

The planner renders two distinct card types based on this field. Readers MUST treat missing `itemType` as `"qa-item"` — that's the only kind that existed before K1.

- **`"qa-item"`** (the only legacy kind) — what every existing item is: a feature/bug/polish/refactor card that flows Outstanding → Current Sprint → QA → Verified per §4's planning workflow.
- **`"build-plan"`** (new in K1) — the **sprint's build plan itself**, rendered as a first-class card alongside its QA items. Carries the full kickoff prompt + short description + queue position. Moves through the same four stages but with the auto-promotion lifecycle codified in `STARTER-PROJECT-PLANNING.md §1.5.4` (Engage app sprints only; Kit Sprints do NOT post build-plan cards — see §1.5.3).

#### Build-plan card fields (only when `itemType === "build-plan"`)

```typescript
kickoffPrompt?: string;    // full pastable prompt for Claude Code (multi-line, ~500-3000 chars)
promptCount?: number;       // e.g., 14 for Sprint 29
shortDescription?: string;  // 1-2 sentence subtitle shown on the card
queueOrder?: number;        // Outstanding-stage only; lower = promoted first
```

- `kickoffPrompt` renders as a click-to-copy dark code block on the build-plan card. The UI exposes a Copy button that writes it to clipboard for paste into a fresh Claude Code session.
- `promptCount` displays as "**N prompts**" on the card header.
- `shortDescription` is the 1-2-sentence summary line under the card title.

#### Queue order (`queueOrder`) — Outstanding-stage build-plan cards only

```typescript
queueOrder?: number;  // present ONLY on build-plan cards in Outstanding; lower = promoted first
```

Rules:

- **Auto-assigned by Cowork on post.** When Cowork posts a new build-plan card to Outstanding (per `COWORK-PLANNING-KICKOFF.md` § STEP 5), it assigns `queueOrder = max(existing queueOrders in Outstanding) + 1`. First-ever Outstanding card gets `queueOrder = 1`.
- **User-editable via the planner UI.** Up/down arrow buttons on the card (K1-P4 ships these) reorder by swapping `queueOrder` with the adjacent card. Drag-to-reorder ships in K2.
- **Consumed by Claude Code at Sprint Completion.** Per `STARTER-PROJECT-PLANNING.md §1.5.4`'s auto-promotion algorithm, the lowest-`queueOrder` Outstanding card promotes to Current Sprint and gets `queueOrder = null`; remaining Outstanding cards re-pack (each decrements by 1).
- **Cleared on stage transition out of Outstanding.** Cards in Current Sprint / QA / Verified do NOT carry `queueOrder` — set it to `null` or omit it entirely when transitioning.
- **NEVER set on `qa-item` cards.** Queue order is a build-plan-card concept only; QA items move through stages via the user's Approve / Complete-Sprint clicks, not via numeric queue position.

### Backwards compatibility (legacy v1 → v2)

Until the K2 grace-period removal, every reader (planner UI, migration script, Cowork, Claude Code) MUST tolerate items that have:

- No `comments[]` field → render the legacy `userDetails` + `claudeResponse` text blocks as before.
- No `itemType` field → treat as `"qa-item"`.
- No `kickoffPrompt` / `promptCount` / `shortDescription` / `queueOrder` fields → the item is a v1 `qa-item`; build-plan-specific UI does not apply.

Writers (Cowork, Claude Code, the migration script) MUST NOT delete legacy `userDetails` / `claudeResponse` from v1 items during the K1 grace period — only ADD the new `comments[]` field rolling the legacy text into the thread. Legacy fields are removed in K2 (see K1 build plan § "Items deferred").

---

## 3a. Writing a comment to the thread (upsert pattern)

Comments are append-only by schema design. The canonical pattern is read-modify-write through the `tracker_state` row — never modify the embedded HTML's `<script id="tracker-data">` block (it's only the initial seed).

```python
# Pseudo-code — Cowork / Claude Code / scripts follow this shape.

SUPABASE_BASE = f"https://{PROJECT_REF}.supabase.co/rest/v1/tracker_state"
headers = {
    "apikey":        ANON_KEY_OR_SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {ANON_KEY_OR_SERVICE_ROLE_KEY}",
}

# 1) READ the full tracker state from the row.
rows = http_get(
    f"{SUPABASE_BASE}?id=eq.{TRACKER_ID}&select=state",
    headers=headers,
)
state = rows[0]["state"]  # shape: { "config": {...}, "items": [...] }

# 2) Find the item by id (or title). Hydrate comments[] lazily if missing —
#    pre-K1-P7-migration items only have the legacy userDetails+claudeResponse
#    pair, and the first new comment must NOT overwrite that history.
item = next(i for i in state["items"] if i["id"] == target_id)
if not isinstance(item.get("comments"), list):
    legacy = []
    if (item.get("userDetails") or "").strip():
        legacy.append({
            "author": "user",
            "timestamp": item.get("dateAdded") or "2026-01-01",
            "text": item["userDetails"],
        })
    if (item.get("claudeResponse") or "").strip():
        legacy.append({
            "author": "cowork",
            "timestamp": item.get("dateAdded") or "2026-01-01",
            "text": item["claudeResponse"],
        })
    item["comments"] = legacy

# 3) APPEND the new comment. NEVER edit a past comment in place.
item["comments"].append({
    "author":    "cowork",                 # or "user" / "claude-code"
    "timestamp": now_iso_utc(),            # ISO 8601 — e.g., "2026-05-24T18:55:00Z"
    "text":      "Sprint 29 build plan finalized. Stripe Billing scope locked.",
})

# 4) Auto-derive pendingClaudeReview from the new last author. Verified items
#    are fully locked — never flip the flag there.
if item.get("status") != "Verified":
    item["pendingClaudeReview"] = item["comments"][-1]["author"] == "user"

# 5) UPSERT the full state back. PostgREST's Prefer header selects between
#    INSERT and UPDATE automatically; return=minimal keeps the response body
#    empty (we already have state in memory).
http_post(
    SUPABASE_BASE,
    headers={
        **headers,
        "Content-Type": "application/json",
        "Prefer":       "resolution=merge-duplicates,return=minimal",
    },
    body=json.dumps({"id": TRACKER_ID, "state": state}),
)
```

Notes:

- **Author taxonomy** — see §3's "Comment thread" subsection. `"user"` = human, `"cowork"` = planning session, `"claude-code"` = build session.
- **Markdown rendering** — `**bold**`, `*italic*`, `- ` lists, and URLs auto-render in the planner UI (URLs route through the K1 `openMockupLink()` handler — see §3b).
- **No automatic save in the browser planner** — the in-browser tracker's `postComment()` mutates `state` locally + flashes "click Save to write to disk." The user has to click Save to upsert. Scripts that bypass the browser go straight to upsert and skip the in-browser staging.
- **Idempotency for migrations** — scripts that retroactively backfill comments (e.g., the K1-P7 migration) MUST check `isinstance(item.get("comments"), list)` AND a populated length before appending, so reruns are no-ops.
- **Atomicity** — each upsert overwrites the entire `state` JSONB column. There is no partial-update at this layer; concurrent writers would race the same way they would have on JSONbin's PUT semantics. The planner UI's `saveToCloud()` issues one upsert per user action; bulk scripts should serialise their writes.

---

## 3b. Mockup URL handler (`engage-mockup://`, clipboard fallback, installer)

Comment text + the legacy `userDetails`/`claudeResponse` blocks both auto-linkify URLs. URLs with the `file://` or `engage-mockup://` schemes route through a special click handler (`openMockupLink()`) introduced in K1-P2:

1. **Click handler** — clicking the link attempts a protocol launch via a hidden iframe. If the OS protocol handler is installed (K1-P3 ships installers), the mockup opens in the user's default browser without further interaction.
2. **Clipboard fallback** — if no handler is registered (no installation, or the 500ms launch timeout elapses without window-blur), the URL is copied to the clipboard and a toast appears at the bottom-right with paste instructions (`Ctrl/Cmd+L` → `Ctrl/Cmd+V` → `Enter`).
3. **Installer** — the planner's setup panel ships a "Single-click local mockup links" install button (K1-P3). It detects the user's OS, downloads the matching installer from the kit mirror (`raw.githubusercontent.com/<EXAMPLE: kit-org>/<EXAMPLE: kit-repo>/main/_scripts/`), and shows OS-specific post-install steps inline.

What this means for Cowork / Claude Code writers:

- **Write file paths and mockup URLs naturally.** `file:///c/path/to/mockup.html` or `engage-mockup:///c/path/to/mockup.html` — both forms render as a single click-to-open link. The handler normalizes between the two.
- **Do NOT URL-encode the path** before posting. The planner's `linkify()` regex consumes the raw form; encoding breaks the click handler's scheme-strip step.
- **http(s) URLs render as plain `target="_blank"` anchors.** They do NOT route through `openMockupLink()` — the special handler is for local mockup files only.

Cross-references:

- `PLANNING-TRACKER-TEMPLATE.html` — `openMockupLink()`, `copyToClipboard()`, `showCopyToast()` implementations (search "K1-P2" in the file).
- `_scripts/engage-mockup-handler-windows.reg` — Windows installer (registers `HKCR\engage-mockup` → PowerShell scheme-strip → `Start-Process`).
- `_scripts/engage-mockup-handler-mac.command` — macOS installer (compiles AppleScript `.app` bundle into `~/Applications/EngageMockupHandler.app`).
- Linux installer — not shipped (clipboard fallback continues to work; deferred to K2 per K1 build plan §4).

---

## 3c. Build plan card lifecycle (Engage app sprints only)

Build plan cards (`itemType: "build-plan"`) are first-class planner items distinct from QA items. They move through the same four stages as QA items (Outstanding → Current Sprint → QA → Verified) but with a specific responsibility matrix + auto-promotion algorithm. The full lifecycle lives in `STARTER-PROJECT-PLANNING.md §1.5.2` (or the downstream project's equivalent — Engage uses §1.5.4). This guide covers only the tracker-shape concerns:

- **Posting** — Cowork posts the build plan card at planning end (per `COWORK-PLANNING-KICKOFF.md` STEP 5A step 1). Stage auto-selection: Current Sprint if that stage is empty for build-plan items, else Outstanding with auto-assigned `queueOrder = max(existing Outstanding queueOrders) + 1`.
- **Auto-promotion** — Claude Code, at Sprint Completion (per the project's `DEPLOYMENT-WORKFLOW.md` § "Sprint Completion" section), moves the currently-in-Current-Sprint build plan card to QA AND promotes the lowest-`queueOrder` Outstanding build plan card to Current Sprint with `queueOrder: null`. Remaining Outstanding cards re-pack (each decrements by 1). This is deterministic — no halt-and-ask.
- **Stage transitions** — Cowork OR Claude Code may upsert the row to change a build plan card's `status` per the responsibility matrix in `STARTER-PROJECT-PLANNING.md §1.5.2`. Users transition Verified only — via the planner UI's Verify button after reviewing all QA items in the sprint group.
- **Queue order edits** — users can reorder via the planner UI's ▲▼ arrows on Outstanding build plan cards (K1-P4). Drag-to-reorder ships in K2 per K1 build plan §4. Scripts that bulk-reorder MUST swap `queueOrder` values pairwise (not just renumber blindly) so concurrent edits via the UI don't collide.
- **Comment thread on build plan cards** — sprint-level discussion only (scope drift, sprint-wide carryover, sprint-completion review). Per-prompt details belong on the matching QA item's thread — see `COWORK-PLANNING-KICKOFF.md` § "TRACKER ETIQUETTE" rule 5.

**Kit Sprints are EXCLUDED from this lifecycle.** Kit Sprints (`reference/kit-sprints/K<n> - <theme>/`) do NOT post build plan cards or QA items to the planner. Their audit trail lives in `STARTER-KIT-SYNC-LOG.md` instead. See `STARTER-PROJECT-PLANNING.md §1.5.3` (if your project has adopted the Kit Sprint workflow) and `COWORK-PLANNING-KICKOFF.md` § STEP 5B.

---

## 4. The planning workflow

A typical cycle:

1. **User adds items to Outstanding** on an ongoing basis.
2. **User moves priority items to Current Sprint** (via Move arrow or status popover).
3. **Claude reviews Outstanding**, optionally moves additional priority items into Current Sprint by setting `status: "Current Sprint"`. (Leave `sprintNumber: null` so the item lands ungrouped.)
4. **Claude reviews all Current Sprint items** and writes feedback into `claudeResponse` — text, research notes, mockup URLs, etc. Mockup links inline as `https://...` URLs; the UI auto-linkifies them.
5. **User reviews Claude's feedback**. If user edits Your details, the card flips to pink "Pending Claude review & update" (`pendingClaudeReview: true`). Claude addresses and clears the flag.
6. **User clicks Approve on each Current Sprint item** when satisfied (sets `approvedForBuild: true`).
7. **User clicks Complete Sprint.** Only items that are `approvedForBuild: true && !pendingClaudeReview && sprintNumber == null` get bundled. For each bundled item the UI sets `sprintNumber: <next>` AND `sprintLocked: true`, then increments `state.config.nextSprintNumber`. Non-approved items remain in Current Sprint, ungrouped, available for the next sprint. The button label reads "Complete Sprint → Sprint N" so the user can see which number is about to be assigned. (User can also rename a sprint number after the fact via the pencil icon on the group header.)
8. **Claude reads the sprint-locked items**, builds the build plan (outside this tracker), and once the plan is finalized, moves the items to QA. For each item: set `status: "QA"`, `sprintLocked: false`. **DO NOT touch `sprintNumber`** — the item must keep its number so it stays inside the Sprint N collapsible group on the QA tab. If the build plan drops or defers an item, set `sprintLocked: false` AND clear `sprintNumber: null` so it falls back into the ungrouped Current Sprint pool; ideally also note the deferral in `claudeResponse`.
9. **Claude Code builds and ships** the code (outside this tracker).
10. **User reviews QA items.** For each one:
    - Verifies → clicks Approve → item goes to Verified, fully locked. `sprintNumber` is preserved so the item appears in its Sprint N group on the Verified tab forever.
    - Needs work → edits Your details (sets `pendingClaudeReview: true`) → clicks Back to sprint → item bounces to Current Sprint with `qaFailed: true`, `pendingClaudeReview: true`, `lastSprintNumber: <previous sprintNumber>`, and `sprintNumber: null` (item leaves the group but the badge will read "QA Failed · Sprint N" referencing where it came from).
11. **Loop returns to step 5** for items that bounced. Approved items become Verified (and the QA Failed tag clears). On the next Complete Sprint, those bounced items — once re-approved — get a fresh `sprintNumber` (a new sprint group), but their `lastSprintNumber` history is gone (overwritten if they bounce again from a new sprint).

Plain: outstanding → current sprint (ungrouped) → user approves → Complete Sprint bundles the approved ones into a numbered Sprint group → Claude moves them to QA (group travels with them) → either verified inside the group, or bounced back to ungrouped Current Sprint with a "QA Failed · Sprint N" badge.

---

## 4a. Sprint groups

A **sprint group** is a logical bucket of items sharing the same `sprintNumber`. Groups exist independently of stage — a single Sprint N can contain items currently in Current Sprint (still locked, waiting for Claude's build plan), items in QA (being tested), and items in Verified (already shipped). Each tab (Current Sprint / QA / Verified) renders one collapsible "Sprint N" header per sprint with items currently in that stage, followed by ungrouped items below. Outstanding never groups — it's always a flat list.

Key invariants:

- An item leaves its group only when it bounces from QA back to Current Sprint (`sendBackToSprint`). In that one case, `sprintNumber` is cleared and copied to `lastSprintNumber`.
- An item that bounces and is later re-approved + re-bundled gets a fresh `sprintNumber` from the user's next Complete Sprint click.
- `state.config.nextSprintNumber` is the single source of truth for what the next bundle will be numbered. It auto-increments; user can also rename existing groups via the pencil icon (which remaps every matching `sprintNumber` AND `lastSprintNumber` in one pass and bumps `nextSprintNumber` if the rename consumed it).
- The collapsed/expanded state of each group is per-browser-session (`collapsedSprintGroups: Set`) and NOT persisted to Supabase.

## 4b. UI affordances Claude should be aware of

- **Copy + Delete buttons are Outstanding-only.** Current Sprint, QA, and Verified cards do NOT expose copy or delete. This is a deliberate guard so committed work isn't casually duplicated or lost. If Claude needs to duplicate or delete an item that's past Outstanding, do it via direct JSON edit (read the row, splice the array, upsert the row), and tell the user.
- **Outstanding cards participate in the color cycle.** A blue left accent = "awaiting your review" (Claude wrote `claudeResponse` last). A pink background = "pending Claude review" (`pendingClaudeReview: true`, user edited details after Claude responded). This matches the Current Sprint and QA behavior.
- **Save errors are loud.** `saveToCloud` pops a JS `alert()` on failure in addition to the status pill so auth or network failures can't slip past unnoticed.
- **Save errors are loud.** `saveToCloud` pops a JS `alert()` on any upsert failure (network, RLS, auth) in addition to the status pill, so silent corruption is impossible.
- **Legacy auto-heal** — when the URL fragment carries JSONbin params (`#bin=…&key=…`) during the K2 grace period, `jsonbinRequest()` retries with the opposite `keyType` header on HTTP 401 and rewrites localStorage to match. This silent self-heal does not apply to the Supabase path; Supabase auth failures surface immediately.

## 5. Common patterns

### "Pull the tracker" / "Review the tracker"

1. Read the `tracker_state` row via the PostgREST `GET` endpoint (§1).
2. Look at items in the Current Sprint or QA tab (filter by `status`).
3. Add or update `claudeResponse` where needed.
4. Clear `pendingClaudeReview: false` on items where you've addressed user feedback.
5. Upsert the full state back via the PostgREST `POST` with `Prefer: resolution=merge-duplicates` (§2).

### "Promote an item from Outstanding to Current Sprint"

1. Read the row.
2. Find the item by id or title, change `status` from `"Outstanding"` to `"Current Sprint"`.
3. Optionally set `priority: "Yes"` if appropriate.
4. Upsert the row back.

### "Move sprint-locked items into QA"

1. Read the row.
2. For each item with `sprintLocked: true` that's part of the finalized build plan, set `status: "QA"` and `sprintLocked: false`. **Leave `sprintNumber` alone** — it must persist so the item stays inside its Sprint N collapsible group on the QA tab.
3. For items the build plan dropped or pushed to a future sprint, set `sprintLocked: false` AND `sprintNumber: null` (returns them to the ungrouped Current Sprint pool, ready for next sprint). Also set `approvedForBuild: false` so the user can re-evaluate, and note in `claudeResponse` why they were deferred.
4. Upsert the row back.

### "Promote a bounced QA-failed item back into a new sprint"

1. Read the row.
2. The bounced item is in Current Sprint with `qaFailed: true`, `pendingClaudeReview: true`, `lastSprintNumber: <prev>`, `sprintNumber: null`.
3. Address Claude's feedback (update `claudeResponse`), clear `pendingClaudeReview: false`.
4. Leave `qaFailed: true` untouched (only Verified clears it) — the "QA Failed · Sprint N" badge stays visible until verified.
5. Upsert the row back. The user will re-approve and the next Complete Sprint will bundle it with a fresh `sprintNumber`.

### "Address pending Claude review items"

1. Read the row.
2. Filter items where `pendingClaudeReview: true` (these are pinned to the top of the UI in their tab).
3. Read the updated `userDetails` to see what the user added.
4. Update `claudeResponse` to address it.
5. Set `pendingClaudeReview: false`.
6. Upsert the row back.

### "Post a comment on an item" (K1-P4 workflow)

The append-only pattern. Full code shape in §3a; the high-level recipe:

1. Read the row.
2. Find the item; hydrate `comments[]` from legacy `userDetails`+`claudeResponse` if absent (lazy migration — see §3a step 2).
3. Append a new `{author, timestamp, text}` entry. Author is `"user"` / `"cowork"` / `"claude-code"` per the taxonomy in §3.
4. Auto-derive `pendingClaudeReview` from the new last author: set to `true` when `comments[-1].author === "user"`, else `false`. Skip the flip on Verified items (fully locked).
5. Upsert the row back.

### "Post a build plan card at sprint planning end" (Cowork, K1-P5 workflow)

For Engage app sprints only. Kit Sprints SKIP this step entirely (audit via `STARTER-KIT-SYNC-LOG.md`).

1. Read the row.
2. Allocate the next item id: `max(i.id for i in state.items) + 1`.
3. Decide the stage:
     - If NO existing item has `itemType === "build-plan" && status === "Current Sprint"`, post this new card with `status: "Current Sprint"` and `queueOrder: null`.
     - Else post with `status: "Outstanding"` and `queueOrder = max(queueOrder for existing Outstanding build-plan items) + 1` (first ever = 1).
4. Build the item: `{id, itemType: "build-plan", title, shortDescription, kickoffPrompt, promptCount, sprintNumber, status, queueOrder, comments: [{author: "cowork", timestamp: now, text: "Sprint <N> build plan finalized. <synthesis>."}], dateAdded: now}`.
5. Append to `state.items`. Upsert the row back.

See `COWORK-PLANNING-KICKOFF.md` § STEP 5A step 1 for the full Cowork-side ritual (includes per-prompt QA item seeding as steps 2 + 3).

### "Promote the next queued build plan card to Current Sprint" (Claude Code, at Sprint Completion)

Deterministic — no halt-and-ask. Per `STARTER-PROJECT-PLANNING.md §1.5.2`'s auto-promotion algorithm:

1. Read the row.
2. Find the build plan card currently in Current Sprint (the one whose sprint just completed). Set `status: "QA"`.
3. Find the Outstanding build plan card with the lowest `queueOrder`. Set its `status: "Current Sprint"` and `queueOrder: null`.
4. Re-pack the remaining Outstanding build plan queue: for each remaining `itemType === "build-plan" && status === "Outstanding"` item, decrement `queueOrder` by 1 (so a former 2nd becomes the new 1st = "Up next").
5. Upsert the row back.

If no Outstanding build plan card exists, Current Sprint stays empty until the next planning conversation posts one. This is a normal terminal state — not an error.

---

## 6. Source of truth

The `tracker_state` row is canonical. Never trust the embedded `<script id="tracker-data">` block in the HTML — it's only used as the initial seed when the row doesn't exist yet, never updated after that. If you read the HTML file directly, you're reading stale data.

If for some reason Supabase is unreachable (project paused, network issue, anon key revoked), say so to the user. Don't fall back to editing the HTML's embedded JSON — those edits won't reach the live tracker.

---

## Legacy JSONbin (grace period)

Pre-K2 trackers used JSONbin.io as the storage backend. K2 introduced Supabase and added a 30-day grace period where the planner template detects which set of URL fragment params is present and routes to the corresponding backend:

| Fragment params present | Backend used | Behavior |
|---|---|---|
| `project` + `anon_key` + `tracker_id` | Supabase (new) | Primary path. "Storage: Supabase" indicator in header. |
| `bin` + `key` (+ optional `keyType`) | JSONbin (legacy) | Read-write still works. Deprecation banner surfaces. "Storage: JSONbin (legacy)" indicator. |
| Both sets present | Supabase (new) | Banner explains the legacy params are being ignored. |
| Neither | localStorage / DEFAULT_BIN_CONFIG | Standard first-time-setup flow. |

Kit version K3 removes the JSONbin code path entirely. After K3-P0 ships:
- The legacy URL fragment shape `#bin=…&key=…` will no longer load the tracker.
- The `JSONBIN_ADAPTER`, deprecation banner, legacy `getBinConfig` branch, and JSONbin setup panel UI will be deleted from `PLANNING-TRACKER-TEMPLATE.html`.
- The legacy JSONbin bin can be safely decommissioned (export a final snapshot before deletion).

### Legacy JSONbin API reference (during grace period only)

If you maintain a project still on JSONbin and need to script against it during the grace period:

```
GET https://api.jsonbin.io/v3/b/<BIN_ID>/latest
Headers:
  X-Master-Key: <X-MASTER-KEY>   # or X-Access-Key: <ACCESS_KEY> — pick one
  X-Bin-Meta: false
```

```
PUT https://api.jsonbin.io/v3/b/<BIN_ID>
Headers:
  X-Master-Key: <X-MASTER-KEY>   # or X-Access-Key: <ACCESS_KEY> — pick one
  Content-Type: application/json
  X-Bin-Versioning: false
Body:
  <full updated {config, items} JSON>
```

Two header gotchas inherited from the K1 design:

1. JSONbin enforces the matching HTTP header. The Master Key MUST be sent as `X-Master-Key`; the Access Key MUST be sent as `X-Access-Key`. Sending one under the other's header returns HTTP 401 with `"X-Master-Key is invalid or the bin doesn't belong to your account"`. The deployed planner's `jsonbinRequest()` auto-detects via the `detectKeyType()` helper and self-heals stale localStorage by retrying on 401 with the opposite header.
2. JSONbin sits behind Cloudflare, which returns HTTP 403 (error code 1010) for default `Python-urllib` User-Agents. Server-side scripts must send a browser-shaped User-Agent. (Supabase has the opposite rule for the service_role key — see §2.)

### Migrating from JSONbin to Supabase

For a step-by-step migration walkthrough adapted from the kit's own upstream cutover, see `TRACKER-SETUP.md` → "Migrating from JSONbin" section. The reference implementation is the upstream Engage planning kit's migration script:

```
reference/kit-sprints/K2 - Tracker on Supabase/_scripts/migrate-jsonbin-to-supabase.py
```

The migration is a storage-layer transfer only — the per-item v2 schema is preserved verbatim. Don't delete the JSONbin bin until you've verified the Supabase row's `state` byte-equals the JSONbin source under canonical encoding (`sort_keys=True`).

---

## Cross-references

- `TRACKER-SETUP.md` — one-time Supabase project + schema setup walkthrough (with a "Migrating from JSONbin" section for legacy projects during the K2 grace period).
- `PLANNING-TRACKER-TEMPLATE.html` — the deployed shell + initial seed JSON. Search "K1-P4" for the comment-thread + build-plan-card renderers, "K1-P2" for the `openMockupLink()` click handler.
- `_sprint-templates/COWORK-PLANNING-KICKOFF.md` — kickoff prompt that reads the tracker first. STEP 0 derives sprint scope from user-confirmed items (K1-P5); STEP 5 branches on sprint type (Engage app → planner post; Kit Sprint → sync-log only).
- `STARTER-PROJECT-PLANNING.md` §1 — planning phase, tracker-driven from sprint 2 onward. §1.5.2 documents the build plan card lifecycle (in projects with Kit Sprint support, this may be renumbered §1.5.4 — see the downstream project's own copy).
- `STARTER-KIT-SYNC-LOG.md` — Kit Sprint completion audit trail (Kit Sprints SKIP the planner).
- `_scripts/engage-mockup-handler-{windows.reg,mac.command}` — OS protocol handler installers for `engage-mockup://` URLs.
