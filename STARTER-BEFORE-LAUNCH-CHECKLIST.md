# Before-Launch Checklist

> Items that must complete before this project is launched to real users. Each sprint may append more. Do NOT remove items — strikethrough when complete and date the strike.
>
> Plain version: a single running list of "things we know we'll have to fix before real users see this." Sprints add to it; nothing gets quietly dropped.

---

## How to use this file

- **Add items proactively.** Anything you defer mid-sprint that has a "must-fix-before-launch" character belongs here. Better to over-record than to discover the gap on launch day.
- **Date the addition.** Each new item should be tagged with the sprint number (or date) that surfaced it, and ideally a `Must-resolve-by:` deadline (e.g., `before public traffic`, `before regulated traffic`, `before $X MRR`).
- **Strike-through, never delete.** When an item is complete, replace the line with `~~original text~~` + `**DONE YYYY-MM-DD**` + a one-line summary of how it was resolved. Retaining the audit trail makes future incident postmortems faster.
- **Reverted items stay.** If a fix lands and is later rolled back, keep the entry but mark `❌ Reverted` with a link to the relevant bug / ADR.

The checklist is read at sprint planning (Phase 1) and at release Q&A (Phase 3 — Question 5 "anything blocking launch"). Reviewers should sanity-check this list before any production deploy that materially expands user exposure.

---

## Sections

The categories below are common starting groupings. Add or remove sections as your project's risk surface grows. **None of the example items below are real for this project** — they are templates showing the shape an entry should take. Replace or delete them as you start filling in your own list.

---

## Security debt

Example items (replace with your own):

- [ ] **Rotate any secrets accidentally committed to git history.** If a sprint discovered a leaked key, the rotation belongs here with a clear `Must-resolve-by:` date. Reference the commit SHA + the file/folder where the key landed. Include the rotation procedure (script path, env vars to update).

- [ ] **Re-create production env vars as the correct secret type for your platform.** Some platforms have multiple "secret" classifications with different operational properties (e.g., readable vs. write-only). If a sprint discovers your secrets are misclassified, the migration belongs here.

- [ ] **Add baseline security response headers.** HSTS, X-Content-Type-Options, X-Frame-Options, Referrer-Policy, Permissions-Policy at minimum. Stage a Content-Security-Policy in report-only mode for 7+ days before enforcing.

---

## Auth configuration

Example items (replace with your own):

- [ ] **Remove dev/preview URLs from production auth allow-list.** Local development and per-branch preview URLs are often added to the auth provider's redirect allow-list for convenience. Before real traffic, strip everything that isn't a canonical production URL. Document the canonical list in your deployment workflow doc.

- [ ] **Disable any test-only sign-in surfaces on production.** Test credential drawers, debug-only API routes, and the env vars that gate them should be off on prod before real users land. Verify both the visible UI gate AND the server route gate are disabled — they're independent layers.

---

## Test infrastructure

Example items (replace with your own):

- [ ] **Delete seeded test accounts from production.** If your seed script created test users on prod for end-to-end QA, they need to be removed before real traffic — and the seed script itself should be gated against `NODE_ENV=production` so future runs can't recreate them.

- [ ] **Rotate any deterministic test passwords.** If your test accounts use a known password for drawer-driven sign-in, that password must be rotated (or the sign-in path removed) before launch.

---

## Observability & incident response

Example items (replace with your own):

- [ ] **Wire production error reporting** (Sentry / Honeybadger / equivalent). Verify a deliberate test error appears in the dashboard before launch.
- [ ] **Wire production uptime monitoring** with an alert path the on-call person reads (PagerDuty, Opsgenie, SMS).
- [ ] **Create the incident runbook.** See `STARTER-CLAUDE-CODE-RUNBOOK.md` for the template.

---

## Compliance & retention

Example items (replace with your own):

- [ ] **Document data retention policy.** Especially for regulated data (financial, health, child-related). If an auditor asks "show me your retention policy," there should be a written answer in `D - Decisions/` and an implementation that enforces it.
- [ ] **Publish privacy policy + terms of service** at canonical URLs. Link them from the sign-up flow.

---

## Cost & rate limiting

Example items (replace with your own):

- [ ] **Configure per-user / per-tenant rate limits** on expensive endpoints (especially anything that calls a paid third-party API).
- [ ] **Configure cost alerts on third-party APIs** (LLM providers, payments, transactional email). Threshold should be low enough to catch a runaway loop within minutes.

---

## Sprint append slot

<!-- Future sprints append items below. Do not remove the marker. -->

---

## Status legend

- `[ ]` Open
- `[x]` ~~Original line~~ — **DONE YYYY-MM-DD** (one-line resolution summary)
- `[x]` ~~Original line~~ — **❌ Reverted YYYY-MM-DD** (link to bug / ADR explaining rollback)

---

## Cross-references

- `STARTER-PROJECT-PLANNING.md` — release Q&A reads this list at Question 5.
- `STARTER-QA-STANDARDS.md` — per-sprint QA gates may surface items that belong here.
- `STARTER-CLAUDE-CODE-RUNBOOK.md` — for incidents that surface launch-blocking items mid-flight.
- `D - Decisions/` — long-lived items often spawn an ADR; cross-link both directions.
