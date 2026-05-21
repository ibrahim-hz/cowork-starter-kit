<!--
PLACEHOLDER FILE — canonical empty-sprint QA checklist shape.

When you start your real Sprint 1, replace the placeholder feature sections with
the actual features the sprint ships. The "Build & test gates" and "Edge-case
checks" sections are reusable as-is; only the per-feature "Golden-path checks"
section needs sprint-specific content.

Cowork's planning conversation populates this file at the end of Sprint 1
planning by copying `_sprint-templates/QA-CHECKLIST.md` and filling in the
feature blocks.
-->

# Sprint 1 — QA Checklist

Feature-level verification. Runs *in addition to* the project's canonical build + test + typecheck commands (those are assumed-green before any item here is checked).

Claude Code should check items off as it completes them. At sprint end, every unchecked item must have an explicit reason in `RETRO.md`.

## Build & test gates (must pass after every prompt)

- [ ] Project's build command succeeds
- [ ] Project's test command passes
- [ ] Type-check has zero errors (if your stack has one)
- [ ] No new lint errors introduced
- [ ] Schema validates (if migrations touched)

## Golden-path checks (per feature)

_Replace the placeholder feature names with Sprint 1's actual deliverables._

### Feature A — <name>

- [ ] User can <action> starting from <entry point>
- [ ] <expected result> appears
- [ ] Data persists across page reload (if relevant)

### Feature B — <name>

- [ ] ...

## Edge-case checks

- [ ] Unauthenticated user cannot hit the new routes
- [ ] Authorization: wrong-role user gets 403, not a 500 or blank page
- [ ] Empty-state UI renders (no data scenario)
- [ ] Loading state renders (slow network scenario)
- [ ] Error state renders (kill the API, confirm graceful failure)
- [ ] Mobile viewport is not broken (test at 375px width minimum, if applicable)

## Cross-feature regressions

_What existing features could this sprint have broken? For Sprint 1, there are no existing features yet — leave this section as a placeholder with "N/A for Sprint 1" or remove it._

- [ ] N/A for Sprint 1 (no prior features to regress)

## Deployment gate

- [ ] Preview / staging deploy builds successfully
- [ ] Preview URL opens without console errors
- [ ] Database migrations apply cleanly (test against a fresh branch / staging DB if schema changed)

## Sign-off

- [ ] All checked items verified by user, not just Claude Code
- [ ] `RETRO.md` written
- [ ] `CARRYOVER.md` written if anything deferred (likely "nothing deferred" for Sprint 1)
