# Architectural Decision Records (ADRs)

Where load-bearing architectural decisions live. Each decision is a separate file (`0001-<short-name>.md`, `0002-...`, etc.). The index of all ADRs lives in [`INDEX.md`](./INDEX.md).

The template for new ADRs lives in [`_template.md`](./_template.md).

---

## What qualifies as an ADR

File an ADR when you make a **non-obvious choice that's load-bearing for future development**.

> The bullets below are **hypothetical illustrations**, not rules your project must follow. They exist to show the *shape* of decisions worth recording. Substitute your own app's vocabulary and choices when writing ADRs.

Examples:

- **Library / framework choice** where the alternatives are roughly comparable (e.g., "we use Drizzle ORM rather than Prisma because of X").
- **Data shape decision** that constrains future schema evolution (e.g., "we model tenant isolation via a `tenantId` column on every table rather than schema-per-tenant"). <!-- generic SaaS example; your app might use `accountId`, `orgId`, `workspaceId`, or whatever fits your domain. -->
- **Permission / security model** decision (e.g., "AI bot tools are tiered: Autonomous / Pause-and-confirm / Forbidden").
- **Deployment topology** decision (e.g., "we run background workers in the same VPS as the web server, not as separate processes").
- **Standard / convention** that the team has implicitly agreed to but never wrote down (e.g., "all server actions live in `actions.ts` files, one per route group").

Skip ADRs for routine implementation choices ("which color to use for the primary button") and for decisions that are fully self-evident from the code.

If you're unsure whether something deserves an ADR, the test is: "If a new engineer joins in 6 months and asks 'why did we do it this way?', would they need to read this decision in detail?" If yes, write the ADR.

---

## ADR lifecycle

ADRs are immutable once accepted. **Don't edit them** — if the decision changes, write a NEW ADR that supersedes the old one and update the index.

States:
- **Proposed** — drafted but not yet decided. Used for ADRs under discussion.
- **Accepted** — decision made. The current ADR governs the topic.
- **Superseded** — a later ADR replaces this one. Update the original ADR's metadata to point to the superseder. The original ADR stays in place for historical context.
- **Deprecated** — the topic is no longer relevant (e.g., feature removed). ADR stays for history but is no longer active.

---

## How to write an ADR

1. Copy `_template.md` to `0NNN-<short-kebab-summary>.md` where NNN is the next available number.
2. Fill in:
   - Title
   - Status (Proposed → Accepted typically after a brief review)
   - Date
   - Context (what problem prompted this decision)
   - Considered options (at least 2, with pros/cons)
   - Decision (which option, in one sentence)
   - Consequences (what changes downstream as a result)
   - Follow-ups (if any concrete next-actions emerge from the decision)
3. Add a row to `INDEX.md` referencing the new ADR file.
4. Commit the ADR with the code change that implements it, when possible, so the decision and the diff live in the same history point.

---

## When ADRs interact with sprint planning

During sprint planning, Cowork reads `INDEX.md` to surface ADRs whose follow-ups touch the current sprint's likely scope. The Cowork planning kickoff prompt (`_sprint-templates/COWORK-PLANNING-KICKOFF.md`) does this automatically.

If a sprint's work makes a decision that warrants an ADR, the ADR should land alongside the code change in the same chore PR or feature branch.

---

## ADR vs lint rule vs runbook entry

These three artifacts solve overlapping problems. Pick the right one:

- **ADR** — the rationale + decision + considered alternatives + downstream consequences. Forensic, narrative. Read when investigating "why".
- **Lint rule** — automated enforcement of a specific pattern in code. Runs every commit, blocks violations. Read when triggered by a failing build.
- **Runbook entry** — operational steps to take when a specific incident class occurs. Read when triaging a live issue.

A decision often spawns ALL THREE: file the ADR for the rationale, add the lint rule to enforce it, write the runbook entry for when the lint rule fires unexpectedly.

---

## Cross-reference

- [`INDEX.md`](./INDEX.md) — index of all ADRs
- [`_template.md`](./_template.md) — template for new ADRs
- [`../STARTER-PROJECT-PLANNING.md`](../STARTER-PROJECT-PLANNING.md) §1.2.2 — Architectural decisions (planning-time integration)
- [`../STARTER-CLAUDE-CODE-RUNBOOK.md`](../STARTER-CLAUDE-CODE-RUNBOOK.md) — operational counterpart for production incidents
