# Project Planning Standards

> **Document scope:** This project's planning, building, and deployment process. The QA protocols in Phase 2, the deployment process in Phase 3, and the kickoff prompt format are the canonical standards for every sprint in this repo.
>
> This is the canonical generalized version from `cowork-app-starter`. Rename to `PROJECT-PLANNING.md` after install. Customize for your specific project as conventions emerge from your own retros.

---

## Project-Specific Essentials (READ FIRST)

### Credentials location

Document where your project's secrets live. Common patterns:

- A gitignored `CREDENTIALS.md` file at the project root (sync the parent folder via OneDrive / Dropbox / iCloud Drive to keep it portable across machines without committing secrets)
- A `.env.local` file (if your project already uses dotenv)
- A password manager (1Password, Bitwarden) referenced from a placeholder doc

Whatever you choose, document it explicitly. The rule that matters: **secrets never go in committed code or in chat output.** Multiple defensive gitignore layers preferred (`.env`, `.env.local`, `CREDENTIALS.md`, etc.).

When Cowork or Claude Code needs credentials, they read from your designated file. Do NOT paste credentials into chat or commits.

### Folder layout

```
<your-project>/
├── apps/, src/, etc.                       ← Code
└── <kit folder, however named>/            ← Planning, bugs, decisions (this kit)
    ├── PROJECT-PLANNING.md                 ← This file (after rename)
    ├── DEPLOYMENT-WORKFLOW.md              ← After PLATFORM-SETUP rename
    ├── QA-STANDARDS.md                     ← After rename
    ├── BEFORE-LAUNCH-CHECKLIST.md
    ├── PROJECT-VISION.md                   ← Your filled-in VISION-TEMPLATE
    ├── SUB-AGENT-METHODOLOGY.md
    ├── QUICK-FIXES.md
    ├── CLAUDE-CODE-RUNBOOK.md
    ├── PLANNING-TRACKER.html               ← After TRACKER-SETUP rename
    ├── PLANNING-TRACKER-GUIDE.md
    ├── _sprint-templates/
    ├── 1 - <First Sprint>/                 ← Your first real sprint folder
    ├── 2 - <Second Sprint>/
    ├── ... (subsequent sprints)
    ├── C - Bugs/
    └── D - Decisions/
```

### Deployment target

After running `PLATFORM-SETUP.md`, you have ONE `DEPLOYMENT-WORKFLOW.md` that covers your platform (Vercel + Supabase OR Hostinger VPS, or your custom rewrite for other platforms). All Phase 3 references in this document point to that single file.

### Tech stack

Document your project's tech stack in `PROJECT-VISION.md` §3 (Platform & Technical Foundation). Cowork and Claude Code read it at planning + execution time to make stack-appropriate decisions.

### Design system

If your project has a design system, document where it lives and how it's enforced (lint rules, mockup conventions, etc.). Common pattern: a `design-system/MASTER.md` doc + a `preview.html` visual reference + lint rules in your code linter.

### Build plan execution style: `proceed` handshake, one prompt at a time

**All build plans in this project MUST use the `proceed`-handshake workflow.** Do NOT use automated "execute the entire sprint" runbooks.

How this works:
- The build plan starts with a "How to Run This Sprint" section listing numbered prompts.
- The user pastes the **kickoff prompt** once (Setup runs end-to-end and STOPs).
- For every prompt thereafter, Claude Code prints a completion report ending with the canonical handshake footer and STOPs.
- The user reviews the report. To advance, the user types `proceed` — Claude Code reads the next prompt from the build plan and executes it. To revise, the user pastes feedback instead.
- The user can override the handshake at any time by pasting the verbatim prompt body.

**Canonical completion-report footer (every prompt):**

```
Status: STOPPED for review.
- Reply `proceed` to begin Prompt N+1.
- Or paste feedback to revise this commit.
- Context-use is approximately X%. <If X >= 60 OR every-3-prompts trigger fires: append: "Status: SESSION RESET RECOMMENDED. Reply 'fresh start' to spin up a new session that resumes from .claude-code-status/sprint-progress.json.">
```

The reusable text source-of-truth lives at `_sprint-templates/_proceed-handshake-snippet.md`.

**Context-bloat session-reset protocol:**

Sessions accumulate context across many prompts. To keep Claude Code coherent, the runner triggers a **session-reset recommendation** when either condition fires:

- **Every-3-prompts** trigger — after Prompts 3, 6, 9, … the completion footer appends `Status: SESSION RESET RECOMMENDED.`
- **60%-threshold** trigger — Claude Code self-reports `context_use_pct` in `.claude-code-status/sprint-progress.json`. Whenever the latest report crosses ≥ 60%, the same recommendation fires.

When the user accepts the recommendation:

1. User types `fresh start`. Claude Code confirms the session can be cleared.
2. User opens a fresh chat (or runs `/clear` in Claude Code), then types `resume sprint <N>` (e.g. `resume sprint 5`).
3. Fresh session reads `.claude-code-status/sprint-progress.json` (canonical structured handoff file — see §2.4), confirms `current_prompt`, and prompts to execute the next prompt.

### Build plan sizing rule

Prompts must be sized so a single prompt's work fits comfortably in the context window without risking context exhaustion or degradation.

