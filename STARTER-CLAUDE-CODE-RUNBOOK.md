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
- `STARTER-QA-STANDARDS.md` — per-prompt VERIFY gates exist partly to keep this list short.
- `STARTER-BEFORE-LAUNCH-CHECKLIST.md` — items here often spawn entries there (e.g., "monitoring missing for incident class X").
- `D - Decisions/` — long-lived runbook decisions (e.g., "we always roll back, never fix-forward, during business hours") deserve an ADR.
