# Sub-Agent Methodology — Roster, Cadence, and Catalog

> **Read this file ONLY when:**
> - The sprint number is a multiple of 5 (Sprint 5, 10, 15, 20, …) — scheduled review trigger
> - OR the past 2 retros mention the same uncovered bug class — event-based mini-review trigger
> - OR you're considering adding a new reviewer mid-sprint and want the catalog of options
>
> Otherwise this file is NOT in the standard kickoff READ-FIRST list. It exists to preserve the roster rationale + run the periodic review process WITHOUT bloating every sprint's planning context.
>
> Plain version: the "what reviewers we have, when we review them, what other reviewers we could add" document. Periodic, not per-sprint.

---

## Purpose

This document covers four things:

1. **The review cadence rule** — every 5 sprints + event-based trigger.
2. **The review-sprint runbook** — what Cowork does during a scheduled review.
3. **The comprehensive agent catalog** — all 14 agents that ship with the starter kit (3 defaults + 5 optional + 6 stack-templates), each with: what it catches, when to add it, where the file lives, originated-from notes.
4. **The roster history table** — append-only log of additions / retirements / modifications.

---

## Current default roster

Three sub-agents ship in `.claude/agents/` and run on every prompt by default:

| Agent | Model | Tools | When it runs | Catches |
|---|---|---|---|---|
| `code-reviewer` | sonnet | Read, Grep, Glob, Bash | End of every prompt's VERIFY block | General-purpose: N+1 queries, missing edge cases, over-replacements, debug code, security S1–S15 checklist, anti-patterns the lint suite doesn't catch |
| `test-runner` | haiku | Bash, Read | Every prompt (parallel with build/lint/typecheck) | Runs the project's test command, parses output, reports structured pass/fail |
| `docs-researcher` | sonnet | WebFetch, WebSearch, Read | On-demand when Claude Code needs current API signatures | Up-to-date API signatures for whatever framework / library you're using |

The §1.5 "Reviewer coverage check" in `STARTER-PROJECT-PLANNING.md` drives the per-prompt invocation logic — Cowork applies a check at plan-drafting time and bakes the appropriate reviewer invocations into each prompt's VERIFY block.

---

## Review cadence rule

**Scheduled review:** every 5 sprints (Sprint 5, 10, 15, 20, …). Lightweight by default — most cycles conclude "no changes needed."

**Event-based trigger:** if ANY bug class appears in 2 consecutive retros (e.g., Sprint N RETRO + Sprint N+1 RETRO both mention the same uncovered failure mode) AND the class is NOT covered by an existing reviewer or static lint rule, trigger a mini-review at the next sprint planning regardless of the scheduled cadence.

**Why this cadence:**

- Every 5 sprints gives enough retro evidence (5 `RETRO.md` files to compare) without becoming a chore.
- Event-based trigger ensures urgent recurring incidents don't wait up to 4 sprints for review.
- The hybrid hedges both ways: predictable rhythm + reactive escalation.

---

## Review-sprint runbook

When a sprint is a scheduled review (multiple of 5) OR an event-trigger fired, Cowork follows this runbook during planning:

### STEP 1 — Gather retro evidence

Read the last 5 sprints' `RETRO.md` files (or the last 2 if event-triggered). Specifically extract:

- "What didn't work" sections
- "Surprises" sections
- Any cross-references to bug files

### STEP 2 — Identify new patterns

For each recurring theme that appears in ≥2 of the read RETROs:

- Is it covered by an existing reviewer? → no action
- Is it covered by a lint rule or other static check? → no action
- Is it a platform/runtime issue (not diff-catchable)? → no reviewer; consider a structural fix instead
- Is it diff-catchable AND uncovered? → candidate for a new reviewer (check the catalog below)

### STEP 3 — Evaluate current roster ROI

For each existing reviewer, check the past sprints' commit history or retro citations:

- Did the reviewer flag at least 1 BLOCKING or NEEDS_ATTENTION finding that was acted on?
  - Yes → keep
  - No → mark for review. If 2 consecutive reviews show zero acted-on findings, retire.

### STEP 4 — Propose changes

Output a structured summary to the user:

```
Sub-agent review — Sprint <N>

Retros read: <N-5> through <N-1>

New patterns identified:
- <pattern>: <sprints affected>. Recommended action: add reviewer X / extend reviewer Y / no action.

Existing roster review:
- <reviewer name>: kept / retire / merge with X. Evidence: <N findings acted on in last 5 sprints>.

Recommended changes:
1. Add: <new reviewer name>
2. Retire: <existing reviewer name>
3. Modify: <existing reviewer name> — <what change>
```