Rules when designing prompts:
- **Minimize the number of prompts in a plan** by consolidating related work — BUT only when consolidation does not increase risk of context bloat
- A single prompt should cover one cohesive slice of work (one feature, one module, one concept)
- If a prompt would require reading 10+ large reference files, creating 15+ new files, AND writing dozens of tests — split it
- When in doubt, KEEP THEM SEPARATE. A slightly longer plan with safer prompts beats a shorter plan with risky prompts
- Each prompt should produce between 3-10 files of meaningful work

Priority order: **Correctness > Reducing risk of context bloat > Minimizing prompt count.** Never sacrifice the first two for the third.

### Testing responsibility: Claude Code, not the user

This project uses a two-tool workflow: Cowork for planning, Claude Code for building. **Claude Code is responsible for all testing and verification** — not the user.

**Claude Code must, at the end of every prompt AND every sprint:**
- Run build, test, lint, typecheck commands appropriate to your stack
- Start the dev server and programmatically walk through features built in that prompt
- Take screenshots or provide written descriptions of each verified state in the QA report
- Fix any issues found during self-verification before reporting the prompt complete

**What the user does:**
- Spot-checks deployed previews (optional)
- Reviews the QA report and sprint completion report
- Confirms the handoff before moving to the next sprint

If Claude Code's report says "you need to manually test this" — that is WRONG. Claude Code must test itself.

---

## How to use this document

**In Cowork (planning):** When the user signals they want to plan a feature — read this file first, then immediately do §1.1 (Codebase Orientation). Then follow the rest of Phase 1 step by step. At the end, generate the kickoff prompt (§1.8) for the user to paste into Claude Code.

**In Claude Code (development):** When this file is referenced in a kickoff prompt — read it, then read the build plan it points to. Follow Phase 2 for every prompt. Follow Phase 3 when the user is ready to deploy.

**How the user triggers this:** Say anything like "let's plan [feature]", "start planning", "new feature", "next sprint", or "read PROJECT-PLANNING.md".

**Canonical planning kickoff prompt (recommended):** open a fresh Cowork chat, type a short opener like "I'm planning the next sprint", then paste the full prompt from `_sprint-templates/COWORK-PLANNING-KICKOFF.md` underneath. Cowork derives the sprint number from the Planning Tracker. The template bundles tracker integration, every read-first file, the codebase-orientation steps, the open-ended-question meta-rule (§1.0.1), the conflict-surfacing sequence, the BEFORE-LAUNCH pre-sprint question, the chore-PR scope rule, the build-plan authoring rules (§1.5), and the build-phase kickoff generation (§1.8) into a single copy-paste.

---

## Phase 1: PLANNING

### 1.0.1 User scope-input precedes Cowork structured questions (meta-rule)

**Hard rule.** BEFORE Cowork asks any structured `AskUserQuestion` picker about scope decisions, fold-ins, or implementation choices, Cowork MUST FIRST ask the user an open-ended freeform question — typically *"What do you want included in this sprint?"* — in plain text (no `AskUserQuestion` tool, no options menu). Cowork waits for the user's freeform answer. Then, and only then, may structured `AskUserQuestion` pickers follow to refine + finalize scope.

This rule fires every sprint planning conversation, every time. Not optional.

**Why.** Structured pickers based on priority signals (carryover anchors, BEFORE-LAUNCH items, etc.) before the user volunteers freeform scope intent produce mismatch — the user has to use "Other" escape hatches repeatedly to redirect. Open-ended-first inverts the flow: the user signals scope freeform; Cowork then asks structured questions to **refine**, not to **discover**.

**Trigger / canonical sequence.** After Cowork has read the standards (PROJECT-PLANNING.md + QA-STANDARDS.md + DEPLOYMENT-WORKFLOW.md + BEFORE-LAUNCH-CHECKLIST.md), the prior-sprint outputs (RETRO.md + CARRYOVER.md + last-response.md + sprint-progress.json), the bug + decision context (`C - Bugs/BACKLOG.md` + `D - Decisions/INDEX.md`), the templates to model artifacts on (most-recent sprint folder), and completed §1.1 codebase orientation — Cowork's FIRST action MUST be to ask:

> *"What do you want included in Sprint &lt;N&gt;?"*

(Or a directly-equivalent freeform variant. The point is plain-text-no-structured-options.)

Cowork waits for the user's freeform answer. After it arrives, Cowork:

1. Surfaces conflicts between the user's freeform answer and the carryover anchors (Sprint N−1 + N−2 outputs, BEFORE-LAUNCH-CHECKLIST, open BUGs, ADRs) — in plain prose, not as a question.
2. Answers any explicit question-only items in the user's freeform list (when the user asks a question rather than scopes work).
3. Asks structured `AskUserQuestion` refinement questions to lock scope.
4. Drafts the chore-PR artifacts.

### 1.1 Codebase orientation (ALWAYS DO FIRST)

Before any planning work, Cowork must understand the existing application. Every new feature must integrate with the existing architecture.

**Step 1: Read project overview and architecture docs**
- `README.md` — project overview, tech stack, project structure
- Any architecture decision docs in `D - Decisions/` that touch likely scope
- Your project's vision doc (`PROJECT-VISION.md` or wherever it lives)

