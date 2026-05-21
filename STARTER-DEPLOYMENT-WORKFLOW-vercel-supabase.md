# Deployment Workflow — Vercel + Supabase

> Rename to `DEPLOYMENT-WORKFLOW.md` after running `PLATFORM-SETUP.md`. Delete the Hostinger variant.

This file instructs Claude Code on how to handle releases, uploads, branching, and commits for projects deployed to **Vercel** (frontend hosting + CI/CD) with **Supabase** (Postgres + Auth + Storage). Deployment is automatic on git push. There is NO manual SSH, NO VPS, NO PM2, NO nginx.

Always follow these instructions before executing any release workflow or code upload.

---

## Architecture

| Environment | Git Branch | Vercel Environment | Supabase |
|---|---|---|---|
| **Production** | `main` | Production | Production Supabase project |
| **Staging** | `develop` | Preview (named) | Staging Supabase project |
| **Feature preview** | `feature/*`, `fix/*` | Preview (auto-generated URL) | Staging Supabase |

**How Vercel deployments work:**
- Every push to `main` → deploys to production
- Every push to `develop` → deploys to staging (stable preview URL)
- Every push to a PR branch → deploys a unique preview URL for that PR
- Environment variables are configured per-environment in Vercel's dashboard

**Credentials location:** wherever your project documents secrets (see `PROJECT-PLANNING.md` § "Credentials location").

---

## Load-bearing Vercel invariants — DO NOT change without a retro

The Vercel project should be configured as follows. Changing any of these without understanding why can break production within one deploy:

1. **Root Directory: `<your-app-root>`** (set in Vercel dashboard → Settings → General). For monorepos, point to the app subdirectory (e.g., `apps/web`).
2. **No `vercel.json` at repo root.** Don't add one. The framework preset handles everything.
3. **Framework preset: matches your stack** (auto-detected from `package.json`).
4. **Output Directory: unset (null) in project settings** — Vercel derives the output dir relative to Root Directory.

### Why this combination is load-bearing

Adding a repo-root `vercel.json` with `outputDirectory: "<app>/.next"` while Root Directory is also `<app>` causes Vercel to stack the paths and look for the build output at `<app>/<app>/.next` — not found. Codifying it here prevents the regression.

Any PR that adds a `vercel.json` to this repo should be flagged and reviewed against this section. Consider enforcing via a lint check that fails any commit introducing `vercel.json` at the repo root.

---

## Repo prerequisites — one-time GitHub settings

These settings must be toggled in your GitHub repo:

- [x] **Default branch: `develop`** — feature branches fork from here
- [ ] **Allow auto-merge** — plan-gated for private repos under GitHub Free. Only available on public repos under Free, or with Pro/Team/Enterprise plans. If not available, the compensating control is the hardcoded merge step in §3.6.1.
- [x] **Delete branches automatically: MUST stay OFF (`delete_branch_on_merge=false`)** — the setting auto-deletes the source branch of any merged PR independent of per-PR flags. With it on, every back-merge PR (`main → develop`) deletes `main` because main is the head ref. Per-PR `--delete-branch` in §3.6.1's merge step covers explicit feature/release branch cleanup; the repo-level toggle would force the same behavior on `main` and `develop` where it's not wanted.
- [ ] **Require PR before merging to `main`** — also plan-gated for private repos. Compensating control: PROJECT-PLANNING.md §3.6.1 hardcoded merge step + lint suite enforcing rules branch protection would have caught at commit time.
- [ ] **Require linear history on `main`** — same plan-gating.

---

## CI/CD pipeline

Deployment is handled by **Vercel** with automatic builds on every push. There is no manual SSH step, no Docker container management, no Nginx reload. The GitHub Actions workflows in this repo cover linting, e2e tests, and any nightly canary — they do not deploy.

**On push to `develop`:** Vercel builds your app's root directory and promotes the deployment to the named preview URL once `READY`.

