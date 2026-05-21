<!--
COWORK-PLANNING-KICKOFF.md — canonical planning-phase kickoff prompt.

How to use this file:
1. Open a fresh Cowork chat.
2. Type a short opener like: "I'm planning the next sprint." (No sprint number needed —
   Cowork derives it from the planning tracker. If you want to override the tracker's
   sprint number, mention the override explicitly: "I'm planning Sprint N, override.")
3. Copy the prompt block below (everything between the ``` fences) and paste it under
   your opener.
4. Cowork reads the tracker first to learn the sprint number + scope, then reads the
   standards + prior-sprint outputs + bug/ADR context, walks the live codebase, and
   surfaces the locked-in scope back to you. From there, planning proceeds per
   STARTER-PROJECT-PLANNING.md Phase 1.

Plain version: open a new Cowork chat, type "I'm planning the next sprint", paste this
prompt below it. No find-replace. No sprint number to look up. Cowork figures it out.

This template is the PLANNING-phase mirror of `_sprint-templates/KICKOFF-PROMPT.md`
(which is the BUILD-phase kickoff, pasted into Claude Code AFTER planning is done).
-->

# Cowork Planning Kickoff — paste this into a fresh Cowork chat

> The prompt below assumes the **Planning Tracker** has already been seeded — i.e., the
> previous Cowork session (or you, manually) clicked "Complete Sprint" in the tracker UI
> at `PLANNING-TRACKER-TEMPLATE.html`, which bundled approved Current Sprint items into a
> numbered Sprint group with `sprintLocked: true`. That action is what the planning
> conversation is operating on. If the tracker has no sprint-locked items, Cowork will
> say so and ask you to either bundle some via the UI or scope this sprint freeform.
>
> **One-time human prep:** none. Type one short opener line, paste the prompt block.

---

## The prompt (copy from inside the fence, paste into Cowork)

```
═══════════════════════════════════════════════════════════════
STEP 0 — READ THE PLANNING TRACKER FIRST
═══════════════════════════════════════════════════════════════

Before reading anything else, follow PLANNING-TRACKER-GUIDE.md to read the tracker bin
via the JSONbin REST API. Credentials live in the project's secrets file (e.g.,
CREDENTIALS.md, under the tracker section).