**Step 2: Read the full data model**
- Your ORM schema file (Prisma `schema.prisma`, Django models, Rails schema.rb, SQL DDL, etc.) — read ENTIRE file
- Seed file (if any) — understand default data

**Step 3: Read shared libraries**
- Module registry / type registry / configuration constants
- Display utilities, date utilities, formatting helpers
- General utility functions

**Step 4: Read page routes and server logic**
- List all routes / endpoints
- Read server actions / API handlers (each file responsible for backend logic)

**Step 5: Read components and view layer**
- Page-level component shells
- Module / tab / view components
- Form components, modals, popovers
- Layout components (sidebar, header, navigation)

**Step 6: Read remaining surfaces**
- Settings pages, admin pages
- Dashboards (per-role)
- Search, notifications, peripheral features

**Step 7: Understand current state from the live codebase**
- Review `package.json` (or equivalent) — current version + dependencies
- Review recent git history (`git log --oneline -20`)

**⚠️ DO NOT browse old sprint folders during orientation.** Past sprint folders contain outdated mockups, old build plans, and stale design artifacts that may no longer reflect the current state. The source of truth is always the **live codebase**.

**After orientation, Cowork must be able to answer:**
- What is the full tech stack and project structure?
- What does the data schema look like — every model, enum, key relation?
- What server-side logic exists and what does it do?
- What does each major component render and how does it interact with the backend?
- What shared utilities and helpers are already available?
- What is the current version and what was recently built (from git history)?

**Do NOT proceed to planning until this orientation is complete.**

### 1.2 Sprint folder setup

Every sprint gets its own numbered sub-folder. Copy from `_sprint-templates/` when creating a new sprint.

```
<N> - <Short Theme>/
├── Sprint-<N>-Build-Plan.md        ← REQUIRED. Exact filename matters.
├── KICKOFF-PROMPT.md               ← REQUIRED. First prompt the user pastes.
├── QA-CHECKLIST.md                 ← REQUIRED. Feature-level checks (template in _sprint-templates/).
├── RETRO.md                        ← Written at sprint end.
├── CARRYOVER.md                    ← Only if work defers to next sprint.
├── mockups/                        ← Per-sprint mockups live here, not globally.
└── REPAIR-PLAN.md                  ← Only for `.5` repair sprints.
```

When planning begins, Cowork creates the sub-folder and populates it with all planning artifacts.

**Cowork is responsible for:**
- Creating the numbered folder with the canonical structure
- Copying `QA-CHECKLIST.md`, `RETRO.md`, `CARRYOVER.md` templates from `_sprint-templates/` and filling them in
- Saving all mockup HTML files into the sprint's `mockups/` subfolder
- Writing the build plan markdown file (named `Sprint-<N>-Build-Plan.md`)
- Checking `C - Bugs/BACKLOG.md` for bugs targeted at this sprint and folding them into the build plan
- **Pre-sprint pre-launch question.** Read `BEFORE-LAUNCH-CHECKLIST.md` and ask the user: *"Want to tackle any pre-launch items in this sprint? Top suggestion: [next-most-relevant open item with a one-line rationale]."* Without this question, BEFORE-LAUNCH items rot in the checklist.
- Ensuring the folder is complete (build plan, kickoff, QA checklist, mockups) before handing off to Claude Code

#### Chore-PR pre-sprint scope discipline

