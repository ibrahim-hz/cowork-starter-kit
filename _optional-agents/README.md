# Optional Agents

> Specialized Claude Code reviewers derived from the upstream source project. None of these are installed by default — copy the relevant file into `.claude/agents/` when you have evidence the failure class affects your project.
>
> Plain version: these are reviewers we know are useful in specific situations. Pick the ones that match your stack and how things have been going wrong.

---

## When to use this folder

The 3 default agents in `.claude/agents/` (`code-reviewer`, `test-runner`, `docs-researcher`) are stack-agnostic and ship by default. The 5 reviewers in this folder are specialists — they catch a particular failure class that doesn't justify the cost of running on every prompt for every project, but is worth adding when:

1. Your stack matches (e.g., Next.js for the boundary reviewer).
2. Your retros are surfacing the failure class repeatedly.
3. The 5-sprint review identifies the gap.

See `STARTER-SUB-AGENT-METHODOLOGY.md` → "Optional agents (5)" for the full catalog with rationale, what each one catches, and the criteria for adoption.

---

## How to install one

```bash
# Copy from this folder into the project's active agent roster
cp _optional-agents/<agent-name>.md .claude/agents/

# Edit the header comment to record the date you adopted it
# (open the file, replace "Added: copied from _optional-agents/ on <date>" with today's date)

# Commit the change in a chore PR with the rationale
git add .claude/agents/<agent-name>.md
git commit -m "chore: add <agent-name> sub-agent — <one-line reason>"
```

After install, the agent runs on every prompt's VERIFY block (or on the trigger condition specified in its file). Update `STARTER-SUB-AGENT-METHODOLOGY.md`'s "Roster history" table to record the addition.

---

## The 5 optional agents

### `next-js-server-client-boundary-reviewer.md`

**Catches:** Missing `"use client"` directives, `NEXT_PUBLIC_*` leaks, async server imports landing in client trees, server-only modules imported into client components.

**Install when:** Your stack is Next.js App Router AND retros mention any "client component failed to hydrate" / "server-only module leaked to client" issues.

---

### `next-js-provider-chain-reviewer.md`

**Catches:** New `useXxx` context hooks introduced into components that don't have the corresponding `<XxxProvider>` ancestor in the layout tree. The "added a hook, forgot to wire the provider in `layout.tsx`" class of bugs.

**Install when:** Your stack uses React + React Context heavily (TanStack Query, Apollo, Zustand-via-context, theme/auth providers) AND retros mention provider-not-found runtime errors.

---

### `dedicated-security-reviewer.md`

**Catches:** The same S1–S15 surface as the default `code-reviewer`, but as a separate reviewer pass. Useful when you want security findings raised independently of the general code review.

**Install when:** Path A in the default `code-reviewer` is producing security findings that get diluted in the general review, OR a security incident shipped that should have been caught by S1–S15 but wasn't, OR you want compliance-style separation between "code review" and "security review" sign-offs.

---

### `external-api-resilience-reviewer.md`

**Catches:** Calls to third-party APIs without try/catch, fallback, timeout, or graceful degradation. Especially valuable for "decorative" integrations (oEmbed previews, exchange-rate lookups, weather) that shouldn't block the main UX when they fail.

**Install when:** Your app heavily integrates third-party APIs AND retros mention "X integration broke and took down feature Y." Common after the 2nd or 3rd third-party API is added.

---

### `build-plan-step-ordering-reviewer.md`

**Catches:** Build plans where a later step depends on a schema / migration / config that was supposed to land in an earlier step but was deferred. Cowork-side reviewer (runs at chore-PR time, not Claude-Code-side).

**Install when:** Retros mention "discovered mid-sprint that Prompt N depends on something Prompt N+M was supposed to provide." Schema-first projects benefit most.

---

## After 5 sprints

When the scheduled review fires (every 5 sprints), reconsider whether your installed agents are still pulling their weight and whether any of the not-yet-installed ones should be added. See `STARTER-SUB-AGENT-METHODOLOGY.md` § "Review-sprint runbook" for the procedure.