### STEP 5 — On user approval, update artifacts

- Copy any new reviewer file from `_optional-agents/` or `_stack-templates/` into `.claude/agents/` (or write a new one)
- Update the "Current default roster" table above
- Append an entry to "Roster history" below
- Update `STARTER-PROJECT-PLANNING.md` §1.5 Reviewer coverage check if the trigger conditions changed
- Update each agent file's header comment with the next review-for-retention sprint number

---

## Comprehensive agent catalog (14 entries)

This catalog covers every agent that ships with the kit. Use it during a review-sprint to consider all options, not just what's currently installed.

### Default agents (3) — ship in `.claude/agents/`

These are stack-agnostic and run on every prompt by default. Do not retire without strong evidence.

#### 1. `code-reviewer`

- **What it catches:** General diff review — N+1 queries, missing edge cases, over-replacements (e.g., `replaceAll` matching unintended substrings), debug code (`console.log`, `print()`, `dd()`, etc.) left behind, anti-patterns the lint suite doesn't catch, and the full **S1–S15 security checklist** (auth, ownership, PII handling, raw SQL, XSS, CSRF, rate limiting, secrets, crypto, audit logging, prompt-injection mitigation, AI-tool tier classification). Security findings are classified BLOCKING — no downgrade to NEEDS_ATTENTION or NIT.
- **When to consider adding:** Default — already installed.
- **When to consider modifying:** If a security finding ships to prod that S1–S15 should have caught, extend the relevant S-item with the specific pattern.
- **Where the file lives:** `.claude/agents/code-reviewer.md`
- **Originated from:** Stripped-down generalization of the upstream source project's general code reviewer. The S1–S15 expansion is from the upstream's Path A decision (security coverage via strengthened general reviewer + planning-time threat modeling, instead of a dedicated security reviewer in the default roster).

#### 2. `test-runner`

- **What it catches:** Runs the project's test command (auto-detected from `package.json`, `pyproject.toml`, `Gemfile`, or asked), parses the output, and reports structured pass/fail with failing test names and one-line context. Does NOT debug the failures — surfaces them so the main loop can act.
- **When to consider adding:** Default — already installed.
- **When to consider modifying:** If the project adopts a non-standard test runner or needs custom output parsing.
- **Where the file lives:** `.claude/agents/test-runner.md`
- **Originated from:** Stripped-down generalization of the upstream source project's test runner. Generalized to call whatever test command the project's manifest declares (or that the user told Cowork during setup) rather than hardcoding a specific test command.

#### 3. `docs-researcher`

- **What it catches:** Looks up current API signatures, breaking-change notes, and migration guides for whatever framework / library is being modified. Reduces hallucinated API shapes (especially after major-version bumps).
- **When to consider adding:** Default — already installed.
- **When to consider modifying:** If your stack has internal documentation conventions the agent should learn about.
- **Where the file lives:** `.claude/agents/docs-researcher.md`
- **Originated from:** Stripped-down generalization of the upstream source project's docs researcher. Library / framework list is project-specific and gets populated during setup.

---

### Optional agents (5) — ship in `_optional-agents/`

These are derived from upstream retros and ship in `_optional-agents/`. Copy into `.claude/agents/` when you have evidence the agent's failure class affects your project.

#### 4. `next-js-server-client-boundary-reviewer`

- **What it catches:** Missing `"use client"` directives, `NEXT_PUBLIC_*` leaks into server-only code, async server imports landing in client trees, server-only modules (Prisma client, server-only libraries) imported into client components.
- **When to consider adding:** Your stack is Next.js App Router AND retros mention any "client component failed to hydrate" / "server component leaked to client" / "server-only client imported into client tree" issues. Upstream evidence: multiple sprints with this failure class before the agent was added.
- **Where the file lives:** `_optional-agents/next-js-server-client-boundary-reviewer.md`
- **Originated from:** The upstream source project's server-client boundary reviewer. Justified by repeated Next.js boundary confusion across multiple upstream sprints.

#### 5. `next-js-provider-chain-reviewer`

