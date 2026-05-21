# Cowork App Starter Kit — Build Plan

> Build plan for assembling the `cowork-app-starter/` package. Executed via 5-phase proceed-handshake mirroring Engage's sprint workflow. Each phase produces a coherent group of files, ends with a completion summary, and stops for `proceed` before continuing to the next phase.

---

## 1. Purpose

`cowork-app-starter/` is a portable starter kit you can copy into any new application project. After dropping the folder in + minor one-time configuration (create a new JSONbin for the tracker, customize for tech stack + deployment platform), the project inherits Engage's full planning, building, and deployment workflow.

It is a **stripped-down generalization** of Engage's `0 - START PLANNING HERE/` and related structures. Conventions and process are preserved verbatim. Engage-specific examples, retro citations, BUG references, and ADR numbers are replaced with placeholder text or generic equivalents.

Plain version: drop this folder into a new app, fill in 4-5 templates, and you've inherited the whole Engage workflow without having to rebuild it.

---

## 2. Architecture

The kit ships as a single folder copied into the new project's repo (or alongside it). It mirrors Engage's `0 - START PLANNING HERE/` directory shape where applicable, with these adaptations:

- Per-project specifics (CREDENTIALS.md, ENGAGE-VISION.md) → replaced with templates the new project fills in
- Engage's specific bugs/decisions/sprints → replaced with empty structural skeletons
- Next.js-specific sub-agents → preserved in `_optional-agents/` (use only if your stack is Next.js App Router)
- Multi-stack reviewer starters → new `_stack-templates/` folder for Vue/Django/Rails/etc.
- Two deployment workflow variants → Vercel + Supabase OR Hostinger VPS, Cowork picks during install
- Strengthened security checklist (S1-S15 + BLOCKING-only severity) → baked into the default code-reviewer

---

## 3. Folder map — target shape after Phase 5

```
cowork-app-starter/
├── STARTER-KIT-BUILD-PLAN.md                          ← THIS FILE
├── README.md                                          ← MASTER DOC (Phase 1)
├── STARTER-KIT-SYNC-LOG.md                            ← Engage → kit sync history (Phase 1)
├── VISION-TEMPLATE.md                                 ← Phase 1
├── TRACKER-SETUP.md                                   ← JSONbin walkthrough (Phase 1)
├── PLATFORM-SETUP.md                                  ← Vercel vs Hostinger picker (Phase 1)
│
├── STARTER-PROJECT-PLANNING.md                        ← Phase 2
├── STARTER-QA-STANDARDS.md                            ← Phase 2
├── STARTER-DEPLOYMENT-WORKFLOW-vercel-supabase.md     ← Phase 2
├── STARTER-DEPLOYMENT-WORKFLOW-hostinger-vps.md       ← Phase 2
│
├── STARTER-QUICK-FIXES.md                             ← Phase 3
├── STARTER-BEFORE-LAUNCH-CHECKLIST.md                 ← Phase 3
├── STARTER-CLAUDE-CODE-RUNBOOK.md                     ← Phase 3
├── STARTER-SUB-AGENT-METHODOLOGY.md                   ← Phase 3 (with comprehensive agent catalog)
├── PLANNING-TRACKER-GUIDE.md                          ← Phase 3
├── PLANNING-TRACKER-TEMPLATE.html                     ← Phase 3
│
├── _sprint-templates/                                 ← Phase 4
│   ├── README.md
│   ├── KICKOFF-PROMPT.md
│   ├── COWORK-PLANNING-KICKOFF.md
│   ├── QA-CHECKLIST.md
│   ├── RETRO.md
│   ├── CARRYOVER.md
│   └── _proceed-handshake-snippet.md
│
├── .claude/
│   ├── settings.json                                  ← Phase 4
│   └── agents/                                        ← Phase 4 (default 3 agents)
│       ├── code-reviewer.md                           ← with S1-S15 security checklist
│       ├── test-runner.md
│       └── docs-researcher.md
│
├── _optional-agents/                                  ← Phase 4 (Engage-derived candidates)
│   ├── README.md
│   ├── next-js-server-client-boundary-reviewer.md
│   ├── next-js-provider-chain-reviewer.md
│   ├── dedicated-security-reviewer.md
│   ├── external-api-resilience-reviewer.md
│   └── build-plan-step-ordering-reviewer.md
│
├── _stack-templates/                                  ← Phase 5
│   ├── README.md
│   ├── vue-nuxt-reviewer.md
│   ├── django-reviewer.md
│   ├── rails-reviewer.md
│   ├── react-vite-reviewer.md
│   ├── express-node-reviewer.md
│   └── generic-python-reviewer.md
│
├── C - Bugs/                                          ← Phase 1 (empty structure)
│   ├── README.md
│   ├── BACKLOG.md
│   ├── _template.md
│   ├── open/
│   ├── fixed/
│   └── wont-fix/
│
├── D - Decisions/                                     ← Phase 1 (empty structure)
│   ├── README.md
│   ├── INDEX.md
│   ├── _template.md
│   └── (no per-ADR files — first project ADR goes here as 0001-<short-name>.md)
│
└── 1 - First Sprint Placeholder/                      ← Phase 5
    ├── Sprint-1-Build-Plan.md
    ├── KICKOFF-PROMPT.md
    ├── QA-CHECKLIST.md
    └── mockups/
        └── .gitkeep
```

