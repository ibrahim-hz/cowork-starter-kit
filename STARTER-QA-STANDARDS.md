# QA Standards — Mandatory for All Sprints

Every sprint build plan MUST include these QA requirements. This is not optional. Claude Code must follow these standards during execution, and the sprint completion checkpoint should fail if they are not met.

Rename to `QA-STANDARDS.md` after install. Customize for your specific stack as patterns emerge.

---

## 1. Per-Prompt Gates (run after EVERY prompt, before committing)

### Build verification

```bash
<your build command>             # Must pass — zero errors
<your test command>              # Must pass — zero failures
<your typecheck command>         # Must pass — zero errors (TypeScript projects)
<your lint command>              # Must pass — fix warnings related to this prompt
<your schema validate command>   # Must pass if schema was touched
```

Adapt to your stack. Examples:

- Node/Next.js: `npm run build`, `npm test`, `npx tsc --noEmit`, `npm run lint`, `npx prisma validate`
- Django: `python manage.py check`, `pytest`, `mypy .`, `ruff check`, `python manage.py migrate --check`
- Rails: `bin/rails zeitwerk:check`, `bin/rails test`, `srb tc` (if Sorbet), `rubocop`, `bin/rails db:migrate:status`
- Vue/Nuxt: `npm run build`, `npm test`, `npx vue-tsc --noEmit`, `npm run lint`

### Diff review

Before committing, Claude Code MUST review its own diff:

```bash
git diff --stat                  # Overview of what changed
git diff -- <source-directory>   # Full diff of source changes
```

