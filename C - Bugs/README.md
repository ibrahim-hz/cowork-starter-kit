# Bug Backlog

Where filed bugs live until they're fixed. Three lifecycle states reflected as subfolders:

- `open/` — bugs known but not yet fixed
- `fixed/` — bugs that have been fixed (preserved for retro lookups + audit)
- `wont-fix/` — bugs that are explicitly out of scope (documented for future readers)

The index of all open bugs lives in [`BACKLOG.md`](./BACKLOG.md). One row per open bug, with the bug's sprint-target and severity.

The template for filing a new bug lives in [`_template.md`](./_template.md).

---

## How to file a bug

Use this folder when a bug is discovered but won't be fixed immediately. For one-off fixes you can do right now, use the `STARTER-QUICK-FIXES.md` workflow instead — it's lighter weight.

### Steps to file

1. Copy `_template.md` to `open/BUG-NNN-<short-kebab-summary>.md` where NNN is the next available number (incrementing from the highest existing bug, including fixed/wont-fix folders).
2. Fill in the template:
   - Title (one line, descriptive)
   - Date filed + reporter
   - Severity (Critical / High / Medium / Low)
   - Sprint target (this sprint / next sprint / unscheduled)
   - Reproduction steps
   - Expected vs actual behavior
   - Suspected root cause (if any)
   - Workaround (if any)
3. Add a row to `BACKLOG.md` referencing the new bug file. Sorted by severity then sprint target.
4. Commit the bug file + BACKLOG.md update together.

### When the bug gets fixed

1. Move the bug file from `open/` to `fixed/` (`git mv open/BUG-NNN-X.md fixed/BUG-NNN-X.md`).
2. Append a "Resolution" section to the bug file:
   - Fixed in commit SHA + sprint number
   - One-paragraph description of the fix
   - Cross-reference to the build plan prompt that contained the fix (if applicable)
   - Cross-reference to the relevant retro entry (if the fix surfaced new conventions)
3. Remove the row from `BACKLOG.md`.
4. Commit the move + BACKLOG.md update together.

### When the bug is explicitly won't-fix

1. Move the bug file from `open/` to `wont-fix/`.
2. Append a "Decision" section to the bug file:
   - Date of decision
   - Who decided
   - Rationale (e.g., "out of scope for current product direction", "would require redesigning X which is too costly")
   - Workaround for affected users (if any)
3. Remove the row from `BACKLOG.md`.
4. If the decision is load-bearing, also file an ADR in `D - Decisions/`.

---

## Severity definitions

- **Critical** — production is broken, data loss possible, security exposure. Fix immediately, hotfix sprint if necessary.
- **High** — major feature broken for some users, no workaround, blocks normal usage of a primary workflow.
- **Medium** — feature works but with friction (slow, ugly, confusing), workaround exists, doesn't block normal usage.
- **Low** — minor cosmetic issue, edge case, nice-to-fix-eventually.

Use Critical sparingly — it's a hotfix signal, not "I'm frustrated."

---

## How bugs interact with sprint planning

During sprint planning, Cowork reads `BACKLOG.md` to surface bugs with:
- `sprint-target: <this-sprint>` — bugs explicitly assigned to this sprint
- `sprint-target: next` — bugs queued for next sprint, evaluated as candidates

The Cowork planning kickoff prompt (`_sprint-templates/COWORK-PLANNING-KICKOFF.md`) does this automatically as part of its conflict-surfacing step.

---

## Where bugs DON'T go

- **Discoveries mid-prompt that you'll fix in the same prompt** → just fix them, don't file
- **Quick UI tweaks, copy changes, color adjustments** → use `STARTER-QUICK-FIXES.md` workflow
- **Known-and-accepted limitations** → document in `STARTER-BEFORE-LAUNCH-CHECKLIST.md` or in your project's vision doc, not as a bug
- **Feature requests** → use the planning tracker's Outstanding tab, not the bug backlog

---

## Cross-reference

- [`BACKLOG.md`](./BACKLOG.md) — index of open bugs
- [`_template.md`](./_template.md) — template for new bug files
- [`../STARTER-PROJECT-PLANNING.md`](../STARTER-PROJECT-PLANNING.md) §1.2.1 — Bug backlog conventions (planning-time integration)
- [`../STARTER-QUICK-FIXES.md`](../STARTER-QUICK-FIXES.md) — the Tier-2 workflow for fixes you can do now without filing