- **What it catches:** New `useXxx` context hooks introduced into components that don't have the corresponding `<XxxProvider>` ancestor in the layout tree. Catches the "added a hook, forgot to wire the provider in `layout.tsx`" class of bugs at PR-time instead of runtime.
- **When to consider adding:** Your stack uses React + React Context heavily (`QueryClientProvider`, `ThemeProvider`, custom auth provider, etc.) AND retros mention provider-not-found runtime errors. Common with TanStack Query, Apollo, Zustand-via-context, and similar.
- **Where the file lives:** `_optional-agents/next-js-provider-chain-reviewer.md`
- **Originated from:** The upstream source project's provider-chain reviewer. Justified by repeated provider-chain failures across multiple upstream sprints (canonical case: a `QueryClientProvider` or equivalent context provider added to a component without being wired into the root layout).

#### 6. `dedicated-security-reviewer`

- **What it catches:** Same S1–S15 surface as the default `code-reviewer`, but as a separate reviewer pass — useful when you want security findings raised independently of the general code review, or when the general reviewer's S1–S15 coverage is producing too many false positives / false negatives.
- **When to consider adding:** Path A in the default `code-reviewer` is producing security findings that get diluted in the general review, OR a security incident shipped that should have been caught by S1–S15 but wasn't, OR you want compliance-style separation between "code review" and "security review" sign-offs.
- **Where the file lives:** `_optional-agents/dedicated-security-reviewer.md`
- **Originated from:** The upstream source project's Path A deliberation. The default kit follows Path A (security via strengthened general reviewer); this file is the Path B alternative for projects that prefer separation.

#### 7. `external-api-resilience-reviewer`

- **What it catches:** Calls to third-party APIs that don't wrap the call in try/catch, don't provide a fallback when the call fails, don't time out, or don't degrade gracefully when the API returns 5xx / rate-limit / unexpected schema. Especially valuable for "decorative" integrations (oEmbed previews, exchange-rate lookups, weather, etc.) that shouldn't block the main UX when they fail.
- **When to consider adding:** Your app heavily integrates third-party APIs AND retros mention "X integration broke and took down feature Y." Common after the 2nd or 3rd third-party API is added.
- **Where the file lives:** `_optional-agents/external-api-resilience-reviewer.md`
- **Originated from:** The upstream source project's "Tier 2 candidates" list (add-when-appetite section). Justified by multiple upstream sprints each surfacing an external-API resilience failure.

#### 8. `build-plan-step-ordering-reviewer`

- **What it catches:** Cowork-side reviewer (runs at chore-PR time, not Claude-Code-side) that flags build plans where steps are ordered such that a later step depends on a schema / migration / config that was supposed to land in an earlier step but was deferred. Catches "we'll add the column in Prompt 5" + "we use the column in Prompt 3" inversions before Prompt 3 starts failing.
- **When to consider adding:** Retros mention "discovered mid-sprint that Prompt N depends on something Prompt N+M was supposed to provide." Schema-first projects benefit most.
- **Where the file lives:** `_optional-agents/build-plan-step-ordering-reviewer.md`
- **Originated from:** The upstream source project's "Tier 2 candidates" list. Justified by an upstream schema-step-ordering inversion incident where a later prompt's step depended on a schema change deferred to an even-later prompt.

---

### Stack-template agents (6) — ship in `_stack-templates/`

These are starting points for stacks other than Next.js. Copy into `.claude/agents/` and tune the system prompt to your project's actual patterns; expect 1–2 sprints of refinement before the agent's catch rate is meaningful.

#### 9. `vue-nuxt-reviewer`

- **What it catches:** Vue 3 / Nuxt 3 anti-patterns — `<script setup>` reactivity gotchas (forgetting `ref()`/`reactive()`, destructuring losing reactivity), Pinia store boundary violations, Nuxt server/client auto-import confusion (e.g., `useState` shared across requests on the server), missing `definePageMeta` / `defineRouteRules`, Composition API hooks called outside `setup`.
- **When to consider adding:** Your stack is Vue 3 + Pinia, with or without Nuxt 3.
- **Where the file lives:** `_stack-templates/vue-nuxt-reviewer.md`
- **Originated from:** Stack-template starter — no upstream precedent. Pattern library based on common Vue 3 / Nuxt 3 bug classes documented in the ecosystem.

#### 10. `django-reviewer`

- **What it catches:** Django / Django REST Framework anti-patterns — N+1 queries (missing `select_related` / `prefetch_related`), `QuerySet.update()` bypassing `save()` signals where signals matter, missing `@transaction.atomic` on multi-write views, `DRF` serializer validation bypasses, raw SQL without parameterization, signal handlers connecting at import time rather than `apps.py`'s `ready()`, `Meta.unique_together` vs. `UniqueConstraint` confusion in migrations.
- **When to consider adding:** Your stack is Django (with or without DRF).
- **Where the file lives:** `_stack-templates/django-reviewer.md`
- **Originated from:** Stack-template starter — no upstream precedent.

