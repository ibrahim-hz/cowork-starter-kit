# Cowork App Starter Kit

> A portable starter kit that gives any new application project a complete planning, building, and deployment workflow on day 1.
>
> Drop this folder into a new project, complete a one-time setup (~30 minutes), and you've inherited a battle-tested Phase 1 (planning) / Phase 2 (development) / Phase 3 (deployment) process — including sub-agent code review, security checklist, planning tracker integration, and sprint discipline.
>
> **Plain version:** copy this folder into your new app, fill in 5 templates, paste a kickoff prompt into Cowork. You now have a full development process.

---

## What this is

`cowork-app-starter` is a stripped-down, portable version of a production planning workflow. It includes:

- **Phase 1 (Planning) — Cowork conventions.** Codebase orientation, mockup-first design, open-ended-question meta-rule, sprint folder structure, chore PR discipline.
- **Phase 2 (Development) — Claude Code conventions.** The proceed-handshake one-prompt-at-a-time execution style, per-prompt VERIFY blocks, sub-agent code review (including S1–S15 security checklist), QA standards.
- **Phase 3 (Deployment) — release process.** Branch strategy, release Q&A, post-deploy verification, rollback. Two variants ship: Vercel + Supabase, or Hostinger VPS.
- **Bug + decision logs.** `C - Bugs/` for filed bugs not yet fixed; `D - Decisions/` for architectural decision records (ADRs).
- **Planning tracker.** A JSONbin-backed HTML tracker for capturing planning items across Outstanding / Current Sprint / QA / Verified stages.
- **Sub-agent layer.** 3 default Claude Code agents (code reviewer with full security checklist, test runner, docs researcher) + 5 optional agents (Next.js boundary, provider chain, dedicated security, external-API resilience, build-plan step-ordering) + 6 stack-template reviewers (Vue/Nuxt, Django, Rails, React-Vite, Express/Node, generic Python).
- **A 5-sprint review cadence** for evolving the sub-agent roster as your codebase matures.

---

## Quick start (4 steps)

### Step 1 — Copy this folder into your new project

```bash
# Drop the entire cowork-app-starter/ folder into your new project's repo root,
# or wherever your planning artifacts live (commonly: <project>/planning/ or
# <project>/reference/).
cp -r cowork-app-starter/ <your-new-project>/planning/

# Then cd into the destination.
cd <your-new-project>/planning/
```

### Step 2 — Let Cowork drive the rest of setup (recommended)

Open a fresh Cowork chat. Type a short opener (`I just copied the kit. Set it up.`), then paste the prompt block from [`SETUP-KICKOFF.md`](./SETUP-KICKOFF.md) below it. Cowork reads this README to orient, then walks you through the platform pick + tracker setup + vision conversation interactively, pausing for your input at every step that requires a human decision. Typical time: 20-30 minutes.

If you'd rather drive setup manually instead of conversationally, follow Steps 2a-2c below.

### Step 2a — Pick your deployment platform (manual path)

Open [`PLATFORM-SETUP.md`](./PLATFORM-SETUP.md). It asks one question: **Vercel + Supabase, or Hostinger VPS?** Follow the steps for the platform you chose — it renames one of the two `STARTER-DEPLOYMENT-WORKFLOW-*.md` files to the canonical `DEPLOYMENT-WORKFLOW.md` and deletes the other.

### Step 2b — Set up the planning tracker (manual path)

Open [`TRACKER-SETUP.md`](./TRACKER-SETUP.md). It walks you through creating a JSONbin.io bin for your project (5–10 minutes), getting the Master Key + Access Key, and populating `PLANNING-TRACKER-TEMPLATE.html` with your bin ID.

### Step 2c — Write your product vision (manual path)

Open [`VISION-TEMPLATE.md`](./VISION-TEMPLATE.md). Rename it to your project's vision document (e.g., `PROJECT-VISION.md` or `<APP-NAME>-VISION.md`). Fill in the sections — Executive Summary, User Types, Tech Stack, etc. This is your north-star document; sprint planning hangs off it.

### Step 3 — Plan Sprint 1

