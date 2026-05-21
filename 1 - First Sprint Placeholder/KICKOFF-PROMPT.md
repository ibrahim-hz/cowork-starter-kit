<!--
PLACEHOLDER FILE — this is the canonical empty-sprint kickoff-prompt shape.

This file is what Cowork generates at the end of Sprint 1 planning by copying
`_sprint-templates/KICKOFF-PROMPT.md` and filling in the substitution markers.

Below is what the filled-in version will look like once Sprint 1 planning runs.
Replace this entire file with the real kickoff prompt Cowork produces at the
end of planning (or run Cowork's planning conversation per `STARTER-PROJECT-PLANNING.md`
Phase 1 to generate it).

The placeholders (<sprint-N>, <sprint-name>, etc.) are intentional — they show
the substitution markers Cowork will replace.
-->

# Sprint 1 — Kickoff Prompt

> Paste the block below into Claude Code (one paste, one prompt). Claude Code will read the planning standards + the build plan, output a structured PRE-FLIGHT block, then execute the SETUP step. Wait for Setup's `pass` checkpoint before typing `proceed` to begin Prompt 1.

This sprint uses the **manual `proceed` handshake** from `STARTER-PROJECT-PLANNING.md` "Build Plan Execution Style". After Setup completes, type `proceed` to advance to Prompt 1; review the manual QA table after each prompt; then type `proceed` again to advance.

---

## Manual prerequisites

**This is the very first sprint.** Before pasting the kickoff prompt, complete the one-time setup checklist:

- [ ] `PLATFORM-SETUP.md` walked end-to-end; one `STARTER-DEPLOYMENT-WORKFLOW-*.md` renamed to `DEPLOYMENT-WORKFLOW.md`; the other deleted.
- [ ] `TRACKER-SETUP.md` walked end-to-end; JSONbin bin created; `PLANNING-TRACKER-TEMPLATE.html` populated with Bin ID + Access Key.
- [ ] `VISION-TEMPLATE.md` renamed to `<PROJECT>-VISION.md` (or similar) and filled in.
- [ ] Project's secrets file created (e.g., `CREDENTIALS.md`) and excluded from git via `.gitignore`.
- [ ] Project's git repo initialized; `develop` branch exists; `main` is the production branch.

Once those one-time items are done, future sprints' "Manual prerequisites" sections drop to "none" — only Sprint 1 carries this checklist.

---

## Kickoff prompt (paste into Claude Code)

```
Read the project planning standards file at STARTER-PROJECT-PLANNING.md (or its renamed canonical PROJECT-PLANNING.md if the kit was renamed during install), then read the build plan at 1 - <sprint-name>/Sprint-1-Build-Plan.md end to end. Also read STARTER-QA-STANDARDS.md and <sprint-specific-read-list>.

After reading, output a PRE-FLIGHT block in this exact shape (no prose, no preamble, just the block):

PRE-FLIGHT
- READ_FILES: [bullet list every reference file path you actually opened]
- PROMPT_COUNT: <prompt-count>
- SPRINT_BRANCH: feature/sprint-1-<short-name>
- SPRINT_VERSION: v0.1.0-alpha.1
- SCOPE_BOUNDARY_ITEMS: [bulleted list of every item from build plan §7]
- PROMPT_1_TITLE: <prompt-1-title>
- PROMPT_1_FILES_TO_READ: [list every path in Prompt 1's READ FIRST block]
- DESIGN_SYSTEM_REFERENCE: <design-system-ref>
- BLOCKING_QUESTIONS: [or 'none']

After the PRE-FLIGHT block, execute the SETUP step from §6 of the build plan:
- STEP 0 — confirm the project's secret resolution path works.
- STEP 1 — create branch feature/sprint-1-<short-name> from develop.
- STEP 2 — baseline build / test / lint / schema-validate all green.
- STEP 3 — independent verification.
- STEP 4 — restate the PRE-FLIGHT block.

After SETUP completes successfully, write .claude-code-status/sprint-progress.json with { sprint: 1, branch: "feature/sprint-1-<short-name>", current_prompt: 0, prompts: [], context_use_pct: <reported>, last_updated: "<ISO>" } and Status: SUCCESS. Wait for user `proceed` before executing Prompt 1.

Token security rules (kit baseline):
- Resolve secrets from env first, then from the project's secrets file.
- Tokens NEVER echo to stderr or log files.
- Never use `--token=$VAR` flag patterns for any CLI.
- Destructive prod-side writes require an explicit guard flag.

Cowork pre-sprint discipline rule: the chore PR for Sprint 1 contains ONLY the new sprint folder. NO lint config edits, NO ADR adds, NO test spec adds, NO doc edits in the chore PR.

Schema-first rule: <schema-first-statement — e.g., "Sprint 1 introduces the initial schema in Prompt 1, ending with the schema generated + validated before any application code.">

Build Plan Execution Style: this sprint uses the `proceed` handshake from STARTER-PROJECT-PLANNING.md "Build Plan Execution Style". After each prompt's commit, end the completion report with: `Status: STOPPED for review. Reply 'proceed' to begin Prompt N+1, or paste feedback to revise this commit.` After every 3 prompts OR if context-use crosses 60%, also append: `Status: SESSION RESET RECOMMENDED. Reply 'fresh start' to spin up a new session that resumes from .claude-code-status/sprint-progress.json.` The reusable footer text source-of-truth lives at _sprint-templates/_proceed-handshake-snippet.md.
```

---

## Per-prompt continuation prompts

**After Setup:** `proceed`

**After Prompt 1, 2, 3, …:** `proceed`

**At session-reset trigger:**

```
fresh start
```

Then in the new session:

```
resume sprint 1
```
