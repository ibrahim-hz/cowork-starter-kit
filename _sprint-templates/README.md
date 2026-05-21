# Sprint Folder Templates

> Canonical files that every sprint folder should contain. When starting a new sprint, copy the relevant templates from here into the new sprint folder and fill them in.
>
> Plain version: this folder is the cookie cutter. Each sprint gets its own folder copied from these templates.

---

## Sprint folder naming

`<N> - <Short Theme>` — e.g. `3 - Auth and Onboarding`. Numeric prefix for sort order, human theme for scannability.

For repair / carryover sprints: `<N>.5 - Sprint N Repair`.

## Required files per sprint

| File | Purpose | When to fill in |
|---|---|---|
| `Sprint-<N>-Build-Plan.md` | The numbered prompts Claude Code will execute | During planning (Cowork writes this) |
| `KICKOFF-PROMPT.md` | First prompt pasted into Claude Code to start the sprint. Copy `_sprint-templates/KICKOFF-PROMPT.md` and search-and-replace the substitution markers (`<sprint-N>`, `<sprint-name>`, `<sprint-version>`, `<branch>`, `<prompt-count>`, `<prompt-1-title>`, `<design-system-ref>`, `<sprint-specific-read-list>`, `<schema-first-statement>`). | During planning |
| `QA-CHECKLIST.md` | Feature-level checks run before declaring the sprint done | During planning; checked off during execution |
| `RETRO.md` | What went well, what didn't, what to change next sprint | End of sprint (after last prompt commits) |
| `CARRYOVER.md` | Work explicitly pushed to next sprint (optional) | End of sprint, only if carryover exists |

## Optional files per sprint

| File | Purpose |
|---|---|
| `mockups/` | HTML / PNG / image mockups referenced by the build plan |
| `REPAIR-PLAN.md` | Only for `.5` repair sprints — what broke and how we're fixing it |

## Reusable fragments (in this folder)

These are not per-sprint deliverables — they are referenced by build plans and `STARTER-PROJECT-PLANNING.md`.

| File | Purpose |
|---|---|
| `COWORK-PLANNING-KICKOFF.md` | Canonical PLANNING-phase kickoff prompt. The user types a short opener ("I'm planning the next sprint") into a fresh Cowork chat and pastes this prompt below it — no find-replace required. Cowork derives the sprint number from the Planning Tracker's sprint-locked items, then runs the canonical Phase 1 sequence: read standards + prior-sprint outputs + bug/ADR context, codebase orientation, surface locked-in scope + ask the open-ended question, structured refinement, draft chore-PR artifacts, generate the build-phase kickoff. Mirror of `KICKOFF-PROMPT.md` (which is the BUILD-phase kickoff). |
| `KICKOFF-PROMPT.md` | Canonical BUILD-phase kickoff prompt template. Cowork copies this into a new sprint folder and fills in the substitution markers. Pasted into Claude Code after planning is done. Implements the PRE-FLIGHT format from `STARTER-PROJECT-PLANNING.md` §1.8 and the `proceed` handshake from `STARTER-PROJECT-PLANNING.md` "Build Plan Execution Style". |
| `_proceed-handshake-snippet.md` | Source-of-truth text for the canonical completion-report footer (`Status: STOPPED for review. Reply 'proceed' …` plus the conditional `SESSION RESET RECOMMENDED` line). Build plans link to this snippet rather than duplicating the text. The leading underscore sorts it above the per-sprint templates and signals "reusable fragment, not a deliverable". |

## Sub-agent methodology (lives at the kit root, not here)

`STARTER-SUB-AGENT-METHODOLOGY.md` is the canonical document for the kit's Phase 2 Claude Code sub-agent roster (the 3 defaults in `.claude/agents/`, plus the 5 optional + 6 stack-template agents catalogued for adoption later). It contains the review cadence rule (every 5 sprints + event trigger), the review-sprint runbook, the comprehensive 14-agent catalog, and the roster history table.

It is intentionally OUTSIDE the standard kickoff READ-FIRST list. Cowork reads it ONLY when: (a) the sprint number is a multiple of 5, OR (b) the past 2 retros mention the same uncovered bug class. See `STARTER-PROJECT-PLANNING.md` §1.2.3 (sub-agent review cadence) and `COWORK-PLANNING-KICKOFF.md` § "CONDITIONAL — SUB-AGENT METHODOLOGY" for the conditional-read trigger.

## Naming consistency

- Use `Sprint-<N>-Build-Plan.md` (hyphenated, numeric). If you ever automate sprint runners, they will key off this exact pattern — don't drift to `BUILD-PLAN.md` or `build-plan.md`.
- Everything else is `UPPERCASE-WITH-HYPHENS.md`.

## Filename drift bites later

If you see a sprint folder using `BUILD-PLAN.md` instead of `Sprint-N-Build-Plan.md`, it's drift — rename it. Any future automation will silently fail to find the plan otherwise.
