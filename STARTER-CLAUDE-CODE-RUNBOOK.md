# Claude Code Runbook — Production Incidents

> Symptom → Diagnose → Fix → Verify table for the most common production incidents on this project. Add a new row when an incident class first appears in production, after running the response through it the first time.
>
> Plain version: a list of "thing breaks → here's the recipe to fix it." Each row is added the first time you hit a class of incident, so the second time it happens it's a 5-minute fix instead of a 90-minute investigation.

---

## How to use this file

- **One row per incident class, not per incident.** If 12 deployments fail because of build errors, that's still one row ("Deploy stuck or failed") with `Fix` covering the common rollback procedure.
- **Add a new row the first time** an incident type appears in production. The marginal cost is low (~10 min while the incident is fresh) and the savings on the next occurrence are large.
- **Every row has 5 cells:**
  - `Symptom` — what the operator notices first (alert text, user report, dashboard signal).
  - `Diagnose` — the exact command(s) to confirm the diagnosis and rule out look-alikes.
  - `Fix` — the exact command(s) to fix it, including any guard flags.
  - `Verify` — how you know the fix worked (specific signal, not "looks fine").
  - `Origin` — what sprint / postmortem / ADR introduced the row, for future archaeology.

---

## Token / credential security preamble

All commands in this runbook assume any required tokens or secrets have been loaded into the invoking shell via your project's secret-resolution path (env var first, project secrets file second). Do not hardcode tokens in command lines, commit messages, or chat output.

**Never paste tokens into command lines, commits, comments, or chat output.** If you find a token in any log or transcript, treat it as leaked: rotate immediately via your provider's rotation procedure, update the project's secrets file with the new value, and re-sync any CI / deployment env stores.

---

## Kit boundary — Claude Code never publishes to the kit repo

The kit at `reference/cowork-app-starter/` (or wherever your project copies the cowork-app-starter kit) mirrors to a separate GitHub repo under the kit-maintainer's GitHub account, distinct from your project's GitHub account + credentials. Maintenance of that mirror is **entirely outside Claude Code's scope**. Claude Code's scope is YOUR project's app code during sprint execution — nothing more.

**Hard rules for Claude Code with respect to the kit:**