The chore PR (Cowork's pre-sprint prep) should contain ONLY:

- The new sprint folder (`<N> - <Theme>/`) and its contents (build plan, kickoff, QA checklist)
- Any sprint-table updates in your project's sprint runner config (if you have one)

Anything else — schema edits, lint rule additions, dependency bumps, code changes — belongs in feature-branch commits authored by Claude Code per the build plan. If Cowork notices a needed change during pre-sprint review that doesn't fit either category, it goes in the build plan as a Prompt 1 STEP, not in the chore PR.

### 1.2.1 Bug backlog

Bugs that are not being fixed immediately live in `C - Bugs/`. See the README there for triage and filing rules.

- **During sprint planning:** Cowork reads `C - Bugs/BACKLOG.md`. Anything with `sprint-target: <this sprint>` or `sprint-target: next` gets considered for inclusion.
- **During sprint execution:** If Claude Code discovers a bug that's out of scope for the current prompt, it files a bug in `C - Bugs/open/` and notes it in the sprint retro — it does NOT silently fix it mid-prompt.
- **For one-off fixes already understood:** Skip the backlog folder entirely, use `QUICK-FIXES.md` (Tier 2 workflow).

### 1.2.2 Architectural decisions

Load-bearing choices get recorded in `D - Decisions/` as ADRs. See the README there for what qualifies.

- **When Cowork makes a non-obvious choice during planning** (picking library A over library B, choosing a data shape, etc.), write an ADR alongside the build plan.
- **Commit the ADR with the code change that implements it**, when possible, so the decision and the diff live in the same history point.
- **Don't backfill everything.** Only file an ADR when the decision is load-bearing and non-obvious. Routine implementation choices do not need ADRs.

### 1.2.3 Sub-agent review cadence

This project uses a roster of Phase 2 Claude Code sub-agents (default: code reviewer with full security checklist, test runner, docs researcher) committed to `.claude/agents/` at the project root. The roster is reviewed periodically against the past few sprints' retros to add, retire, or modify reviewers as the codebase's bug patterns evolve.

**Cadence:** scheduled review every 5 sprints (Sprint 5, 10, 15, 20, ...) PLUS an event-based trigger when any bug class appears in 2 consecutive retros AND isn't covered by an existing reviewer or static check.

**What Cowork does when the cadence fires:**

1. Read `SUB-AGENT-METHODOLOGY.md` — the canonical sub-agent methodology document with retro-derived analysis, current roster, review-sprint runbook, and roster history.
2. Run the §"Review-sprint runbook" steps in that file.
3. Land any roster changes in the sprint's chore PR alongside the standard sprint folder contents.

**When the cadence does NOT fire,** Cowork does NOT read `SUB-AGENT-METHODOLOGY.md` during standard planning. The file is intentionally outside the kickoff READ-FIRST list.

### 1.3 Mockup creation

Before any code is written, interactive HTML mockups are created for every new screen, tab, popup, and major UI change. Mockups are the single source of truth for visual design.

**Mockup requirements:**
- Self-contained HTML files (inline CSS/JS, no external dependencies) so they open in any browser
- Interactive where applicable — switchers, tab toggles, expand/collapse sections, hover states
- Use the app's actual design tokens (colors, fonts, spacing)
- Cover all variants — empty states, error states, role-specific views
- Named descriptively: `[feature]-mockup.html` or `[feature]-mockup-[variant].html`
- **Accessibility pass at mockup level.** Run axe-core against the mockup HTML before approval — contrast violations, missing landmarks (`<header>/<main>/<footer>`), and form-label gaps are far cheaper to fix in static HTML than in live components.
- **Every route has the semantic-landmark trio.** `<header>`, `<main>`, and `<footer>` must be present.

### 1.4 Mockup approval

Mockups are reviewed and approved in Cowork before coding begins. Claude Code must never build against a mockup that hasn't been confirmed by the user. If the user requests changes, update the HTML first, get re-confirmation, then proceed.

### 1.5 Build plan document

Each sprint folder contains a single comprehensive build plan markdown file. This is the architectural spec that Claude Code reads cover-to-cover before writing any code.

**Required sections in every build plan:**

1. **Architecture** — how the new feature integrates with the existing system (which files change, which are new, how routing / data model extends)
2. **Domain model changes** — full schema additions: new enums, new models, new fields on existing models, with exact field names, types, and defaults
3. **File naming and numbering conventions** — if the feature introduces new file types or naming patterns
4. **Feature specifications** — section-by-section spec for every new screen/tab/component, including:
   - Layout structure (ASCII diagrams)
   - Data fields with types and which variants they apply to
   - Conditional visibility rules
   - Color tokens, badge styles, icon choices
   - Server actions / API endpoints needed (function signatures)
   - Reference to the approved mockup file
5. **Impact map** — a table listing every file that needs modification, what changes, and why. Split into "Must modify" and "May need minor touch"
6. **Build sequence** — numbered prompts with explicit instructions (see Phase 2). **Schema-first rule:** If the feature requires schema changes (new models, new enums, new fields), those changes MUST be in Prompt 1. The schema is the foundation. Prompt 1 should end with a verified, validated, and generated schema before any application code is written.

#### Codebase-grep convention before prescribing storage / nav / component conventions

Build plan authoring MUST grep the codebase for relevant conventions BEFORE prescribing structure. This applies to (1) nav-item labels (grep for the canonical role-permissions file); (2) admin-settings storage layer (grep for actual model names + the existing upsert pattern); (3) component file paths (grep for the actual component name, not the build plan author's expected name); (4) external-resource references (grep for actual URL/path used in source + public/ assets). Build plan authors who skip this step prescribe storage layers / labels / paths / asset locations that don't match codebase reality, generating mid-sprint halt-and-asks that consume budget on planning issues rather than implementation issues.

#### Cross-sprint verification compatibility

When a build plan's VERIFY assertions reference a runtime mechanism (a test spec, a fixture, a seed account, a feature flag, etc.) that originates from a different sprint, Cowork MUST cross-check that the mechanism is still operational under the target environment's current configuration. If the mechanism was disabled, removed, or gated by a later sprint, the build plan author must either: (a) substitute a compatible verification mechanism, OR (b) explicitly note the cross-sprint constraint in the prompt's VERIFY block + the Notes section.

#### Pre-flight read-only verification

When a build plan STEP proposes a destructive prod-side mutation (DELETE/INSERT/UPDATE/DROP/TRUNCATE/CREATE POLICY against an API or production database), the STEP MUST include a pre-flight read-only verification step that surfaces the actual current state before the mutation executes. Write the SELECT/GET first, run it, surface the result + the proposed mutation in the prompt completion report, then execute the mutation as a separate STEP. If the pre-flight verification surprises you, STOP and re-think the mutation before executing.

#### Mockup/build-plan versioning rule

The mockup is a load-bearing input to the build plan. When the mockup is edited AFTER the build plan is written, Cowork MUST update the build plan before the next prompt executes in Claude Code. Stale mockup references inside a committed build plan will cause Claude Code to build against the wrong spec.

#### workflow_dispatch verification rule

When a build plan adds a new CI workflow file (`.github/workflows/*.yml` or equivalent), any verification step that depends on triggering the workflow manually must be explicitly deferred to Sprint Completion (post-merge to the default branch). Manual trigger only works when the YAML is on the default branch.

#### Playwright (or equivalent e2e) coverage check — per-prompt VERIFY-block planning-time trigger (planning-process improvement)

When Cowork drafts the build plan's per-prompt VERIFY blocks (§1.5 Build sequence), it MUST run the 4-question coverage check below against each prompt's proposed work. If ANY answer is yes, the corresponding e2e spec invocation MUST be added to that prompt's VERIFY block AT PLANNING TIME — not deferred to Claude Code's runtime discretion.

**The 4 questions:**

1. **Does this prompt CREATE OR MODIFY authenticated routes?**
   → Add: invocation of your project's primary-routes e2e spec (a spec that walks every authenticated route per role, catching missing-provider-wiring or orphaned-hook regressions).

2. **Does this prompt MODIFY component trees, layouts, or middleware that affect rendering?**
   → Add: same primary-routes spec. Rationale: catches the "hook introduced into a component whose ancestor Provider tree is not wired" class of bug.

3. **Does this prompt CHANGE design-system tokens OR modify visual-regression surfaces?**
   → Add: visual regression spec(s) for the affected surfaces.

4. **Does this prompt ADD a new dependency to your package manifest (or revive a previously-unused one)?**
   → Add: primary-routes spec. Rationale: catches the "library imported in source, importing module never rendered in a layout chain" runtime-failure class.

**No to all four:** the prompt does NOT need an e2e invocation in VERIFY (just the default build, schema, lint, test, regression).

**Why this is a planning-time check, not a runtime check:** the build plan VERIFY block is the most reliable trigger — Claude Code executes its contents verbatim. Moving the trigger decision upstream to planning-time means Cowork greps the proposed prompt's file paths against the 4 conditions while drafting, and the resulting invocation becomes part of the prompt itself.

#### Reviewer coverage check — per-prompt sub-agent invocation planning-time trigger (planning-process improvement)

When Cowork drafts the build plan's per-prompt VERIFY blocks, it MUST run the 3-question check below against each prompt to decide WHICH specialized sub-agent reviewers spawn for that prompt. The general-purpose `code-reviewer` and `test-runner` spawn on EVERY prompt's VERIFY by default; specialized reviewers are conditional.

**The 3 questions:**

1. **Does this prompt touch the framework-specific boundary surfaces (e.g., Next.js server/client, Vue SFC reactivity boundaries, React context provider trees)?**
   → Add to VERIFY: spawn the appropriate stack-specific boundary reviewer (see `SUB-AGENT-METHODOLOGY.md` catalog).

2. **Does this prompt introduce new context hooks OR modify provider/layout files?**
   → Add to VERIFY: spawn the provider-chain reviewer (if using React/Next.js stack) or equivalent.

3. **Will this prompt likely need to verify a current API signature on a fast-moving dep?**
   → Note `docs-researcher` as an available on-demand sub-agent.

**Default per-prompt VERIFY structure:**

```
VERIFY:
- (parallel group — independent checks)
  - test-runner            (Task tool, model: haiku)
  - build command
  - typecheck
  - lint
  - schema validation (if schema touched)
- (after parallel, sequenced)
  - code-reviewer          (against `git diff HEAD`, model: sonnet)
  - [stack-specific reviewers if questions 1/2 fire]
- (on-demand)
  - docs-researcher        (Claude Code spawns when an API signature needs verification)
- (conditional per §1.5 Playwright coverage check)
  - primary-routes e2e spec
  - visual regression specs
```

See `SUB-AGENT-METHODOLOGY.md` for the current sub-agent roster and the periodic review cadence (every 5 sprints + event trigger).

#### Security threat-modeling rule — sprints touching security-sensitive surfaces (planning-process improvement)

Adding generic "Security considerations" sections to every build plan produces compliance theatre. To get genuine threat-modeling where it matters without polluting every build plan, Cowork applies a conditional trigger during §1.5 build plan drafting.

**Trigger condition.** If the sprint touches ANY of the following surfaces, the build plan's §1 Architecture section MUST include a dedicated "Security threat-modeling" sub-section:

1. **Authentication flows** — login, password reset, magic-link, session-cookie handling, auth method calls
2. **AI / LLM tool implementations** — new tools, modifications to the AI tool registry, new prompt constructions where user-supplied content reaches the prompt
3. **Billing operations** — payment provider SDK invocations, webhook handlers, subscription management
4. **New API routes** — any new endpoint handling POST/PUT/DELETE/PATCH (GET routes exempt unless they expose tenant-scoped data without auth)
5. **Multi-tenant data boundaries** — new schema models with tenant-scoping fields, new server actions accepting tenant-scoped IDs, or new queries that could leak across tenants

**Required content:**

A) **Threat surface.** What new attack surface does this sprint expose?
B) **Threats considered.** Enumerate plausible attacks — at minimum: unauthorized access, IDOR / ownership bypass, CSRF, open redirect, PII leak, rate-limit abuse, prompt injection (if AI-consuming).
C) **Mitigations.** For each threat, name the mitigation present in the implementation.
D) **Cross-references.** Cite applicable ADRs and lint rules that statically enforce part of the mitigation.
E) **Verification.** What VERIFY-block check confirms the mitigations actually hold?

