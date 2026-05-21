# Sprint <N> — QA Checklist

Feature-level verification. Runs *in addition to* the project's canonical build + test + typecheck commands (those are assumed-green before any item here is checked).

Claude Code should check items off as it completes them. At sprint end, every unchecked item must have an explicit reason in `RETRO.md` (deferred to next sprint, cut from scope, blocked by external dependency, etc.).

## Build & test gates (must pass after every prompt)

- [ ] Project's build command succeeds (e.g., `npm run build`, `pnpm build`, `python -m build`)
- [ ] Project's test command passes (e.g., `npm test`, `pytest`, `bundle exec rspec`)
- [ ] Type-check has zero errors (if your stack has one — `tsc`, `mypy`, `sorbet`, etc.)
- [ ] No new lint errors introduced
- [ ] Schema validates (if migrations touched — e.g., `npx prisma validate`, `alembic check`)

## Golden-path checks (per feature)

_List each feature the sprint ships. For each, list the happy-path flow a real user would take._

### Feature A — <name>

- [ ] User can <action> starting from <entry point>
- [ ] <expected result> appears
- [ ] Data persists across page reload

### Feature B — <name>

- [ ] ...

## Edge-case checks

_Explicit negatives. Easy to forget. Worth listing._

- [ ] Unauthenticated user cannot hit the new routes
- [ ] Authorization: wrong-role user gets 403, not a 500 or blank page
- [ ] Empty-state UI renders (no data scenario)
- [ ] Loading state renders (slow network scenario — throttle in devtools)
- [ ] Error state renders (kill the API, confirm graceful failure)
- [ ] Mobile viewport is not broken (test at 375px width minimum, if applicable)

## Cross-feature regressions

_What existing features could this sprint have broken?_

- [ ] <existing feature 1> still works
- [ ] <existing feature 2> still works

## Deployment gate

- [ ] Preview / staging deploy builds successfully
- [ ] Preview URL opens without console errors
- [ ] Database migrations apply cleanly (test against a fresh branch / staging DB if schema changed)

## Sign-off

- [ ] All checked items verified by user, not just Claude Code
- [ ] `RETRO.md` written
- [ ] `CARRYOVER.md` written if anything deferred
