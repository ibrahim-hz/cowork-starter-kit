<!--
PLACEHOLDER FILE — this is the canonical empty-sprint folder shape.

When you start your real Sprint 1:
1. Rename this folder to "1 - <Your Sprint 1 Theme>" (e.g., "1 - Auth and Onboarding")
2. Replace the contents of this file with the real build plan produced by Cowork's
   planning conversation (paste the prompt from `_sprint-templates/COWORK-PLANNING-KICKOFF.md`).
3. Fill in `KICKOFF-PROMPT.md` with the substitution markers (Cowork does this automatically
   at the end of planning).
4. Fill in `QA-CHECKLIST.md` with the actual feature-level checks.
5. Drop any mockups (HTML, PNG, Figma exports) into `mockups/`.
6. Delete this comment block.

The sections below are the canonical shape every Sprint-N-Build-Plan.md should have.
Cowork's planning conversation produces this shape automatically; this placeholder
exists so a brand-new project can see what to expect.
-->

# Sprint 1 — <Theme> — Build Plan

> Status: PLACEHOLDER. This file is replaced by Cowork during Sprint 1 planning.

## §0. Goal

One paragraph describing what this sprint ships. User-visible outcome, not implementation detail.

## §1. Architecture

Short prose on the structural decisions this sprint makes. Diagrams allowed (ASCII or links to mockups). If the sprint touches any of the 5 security-threat-modeling surfaces (auth flows, AI bot tools, billing, new API routes, multi-tenant data), include a **Security threat-modeling** sub-section per `STARTER-PROJECT-PLANNING.md` §1.5.

### Security threat-modeling (omit this sub-section if no surfaces are touched)

- **Threat surface:** <which surface(s)>
- **Threats considered:** <enumerated threats relevant to this surface>
- **Mitigations per threat:** <one mitigation per threat>
- **ADR / lint cross-references:** <links to relevant `D - Decisions/` entries or lint rules>
- **Verification check:** <which VERIFY assertion confirms the mitigation holds>

## §2. Scope summary

Three to seven bullet points summarizing what's IN this sprint. One bullet per major deliverable.

## §3. Database / schema changes

If any. Per the schema-first rule (`STARTER-PROJECT-PLANNING.md` §1.5), schema changes land in Prompt 1.

If this sprint has zero schema changes: state that explicitly here.

## §4. Reference files

Each feature in §2 should map to a mockup file (HTML, PNG, Figma link) under `mockups/`. List the mapping here:

| Feature / Prompt | Mockup file |
|---|---|
| <feature> | `mockups/<file>` |

## §5. Test strategy

How does this sprint know it works? Unit tests, integration tests, end-to-end tests, manual verification — list per feature. If the project doesn't have a test runner yet, this is the sprint to add one.

## §6. Build sequence

The numbered prompts Claude Code will execute. Each prompt is one commit.

### Setup

- STEP 0 — confirm secrets resolution (env → project secrets file).
- STEP 1 — create branch `feature/sprint-1-<short-name>` from `develop`.
- STEP 2 — baseline build / test / lint all green.
- STEP 3 — independent verification of clean state.
- STEP 4 — restate the PRE-FLIGHT block.

After SETUP, wait for `proceed`.

### Prompt 1 — <Title>

**READ FIRST:** <files>

**Goal:** <one-line outcome>

**Steps:**
1. <action>
2. <action>
3. ...

**VERIFY:**
- [ ] <assertion 1>
- [ ] <assertion 2>
- [ ] `code-reviewer` reports SEVERITY: NONE (or all findings addressed)
- [ ] `test-runner` reports PASS
- [ ] Other specialized reviewers invoked per the §1.5 reviewer-coverage check
- [ ] E2E test invocation per the §1.5 E2E-coverage check (Q1-Q4)

**On completion:** commit with message `<conventional commit>` and emit the canonical `proceed` handshake footer (see `_sprint-templates/_proceed-handshake-snippet.md`).

### Prompt 2 — <Title>

(Same shape as Prompt 1.)

### ... etc

## §7. Scope boundary — NOT in this sprint

Explicitly excluded from this sprint's scope:

- <item>
- <item>

These belong in future sprints or are intentionally cut. Keeping this list short forces the build plan to be honest about scope.

## §8. Sprint Completion

After the last prompt's commit:

1. Update `QA-CHECKLIST.md` with any items that are still unchecked + the reason (per `STARTER-QA-STANDARDS.md`).
2. Write `RETRO.md` per `_sprint-templates/RETRO.md` shape.
3. If anything carried over to Sprint 2, write `CARRYOVER.md`.
4. If the sprint introduced any new ADRs, file them under `D - Decisions/`.
5. Open the release PR per `DEPLOYMENT-WORKFLOW.md` Phase 3.

The canonical completion-report footer (`Status: STOPPED for review …`) for every prompt lives at `_sprint-templates/_proceed-handshake-snippet.md`. Reproduce it verbatim — do not paraphrase.