**Where the sub-section lives in the build plan.** Inside §1 (Architecture), required only when the trigger condition fires. Sprints not touching the listed surfaces do NOT include this sub-section.

#### Tag convention note (proactive vs retro-driven)

This document uses two tag formats for rule provenance:

- **Retro-driven:** `(Sprint X retro — Sprint Y codification)` — rule born from a real failure (retro item, BUG, postmortem). Includes specific origin context.
- **Proactive:** `(planning-process improvement — ...)` — rule identified during process review, not from a real failure. The trailing reference (e.g., `— Sprint Y planning-time complement`) anchors to its closest retro-driven sibling when applicable.

Use retro-driven tags when adding rules motivated by a real failure in YOUR project's history. Use proactive tags for rules adopted from external sources (this kit, industry best practices, etc.) without your own failure evidence. This distinction matters for the kit's sync mechanism — only `planning-process improvement` tagged rules generalize across projects.

#### Build plan §2 retroactive-correction discipline

Build plan §2 ("Domain model changes") captures authored intent at planning time. Predictions in §2 MAY turn out factually wrong during execution if a halt-and-ask produces an authorized scope expansion. Such corrections MUST land in the sprint's `RETRO.md` "What didn't work" section, NOT in retroactive edits to the build-plan §2 file.

The build plan is a **record of authored intent, not retroactive truth**. The audit trail — git log shows when §2 was authored vs. when the fact-divergent execution landed — is preserved by NOT editing §2 retroactively.