Total files: ~45. Distributed across phases per §5 below.

---

## 4. Scope boundary — what is NOT in this kit

Explicitly excluded (so future Cowork sessions know NOT to add these during execution):

- **`ENGAGE-VISION.md`** — replaced with empty `VISION-TEMPLATE.md`. Setup process walks the new project through filling it in.
- **Engage's specific BUG-XXX files** — empty `C - Bugs/` structure only. New project starts with empty backlog.
- **Engage's specific ADR-XXXX files** — empty `D - Decisions/INDEX.md` + `_template.md` only. First ADR for the new project goes in as `0001-<topic>.md`.
- **Engage's past sprint folders** (Sprint 1 through Sprint 28) — replaced with single `1 - First Sprint Placeholder/` showing the canonical empty sprint folder shape.
- **Engage's specific lint rules in code** (e.g., `no-slate-tokens`, `no-prisma-in-middleware`) — the kit documents the PATTERN for adding lint rules but does not ship Engage's specific rules.
- **`CREDENTIALS.md`** — each project's secrets file is project-specific.
- **`A - Sprint Runners/` automation scripts** — skipped per decision in planning conversation. Manual proceed-handshake only.
- **All retro-driven examples from Engage's PROJECT-PLANNING.md** — replaced with placeholder text or short generic examples. Citation format `(Sprint X retro — Sprint Y codification)` retained as a convention, but no specific Engage retro entries are carried over.

---

## 5. Build sequence — 5 phases (proceed-handshake)

Each phase produces a coherent group of files. After completing a phase, I emit a brief completion summary listing files created + any deferred items + the canonical handshake footer (`Status: STOPPED for review. Reply 'proceed' to begin Phase N+1.`). You review, type `proceed`, and the next phase executes.

### Phase 1 — Foundation + Setup Flow (~11 files)

**Files:**
1. `README.md` — MASTER DOC. Quick-start, folder map, customize-for-your-stack checklist, workflow overview, tracker setup, first-sprint kickoff, when to evolve the process. **Load-bearing — drafted first because everything else hangs off it.**
2. `STARTER-KIT-SYNC-LOG.md` — initial sync log entry (sourced from Engage's state at this conversation's time)
3. `VISION-TEMPLATE.md` — empty product-vision skeleton (sections: Executive Summary, User Types, Tech Stack, etc.)
4. `TRACKER-SETUP.md` — JSONbin creation + Master Key + Access Key + credentials placement walkthrough
5. `PLATFORM-SETUP.md` — Vercel vs Hostinger picker (Cowork asks user, then renames the appropriate STARTER-DEPLOYMENT-WORKFLOW variant to canonical name and deletes the other)
6. `C - Bugs/README.md` — bug triage + filing conventions
7. `C - Bugs/BACKLOG.md` — empty index
8. `C - Bugs/_template.md` — bug-file template
9. `D - Decisions/README.md` — ADR conventions
10. `D - Decisions/INDEX.md` — empty ADR index
11. `D - Decisions/_template.md` — ADR template