Check for:
- Accidental deletions (files that shouldn't have been touched)
- Over-replacements (find-replace that hit variable names, comments, or strings incorrectly)
- Duplicate entries in arrays (e.g., same role listed twice in a permissions array)
- Debug code left in (console.log, debugger statements, print() calls)
- Hardcoded test values that should be dynamic

### Regression check

After every prompt, verify that these core paths still work by checking the code compiles and the components exist:
- Login / authentication entry points
- Primary dashboard / home view
- Each role-specific area (Admin, User, etc.)
- Navigation / sidebar component renders correctly
- Protected routes enforce auth/role guards

### Anti-regression rules must specify path, not just pattern

A banned pattern without a path context will flag legitimate uses elsewhere. Write every anti-regression entry as:

```
<pattern> in <file or glob>
```

Examples:
- BAD: `<icon> used as icon`
- GOOD: `<icon> in src/components/landing/trio.tsx`
- BAD: `outdated-class-name`
- GOOD: `outdated-class-name in src/**/*.tsx`

A pattern with no scope should be rejected at config-load time, so the path-scoping discipline is structurally required, not merely encouraged.

### Copy verification against rendered HTML

When verifying that a literal string appears on a production page, the naïve `curl | grep -F` approach fails when the string is split across DOM elements (e.g., `Trusted by ... since <strong>2015</strong>`). Choose one of these two approaches instead:

1. **E2E text extraction** (preferred for stable assertions):
   ```js
   const text = await page.textContent('body');
   if (!text.includes('expected literal')) throw new Error('missing');
   ```

2. **Tag-stripped curl** (for shell-based smoke checks):
   ```bash
   curl -sS "$URL" | sed 's/<[^>]*>//g' | tr -s '[:space:]' ' ' \
     | grep -qF "expected literal"
   ```

### Scope-boundary-aware QA thresholds

When a sprint's Scope Boundary explicitly defers a category (e.g., "SEO metadata deferred to polish sprint"), the corresponding QA threshold should be marked `DEFERRED — next sprint` rather than failing the sprint.

Format in `QA-CHECKLIST.md`:

```
- [x] `/` Performance ≥ 90
- [x] `/` A11y ≥ 95
- [x] `/` Best Practices ≥ 95
- [ ] `/` SEO ≥ 90 — **DEFERRED** (see Sprint N scope boundary)
```

A QA-CHECKLIST item that's deferred by an explicit scope boundary is not a failure — it's a known-incomplete tracked for the next sprint.

### VERIFY assertion grep narrowing

When a VERIFY assertion lists `grep -F '<URL>' <file>` (or any similar literal-string-in-file check) expecting nothing, narrow the assertion to the exact line(s) that should not contain the literal — for example `grep -E '^NEXT_PUBLIC_APP_URL=.*<URL>'` or `awk '/<section-marker>/,/<end-marker>/{print}' <file> | grep -F '<URL>'`. Whole-file greps are brittle when the file legitimately mentions the literal in unrelated documentation, comments, or commented-out code.

### Primary-routes e2e spec on new dependencies (planning-time complement in PROJECT-PLANNING.md §1.5)

Any prompt that adds a new dependency to your package manifest (or revives a previously-unused dep) MUST run your project's primary-routes end-to-end spec as part of its VERIFY block before commit. A primary-routes spec exercises every authenticated route per role; if a new dep introduces a missing-provider-wiring or orphaned-hook regression, the spec catches it at the first navigation against the deployed staging URL.

Build plan authors should explicitly enumerate the spec invocation in the VERIFY block of any prompt that touches dependencies — this is the planning-time complement to this runtime rule (see `PROJECT-PLANNING.md` §1.5 E2E coverage check Q4).

### Smoke test discipline — verify content is present BEFORE asserting it

When adding a content-match assertion to a curl-based smoke test, verify the expected literal IS in the curl response BEFORE adding the assertion. Modern web frameworks commonly wrap content in `<Suspense fallback={null}>` boundaries (added defensively for `useSearchParams`, server-component-streaming, etc.). Curl receives only the empty fallback HTML; real browsers see the hydrated content. An assertion targeting hydrated content will silently fail in curl-based smoke tests despite the page rendering correctly for users.

Verification command before staging the assertion:

```bash
curl -sS "$URL" | sed 's/<[^>]*>//g' | tr -s '[:space:]' ' ' | grep -qF "<expected-literal>"
```

If the literal isn't present in the stripped response, EITHER (a) pick a different literal that IS server-rendered, OR (b) upgrade the smoke test to use a headless browser against the staging URL.

---

## 2. Test Requirements Per Sprint

### Minimum test coverage

Every sprint MUST produce at least one test file: `<test-directory>/sprint{N}-qa.<test-extension>` (e.g., `apps/web/src/__tests__/sprint5-qa.test.ts` for Vitest, `tests/sprint5_qa_test.py` for pytest).

This file must include:
- **Schema validation** — if your data schema changed, verify new types exist and old types don't
- **Role helper tests** — if roles changed, verify role helpers return correct values for ALL role types
- **Component existence tests** — verify new/modified components export correctly
- **Route protection tests** — verify new pages have correct role guards
- **Data aggregation tests** — if data-aggregation functions changed, verify they return expected shape

### Test naming convention

```
<test-directory>/sprint{N}-qa.<ext>          # Main QA test file
<test-directory>/sprint{N}-prompt{M}.<ext>   # Optional per-prompt tests for complex prompts
```

### Test must pass before checkpoint

The sprint completion checkpoint should only be written as "pass" AFTER the test command succeeds. If tests fail, checkpoint must be "fail" with the test output as the reason.

---

## 3. Seed Data Requirements

### Test accounts

The seed file MUST include at least one test user for each role in the system. These accounts are used for manual QA verification and dashboard testing.

Pattern (adapt to your role model):

```
admin@<your-domain>           — ADMIN
ops@<your-domain>             — OPERATIONS_USER (or your project's equivalent)
manager@<your-domain>         — MANAGER_ROLE
member@<your-domain>          — MEMBER_ROLE
ai@<your-domain>              — AI_BOT (if applicable)
```

If a sprint adds new roles, it MUST add corresponding seed accounts.

### Production-safe seed gates

Your seed file should NOT create test accounts on production. Common pattern:

```typescript
// Or your language's equivalent guard
if (process.env.NODE_ENV !== 'production' && process.env.SEED_TEST_ACCOUNTS === 'true') {
  // create test accounts here
}
```

This prevents future production migrations from accidentally re-creating test accounts that have been cleaned up for launch.

---

## 4. Migration Safety (when schema changes)

### Before applying migration

1. Back up current database state (or use a database branch / snapshot)
2. Read the generated SQL migration file — verify it does what you expect
3. Check for data loss: does any ALTER or DROP affect existing data?
4. Verify UPDATE statements map old values to new values correctly

### After applying migration

1. Run schema validate / generate types — must succeed
2. Run build — must succeed (verifies type integrity)
3. Query the database to verify data was migrated correctly

### Rollback plan

Every migration prompt must include a rollback SQL block in comments:

```sql
-- ROLLBACK (if migration fails):
-- UPDATE "User" SET role = 'OLD_ROLE_NAME' WHERE role = 'NEW_ROLE_NAME';
-- ... etc.
```

---

## 5. Visual/Behavioral QA (per sprint, not per prompt)

At the END of the sprint (final prompt or completion step), Claude Code must:

### Start the dev server and verify

```bash
<your dev server command> &
sleep 5
```

### Check critical routes respond

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:<port>/login      # Expect 200
curl -s -o /dev/null -w "%{http_code}" http://localhost:<port>/dashboard  # Expect 200 or 302
# Add your project's critical routes
```

### Verify no console errors in page source

Check that server-rendered pages don't contain error boundaries or stack traces.

### Kill dev server

```bash
kill %1
```

---

## 6. Sprint Completion Requirements

Before writing the "pass" checkpoint for sprint completion:

- [ ] All prompts committed with Conventional Commits
- [ ] Build command passes
- [ ] Test command passes — including the new sprint QA test file
- [ ] Zero references to deprecated/old patterns (sprint-specific grep checks)
- [ ] Diff reviewed for each commit — no accidental changes
- [ ] Test seed accounts updated if roles changed
- [ ] RETRO.md written in the sprint folder documenting: what went well, what was tricky, what was deferred
- [ ] CARRYOVER.md written if anything was cut from scope

---

## 7. How Sprint Plans Reference This Document

Every sprint build plan must include this line in its QA section:

```
Follow the QA standards defined in `QA-STANDARDS.md`.
```

And then add sprint-specific QA items on top (golden-path checks, feature-specific edge cases, etc.).

---

## 8. Edge Runtime / Middleware Safety

If your stack uses edge runtimes (Vercel Edge Middleware, Cloudflare Workers, Deno Deploy), some Node.js APIs are NOT available and some heavy dependencies (ORM clients, native modules) cannot be imported.

**Rules:**
- NEVER import ORM clients into edge middleware, directly or indirectly
- NEVER import server-only libraries into code that middleware depends on
- Edge-compatible modules must use plain TypeScript types, not generated types from ORM
- If middleware needs a type that the ORM also defines, duplicate it as a string union with a comment linking back to the source
- Before committing any change that touches middleware or files it imports, verify the full import chain has zero ORM/Node.js dependencies

**Quick check:**

```bash
# Trace middleware imports — none should reach the ORM or Node.js modules
grep -r "from.*<orm-package>\|from.*node:" <middleware-file> <middleware-deps>
```

If your stack doesn't use edge runtimes (pure Node, pure Python, pure Ruby on a normal server), this section doesn't apply — you can delete it.

---

## 9. What Claude Code Must NOT Do

- Do NOT skip the test command because "the build passes"
- Do NOT commit without reviewing the diff
- Do NOT write a "pass" checkpoint if any test fails
- Do NOT delete test files from previous sprints
- Do NOT modify seed data without adding the new accounts
- Do NOT claim "visual QA passed" without actually checking route responses
- Do NOT proceed to the next prompt if the current prompt's build is broken
- Do NOT import server-only code into middleware or edge-compatible modules
- Do NOT skip the sub-agent code review step in VERIFY