### 1.5.1 Process-improvement check at planning end (planning-process improvement — codification of continuous process-review rule)

At the end of every planning conversation in Cowork — after refinement + drafting is settled, when the user signals "we're done planning" / "let's start building" — Cowork runs a **process-improvement check** before moving to the tracker-finalize + Claude Code kickoff steps. The check identifies anything from the just-completed planning conversation that should land in the project's standards docs (or, if your project is downstream of this kit, also surface back to the upstream kit maintainer).

**Why this rule exists.** Planning workflows evolve every sprint. New rules, new conventions, new VERIFY-block patterns get added in conversation but often don't make it into the standards docs unless someone explicitly captures them. Two failure modes happen without a deliberate check at planning end:
1. **Drift** — improvements stay in chat history and never reach the canonical standards; future sprints re-derive what's already been figured out.
2. **Lost lessons** — projects that share lineage (forks, copies of this kit) don't benefit from each other's improvements.

The process-improvement check at planning end is the lightweight counter-pressure to both.

**What qualifies as a process-improvement candidate.** Use the §1.5 tag convention as the primary filter:
- `(planning-process improvement — ...)` → ALWAYS a candidate. Proactive, project-agnostic by definition.
- `(Sprint X retro — Sprint Y codification)` → retro-driven; lives in YOUR project's standards but should NOT be re-raised every sprint as a candidate.
- Untagged rules → manual judgment. Default to NOT a candidate unless the rule is obviously generalizable.

**Operational specification.** Lives in `_sprint-templates/COWORK-PLANNING-KICKOFF.md` → STEP 4.5. The rule fires after STEP 4's drafting is settled and gates STEP 5 (move to QA + generate Claude Code kickoff). Every check appends an entry to the project's planning-process change log (default: a section in PROJECT-PLANNING.md, or a dedicated `PLANNING-PROCESS-CHANGELOG.md` you create) regardless of outcome — no-op sprints get a "no items surfaced" entry.

**For projects downstream of this kit:** if you identify items that would also generalize back UPSTREAM, flag them separately during the check and decide whether to surface them to the kit maintainer. This is the per-project complement to the kit's own batch-sync mechanism in `STARTER-KIT-SYNC-LOG.md`.

**Cross-references:**
- `_sprint-templates/COWORK-PLANNING-KICKOFF.md` § STEP 4.5 — the operational location where the rule fires
- §1.5 "Tag convention" — the per-rule tag system this check uses to filter candidates
- `STARTER-KIT-SYNC-LOG.md` — the kit's own quarterly-batch sync mechanism (complement to this per-sprint check)

### 1.6 Scope boundary

Every build plan must include a **Scope boundary** section that explicitly states what is NOT included in this sprint.

**Format:**

```markdown
## Scope boundary — what is NOT in this sprint

- [ ] <Feature X> integration (stubbed only, real API calls deferred to sprint N+1)
- [ ] <Y> generation (UI only, generation deferred)
- [ ] Mobile responsive layouts (desktop-first, mobile deferred)
- [ ] <Automated workflow Z>
```

Claude Code must not build anything in the "not included" list unless the user explicitly changes scope mid-sprint. If scope creep is detected (e.g., a prompt requires something from the exclusion list), Claude Code should flag it and ask the user how to proceed.

### 1.7 Reference material

When the feature references an external application or codebase, the reference code is included in the sprint folder as a zip or extracted directory. The build plan specifies exactly which files in the reference app to read and why — Claude Code should never blindly import code from a reference app.

### 1.8 Handoff to Claude Code — the kickoff prompt