Whether you used the Cowork-driven path (Step 2) or the manual path (Steps 2a-2c), Sprint 1 starts the same way: copy the prompt from [`_sprint-templates/COWORK-PLANNING-KICKOFF.md`](./_sprint-templates/COWORK-PLANNING-KICKOFF.md), type a short opener (`I'm planning Sprint 1 — first sprint for this project`), and paste the prompt below it. Cowork takes over from there.

If you used Step 2 (the SETUP-KICKOFF flow), Cowork will offer to roll straight into Sprint 1 planning at the end of setup — you can either accept and skip ahead, or pause and resume later by pasting `COWORK-PLANNING-KICKOFF.md` into a fresh chat.

That's it. The rest of this README is reference for what's in the kit and when you'd touch each piece.

---

## Folder map

```
cowork-app-starter/   (or whatever you renamed it to in your project)
│
├── README.md                                          ← this file
├── STARTER-KIT-BUILD-PLAN.md                          ← record of how this kit was assembled
├── STARTER-KIT-SYNC-LOG.md                            ← log of Engage → kit syncs
│
├── SETUP-KICKOFF.md                                   ← post-copy setup kickoff prompt (paste into Cowork)
├── VISION-TEMPLATE.md                                 ← rename + fill in for your project
├── TRACKER-SETUP.md                                   ← one-time JSONbin walkthrough
├── PLATFORM-SETUP.md                                  ← Vercel vs Hostinger picker
│
├── STARTER-PROJECT-PLANNING.md                        ← canonical Phase 1/2/3 process
├── STARTER-QA-STANDARDS.md                            ← per-prompt + per-sprint QA discipline
├── STARTER-DEPLOYMENT-WORKFLOW-vercel-supabase.md     ← keep one, delete the other (see PLATFORM-SETUP)
├── STARTER-DEPLOYMENT-WORKFLOW-hostinger-vps.md       ← keep one, delete the other
├── STARTER-QUICK-FIXES.md                             ← Tier-2 lightweight-fix workflow
├── STARTER-BEFORE-LAUNCH-CHECKLIST.md                 ← deferred items to close before public launch
├── STARTER-CLAUDE-CODE-RUNBOOK.md                     ← production incident triage table (template)
├── STARTER-SUB-AGENT-METHODOLOGY.md                   ← agent roster + cadence rule + agent catalog
│
├── PLANNING-TRACKER-TEMPLATE.html                     ← your tracker UI (populate via TRACKER-SETUP)
├── PLANNING-TRACKER-GUIDE.md                          ← how Cowork reads/writes the tracker
│
├── _sprint-templates/                                 ← copied per sprint
│   ├── README.md
│   ├── KICKOFF-PROMPT.md                              ← Claude Code (build phase) kickoff
│   ├── COWORK-PLANNING-KICKOFF.md                     ← Cowork (planning phase) kickoff
│   ├── QA-CHECKLIST.md
│   ├── RETRO.md
│   ├── CARRYOVER.md
│   └── _proceed-handshake-snippet.md
│
├── .claude/                                           ← Claude Code project config
│   ├── settings.json                                  ← baseline Cowork permissions
│   └── agents/                                        ← default sub-agents (3)
│       ├── code-reviewer.md                           ← with full S1–S15 security checklist
│       ├── test-runner.md                             ← Vitest/Jest/pytest runner
│       └── docs-researcher.md                         ← API signature lookup
│
├── _optional-agents/                                  ← optional reviewers (copy into .claude/agents/ if needed)
│   ├── README.md
│   ├── next-js-server-client-boundary-reviewer.md     ← if your stack is Next.js App Router
│   ├── next-js-provider-chain-reviewer.md             ← if your stack uses React Provider patterns
│   ├── dedicated-security-reviewer.md                 ← if you want a separate reviewer for security alone
│   ├── external-api-resilience-reviewer.md            ← if your app heavily integrates third-party APIs
│   └── build-plan-step-ordering-reviewer.md           ← Cowork-side reviewer for schema-step ordering
│
├── _stack-templates/                                  ← starter reviewers for stacks other than Next.js
│   ├── README.md
│   ├── vue-nuxt-reviewer.md
│   ├── django-reviewer.md
│   ├── rails-reviewer.md
│   ├── react-vite-reviewer.md
│   ├── express-node-reviewer.md
│   └── generic-python-reviewer.md
│
├── C - Bugs/                                          ← bug backlog (starts empty)
│   ├── README.md
│   ├── BACKLOG.md
│   ├── _template.md
│   ├── open/
│   ├── fixed/
│   └── wont-fix/
│
├── D - Decisions/                                     ← ADR log (starts empty)
│   ├── README.md
│   ├── INDEX.md
│   └── _template.md
│
└── 1 - First Sprint Placeholder/                      ← canonical empty sprint folder shape
    ├── Sprint-1-Build-Plan.md
    ├── KICKOFF-PROMPT.md
    ├── QA-CHECKLIST.md
    └── mockups/
```

