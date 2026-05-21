<!--
SETUP-KICKOFF.md — canonical post-copy setup kickoff prompt.

How to use this file:
1. Copy the cowork-app-starter/ folder into your new project (e.g., as <project>/planning/).
2. Open a fresh Cowork chat.
3. Type a short opener like: "I just copied the kit. Set it up."
4. Copy the prompt block below (everything between the ``` fences) and paste it under
   your opener.
5. Cowork reads README.md to orient, then walks you through the 4-step quick start
   interactively — pausing for your input at every step that requires a human decision
   (platform choice, tracker creds, vision content).

Plain version: paste this into Cowork after copying the kit. Cowork does the setup
conversation with you. At the end, the kit is ready and you're handed off to Sprint 1
planning.

This template is the SETUP-phase counterpart to:
  - _sprint-templates/COWORK-PLANNING-KICKOFF.md  (planning phase, per sprint)
  - _sprint-templates/KICKOFF-PROMPT.md           (build phase, per sprint, into Claude Code)
-->

# Cowork Setup Kickoff — paste this into a fresh Cowork chat

> The prompt below assumes you've just copied the entire `cowork-app-starter/` folder
> into your new project's repo (or somewhere alongside it). It does NOT assume you've
> opened any other file in the kit — Cowork reads the README first and drives the rest
> conversationally.
>
> **One-time human prep:** none. Type one short opener line, paste the prompt block.

---

## The prompt (copy from inside the fence, paste into Cowork)

```
I just copied the cowork-app-starter kit into my project. Drive the one-time setup
interactively per README.md → "Quick start (4 steps)". Read README.md at the kit root
first to orient, then walk me through the 4 steps in order, pausing for my input at
every step that requires a human decision.

═══════════════════════════════════════════════════════════════
STEP 1 — PICK DEPLOYMENT PLATFORM
═══════════════════════════════════════════════════════════════

Read PLATFORM-SETUP.md end-to-end. Then ask me, in one freeform message (NOT
AskUserQuestion):

  "Which deployment platform do you want for this project — Vercel + Supabase, or
   Hostinger VPS? Brief pros/cons of each: <one-line each>."

Wait for my answer. After I pick:

  - Rename the chosen STARTER-DEPLOYMENT-WORKFLOW-<picked>.md to DEPLOYMENT-WORKFLOW.md
  - Delete the other STARTER-DEPLOYMENT-WORKFLOW-*.md file
  - Confirm both operations succeeded with a one-line summary

If I'm unsure, give me the 3-question decision tree from PLATFORM-SETUP.md to help me
decide.

═══════════════════════════════════════════════════════════════
STEP 2 — SET UP THE PLANNING TRACKER
═══════════════════════════════════════════════════════════════

Read TRACKER-SETUP.md end-to-end. Then walk me through the JSONbin steps:

  1. Tell me to open https://jsonbin.io in a browser, sign up / sign in, and create
     a new private bin seeded with the minimal `{"config": {...}, "items": []}` JSON
     shape (the exact seed JSON is in TRACKER-SETUP.md — print it for me to paste).
  2. Tell me how to find the Bin ID, the Master Key, and how to create a scoped
     Access Key (Read + Update, scoped to the bin).
  3. PAUSE and wait for me to paste back the Bin ID + the Access Key. Don't proceed
     until I provide both.
  4. Once I paste the keys back, populate DEFAULT_BIN_CONFIG inside
     PLANNING-TRACKER-TEMPLATE.html with my Bin ID + Access Key, keyType: 'access'.
  5. Tell me where to store the Master Key — recommend my project's secrets file
     (CREDENTIALS.md alongside the kit folder, or my project's existing secrets
     pattern). Do NOT paste the Master Key into any committed file.
  6. Confirm the tracker is ready by telling me to open PLANNING-TRACKER-TEMPLATE.html
     in a browser. If it loads with no "setup banner" and shows an empty
     Outstanding / Current Sprint / QA / Verified tab set, setup is correct.

═══════════════════════════════════════════════════════════════
STEP 3 — WRITE THE PRODUCT VISION
═══════════════════════════════════════════════════════════════

Read VISION-TEMPLATE.md end-to-end. Then have a freeform conversation with me to
fill it in:

  1. Ask me the high-level product question first: "What are you building, in one
     paragraph? Who is it for? What's the core promise?"
  2. After my answer, ask follow-ups one at a time as needed to fill in:
     - Executive Summary
     - User Types / target audience
     - Core capabilities (the ~5-10 major feature areas)
     - Tech Stack (framework, language, ORM, auth, deployment platform — use my
       Step 1 platform choice as the canonical deployment answer)
     - Anything else the template asks for that isn't obvious from my answers
  3. Once we have enough material, ask me what to name the renamed vision file —
     suggest `PROJECT-VISION.md` or `<APP-NAME>-VISION.md`. After I pick:
     - Rename VISION-TEMPLATE.md to my chosen name
     - Fill in every section from our conversation
     - Show me the result and ask if I want to revise anything before moving on

Do NOT accept a vision draft that's mostly placeholder text. Push back if my answers
are vague — this document anchors every future sprint's planning.

═══════════════════════════════════════════════════════════════
STEP 4 — HAND OFF TO SPRINT 1 PLANNING
═══════════════════════════════════════════════════════════════

After Steps 1-3 are done, summarize the kit state for me:

  - Platform chosen: <platform>; DEPLOYMENT-WORKFLOW.md present, other variant deleted
  - Tracker configured: Bin ID set in PLANNING-TRACKER-TEMPLATE.html, Master Key in
    <secrets location>
  - Vision filled: <renamed filename> reflects the product I described

Then offer to start Sprint 1 planning:

  "The kit is set up. Want to start Sprint 1 planning right now, or pick this back up
   later? If now: I'll read _sprint-templates/COWORK-PLANNING-KICKOFF.md and start
   the planning conversation. If later: copy that file's prompt block into a fresh
   Cowork chat when you're ready, with an opener like 'I'm planning Sprint 1 — first
   sprint for this project.'"

═══════════════════════════════════════════════════════════════
RULES FOR THIS SETUP CONVERSATION
═══════════════════════════════════════════════════════════════

- PAUSE for my input at every human-decision step. Don't auto-pick platform.
  Don't invent tracker creds. Don't auto-fill vision content from assumptions.
- ASK in freeform prose, not AskUserQuestion. The setup conversation is exploratory.
- BE CONCRETE. When you tell me to do something (create a JSONbin bin, paste a key),
  tell me the exact URL, the exact button name, the exact field. Don't hand-wave.
- DON'T COMMIT secrets. The Master Key never lands in a tracked file.
- DON'T SKIP STEPS. If I try to skip platform setup or tracker setup, push back —
  Sprint 1 planning depends on both being done.
- IF SOMETHING'S ALREADY DONE (I tell you "platform's already picked" or "tracker's
  already set up"), verify by reading the relevant file's state, then skip ahead.

When all 4 steps are complete, we're ready to plan Sprint 1.
```

---

## Notes

- **No find-replace needed.** Type "I just copied the kit. Set it up." (or any short
  opener) above the pasted prompt. Cowork derives everything else from the kit's
  files and your answers.

- **Skip-ahead path.** If you've already done some steps manually (e.g., you renamed
  the deployment workflow file yourself), tell Cowork in your opener: "I already
  picked Vercel + Supabase; tracker and vision still need setup." Cowork will verify
  the platform state from the files and resume from the first incomplete step.

- **What this prompt does NOT do:** it does not write code (that's Claude Code in
  Phase 2 of each sprint), it does not auto-decide platform or vision content
  (those are yours), and it does not deploy anything (Phase 3, much later).

- **Cross-references:** the planning-phase kickoff is
  `_sprint-templates/COWORK-PLANNING-KICKOFF.md`. The build-phase kickoff (for
  Claude Code, per sprint) is `_sprint-templates/KICKOFF-PROMPT.md`. The READ FIRST
  list this prompt enforces is documented in `README.md → Quick start (4 steps)`.