Once the user confirms that planning is complete ("we're done planning", "let's start building", etc.), Cowork generates the **kickoff prompt** — a single copy-paste command the user runs in Claude Code to begin development.

The kickoff prompt's job is twofold: (1) get Claude Code to read the standards + build plan, and (2) make Claude Code emit a **structured PRE-FLIGHT block** that Cowork (or the user) can scan for correctness before authorising Setup.

**Canonical PRE-FLIGHT block:**

```
PRE-FLIGHT
- READ_FILES: [bullet list of every reference file path you actually opened]
- PROMPT_COUNT: <N>
- SPRINT_BRANCH: <branch>
- SPRINT_VERSION: <version>
- SCOPE_BOUNDARY_ITEMS: [bulleted list of every item from build plan §6 or §7]
- PROMPT_1_TITLE: <title>
- PROMPT_1_FILES_TO_READ: [list every path in Prompt 1's READ FIRST block]
- DESIGN_SYSTEM_REFERENCE: <mockup file or 'not applicable this sprint (no UI surface)'>
- BLOCKING_QUESTIONS: [or 'none']
```

The canonical kickoff template lives at `_sprint-templates/KICKOFF-PROMPT.md` — Cowork copies that file into a new sprint folder and search-and-replaces the substitution markers.

**Rules for the kickoff prompt:**
- Cowork generates this; the user just copies it into Claude Code
- Always starts with reading PROJECT-PLANNING.md so Claude Code knows the process
- Always points to the specific build plan file path
- Instructs Claude Code to emit the PRE-FLIGHT block before any Setup work
- Encodes token security rules + chore-PR scope rule + schema-first rule
- After Setup, user types `proceed` and the handshake takes over

---

## Phase 2: DEVELOPMENT

### 2.0 Source of truth rule

**During development, the ONLY reference material Claude Code should use is:**
1. `PROJECT-PLANNING.md` (this file — process rules)
2. The **current sprint's** build plan and mockups
3. The **live codebase**

**Claude Code must NEVER open or read files from previous sprint folders.** Past mockups, old build plans, and prior reference material are snapshots that may be outdated — the shipped code is the only reliable source for how the app currently looks and works. If a prompt's instructions seem to conflict with what the live code actually does, trust the live code and flag the discrepancy.

### 2.0.1 Clean working tree prerequisite

Sprint operations assume a clean working tree. Before any branching, rebasing, or merging operation, `git status --short` must report only expected drift. Unexpected untracked files should abort the step with a warning rather than silently committing them.

Canonical setup snippet:

```bash
DRIFT=$(git status --short | grep -vE '<expected drift patterns>' || true)
if [[ -n "$DRIFT" ]]; then
  echo "FATAL: unexpected working-tree drift"; echo "$DRIFT"; exit 1
fi
```

### 2.1 Prompt-based development

All development is organized into numbered prompts. Each prompt is a self-contained unit of work that Claude Code executes sequentially.

**Rules for prompt execution:**
- Execute prompts sequentially (Prompt 1 -> 2 -> 3 -> ...)
- Never start a prompt until the previous one passes QA
- Read ALL files in the "READ FIRST" block before writing any code
- Read the mockup HTML to understand the visual spec before building
- The existing app must never break — all existing functionality remains pixel-identical

### 2.2 Mandatory QA protocol — after EVERY prompt

After completing a prompt's build work, Claude Code must run both QA steps below and fix all issues before reporting the prompt as complete.

#### STEP 1: VERIFY (automated QA)

Run these checks in order. Fix any failures before moving to the next check.