**On push to `main`:** Vercel builds and promotes to the canonical production URL once `READY`.

**On push to a feature/fix/chore PR branch:** Vercel builds and exposes a unique per-PR preview URL (commented on the PR by the Vercel GitHub App).

### CI lint gate via GitHub Actions

`.github/workflows/lint.yml` runs your project's lint on every `pull_request` and `push` to `develop` and `main`. This is the structural complement to the local pre-commit hook: the hook catches violations before they leave the developer's machine, the CI gate catches anything that slipped past.

**Merge rule:** No PR targeting `develop` or `main` may be merged while CI is failing or in progress. The §3.6.1 merge step verifies CI is green via `gh pr checks <pr-number>` before invoking `gh pr merge`.

---

## Self-service tokens

Tokens needed for the deployment workflow:

- `VERCEL_TOKEN` — for Vercel API + CLI calls
- `VERCEL_PROJECT_ID` — your Vercel project identifier
- `VERCEL_TEAM_ID` — your Vercel team identifier (if applicable)
- `SUPABASE_PAT` — Supabase Management API Personal Access Token
- `SUPABASE_PROD_REF` — production Supabase project reference ID
- `SUPABASE_STAGING_REF` — staging Supabase project reference ID
- `SENTRY_DSN` and `SENTRY_AUTH_TOKEN` — for runtime observability (if you ship Sentry)

Resolve via env-first (CI), credentials-file-second (local) pattern. Tokens NEVER echo to stderr or log files. Use `set +x` around any credentials-file parsing.

### Vercel CLI token-flag prohibition

Build plans, runners, and scripts MUST NOT use the `vercel ... --token=$VAR` flag pattern. The flag pattern leaks the token through two channels:

1. CLI argv — visible via `ps -ef` to any process on the same host.
2. CLI's own JSON error output — `action_required` blocks emitted by post-login hooks include argv echoes.

Approved alternatives:

- Authorization header via curl: `curl -sS -H "Authorization: Bearer $VERCEL_TOKEN" https://api.vercel.com/...`
- Env-var-only invocations: `VERCEL_TOKEN=$VERCEL_TOKEN vercel env pull ...`

Apply retroactively across the codebase. Consider enforcing via lint check.

---

## Supabase Redirect URL allow-list

Any new auth-redirect destination — i.e., any new `redirectTo` argument value passed to a Supabase Auth method (`generateLink`, `resetPasswordForEmail`, `signInWithOtp`, `signInWithOAuth`, `inviteUserByEmail`, etc.) — MUST be added to the Supabase project's `uri_allow_list` before traffic hits the new redirect.

The procedure:

1. Update your canonical allow-list documentation (in this file or in a separate `AUTH-REDIRECTS.md`)
2. PATCH BOTH the staging AND production Supabase projects via the Management API:
   ```bash
   curl -sS -X PATCH -H "Authorization: Bearer $SUPABASE_PAT" -H "Content-Type: application/json" \
     "https://api.supabase.com/v1/projects/$SUPABASE_REF/config/auth" \
     -d '{"uri_allow_list": "<comma-separated-list>"}'
   ```
3. Add an end-to-end test asserting the new redirect target actually lands the user on the intended page.

**Why:** Supabase Auth silently falls back to the project's `site_url` when `redirectTo` is not on the allow-list. The failure mode is "signin returns 200 but the user lands on the wrong page." Consider enforcing via a lint check that cross-references every `redirectTo:` literal in source against the live Supabase config.

### Canonical allow-list (project-specific — fill in)

**Staging Supabase project:**
- `<staging-app-url>/dashboard`
- `<staging-app-url>/<other-redirect-target>`
- (development convenience) `http://localhost:<port>/dashboard`

**Production Supabase project:**
- `<prod-app-url>/dashboard`
- `<prod-app-url>/<other-redirect-target>`
- DO NOT include `localhost:<port>` or feature-preview URL patterns in production allow-list