---

## Customize for your stack

The kit ships with three "tracks" for sub-agent coverage. Pick the one that fits.

### Track A — Stack-agnostic (default, no action needed)

The 3 default agents in `.claude/agents/` are stack-agnostic:
- `code-reviewer` — general diff review + full S1–S15 security checklist
- `test-runner` — adapts to your project's test framework (reads test command from `package.json` or equivalent)
- `docs-researcher` — looks up current API signatures for whatever stack you tell it

**If your stack is novel, niche, or you're not sure yet — use Track A.** You can always add specialists later via the 5-sprint review.

### Track B — Next.js App Router (use the optional agents)

If your project is Next.js (especially App Router with server/client components):

```bash
cp _optional-agents/next-js-server-client-boundary-reviewer.md .claude/agents/
cp _optional-agents/next-js-provider-chain-reviewer.md .claude/agents/
```

These two agents catch the most common Next.js-specific bug classes (missing `"use client"`, providers unwired from the layout tree).

### Track C — Other stacks (start with a stack template)

If your project is Vue/Nuxt, Django, Rails, React without Next.js, Express/Node, or pure Python:

```bash
# Pick the matching template — example for Django:
cp _stack-templates/django-reviewer.md .claude/agents/
# Open and edit the file — most templates need light customization for your project's specifics.
```

The stack templates are starting points; you'll typically tune the system prompts to your project's actual patterns within 1–2 sprints.

### Adding more agents over time

After Sprint 5, 10, 15 etc., your `STARTER-SUB-AGENT-METHODOLOGY.md` says to review the agent roster. At that review, you can pull in any agent from `_optional-agents/` or `_stack-templates/` that the past 5 sprints' retros suggest you'd benefit from. The methodology file has the full catalog with criteria.

---

## The workflow at a glance

### Phase 1 — Planning (in Cowork)

1. Open a fresh Cowork chat.
2. Type "I'm planning Sprint N" + paste the prompt from `_sprint-templates/COWORK-PLANNING-KICKOFF.md`.
3. Cowork reads the standards, walks your codebase, reads the planning tracker for already-locked items, and asks you (in plain English): "What do you want included in Sprint N?"
4. After freeform conversation, Cowork drafts the sprint folder + build plan + QA checklist + kickoff prompt for Claude Code.
5. You commit the chore PR (sprint folder only — no code changes) and the planning is locked.

### Phase 2 — Development (in Claude Code)

1. Open Claude Code in your project.
2. Paste the kickoff prompt from `<N> - <Sprint Theme>/KICKOFF-PROMPT.md`.
3. Claude Code reads the standards + build plan, outputs a PRE-FLIGHT block confirming scope, and runs SETUP (branch, baseline build/test/lint).
4. After SETUP, type `proceed` to begin Prompt 1.
5. Claude Code executes Prompt 1, runs VERIFY (build + test + lint + sub-agent code review + conditional Playwright + conditional specialized reviewers), and stops with a completion report.
6. Review the report. Type `proceed` to advance, or paste feedback to revise.
7. Repeat for each prompt until the sprint completes.

### Phase 3 — Deployment

When the sprint's branch is ready to merge to `develop`:
1. Run through the release Q&A in `DEPLOYMENT-WORKFLOW.md` (Questions 0–6 plus pre-question code analysis).
2. Cut a release branch, bump version, open PR to `main` (production) or just push `develop` (staging).
3. Verify the deploy with the post-deploy checklist.
4. If issues: rollback procedure documented in the same file.

---

## Tracker setup