1. **Build check** — run your project's build command. Must compile with zero errors.
2. **Schema check** — validate the schema. If schema changed, also run generate + db push (or your project's equivalent migration command).
3. **Schema integrity check** — if the schema was modified, run `git diff HEAD -- <schema-file>` to confirm the working tree matches what was committed.
4. **Seed check** — if seed data was modified, run the seed command and query the database to confirm correct counts.
5. **Start check** — run the dev server, confirm the app starts without console errors. Navigate to key pages.
6. **Lint check** — run the linter. Fix warnings related to code written in this prompt. Run typecheck (`tsc --noEmit` or equivalent). Both run as separate CI gates.
7. **Test check** — write and run tests for everything created or modified in this prompt:
   - Every server action / endpoint (create, update, delete)
   - Every utility function (calculations, formatting, helpers)
   - Every constant/config added
   - Database queries return expected data
   - Components render without crashing (basic render test)
8. **Regression check** — verify existing functionality still works.
9. **Sub-agent code review** (planning-process improvement) — after checks 1–8 pass, spawn the sub-agents listed in this prompt's VERIFY block per the §1.5 Reviewer coverage check.

**Print a QA report in this exact format:**

```
═══════════════════════════════════════
QA REPORT — PROMPT [N]: [Title]
═══════════════════════════════════════
✅ Build check: PASS
✅ Schema check: PASS
✅ Schema integrity check: PASS
✅ Seed check: PASS
✅ Start check: PASS (no console errors)
✅ Lint check: PASS
✅ Test check: PASS (X tests run, X passing)
✅ Regression check: PASS (existing functionality unchanged)
✅ Sub-agent review: PASS (code-reviewer SEVERITY: NONE; [specialized reviewers: SEVERITY: NONE])
═══════════════════════════════════════
RESULT: ALL CHECKS PASSED
═══════════════════════════════════════
```

If a sub-agent reviewer returns SEVERITY: BLOCKING, treat it like a build failure — fix before committing. NEEDS_ATTENTION findings are addressed before committing by default; NITs may be deferred with a justification.

#### STEP 2: COMPARE (self-review against mockups)

After VERIFY passes, compare the built UI against the approved mockups.

1. Open the reference HTML mockup file(s) mapped to this prompt.
2. Read the HTML structure — catalog every UI element.
3. Compare element-by-element against what was built.
4. Fix any differences before proceeding.

#### STEP 3: MANUAL QA TABLE (for user verification)

After both automated QA and comparison pass, Claude Code must provide a Manual QA Table. This is a checklist of things only a human can verify — end-to-end flows, feel, edge cases, and visual polish.

**Rules:**
- Every new UI element or interaction gets a row
- Descriptions must be in plain words
- Always identify the specific mockup file for side-by-side comparison
- Include edge cases: empty states, long text overflow, many items, zero items
- **Claude Code executes every row itself** and fills in the Status column: ✅ verified, ❌ verified failed (fix before reporting complete), ⚠️ requires human judgment (rare)
- The user reviews the completed table but does NOT re-execute each item manually
- Only ⚠️ items require user review before the prompt is marked complete

### 2.3 Reference file mapping

Every build plan must include a table mapping each prompt to its mockup file(s). This tells Claude Code (during COMPARE) and the user (during MANUAL QA) exactly which mockup to check.

### 2.3.1 Cowork file modification rules — never bash-write the workspace

When Cowork has access to a user's workspace folder, it MUST modify files using only the Edit / Write / Read file tools. Cowork's bash sandbox sees the workspace through a mounted mirror that does NOT auto-refresh when Edit/Write/Read modifies files. Bash writes can overwrite the canonical file with the bash mount's stale view, destroying recent Edit-tool modifications.

**Allowed bash operations on workspace files (read-only):** `cat`, `wc`, `grep`, `ls`, `tail`, `head`, `bash -n` (read-only syntax check), `git status`, `git log`, `git diff`.

**Forbidden bash operations on workspace files:** anything that writes — `sed -i`, `>>`, `>`, `tee`, `rm`, `mv`, `cp`, `chmod`, `truncate`, etc. If you need to modify a file, use the Edit tool. If you need to create one, use Write.

### 2.4 Cowork ↔ Claude Code handoff protocol

When Cowork hands off a multi-step task to Claude Code (or vice versa), every Claude Code prompt must update `.claude-code-status/sprint-progress.json` with the prompt's outcome.

**Canonical JSON shape:**

```json
{
  "sprint": 5,
  "branch": "feature/sprint-5-foo",
  "current_prompt": 3,
  "prompts": [
    {
      "n": 1,
      "title": "Schema + foundation",
      "status": "SUCCESS",
      "commit_sha": "abc1234",
      "qa": { "build": "PASS", "test": "PASS", "lint": "PASS", "regression": "PASS" }
    }
  ],
  "context_use_pct": 42,
  "last_updated": "<ISO-8601 timestamp>"
}
```

**Rule:** if Claude Code completes a prompt without updating this file, that's a bug in the prompt's wrapper — not optional polish.

---

## Phase 3: DEPLOYMENT

Phase 3 here is the high-level orchestration. **`DEPLOYMENT-WORKFLOW.md` is the operational authority** — load-bearing platform invariants, the release-flow executable steps all live there. This file references DEPLOYMENT-WORKFLOW.md rather than duplicating it.

### 3.1 Infrastructure overview

See `DEPLOYMENT-WORKFLOW.md` § "Architecture" for your platform-specific infrastructure.

### 3.2 Branch strategy

Standard pattern (adapt per platform):

| Branch | Purpose | Deploys to |
|--------|---------|------------|
| `develop` | Active development, all prompt work lands here | Staging environment |
| `main` | Production-ready code only | Production environment |
| `release/vX.Y.Z` | Release branch cut from develop, merged to main | Pre-production / preview |
| `feature/*`, `fix/*`, `chore/*` | PR work | Per-PR preview (if platform supports) |

**Flow:** `develop` → `release/vX.Y.Z` → `main` → tag → delete release branch → back-merge `main` → `develop` (mandatory; see §3.7).

### 3.3 CI/CD pipeline

See `DEPLOYMENT-WORKFLOW.md` § "CI/CD pipeline" for your platform-specific build + deploy mechanics.

### 3.4 Release process — information gathering

Before ANY deployment, Claude Code must first read `DEPLOYMENT-WORKFLOW.md`. Follow the release process defined there. This is a mandatory question-and-answer flow.

**Questions 0-6 (ask in order, wait for answers):**

| # | Question |
|---|----------|
| 0 | Is this release for STAGING or PRODUCTION? |
| 1 | What type of release is this? (Alpha / Beta / Feature / Patch / Hotfix) |
| 2 | What is the target version number? |
| 3 | Write a brief summary of what changed |
| 4 | List the major features and fixes |
| 5 | Are there any BREAKING CHANGES? |
| 6 | Should this be merged back to develop? |

**Execution steps