---

## Release process — information gathering

Before ANY deployment, follow the release Q&A. Read this entire section before starting.

### Pre-question code analysis

Before asking any questions, Claude Code must first analyze the code being deployed:

1. **Run `git diff develop...HEAD`** (or `git status`) — identify all files changed, added, deleted
2. **Review project state** — check `package.json` (or equivalent) version, review schema for changes, look at recent commits
3. **Classify features** — mark each as COMPLETE or WIP
4. **Flag risks** — schema migrations, breaking changes, secrets accidentally included
5. **Present findings** to the user in a clear summary before proceeding to questions

### Questions 0-6 (ask in order, wait for answers)

Claude Code must ask these questions sequentially and wait for the user's response to each. Provide intelligent suggestions based on the code analysis.

| # | Question | What Claude Code suggests |
|---|----------|--------------------------|
| 0 | **Is this release for STAGING or PRODUCTION?** | Based on code analysis — suggest staging if features are new/unproven, production if tested and stable |
| 1 | **What type of release is this?** | Alpha, Beta, Feature release, Patch, Hotfix — suggest based on code analysis and staging/production answer |
| 2 | **What is the target version number?** | Suggest specific version based on last release + semver rules + code analysis |
| 3 | **Write a brief summary of what changed** | Draft a summary from the code analysis, ask user to confirm or edit |
| 4 | **List the major features and fixes** | Generate bullet list from code analysis, mark WIP items, ask user to confirm |
| 5 | **Are there any BREAKING CHANGES?** | Flag any breaking changes found during analysis, suggest "No" if none detected |
| 6 | **Should this be merged back to develop?** | Usually "Yes" for releases from release branches; "No" for initial uploads |

### Execution steps (after all questions answered)

**CRITICAL: Follow the correct path based on Question 0. NEVER merge to `main` for a staging release.**

**If Question 0 = STAGING:**

1. Ensure all work is committed and pushed to `develop`
2. Update `package.json` (or equivalent) version to the pre-release version (e.g., `v0.5.0-alpha.1`)
3. Commit: `chore(release): bump version to vX.Y.Z-alpha.N`
4. Push to `develop` — Vercel auto-deploys to staging preview URL once `READY`
5. Create a GitHub Pre-release from the `develop` branch with the pre-release tag
6. Confirm the Vercel deployment reaches `READY` (poll via Vercel dashboard or `vercel inspect <url>`)
7. Print the GitHub Release URL and the staging preview URL

**DO NOT** create a release branch. **DO NOT** create a PR to `main`. **DO NOT** merge anything to `main`. Staging releases never touch production.

**If Question 0 = PRODUCTION:**

The code MUST have been tested on staging first.

1. Checkout `develop`, create `release/vX.Y.Z` branch
2. Update version to the production version
3. Commit: `chore(release): bump version to vX.Y.Z`
4. Create PR from `release/vX.Y.Z` → `main` with changelog body
5. Merge PR with merge commit (no squash) — Vercel auto-deploys to the canonical production URL once `READY`
6. Tag `main` with `vX.Y.Z`, push tag
7. Delete the release branch (local + remote)
8. Create GitHub Release from the tag
9. Back-merge `main` → `develop` (mandatory; see PROJECT-PLANNING.md §3.7)
10. Confirm the Vercel production deployment reaches `READY`
11. Print the GitHub Release URL and the production URL

---

## Post-deployment verification

After Vercel marks the deployment `READY`, Claude Code should verify:

1. **Staging deploy** — confirm staging URL loads, spot-check the new features. Run your project's smoke-test script if available.
2. **Production deploy** — confirm prod URL loads, verify no console errors, spot-check critical flows, run smoke tests + canonical verification scripts.
3. **Database** — if schema changed, confirm migrations applied cleanly (Supabase dashboard or via SQL query through the Management API).
4. **Report** — print a deployment confirmation:

```
═══════════════════════════════════════
DEPLOYMENT COMPLETE
═══════════════════════════════════════
Version: vX.Y.Z
Environment: [Staging / Production]
URL: [URL]
Tag: vX.Y.Z
GitHub Release: [URL]
Pipeline status: ✅ PASSED
═══════════════════════════════════════
```

---

## Rollback

If a deployment causes issues:

1. **Staging** — push a revert commit to `develop`; Vercel auto-deploys the fix.
2. **Production** — preferred path is `vercel rollback` (zero-downtime promotion of a prior `READY` deployment): `VERCEL_TOKEN=$VERCEL_TOKEN vercel rollback <previous-deployment-url>`. Inspect the failed build with `VERCEL_TOKEN=$VERCEL_TOKEN vercel logs <failed-deployment-url>`. As a follow-up, land a `git revert` commit on `main` so the rolled-back state matches the source of truth.
3. **Database** — Supabase migrations don't auto-rollback. If schema rollback is needed, write the inverse migration and apply via SQL Management API. Restore from a Supabase point-in-time snapshot only as a last resort.

---

## Sprint Completion ceremony

After all prompts complete and the final test runs are green, Sprint Completion produces FIVE canonical deliverables:

1. `.claude-code-status/last-response.md` — mid-cutover scratchpad with full evidence trail + final summary
2. `.claude-code-status/sprint-progress.json` — structured handoff with `current_prompt`, `prompts[]` array, `completion_state`, `prod_cutover` block (if cutover ran), `sprint_<N+1>_carryovers[]` array
3. `<N> - <theme>/RETRO.md` — canonical retrospective
4. `<N> - <theme>/CARRYOVER.md` — canonical carryover (only if anything deferred)
5. `C - Bugs/BACKLOG.md` — updated to reflect any newly-filed BUGs (status: open) + any newly-fixed BUGs (moved to Recently-fixed table)

### Direct-DB verification gate for prod-side mutation claims

Any `.claude-code-status/sprint-progress.json` write claiming a prod-side mutation succeeded (canonical example: `prod_cutover.schema_push_applied: true`) MUST be gated on direct-DB verification. Two fields make the gate auditable:

1. **`verified_via`** — names the verification mechanism. Canonical values: `"supabase-management-api-sql-endpoint"`, `"<your-orm>-prod.sh-validate"`, or `"prod-promote.sh-internal-curl-probe"`.
2. **`verification_response`** — the raw query output, captured verbatim (truncated only if response exceeds ~4 KB).

The verification query MUST be a **positive-presence check** that returns expected data, not a "no error" check. Negative-absence checks ("the push command returned no error") are NOT sufficient — silent staging-vs-staging false positives are catastrophically expensive.

If verification fails, the closure ceremony **halts**. Resolve drift before STEP 16 can produce its 5 deliverables.

### Sentry sanity ceremony (if Sentry is wired)

After production cutover, query Sentry API directly for issues matching the just-deployed release SHA. The verification mechanism is `Sentry-API-direct` (not a dashboard ask). The captured evidence block MUST include the `{eventID, release, environment, url}` tuple verbatim from the API response. The strong-verification assertion is `latestEvent.release === <merge-sha>` (exact match against the just-merged main SHA).

This is positive-presence: PASSES when API response contains an issue with matching release tag, FAILS when response is empty or release doesn't match. Negative-absence proxies ("no Sentry alerts in #incidents") are NOT sufficient.

---

## Cross-reference

- `PROJECT-PLANNING.md` Phase 3 — high-level deployment orchestration
- `QA-STANDARDS.md` — per-prompt + per-sprint QA discipline
- `BEFORE-LAUNCH-CHECKLIST.md` — operational items that must close before public launch
- `CLAUDE-CODE-RUNBOOK.md` — production incident triage table
- `_sprint-templates/KICKOFF-PROMPT.md` — Claude Code build-phase kickoff that references this file