The planning tracker (`PLANNING-TRACKER-TEMPLATE.html`) is a self-contained HTML page backed by JSONbin.io. It captures planning items across four stages (Outstanding → Current Sprint → QA → Verified) and survives across Cowork sessions.

**Each project needs its own JSONbin bin.** Do NOT reuse a bin across projects — items will collide.

Walkthrough: [`TRACKER-SETUP.md`](./TRACKER-SETUP.md). About 10 minutes.

The tracker's role in the workflow:
- You add items to **Outstanding** as ideas come up.
- You move priority items to **Current Sprint** (or Cowork does, based on your direction).
- When you've approved enough items, click **Complete Sprint** in the tracker UI. The items get a sprint number stamped on them.
- Cowork reads the sprint-locked items at the start of Sprint N planning — they're the scope baseline.
- After Claude Code ships the work, items move to **QA**.
- You verify in QA; pass → **Verified**, fail → back to Current Sprint with a "QA Failed · Sprint N" tag.

The `_sprint-templates/COWORK-PLANNING-KICKOFF.md` prompt is tracker-aware: it derives the sprint number from the tracker (no find-replace required).

---

## Platform setup

The kit ships with two `STARTER-DEPLOYMENT-WORKFLOW-*.md` variants. Pick one during setup; delete the other.

- **Vercel + Supabase:** Hosted Next.js (or similar) on Vercel with Supabase Postgres + Auth + Storage. Auto-deploy on push to `main`/`develop`. Best for fast iteration, low ops overhead.
- **Hostinger VPS:** Self-hosted on a Hostinger VPS (Ubuntu 22/24) with PostgreSQL on the same VPS, deployed via git-pull + PM2 + nginx + Let's Encrypt. Best for cost control, full server access, or when you need long-running background workers.

Walkthrough: [`PLATFORM-SETUP.md`](./PLATFORM-SETUP.md). About 5 minutes.

After setup, one of the two files becomes your canonical `DEPLOYMENT-WORKFLOW.md`; the other is deleted from the project.

---

## When to evolve the process

This kit is a **starting point**, not a final state. The upstream source project's process accumulated learnings across many sprints; yours will too. Mechanisms for evolving:

### 1. Add rules from your own retros

Every sprint's `RETRO.md` surfaces "What didn't work" and "Surprises." When a pattern repeats across multiple retros, codify it as a rule in your `STARTER-PROJECT-PLANNING.md` (which you'll likely rename to just `PROJECT-PLANNING.md` after install) using the **retro-driven tag convention**: `(Sprint X retro — Sprint Y codification)`.

For proactive process improvements (not retro-driven), use the **proactive tag**: `(planning-process improvement — ...)`. This distinction matters for the sync mechanism below.

### 2. Review sub-agents every 5 sprints

`STARTER-SUB-AGENT-METHODOLOGY.md` defines a cadence: every 5 sprints (Sprint 5, 10, 15, 20, ...) Cowork reviews the past 5 retros and proposes additions/retirements to the sub-agent roster. The methodology file has a comprehensive **agent catalog** so the review can consider all available options, not just what's currently installed.

### 3. Sync from the upstream source project periodically

The kit was assembled from the upstream source project's planning workflow at a specific point in time. As the upstream adds new `(planning-process improvement — ...)` rules, you can backport them to this kit and (optionally) into your own project. See [`STARTER-KIT-SYNC-LOG.md`](./STARTER-KIT-SYNC-LOG.md) for the sync log and procedure. Default cadence: quarterly, or operator-triggered.

---

## Cross-reference index — which file covers what