#### 11. `rails-reviewer`

- **What it catches:** Rails anti-patterns — N+1 queries (missing `.includes`), mass-assignment violations of `strong_parameters`, `find_by_sql` / raw SQL without sanitization, `before_save` / `after_create` callbacks doing too much, `update_columns` skipping validations where validations matter, migrations missing `reversible` blocks, ActiveJob handlers swallowing exceptions silently.
- **When to consider adding:** Your stack is Rails.
- **Where the file lives:** `_stack-templates/rails-reviewer.md`
- **Originated from:** Stack-template starter — no upstream precedent.

#### 12. `react-vite-reviewer`

- **What it catches:** React + Vite (no Next.js, no SSR) anti-patterns — missing `key` props on lists, effects with missing dependencies, stale closures in event handlers, fetching inside render, environment variables exposed via `import.meta.env.VITE_*` that shouldn't be public, missing `lazy()` / `Suspense` boundaries for code-split routes.
- **When to consider adding:** Your stack is React + Vite as an SPA (no Next.js, no Remix).
- **Where the file lives:** `_stack-templates/react-vite-reviewer.md`
- **Originated from:** Stack-template starter — no upstream precedent. Closest neighbor is the Next.js boundary reviewer (#4), but the failure surface is different enough to justify a separate template.

#### 13. `express-node-reviewer`

- **What it catches:** Express / Node.js API server anti-patterns — async route handlers without error catching (uncaught promise rejection), missing `helmet` / CORS / rate-limit middleware, JWT validation bypasses, request-body parsing without size limits, `process.env.X` reads without validation, mutable module-level state shared across requests, missing graceful-shutdown handler for in-flight requests.
- **When to consider adding:** Your stack is Express or a Node.js HTTP framework (Fastify, Koa) — adjust the patterns to your specific framework.
- **Where the file lives:** `_stack-templates/express-node-reviewer.md`
- **Originated from:** Stack-template starter — no upstream precedent.

#### 14. `generic-python-reviewer`

- **What it catches:** Generic Python anti-patterns — mutable default arguments, missing context managers on file / DB connections, broad `except Exception` swallowing real errors, `subprocess` calls with `shell=True` on untrusted input, `eval` / `exec` on untrusted input, `pickle.loads` on untrusted input, missing type hints on public API boundaries, threading vs. asyncio mixing.
- **When to consider adding:** Your stack is Python and doesn't fit Django (#10) — e.g., FastAPI, Flask, pure scripts, data pipelines.
- **Where the file lives:** `_stack-templates/generic-python-reviewer.md`
- **Originated from:** Stack-template starter — no upstream precedent.

---

## Roster history

| Sprint | Action | Agent(s) | Rationale |
|---|---|---|---|
| 1 (install) | Initial setup | `code-reviewer`, `test-runner`, `docs-researcher` | Default 3-agent roster from the starter kit. Stack-agnostic; runs on every prompt. |

Future entries follow this shape:

```
| <N> | <Added | Retired | Modified> | <agent name(s)> | <reason: retro evidence, ROI signal, etc.> |
```

---

## Tag convention reminder

This document was produced as a **planning-process improvement** — proactive review of the planning + Phase 2 verification flow. Rules introduced from this doc carry the `(planning-process improvement — …)` tag, not a retro-driven tag, because the starter kit has no retro history of its own at install time.

---

## Cross-references

- `.claude/agents/*.md` — the default agent files themselves
- `_optional-agents/*.md` — copy into `.claude/agents/` when criteria met
- `_optional-agents/README.md` — quick-reference for when to copy each one
- `_stack-templates/*.md` — copy + customize for non-Next.js stacks
- `_stack-templates/README.md` — quick-reference for which template fits which stack
- `STARTER-PROJECT-PLANNING.md` §1.2.3 — sub-agent review cadence rule (planning-time)
- `STARTER-PROJECT-PLANNING.md` §1.5 "Reviewer coverage check" — per-prompt invocation rule
- `STARTER-PROJECT-PLANNING.md` §2.2 STEP 1 — VERIFY-block format including sub-agent spawn
- `_sprint-templates/COWORK-PLANNING-KICKOFF.md` — conditional read of this file in STEP 1
- `STARTER-QA-STANDARDS.md` §1 — standing rules that complement (not duplicate) the reviewers
- `C - Bugs/fixed/` — file bugs here so future review-sprints have retro evidence to draw from
