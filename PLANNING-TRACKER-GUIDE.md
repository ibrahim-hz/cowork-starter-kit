# Planning Tracker — Guide for Claude Cowork

> How to read, edit, and respect the conventions of the continuous planning tracker.
>
> Plain version: the tracker is a web page backed by a cloud JSON store. This file tells Cowork exactly how to talk to it without breaking the workflow conventions.

---

## Where things live

The tracker UI lives at `PLANNING-TRACKER-TEMPLATE.html` (or whatever you renamed it to during install). The live data lives in a JSONbin.io bin — **the HTML is just a shell**. Always read/write through the JSONbin REST API, never by modifying the `<script id="tracker-data">` block inside the HTML.

Credentials live in your project's secrets file (e.g., `CREDENTIALS.md`) under the tracker section. Two keys are typically listed there:

- **X-Master-Key** — full account access. Use this from Claude Code / trusted tooling that calls JSONbin directly.
- **Access Key** — scoped Read+Update on this single bin. Embedded in `DEFAULT_BIN_CONFIG` inside the deployed HTML so first-time visitors auto-connect with no setup banner.

JSONbin enforces the matching HTTP header. The Master Key MUST be sent as `X-Master-Key`; the Access Key MUST be sent as `X-Access-Key`. Sending one under the other's header returns `HTTP 401 "X-Master-Key is invalid or the bin doesn't belong to your account"`. When in doubt, the deployed page auto-detects via the `detectKeyType()` helper and self-heals stale localStorage via `jsonbinRequest()` (retries with the other header on 401 and rewrites the stored `keyType`).

See `TRACKER-SETUP.md` for the one-time bin creation walkthrough.

---

## 1. Reading the tracker

```
GET https://api.jsonbin.io/v3/b/<BIN_ID>/latest
Headers:
  X-Master-Key: <X-MASTER-KEY>        # use the Master Key from your secrets file
  X-Bin-Meta: false
```

If using the Access Key instead, swap the header name to `X-Access-Key` (same key value goes there — JSONbin rejects either key under the wrong header).

Response is the raw tracker state JSON: `{ "config": {...}, "items": [...] }`. From Claude Code, the easiest invocation is `curl` via bash. `WebFetch` works for simple reads too, but `curl` is more reliable for repeated calls and inspecting headers.

Plain: open the bin, get back the same shape of JSON that's embedded in the HTML file.

## 2. Writing the tracker

```
PUT https://api.jsonbin.io/v3/b/<BIN_ID>
Headers:
  X-Master-Key: <X-MASTER-KEY>        # or X-Access-Key: <ACCESS_KEY> — pick one
  Content-Type: application/json
  X-Bin-Versioning: false
Body:
  <full updated tracker state JSON>
```

Always read first, modify in place, write the entire object back. JSONbin overwrites the entire bin contents on each `PUT` — partial writes will wipe everything else.

If you're scripting a bulk update from inside the running planner (browser DevTools), prefer calling `await loadState()` first to refresh `state` from the bin, mutating `state.items` / `state.config` directly, then `await saveToCloud()` — that goes through the auto-heal path and surfaces auth errors loudly.

Plain: grab the whole thing, change what you need, put the whole thing back.

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
- The collapsed/expanded state of each group is per-browser-session (`collapsedSprintGroups: Set`) and NOT persisted to JSONbin.

## 4b. UI affordances Claude should be aware of

- **Copy + Delete buttons are Outstanding-only.** Current Sprint, QA, and Verified cards do NOT expose copy or delete. This is a deliberate guard so committed work isn't casually duplicated or lost. If Claude needs to duplicate or delete an item that's past Outstanding, do it via direct JSON edit (read the bin, splice the array, write the bin), and tell the user.
- **Outstanding cards participate in the color cycle.** A blue left accent = "awaiting your review" (Claude wrote `claudeResponse` last). A pink background = "pending Claude review" (`pendingClaudeReview: true`, user edited details after Claude responded). This matches the Current Sprint and QA behavior.
- **Save errors are loud.** `saveToCloud` pops a JS `alert()` on failure in addition to the status pill so auth or network failures can't slip past unnoticed.
- **Auto-heal is silent.** If a load or save returns 401 with the configured `keyType`, `jsonbinRequest()` retries with the opposite header. If the retry succeeds, localStorage is rewritten with the corrected `keyType` and a `console.info` line logs the fix. The user sees nothing unusual.

## 5. Common patterns

### "Pull the tracker" / "Review the tracker"

1. Read the bin via the `GET` endpoint.
2. Look at items in the Current Sprint or QA tab (filter by `status`).
3. Add or update `claudeResponse` where needed.
4. Clear `pendingClaudeReview: false` on items where you've addressed user feedback.
5. Write the full state back via `PUT`.

### "Promote an item from Outstanding to Current Sprint"

1. Read the bin.
2. Find the item by id or title, change `status` from `"Outstanding"` to `"Current Sprint"`.
3. Optionally set `priority: "Yes"` if appropriate.
4. Write the bin back.

### "Move sprint-locked items into QA"

1. Read the bin.
2. For each item with `sprintLocked: true` that's part of the finalized build plan, set `status: "QA"` and `sprintLocked: false`. **Leave `sprintNumber` alone** — it must persist so the item stays inside its Sprint N collapsible group on the QA tab.
3. For items the build plan dropped or pushed to a future sprint, set `sprintLocked: false` AND `sprintNumber: null` (returns them to the ungrouped Current Sprint pool, ready for next sprint). Also set `approvedForBuild: false` so the user can re-evaluate, and note in `claudeResponse` why they were deferred.
4. Write the bin back.

### "Promote a bounced QA-failed item back into a new sprint"

1. Read the bin.
2. The bounced item is in Current Sprint with `qaFailed: true`, `pendingClaudeReview: true`, `lastSprintNumber: <prev>`, `sprintNumber: null`.
3. Address Claude's feedback (update `claudeResponse`), clear `pendingClaudeReview: false`.
4. Leave `qaFailed: true` untouched (only Verified clears it) — the "QA Failed · Sprint N" badge stays visible until verified.
5. Write the bin back. The user will re-approve and the next Complete Sprint will bundle it with a fresh `sprintNumber`.

### "Address pending Claude review items"

1. Read the bin.
2. Filter items where `pendingClaudeReview: true` (these are pinned to the top of the UI in their tab).
3. Read the updated `userDetails` to see what the user added.
4. Update `claudeResponse` to address it.
5. Set `pendingClaudeReview: false`.
6. Write the bin back.

---

## 6. Source of truth

The bin is canonical. Never trust the embedded `<script id="tracker-data">` block in the HTML — it's only used as the initial seed for first-time bin creation, never updated after that. If you read the HTML file directly, you're reading stale data.

If for some reason the bin is unreachable (JSONbin down, network issue), say so to the user. Don't fall back to editing the HTML's embedded JSON — those edits won't reach the live tracker.

---

## Cross-references

- `TRACKER-SETUP.md` — one-time JSONbin bin creation + key-pasting walkthrough.
- `PLANNING-TRACKER-TEMPLATE.html` — the deployed shell + initial seed JSON.
- `_sprint-templates/COWORK-PLANNING-KICKOFF.md` — kickoff prompt that reads the tracker first to derive the sprint number.
- `STARTER-PROJECT-PLANNING.md` §1 — planning phase, which is tracker-driven from sprint 2 onward.