| Topic | File |
|---|---|
| Master overview (you're reading it) | `README.md` |
| Planning, building, deployment process | `STARTER-PROJECT-PLANNING.md` |
| Per-prompt + per-sprint QA discipline | `STARTER-QA-STANDARDS.md` |
| Vercel + Supabase deployment | `STARTER-DEPLOYMENT-WORKFLOW-vercel-supabase.md` |
| Hostinger VPS deployment | `STARTER-DEPLOYMENT-WORKFLOW-hostinger-vps.md` |
| Tier-2 lightweight-fix workflow | `STARTER-QUICK-FIXES.md` |
| Pre-launch security/operational items | `STARTER-BEFORE-LAUNCH-CHECKLIST.md` |
| Production incident triage | `STARTER-CLAUDE-CODE-RUNBOOK.md` |
| Sub-agent roster + cadence + agent catalog | `STARTER-SUB-AGENT-METHODOLOGY.md` |
| Planning tracker conventions | `PLANNING-TRACKER-GUIDE.md` |
| One-time tracker setup | `TRACKER-SETUP.md` |
| One-time platform picker | `PLATFORM-SETUP.md` |
| Post-copy setup kickoff prompt | `SETUP-KICKOFF.md` |
| Product vision (rename + fill in) | `VISION-TEMPLATE.md` |
| Sprint folder templates | `_sprint-templates/` |
| Default sub-agents | `.claude/agents/` |
| Optional reviewers (Next.js, security, resilience, etc.) | `_optional-agents/` |
| Stack-specific reviewer templates | `_stack-templates/` |
| Bug backlog | `C - Bugs/` |
| Architectural decision records | `D - Decisions/` |
| First sprint folder shape | `1 - First Sprint Placeholder/` |
| Engage → kit sync log | `STARTER-KIT-SYNC-LOG.md` |
| How this kit was assembled | `STARTER-KIT-BUILD-PLAN.md` |

---

## What this kit is NOT

- **NOT a substitute for understanding the process.** The conventions encoded here came from real production incidents. The kit gives you the structure; treat each retro you write as an opportunity to add to that structure.
- **NOT a tech-stack constraint.** The default agents are stack-agnostic. The optional Next.js agents and stack templates are exactly that — optional.
- **NOT a deployment platform constraint.** Vercel and Hostinger are the two shipped variants; if you use Railway, Render, Fly, AWS, or anything else, rewrite `DEPLOYMENT-WORKFLOW.md` for your platform using the existing variants as structural templates.
- **NOT a magic productivity machine.** It's process discipline. The first sprint will feel slow (you're learning the conventions). By Sprint 3 it'll feel natural. By Sprint 10 you'll be wondering how you ever worked without it.

---

## Kit governance + upstream sync

This kit is maintained from a private upstream project that drives ongoing improvements. The relationship is **strictly one-directional**:

- **Upstream → kit:** Improvements (new rules, refined conventions, new sub-agents, bug fixes) flow from the upstream project's sprint planning sessions into this kit. Roughly once per sprint, the upstream's planning workflow runs a kit-sync check, identifies generalizable improvements from the conversation, and pushes them here.
- **Kit → downstream apps:** When you copy the kit into a new project, that project owns its local copy. Your local edits stay local. To pick up kit improvements made upstream, you re-pull (or re-copy) the kit's latest published state and reconcile with your local customizations.
- **App-specific content NEVER flows INTO the kit.** This is intentional. The kit must stay generic so it remains useful across many projects. Domain-specific terms, business logic, customer data, secrets, and project-specific examples are scrubbed at the upstream sync boundary and never land in this repo.

**Why this matters for you (as a kit user):**

- The kit you cloned is a snapshot at a point in time. The upstream may have added new rules since you cloned. Periodically re-check this repo for updates — or set up a sync script in your project that pulls the latest kit content into your `planning/` folder without overwriting your project-specific files (e.g., your `PROJECT-VISION.md`, your sprint folders, your tracker config).
- If you fork the kit and customize it, your fork diverges from upstream. That's fine — but you lose the automatic improvement flow. Decide consciously whether to track upstream or fork.
- If you contribute back, the path is: open an issue or discussion on this repo describing the convention you want added. The upstream maintainer will evaluate whether it generalizes to other projects (most improvements do; some are too domain-specific to land here). Direct PRs are welcome but evaluation happens through the upstream's planning process, not a quick merge.

**The kit's audit trail:** Each upstream sync into this kit is logged in `STARTER-KIT-SYNC-LOG.md` (in this folder, gitignored from the public mirror but visible to the upstream maintainer). The kit's own construction history is in `STARTER-KIT-BUILD-PLAN.md` for anyone curious about how the kit was assembled.

---

## Ready to start

→ Read [`PLATFORM-SETUP.md`](./PLATFORM-SETUP.md) (Step 2 of Quick Start).