1. **Do not modify any file under `reference/cowork-app-starter/`** (or wherever you've copied the kit). Treat that folder as read-only. If you need to reference a kit standard or template during a sprint, READ it for context; never edit it. Kit edits happen ONLY during Cowork's STEP 4.5, with the human in the loop, with an audit trail in `STARTER-KIT-SYNC-LOG.md`.
2. **Do not add `<EXAMPLE: github.com/your-kit-org/cowork-starter-kit>` (or any URL under the kit-maintainer's GitHub account) as a git remote to your project's repo.** That remote belongs to a different GitHub account; mixing it into your project's git config creates a direct path for your project's code to leak into the public kit.
3. **Do not run `git push` against any URL containing the kit-maintainer's GitHub account name.** The only sanctioned path for content to reach the kit repo is `reference/scripts/publish-kit-to-github.sh` (or your project's renamed equivalent), and that script is invoked exclusively by Cowork during STEP 4.5. Claude Code does not invoke it.
4. **Do not copy `reference/cowork-app-starter/` content out of the kit and into your project's app code paths without checking with the human first.** Kit content is generic by design; your project's app code is project-specific. Mixing them without conscious intent erodes both.
5. **If a sprint asks you to "update the kit" or "push to the kit," STOP** — UNLESS the sprint is an explicit Kit Sprint with the exception path declared (see "Exception path" below). Otherwise that's a kit-sync action, which is a Cowork concern. Reply that the request is out of scope for Claude Code and direct it to be handled in a Cowork planning session.

**Exception path: Kit Sprints with explicit `🔓 KIT-BOUNDARY EXCEPTION` declaration.** Rule 1 above (the read-only-by-default rule on `reference/cowork-app-starter/`) has a narrow exception for Kit Sprints. A Kit Sprint is a build plan that modifies the kit itself as deliberate scope, not as an incidental side effect — see `STARTER-PROJECT-PLANNING.md §1.5.3` (or the downstream-project equivalent) if your project has adopted the Kit Sprint workflow. When ALL of these conditions hold, Rule 1 is overridden for that specific prompt only:

- The active sprint's build plan opens with a `🔓 KIT-BOUNDARY EXCEPTION` declaration at the top.
- The declaration enumerates which prompts within the sprint may modify kit files.
- The prompt Claude Code is currently executing appears in that enumerated list.

Sample declaration shape Claude Code recognizes verbatim:

> **🔓 KIT-BOUNDARY EXCEPTION (one-time, scoped to this sprint)**
>
> This sprint's prompts **P1, P2, P3** may modify files under `reference/cowork-app-starter/`.
> This exception is explicitly granted by the planning conversation that produced this build plan.
> After this sprint ships, the standard kit-boundary rule resumes — Claude Code is read-only on
> `reference/cowork-app-starter/` unless a future Kit Sprint's build plan grants another explicit exception.
>
> **What's NOT covered by the exception:**
> - Pushing to `<EXAMPLE: github.com/your-kit-org/cowork-starter-kit>` directly. The publish path remains
>   `reference/scripts/publish-kit-to-github.sh` (invoked as the final prompt of the sprint).
> - Adding kit-maintainer URLs as a git remote to your project. Still forbidden.

**The exception NEVER covers Rules 2, 3, or 4 above.** Rule 2 (no kit-maintainer remote on your project), Rule 3 (no `git push` to any kit-maintainer URL), and Rule 4 (no kit-content copy into your project's app code without human check) still hold throughout a Kit Sprint. The publish path stays through `reference/scripts/publish-kit-to-github.sh` — Kit Sprints invoke it as their last prompt (Claude Code reads-and-runs the script; it does NOT execute `git push` directly). If a build plan declares the exception but the current prompt is NOT enumerated in the declaration, Rule 1 still holds for that prompt. If no declaration exists in the build plan, Rule 1 holds for the entire sprint regardless of how the sprint is named.

In plain language: there are two GitHub accounts (your project's, and the kit-maintainer's). Claude Code only ever touches your project's. The kit publish path is locked behind a script that only Cowork's planning sessions — and Kit Sprints' final prompt — invoke. Even if you (the human) typo something into a Claude Code session asking it to "push the kit," Claude Code refuses and routes the request to the right place; the only exception is a Kit Sprint's enumerated prompt under the explicit declaration above.

**Cross-references:**
- `STARTER-PROJECT-PLANNING.md` §1.5.2 — Build plan card lifecycle (Engage app sprints vs Kit-fork sprint scope)
- `STARTER-PROJECT-PLANNING.md §1.5.3` — Kit Sprint workflow + when the exception path above applies (in projects that have adopted Kit Sprints)
- `_sprint-templates/COWORK-PLANNING-KICKOFF.md` § STEP 4.5 — the publish flow this rule walls off
- `_sprint-templates/COWORK-PLANNING-KICKOFF.md` § STEP 5B — Kit-fork sprint planning end (SKIP planner; append to `STARTER-KIT-SYNC-LOG.md` instead)
- `reference/scripts/publish-kit-to-github.sh` — the only sanctioned push path

---

## Symptom: <EXAMPLE — replace with your first real incident class>

| Cell | Command |
|---|---|
| Diagnose | `<command-to-confirm>` returns `<observable signal>`. Cross-check via `<secondary command>` to rule out `<look-alike incident class>`. |
| Fix | `<command(s) to fix>`. Include any required `--i-mean-it` / `--force` / guard flags so the row is copy-paste-safe. |
| Verify | `<command-to-verify-fix>` returns `<expected post-fix signal>`. Optionally: re-run the diagnose command and confirm the failing signal is now green. |
| Origin | <Sprint N retro / postmortem / ADR-NNNN / standard ops codification>. |

---

## Adding new rows

When you ship the response to a new incident class:

1. Append a new section below the last existing one, with the same 5-cell shape.
2. Use the exact command line you ran (not an idealized version) — runbooks rot when the recorded command isn't the one that actually works.
3. Include guard flags / dry-run flags where they exist.
4. Cross-reference any ADR or sprint retro that captured the underlying decision.
5. If the incident also surfaced a `STARTER-BEFORE-LAUNCH-CHECKLIST.md` item or a Tier-2 fix, link both directions.

---

## Cross-references

- `STARTER-PROJECT-PLANNING.md` — read this runbook before paging anyone for a prod incident.
- `STARTER-PROJECT-PLANNING.md §1.5.2` — Build plan card lifecycle (planner stage flow that drives the Sprint Completion ritual which feeds incident learnings back here).
- `STARTER-QA-STANDARDS.md` — per-prompt VERIFY gates exist partly to keep this list short.
- `STARTER-BEFORE-LAUNCH-CHECKLIST.md` — items here often spawn entries there (e.g., "monitoring missing for incident class X").
- `D - Decisions/` — long-lived runbook decisions (e.g., "we always roll back, never fix-forward, during business hours") deserve an ADR.
- See "Kit boundary" section above — Claude Code never publishes to the kit repo (Cowork's STEP 4.5 is the only path; Kit Sprints' final prompt invoke the publish script as their audit ritual).