**Phase 1 purpose:** Establish kit shape + master doc. Everything else references README.

### Phase 2 — Core Standards Docs (4 large files)

**Files:**
1. `STARTER-PROJECT-PLANNING.md` — full Phase 1/2/3 process. Largest file. Preserves all conventions (proceed handshake, schema-first rule, codebase-grep convention, scope boundary, kickoff prompt format, tag convention, §1.5 reviewer coverage check, §1.5 Playwright coverage check, §1.5 Security threat-modeling rule, §1.2.3 sub-agent cadence, §2.2 VERIFY-block format with sub-agent invocation). Engage-specific examples replaced with `<EXAMPLE: ...>` placeholders.
2. `STARTER-QA-STANDARDS.md` — per-prompt gates, anti-regression discipline, test coverage minimums, seed accounts pattern (genericized), migration safety, edge-runtime safety (with placeholder for stack-specific edge-runtime concerns), what-not-to-do.
3. `STARTER-DEPLOYMENT-WORKFLOW-vercel-supabase.md` — Vercel + Supabase variant. Covers branch strategy, CI/CD pipeline, release Q&A, post-deploy verification, rollback. Cross-references engage-lint patterns.
4. `STARTER-DEPLOYMENT-WORKFLOW-hostinger-vps.md` — Hostinger VPS variant (Ubuntu 22/24 + PostgreSQL on same VPS + git-pull deploy + PM2 + nginx + Let's Encrypt). Same conventions, different platform commands.

**Phase 2 purpose:** Heaviest drafting. Isolated for quality.

### Phase 3 — Remaining Standards Docs + Tracker (6 files)

**Files:**
1. `STARTER-QUICK-FIXES.md` — Tier-2 lightweight-fix workflow. Mostly direct port from Engage's version, light edits.
2. `STARTER-BEFORE-LAUNCH-CHECKLIST.md` — empty structure with example items (security headers, secret rotation, auth allow-list cleanup) marked as common examples.
3. `STARTER-CLAUDE-CODE-RUNBOOK.md` — production incident triage template. One example row to show the pattern; users fill in their own as incidents emerge.
4. `STARTER-SUB-AGENT-METHODOLOGY.md` — cadence rule (every 5 sprints + event trigger), review-sprint runbook, **comprehensive agent catalog** (all 14 agents shipped or templated in the kit, each with: name, what it catches, when to consider adding, where the file lives, originated from).
5. `PLANNING-TRACKER-GUIDE.md` — generalized port from Engage's version.
6. `PLANNING-TRACKER-TEMPLATE.html` — Engage's HTML with `DEFAULT_BIN_CONFIG` blanked out, embedded `<script id="tracker-data">` reset to generic defaults (standard stages, minimal config).

**Phase 3 purpose:** Operational docs + tracker setup. Most are direct ports.

### Phase 4 — Sprint Templates + Default Agents + Optional Agents (~17 files)

**Files:**
- `_sprint-templates/README.md`
- `_sprint-templates/KICKOFF-PROMPT.md` (build phase)
- `_sprint-templates/COWORK-PLANNING-KICKOFF.md` (planning phase — tracker-driven, no find-replace)
- `_sprint-templates/QA-CHECKLIST.md`
- `_sprint-templates/RETRO.md`
- `_sprint-templates/CARRYOVER.md`
- `_sprint-templates/_proceed-handshake-snippet.md`
- `.claude/agents/code-reviewer.md` (default — includes S1-S15 security checklist + BLOCKING-only severity for security findings)
- `.claude/agents/test-runner.md`
- `.claude/agents/docs-researcher.md`
- `.claude/settings.json` (baseline Cowork permissions)
- `_optional-agents/README.md` (when to copy each into `.claude/agents/`)
- `_optional-agents/next-js-server-client-boundary-reviewer.md`
- `_optional-agents/next-js-provider-chain-reviewer.md`
- `_optional-agents/dedicated-security-reviewer.md` (for projects that prefer it over Path A)
- `_optional-agents/external-api-resilience-reviewer.md`
- `_optional-agents/build-plan-step-ordering-reviewer.md`

**Phase 4 purpose:** Sprint-execution templates + agent layer (defaults + Engage-derived options).

### Phase 5 — Stack Templates + Sprint 1 Placeholder + Final Sanity Walk (~10 files)

**Files:**
- `_stack-templates/README.md` (what each template catches, how to adapt to your stack)
- `_stack-templates/vue-nuxt-reviewer.md`
- `_stack-templates/django-reviewer.md`
- `_stack-templates/rails-reviewer.md`
- `_stack-templates/react-vite-reviewer.md`
- `_stack-templates/express-node-reviewer.md`
- `_stack-templates/generic-python-reviewer.md`
- `1 - First Sprint Placeholder/Sprint-1-Build-Plan.md` (canonical empty build plan with placeholder sections)
- `1 - First Sprint Placeholder/KICKOFF-PROMPT.md`
- `1 - First Sprint Placeholder/QA-CHECKLIST.md`
- `1 - First Sprint Placeholder/mockups/.gitkeep` (preserves the mockups subfolder in git)

**Final sanity walk (last action of Phase 5):**
- Re-read `README.md` end-to-end as if newly cloning the kit
- Verify all cross-references resolve (every file path mentioned in any doc actually exists)
- Verify the agent catalog in `STARTER-SUB-AGENT-METHODOLOGY.md` lists every agent file present in the kit
- Verify the install flow described in `README.md` actually works (would a new user be able to follow it?)
- Verify no Engage-specific terms slipped through (search for "Engage", "BUG-009", "ADR-0003", "Sprint 13", "broker", "mortgage", "FSRA", etc.)
- Verify the platform picker flow (Vercel vs Hostinger) is clear and reversible

**Phase 5 purpose:** Round out stack support + first-sprint scaffold + kit integrity verification.

---

## 6. Cross-reference map (what file references what)

Important for the Phase 5 sanity walk — every cross-reference below must resolve to an existing file.

- `README.md` → all standards docs, tracker setup, platform setup, vision template, sprint templates, agent catalog
- `STARTER-PROJECT-PLANNING.md` → QA-STANDARDS, both DEPLOYMENT-WORKFLOW variants, BEFORE-LAUNCH-CHECKLIST, CLAUDE-CODE-RUNBOOK, SUB-AGENT-METHODOLOGY, sprint templates, tracker guide
- `STARTER-QA-STANDARDS.md` → PROJECT-PLANNING §2.2, BEFORE-LAUNCH-CHECKLIST, code-reviewer agent
- `STARTER-SUB-AGENT-METHODOLOGY.md` → every agent file in `.claude/agents/`, `_optional-agents/`, `_stack-templates/`; cross-references PROJECT-PLANNING §1.2.3 + §1.5
- `STARTER-KIT-SYNC-LOG.md` → Engage's `0 - START PLANNING HERE/` source files (for backport tracking)
- `_sprint-templates/COWORK-PLANNING-KICKOFF.md` → all standards docs (the READ FIRST list), tracker guide, sprint folder structure
- `_sprint-templates/KICKOFF-PROMPT.md` → PROJECT-PLANNING, sprint runner doc (which says runners are skipped — link to manual proceed-handshake instead)
- `_optional-agents/README.md` → each agent file in folder + criteria for adoption
- `_stack-templates/README.md` → each stack reviewer file + adaptation instructions

---

## 7. Periodic Engage → kit sync mechanism

Two mechanisms working together (both confirmed in planning conversation):

### Mechanism 1 — Tag-based signal

Engage's PROJECT-PLANNING.md §1.5 codified two tag categories:
- `(Sprint X retro — Sprint Y codification)` → retro-driven, Engage-specific. Does NOT generalize.
- `(planning-process improvement — ...)` → proactive, identified during process review. DOES generalize.

When syncing, only `planning-process improvement` tagged rules are candidates for backport to the kit.

### Mechanism 2 — Recurring sync conversation

Quarterly (or operator-triggered) Cowork conversation:

1. Read `STARTER-KIT-SYNC-LOG.md` to see last sync date + Engage commit SHA.
2. Read Engage's `0 - START PLANNING HERE/PROJECT-PLANNING.md` + `QA-STANDARDS.md` + `DEPLOYMENT-WORKFLOW.md`.
3. Identify any `(planning-process improvement — ...)` tagged rule added AFTER the last-sync Engage commit SHA.
4. For each, propose whether to backport (most will). Skip retro-driven rules.
5. On approval, apply changes to the corresponding kit files + append entry to `STARTER-KIT-SYNC-LOG.md` with date + Engage commit SHA + items brought over.

Schedule reminder: every 90 days or after any major Engage sprint that lands process improvements.

---

## 8. Decisions log (from this planning conversation)

Recorded here for traceability:

1. **Tech-stack scope:** All 3 variations co-exist — stack-agnostic default (3 generic agents) + Next.js optional (in `_optional-agents/`) + multi-stack templates (in `_stack-templates/`)
2. **Deployment scope:** Vercel + Supabase as default, Hostinger VPS variant included; Cowork picks one during install via `PLATFORM-SETUP.md` flow
3. **Sprint Runners:** Skipped. Manual proceed-handshake only.
4. **Folder name + location:** `cowork-app-starter/` at `engage/reference/cowork-app-starter/` (lives inside Engage workspace for ongoing updates)
5. **Vision template:** Included as empty skeleton (`VISION-TEMPLATE.md`)
6. **Hostinger setup defaults:** VPS (Ubuntu 22/24) + PostgreSQL on same VPS + git-pull deploy + PM2 + nginx + Let's Encrypt
7. **Security checklist:** Strengthened S1-S15 + BLOCKING-only severity baked into default `code-reviewer.md`
8. **Agent cataloging:** All Engage-derived + multi-stack agents catalogued in `STARTER-SUB-AGENT-METHODOLOGY.md` as options for the new project's eventual 5-sprint reviews
9. **Sync mechanism:** Tag-based + recurring conversation, recorded in `STARTER-KIT-SYNC-LOG.md`
10. **Execution approach:** 5-phase proceed-handshake (this build plan)

---

## 9. Sanity walk checklist (Phase 5 final step)

Verify the kit is internally consistent and externally usable before declaring done:

- [ ] `README.md` reads end-to-end without referencing files that don't exist
- [ ] Every file in the folder map (§3) actually exists
- [ ] No "Engage", "BUG-NNN", "ADR-NNNN", specific sprint numbers, or domain-specific terms ("broker", "mortgage", "FSRA", "Treadstone", "Engage-Test-2026!") leaked into any kit file (except as bracketed `<EXAMPLE: ...>` placeholders)
- [ ] Both DEPLOYMENT-WORKFLOW variants cover the same conventions (release Q&A, branch strategy, post-deploy verification, rollback) — differ only in platform commands
- [ ] `STARTER-SUB-AGENT-METHODOLOGY.md` catalog lists every agent file present in `.claude/agents/`, `_optional-agents/`, `_stack-templates/`
- [ ] `PLATFORM-SETUP.md` flow is reversible (user picks wrong, can switch)
- [ ] `TRACKER-SETUP.md` instructions actually work (would produce a working JSONbin bin + populate `DEFAULT_BIN_CONFIG`)
- [ ] `_sprint-templates/COWORK-PLANNING-KICKOFF.md` references reflect the kit's structure, not Engage's
- [ ] `STARTER-KIT-SYNC-LOG.md` initial entry records this conversation's date + Engage state as the source-of-truth baseline
- [ ] `1 - First Sprint Placeholder/` is genuinely empty/template-only — no Engage-specific content

---

## 10. How to use this build plan

Each phase follows the proceed-handshake from Engage's PROJECT-PLANNING.md "Build Plan Execution Style":

1. Phase N executes → emits completion summary → stops with `Status: STOPPED for review. Reply 'proceed' to begin Phase N+1.`
2. You review the files created. To advance, type `proceed`. To revise, paste feedback instead.
3. The conversation may be paused and resumed across multiple Cowork sessions — Phase numbers are stable, and the build plan itself is the source of truth for what's done vs pending.

**Resume protocol:** if a session is interrupted mid-phase, the next Cowork session reads `STARTER-KIT-BUILD-PLAN.md` + lists the kit folder to determine the last completed phase. Then resumes Phase N+1 on your `proceed`.

**Estimated total work:** ~3.5–4 hours across the 5 phases.

---

Build plan complete. Ready to execute Phase 1 on your `proceed`.