From the tracker, derive the sprint number for this planning session:

  - Look at items where status == "Current Sprint" AND sprintLocked == true.
  - Their `sprintNumber` field is the sprint we're planning. (All sprint-locked items in
    Current Sprint share the same sprintNumber by design — that's what Complete Sprint did.)
  - If multiple distinct sprintNumbers appear among sprint-locked items, halt and ask
    me which one is the planning target.
  - If NO items are sprint-locked, halt and tell me. I'll either bundle items via the
    tracker UI or scope this sprint freeform.
  - If I named a specific sprint number in my opener (e.g., "I'm planning Sprint N,
    override"), use my number — but flag the override in your first response so I know
    the tracker disagrees.

The sprint number you derived above is THIS sprint's number for everything that follows:
sprint folder name (`<N> - <theme>/`), feature branch (`feature/sprint-<N>-<short-name>`),
release version target (`v0.<N>.0-alpha.1` or your project's chosen scheme), and any
runner script names.

═══════════════════════════════════════════════════════════════
STEP 1 — READ STANDARDS + CONTEXT
═══════════════════════════════════════════════════════════════

Read all of the following before saying anything beyond a brief tracker-status note:

STANDARDS (full files):
  - STARTER-PROJECT-PLANNING.md  (or its renamed canonical PROJECT-PLANNING.md)
  - STARTER-QA-STANDARDS.md      (or QA-STANDARDS.md)
  - DEPLOYMENT-WORKFLOW.md       (the platform variant kept after install)
  - STARTER-BEFORE-LAUNCH-CHECKLIST.md  (or BEFORE-LAUNCH-CHECKLIST.md)
  - CLAUDE.md (repo root, if present)

PRIOR-SPRINT OUTPUTS (the two most recent sprints — find them by listing the planning
workspace and taking the two highest-numbered folders BELOW this sprint's number):
  - <prev sprint folder>/RETRO.md
  - <prev sprint folder>/CARRYOVER.md  (may not exist if nothing was deferred)
  - <sprint before that>/RETRO.md
  - <sprint before that>/CARRYOVER.md  (may not exist)
  - .claude-code-status/sprint-progress.json   (if present)
  - .claude-code-status/last-response.md       (if present)

BUG + DECISION CONTEXT:
  - C - Bugs/BACKLOG.md  (look for sprint-target: <this sprint> or sprint-target: next)
  - D - Decisions/INDEX.md  (read titles; open any ADR whose follow-ups touch likely scope)

CONDITIONAL — SUB-AGENT METHODOLOGY (only if a review is due):
  IF the sprint number derived in STEP 0 is a multiple of 5 (5, 10, 15, 20, ...)
     OR the past 2 retros (Sprint N−1 + N−2) mention the same uncovered bug class that
     is NOT covered by an existing reviewer in `.claude/agents/` or by a static lint rule,
  THEN also read:
     - STARTER-SUB-AGENT-METHODOLOGY.md
  This file contains the sub-agent roster + the review-sprint runbook
  (gather retro evidence → identify new patterns → evaluate roster ROI → propose changes).
  Running the runbook produces .claude/agents/*.md edits that land in this sprint's chore PR
  alongside the standard sprint folder contents (the chore-PR scope rule is intentionally
  extended to allow sub-agent file edits on review sprints — see SUB-AGENT-METHODOLOGY.md
  § Roster history).

  IF the conditions above are NOT met, SKIP this read. The methodology file is intentionally
  outside the standard kickoff load to keep planning conversations lean — every sprint
  shouldn't pay the cost of re-reading the research analysis.

TEMPLATES TO MODEL ARTIFACTS ON:
  - The most recent sprint folder's Sprint-N-Build-Plan.md, KICKOFF-PROMPT.md, QA-CHECKLIST.md
    — structural reference for the new artifacts
  - _sprint-templates/  — canonical template shapes

═══════════════════════════════════════════════════════════════
STEP 2 — CODEBASE ORIENTATION (STARTER-PROJECT-PLANNING.md §1.1)
═══════════════════════════════════════════════════════════════

Do the codebase orientation steps in order, per STARTER-PROJECT-PLANNING.md §1.1. The
exact files-to-read depend on your stack; the canonical sequence is:

  1. README.md + any active refactoring / architecture plan
  2. The schema / model layer (e.g., prisma/schema.prisma, models/, db/migrations/)
  3. Core shared libs (module registry, constants, utility files)
  4. Top-level routes / controllers / route handlers
  5. Major feature surfaces (UI clients, view layers, command palettes)
  6. Cross-cutting layers (dashboards, calendar, settings, layout)
  7. package.json (or equivalent — current version) + recent git log

⚠️ DO NOT browse old sprint folders during orientation. The live codebase is the source
of truth — past mockups and build plans may be stale.

═══════════════════════════════════════════════════════════════
STEP 3 — SURFACE THE LOCKED-IN SCOPE + ASK THE OPEN-ENDED QUESTION
═══════════════════════════════════════════════════════════════

In plain prose (NOT AskUserQuestion), do this in one message:

  1. Confirm the sprint number you derived from the tracker.
  2. List the sprint-locked items grouped under this sprint — for each, give title +
     one-line summary from `userDetails` + any `claudeResponse` already on it.
  3. Surface conflicts (in plain prose) between the locked-in scope and:
       - Sprint N−1 + N−2 RETRO / CARRYOVER anchors
       - BEFORE-LAUNCH-CHECKLIST.md open items (must-resolve-by deadlines)
       - C - Bugs/BACKLOG.md items with sprint-target: <this sprint> or sprint-target: next
       - D - Decisions/INDEX.md ADRs whose follow-ups touch the locked scope
  4. Then ask me, in plain freeform text (NOT AskUserQuestion): "Anything to add, remove,
     or refine in this scope before we build the plan?"

Wait for my freeform answer. Do NOT pre-emptively offer structured options — structured
AskUserQuestion rounds come later to REFINE, not to DISCOVER. This is the §1.0.1 meta-rule
adapted for tracker-driven planning: tracker provides the scope baseline, my freeform
answer adjusts it.

═══════════════════════════════════════════════════════════════
STEP 4 — AFTER MY FREEFORM ANSWER
═══════════════════════════════════════════════════════════════

  1. If I asked to add/remove items, update the tracker via PUT (per PLANNING-TRACKER-GUIDE
     §3 + §4) — preserve `sprintNumber` for items that move stages; only clear it when
     items are explicitly dropped from sprint scope.
  2. Answer any question-only items in my freeform list with line-cited evidence.
  3. Ask the BEFORE-LAUNCH-CHECKLIST pre-sprint question (STARTER-PROJECT-PLANNING.md §1.2):
     "Want to tackle any pre-launch items in this sprint? Top suggestion: [next-most-relevant
     open item with a one-line rationale]." Yes / no / specific item.
  4. Ask structured AskUserQuestion refinement rounds to lock the remaining details
     (sprint-shape, schema decisions if any, hotfix splits, design-system impacts, etc.).
  5. Draft the chore-PR artifacts (use the sprint number you derived in STEP 0):
       - <N> - <theme>/Sprint-<N>-Build-Plan.md  (per §1.5)
       - <N> - <theme>/KICKOFF-PROMPT.md  (copy from _sprint-templates/KICKOFF-PROMPT.md
         and search-and-replace the substitution markers)
       - <N> - <theme>/QA-CHECKLIST.md  (copy from _sprint-templates/QA-CHECKLIST.md)

═══════════════════════════════════════════════════════════════
BUILD-PLAN AUTHORING RULES (non-negotiable — STARTER-PROJECT-PLANNING.md §1.5)
═══════════════════════════════════════════════════════════════

  - Schema-first rule. Schema / model changes go in Prompt 1, ending with a verified +
    validated + generated schema BEFORE any application code.
  - Codebase-grep before prescribing labels / model names / file paths / URLs.
  - Cross-sprint verification compatibility — for every VERIFY assertion referencing a
    prior-sprint mechanism, confirm it's still operational on the target environment.
  - Pre-flight read-only verification — every destructive prod-side mutation gets a
    SELECT / GET pre-flight check first.
  - Scope boundary — build plan §7 lists what is NOT in this sprint.
  - Reference file mapping — every prompt maps to its mockup file(s).
  - Workflow / CI rule — new CI workflow files' verification is deferred to Sprint
    Completion (post-merge to develop).
  - Auth redirect-URL allow-list rule — any new `redirectTo` value: update
    DEPLOYMENT-WORKFLOW.md allow-list, push the change to staging + prod via the auth
    provider's management API, add an end-to-end assertion that the redirect works.
  - CLI token-flag prohibition — no `cli ... --token=$VAR`; use Authorization: Bearer
    curl headers OR `TOKEN=$VAR cli ...` env-only.
  - Security threat-modeling rule (per-sprint, at plan-drafting time) — if the sprint
    touches ANY of these surfaces, build plan §1 Architecture MUST include a "Security
    threat-modeling" sub-section per STARTER-PROJECT-PLANNING.md §1.5 "Security
    threat-modeling rule":
      (1) Auth flows: auth lib, middleware, login / reset routes, identity provider calls
      (2) AI bot tools: AI tool registry, messages[] constructions with user content
      (3) Billing: payment-SDK invocations, billing routes
      (4) New API routes: any new endpoint accepting POST/PUT/DELETE/PATCH
      (5) Multi-tenant data: new schema models with tenant-scoping fields, new server
          actions accepting tenant-scoped IDs
    Required content of the sub-section: (A) Threat surface, (B) Threats considered,
    (C) Mitigations per threat, (D) ADR / lint cross-references, (E) Verification check that
    confirms mitigation holds. If none of the 5 surfaces are touched, OMIT the sub-section —
    do NOT generate boilerplate "N/A" entries.

  - E2E coverage check (per-prompt, at plan-drafting time) — for each prompt in the
    Build sequence, run the 4-question check from STARTER-PROJECT-PLANNING.md §1.5:
      Q1. Does this prompt create or modify authenticated routes?
      Q2. Does this prompt modify provider trees, layouts, middleware, or files those
          import?
      Q3. Does this prompt change design-system tokens or modify any visual-regression
          surface?
      Q4. Does this prompt add a new dependency to package.json (or revive a previously-
          unused one)?
    If ANY answer is yes, bake the corresponding end-to-end test invocation into the
    prompt's VERIFY block AT PLANNING TIME — do not leave it for Claude Code to deduce at
    execution time.

═══════════════════════════════════════════════════════════════
CHORE-PR DISCIPLINE (STARTER-PROJECT-PLANNING.md §1.2)
═══════════════════════════════════════════════════════════════

The chore PR contains ONLY:
  (a) the new sprint folder + its contents
  (b) any sprint-runner / table updates that are strictly mechanical

NO lint config edits. NO ADR adds. NO test spec adds. NO doc edits. Schema edits,
dependency bumps, and code changes belong in feature-branch commits authored by Claude
Code per the build plan.

═══════════════════════════════════════════════════════════════
STEP 4.5 — PROCESS-IMPROVEMENT CHECK (planning-process improvement — codification of continuous process-review rule)
═══════════════════════════════════════════════════════════════

When I signal planning is done ("we're done planning" / "let's start building"), do NOT
immediately move to STEP 5. Run the process-improvement check FIRST. STEP 5 is gated on
this check completing.

The goal: identify anything from THIS planning conversation that improves the project's
planning / building / deployment process, and propagate it to the appropriate standards
doc so future sprints inherit the improvement.

  1. Re-read this planning conversation in this chat (everything from STEP 0 onward).
     Look specifically for:
       - New rules added during the conversation that carry (or should carry) a
         `(planning-process improvement — ...)` tag per STARTER-PROJECT-PLANNING.md §1.5
         tag convention.
       - New shapes / formats / VERIFY-block patterns / build-plan section conventions
         that should land in the project's standards docs.
       - New cross-references the standards docs don't have yet.
       - Improvements to the project's own files (PROJECT-PLANNING.md, QA-STANDARDS.md,
         DEPLOYMENT-WORKFLOW.md, sub-agent files, etc.) that I pointed out during the
         conversation.

     EXCLUDE:
       - Items tagged `(Sprint X retro — Sprint Y codification)` — those are
         retro-driven and live in the project's standards but should NOT be re-raised
         every sprint as candidates.
       - Anything that's purely about THIS sprint's scope (a one-off decision); only
         flag if the pattern is likely to recur.

  2. List the candidate items in plain prose:

       "Here are <N> items from this planning conversation that look like
        process improvements worth codifying:
         1. <item> — proposed change: <which standards file to edit and what changes>
         2. ...
       "

     If <N> is zero, say so explicitly: "No process-improvement items surfaced this
     sprint."

  3. Ask in freeform prose (NOT AskUserQuestion): "Anything else from this planning
     conversation YOU think should land in the standards docs that I missed?"

  4. After my answer:
       - For each item I approve: apply the change to the corresponding standards file.
       - For each item I decline: record the deferral in a sync / change log so it
         doesn't get re-raised every sprint.

  5. If the project is using this starter kit and you can identify items that would
     also generalize back UPSTREAM (to the kit's source / the upstream `cowork-app-starter`
     repo your team maintains), flag those separately and ask whether to surface them
     to the kit maintainer.

  6. Append an entry to the project's planning-process change log (default: a section
     of PROJECT-PLANNING.md, or a dedicated `PLANNING-PROCESS-CHANGELOG.md` if you've
     created one) regardless of outcome. Every check leaves a paper trail, even when
     the answer is "nothing changed".

  7. After the entry is written, ask me: "Process-improvement check complete. Ready
     to move to STEP 5 (finalize tracker + generate Claude Code kickoff)?"

Wait for my "yes" or further direction. Do NOT auto-advance to STEP 5 — the
process-improvement check is its own gate.

═══════════════════════════════════════════════════════════════
STEP 5 — WHEN PLANNING IS DONE
═══════════════════════════════════════════════════════════════

When I confirm planning is complete ("we're done planning" / "let's start building"):

  1. Move the in-scope tracker items from Current Sprint to QA (per PLANNING-TRACKER-GUIDE
     §4 step 8 + Common pattern "Move sprint-locked items into QA"):
       - For each finalized item: set status: "QA", sprintLocked: false. PRESERVE
         sprintNumber so the item stays in its Sprint N group on the QA tab.
       - For items the build plan dropped or deferred: set sprintLocked: false,
         sprintNumber: null, approvedForBuild: false, and note the deferral in
         claudeResponse.
     Write the bin back via PUT.

  2. Generate the build-phase kickoff prompt by copying _sprint-templates/KICKOFF-PROMPT.md
     into <N> - <theme>/KICKOFF-PROMPT.md and search-and-replacing every substitution
     marker:

       <sprint-N>                  → the sprint number
       <sprint-name>               → the sprint theme
       <sprint-version>            → v0.<N>.0-alpha.1  (or your project's version scheme)
       <branch>                    → feature/sprint-<N>-<short-name>
       <prompt-count>              → final number of execution prompts
       <prompt-1-title>            → Prompt 1's title from build plan §6
       <design-system-ref>         → mockup file path OR "not applicable this sprint (no UI surface)"
       <sprint-specific-read-list> → READ-FIRST list (DEPLOYMENT-WORKFLOW.md sections,
                                     ADR INDEX, BEFORE-LAUNCH-CHECKLIST, prior CARRYOVER, etc.)
       <schema-first-statement>    → "Sprint <N> has zero schema changes — the schema-first
                                     rule is satisfied trivially." OR sprint-specific
                                     schema note

  3. Print the final filled-in kickoff prompt block in the chat so I can copy-paste it
     into Claude Code to begin Phase 2 (development).
```

---

## Notes

- **No find-replace needed.** Type "I'm planning the next sprint" (or just "let's plan")
  above the pasted prompt. Cowork derives the sprint number from the planning tracker's
  sprint-locked items. The sprint number is canonical because Complete Sprint stamped it
  there before planning began.

- **Override path.** If you want a sprint number different from what the tracker says
  (rare — usually only when manually retrying a planning session), name it in your opener:
  "I'm planning Sprint N, override." Cowork uses your number and flags the disagreement.

- **No tracker items? Halt path.** If no items have `sprintLocked: true` when STEP 0 runs,
  Cowork will tell you and ask whether to (a) wait while you bundle items via the tracker
  UI, or (b) scope this sprint freeform without the tracker. Most planning sessions will
  go path (a).

- **What this prompt does NOT do:** it does not write code (that's Claude Code's job in
  Phase 2), it does not deploy anything (Phase 3), and it does not auto-decide scope —
  the tracker's sprint-locked items + your freeform refinement drive scope together.

- **Cross-references:** the build-phase mirror is `_sprint-templates/KICKOFF-PROMPT.md`.
  Tracker conventions are in `PLANNING-TRACKER-GUIDE.md`. The Phase 1 rules this prompt
  enforces all live in `STARTER-PROJECT-PLANNING.md` §1.0.1 through §1.8.
