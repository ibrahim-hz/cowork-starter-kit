# Quick Fixes & Small Updates

> **Tier-2 lightweight-fix workflow.** Use this instead of the full sprint process when the change is small, isolated, and low-risk.
>
> Plain version: not every change deserves a sprint folder. Tiny fixes get a one-prompt workflow instead.

---

## How to use this document

**In Cowork (thinking):** When the user says they have a quick fix, a small bug, a UI tweak, or any small change — read this file first, then follow the workflow below. Cowork reads the code, figures out what to change, and writes an all-inclusive prompt for the user to paste into Claude Code. No build plan, no sprint folder, no separate documents.

**In Claude Code (execution):** The user pastes the prompt Cowork gave them. Claude Code makes the edit, runs the project's build/test/lint commands, and confirms. One prompt in, one fix out.

**How the user triggers this:** Say anything like "I have a quick fix", "small bug", "can you tweak…", "fix this…", or "read QUICK-FIXES.md". Cowork will read this file and begin.

---

## When to use this workflow

Use this lightweight process (Tier 2) instead of the full `STARTER-PROJECT-PLANNING.md` workflow (Tier 1) when the change meets **ALL** of these criteria:

- No new database models or migrations
- No new pages or routes
- No new external integrations
- Touches 3 or fewer files
- You can describe the fix in 2-3 sentences
- Getting it wrong wouldn't break other features

**If any of these are false, use the full Tier 1 process (`STARTER-PROJECT-PLANNING.md`).**

### Examples that fit Tier 2

- Fix a toast/notification message that says the wrong thing
- Add a missing loading spinner to a button
- Change the sort order on a table
- Fix a filter that doesn't reset properly
- Adjust spacing, colors, or label text
- Add validation to an existing form field
- Fix a date format displaying incorrectly
- Update a dropdown's option list
- Fix a broken hover state or tooltip

### Examples that should be bumped to Tier 1

- "Just add a column" → needs a migration
- "Small auth change" → touches security, has ripple effects
- Anything in business-rule, workflow, or pricing logic
- Adding a new top-level module/feature
- Changes that affect more than one feature area

---

## Workflow

### Step 1: User describes the fix

The user says what's wrong or what they want changed. One or two sentences is enough.

### Step 2: Cowork reads the code

Cowork reads the relevant file(s) in the codebase to find the exact line(s) that need to change. Cowork identifies:

- Which file(s) are involved
- What the current code does
- What needs to change

### Step 3: Scope check

Before writing the prompt, Cowork checks the Tier-2 criteria above. If the fix turns out to be bigger than expected (touches more than 3 files, needs a migration, could break other features), Cowork flags it:

> "This is bigger than a quick fix — it touches [X files / needs a migration / could affect Y]. I'd recommend moving this to Tier 1 so it gets a proper build plan. Want me to set up a sprint folder instead?"

The user has the final call. They can agree and open a new Tier-1 session, or say "just do it" and proceed.

### Step 4: Cowork writes an all-inclusive prompt

Cowork writes a single, self-contained prompt that includes everything Claude Code needs:

- What the fix is and why
- Which file(s) to read
- Exactly what to change (with current code and expected result where helpful)
- Verification: run the project's build + test + lint commands and confirm zero errors

**The prompt is all-inclusive — no build plan file, no reference documents.** Claude Code should be able to paste and execute without reading anything else.

### Step 5: User pastes prompt into Claude Code

The user copies the prompt from Cowork and pastes it into a Claude Code session. Claude Code makes the edit, runs the verification commands, and reports done.

### Step 6: User verifies

The user eyeballs the change in the browser (or relevant surface). That's the only QA gate.

### Step 7: Log the fix

Cowork adds a row to the fix log table at the bottom of this file with what was changed, which files were touched, and the date. The user updates the status after Claude Code completes and they verify.

---

## Deployment

Quick fixes follow the same deployment process as Tier 1 (Phase 3 of `STARTER-PROJECT-PLANNING.md`), including the six-question release process (Questions 0-6). The difference is timing:

- **Don't deploy after every fix.** Accumulate fixes on `develop` and deploy them together as a patch release.
- **Deploy at least weekly**, or immediately if a fix is user-facing and embarrassing.
- When you're ready, tell Claude Code "let's deploy" and it walks through the same six questions (staging or production, release type, version number, summary, features/fixes, breaking changes, merge back) and handles the git workflow.

---

## Reference folder

Quick fixes do NOT create numbered sprint folders. The fix log below is your record of what changed and why. This keeps the planning workspace clean — numbered sprint folders are always Tier 1 sprints.

---

## Fix log

| # | Date | Description | Files touched | Status |
|---|------|-------------|---------------|--------|
|   |      |             |               |        |

### Status key

- ☐ Logged — fix identified, not yet made
- ◐ Prompted — prompt given to Claude Code, not yet implemented
- ☑ Done — implemented, build passes, user verified
- ✘ Bumped — too complex, moved to Tier 1
- ❌ Reverted — implemented but rolled back; row retained as audit trail

---

## Quick start prompt (copy-paste into a new Cowork session)

```
Read STARTER-QUICK-FIXES.md. I have a quick fix: [describe the issue].
```
