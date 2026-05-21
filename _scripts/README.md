# `_scripts/` — kit maintenance scripts

This folder contains scripts that maintain the kit itself. Most kit users will never need to touch them — except for `sync-from-upstream.sh`, which is the one-line trigger for "pull the latest kit content from upstream."

## What's here

### `sync-from-upstream.sh`

Pulls the latest cowork-app-starter content from the public GitHub mirror (`github.com/ibrahim-hz/cowork-starter-kit`) and applies template-only files to this kit folder. **Preserves all per-app customizations** — sprint folders, bugs, ADRs, mockups, your renamed VISION/PROJECT-PLANNING files, secrets, etc.

**Usage from Cowork (recommended):** see the "Sync the kit" trigger prompt in the upstream maintainer's docs. Cowork invokes this script in its sandbox after confirming the working directory is this kit folder.

**Usage from a regular shell:**

```bash
# From inside the kit folder:
./_scripts/sync-from-upstream.sh           # interactive: dry-run, then prompt to apply
./_scripts/sync-from-upstream.sh --dry-run # show changes without applying
./_scripts/sync-from-upstream.sh --apply   # apply immediately, no prompt
```

**What it touches:**

ALWAYS overwrites (template content from upstream):

- All `STARTER-*.md` planning standards templates
- `_sprint-templates/`, `_optional-agents/`, `_stack-templates/`
- `.claude/agents/`, `.claude/settings.json`
- `README.md`, `SETUP-KICKOFF.md`, `PLATFORM-SETUP.md`, `TRACKER-SETUP.md`, `VISION-TEMPLATE.md`
- `PLANNING-TRACKER-GUIDE.md`, `PLANNING-TRACKER-TEMPLATE.html`
- `C - Bugs/_template.md`, `C - Bugs/README.md`
- `D - Decisions/_template.md`, `D - Decisions/README.md`
- `STARTER-KIT-BUILD-PLAN.md`
- `.gitignore`

NEVER touches (per-app, app-owned):

- `PROJECT-VISION.md`, `PROJECT-PLANNING.md`, `QA-STANDARDS.md`, `QUICK-FIXES.md`, `CLAUDE-CODE-RUNBOOK.md`, `BEFORE-LAUNCH-CHECKLIST.md`, `SUB-AGENT-METHODOLOGY.md`, `DEPLOYMENT-WORKFLOW.md` (renamed copies of STARTER-*)
- `PLANNING-TRACKER.html` (your local tracker working copy, if any)
- Numbered sprint folders (`1 - *`, `2 - *`, etc.)
- `C - Bugs/open/`, `C - Bugs/fixed/`, `C - Bugs/wont-fix/`, `C - Bugs/BACKLOG.md`
- `D - Decisions/0001-*.md`, `D - Decisions/0002-*.md`, etc. (numbered ADRs)
- `D - Decisions/INDEX.md`
- `mockups/` folders
- `CREDENTIALS.md`, `.env*`, `secrets/` (defense-in-depth)
- `STARTER-KIT-SYNC-LOG.md` (gitignored anyway)

**Safety:**

- The script ONLY operates on this kit folder. It cannot reach outside it.
- The script NEVER pushes anywhere — it's a one-way pull.
- Always dry-runs first; in interactive mode it shows you the diff and waits for `y` before applying.
- The script verifies it's running inside an actual kit folder (sentinel files check) before doing anything.
