<!--
KICKOFF-PROMPT.md template — canonical BUILD-phase sprint-startup prompt.

How Cowork uses this file:
1. Copy this file into the new sprint folder: cp "_sprint-templates/KICKOFF-PROMPT.md" "<N> - <Sprint Name>/KICKOFF-PROMPT.md".
2. Search-and-replace every substitution marker with sprint-specific values:
     <sprint-N>          → integer sprint number (e.g. `3`)
     <sprint-name>       → short theme (e.g. `Auth and Onboarding`)
     <sprint-version>    → release version target (e.g. `v0.3.0-alpha.1`)
     <branch>            → feature branch name (e.g. `feature/sprint-3-auth-onboarding`)
     <prompt-count>      → number of execution prompts in the build plan (e.g. `8`)
     <prompt-1-title>    → Prompt 1 short title from the build plan
     <design-system-ref> → mockup file path OR `not applicable this sprint (no UI surface)`
     <sprint-specific-read-list>   → READ-FIRST list (which DEPLOYMENT-WORKFLOW.md sections, ADR INDEX,
                                     BEFORE-LAUNCH-CHECKLIST.md, prior-sprint CARRYOVER.md, etc.)
     <schema-first-statement>      → "Sprint <N> has zero schema changes — the schema-first rule is
                                     satisfied trivially." OR a sprint-specific schema-change note.
3. Add sprint-specific Manual prerequisites (one-time human setup, secrets that aren't yet provisioned, etc.)
   into the "Manual prerequisites" section if any. If none, leave the "No one-time human prereqs" line.
4. Review the resulting file end-to-end before pasting into Claude Code.

This template implements the canonical PRE-FLIGHT format from STARTER-PROJECT-PLANNING.md §1.8 and the
`proceed` handshake from STARTER-PROJECT-PLANNING.md "Build Plan Execution Style". Both are load-bearing —
do not paraphrase the kickoff prompt block, the PRE-FLIGHT shape, or the handshake footer text.
-->

# Sprint <sprint-N> — Kickoff Prompt

> Paste the block below into Claude Code (one paste, one prompt). Claude Code will read the planning standards + the build plan, output a structured PRE-FLIGHT block, then execute the SETUP step. Wait for Setup's `pass` checkpoint before typing `proceed` to begin Prompt 1.

This sprint uses the **manual `proceed` handshake** from `STARTER-PROJECT-PLANNING.md` "Build Plan Execution Style". After Setup completes, type `proceed` to advance to Prompt 1; review the manual QA table after each prompt; then type `proceed` again to advance. There is no automated sprint runner in this kit — every prompt is a deliberate human-in-the-loop step.

---

## Manual prerequisites

**No one-time human prereqs for Sprint <sprint-N>.** All required tokens / secrets are already provisioned from prior sprints. *(If this sprint introduces a new secret or one-time human setup step, replace this paragraph with that requirement.)*

**Pre-merge placeholder scan.** Before committing the chore PR for a new sprint, scan the build plan + QA-CHECKLIST + KICKOFF-PROMPT for unsubstituted angle-bracket placeholders:

```bash
grep -nE '<[A-Z][A-Z-]+>' "<N> - <theme>/"*.md
```

Any matches that aren't legitimate instructional substitution markers (e.g. `<N>`, `<URL>` in command examples) are doc bugs and must be replaced before the chore PR merges.

**Cold-session resume mechanics:** if Setup or any subsequent prompt fires a session-reset recommendation and the user accepts it via `fresh start`, the next session bootstraps via the canonical `resume sprint <sprint-N>` keyword. The protocol — read the sprint-progress status file, identify next prompt, output a brief PRE-FLIGHT-resume block, wait for `proceed` — is documented in repo-root `CLAUDE.md → Resume sprint protocol`. The literal `resume sprint <N>` phrasing is the trigger; paraphrases are not guaranteed to invoke it.

**Prerequisites auto-handled by Setup:**
- Project secrets file present — preflight verifies.
- Develop branch checked out, clean tree — preflight handles.

---

## Kickoff prompt (paste into Claude Code)

```
Read the project planning standards file at STARTER-PROJECT-PLANNING.md (or its renamed canonical PROJECT-PLANNING.md if the kit was renamed during install), then read the build plan at <N> - <sprint-name>/Sprint-<sprint-N>-Build-Plan.md end to end. Also read STARTER-QA-STANDARDS.md and <sprint-specific-read-list>.

After reading, output a PRE-FLIGHT block in this exact shape (no prose, no preamble, just the block):

PRE-FLIGHT
- READ_FILES: [bullet list every reference file path you actually opened]
- PROMPT_COUNT: <prompt-count>
- SPRINT_BRANCH: <branch>
- SPRINT_VERSION: <sprint-version>
- SCOPE_BOUNDARY_ITEMS: [bulleted list of every item from build plan §7]
- PROMPT_1_TITLE: <prompt-1-title>
- PROMPT_1_FILES_TO_READ: [list every path in Prompt 1's READ FIRST block]
- DESIGN_SYSTEM_REFERENCE: <design-system-ref>
- BLOCKING_QUESTIONS: [or 'none']

After the PRE-FLIGHT block, execute the SETUP step from §6 of the build plan:
- STEP 0 — confirm the project's secret resolution path works (env vars first, project secrets file second). Halt only on first-time / edge-case human conditions.
- STEP 1 — create branch <branch> from develop.
- STEP 2 — baseline build / test / lint / schema-validate all green (run the project's canonical commands).
- STEP 3 — independent verification (confirm `git status --short` shows only allowed drift; confirm `git rev-parse HEAD` matches develop tip).
- STEP 4 — restate the PRE-FLIGHT block above (already emitted; this STEP confirms it is the canonical record).

After SETUP completes successfully, write .claude-code-status/sprint-progress.json with { sprint: <sprint-N>, branch: "<branch>", current_prompt: 0, prompts: [], context_use_pct: <reported>, last_updated: "<ISO>" } and Status: SUCCESS. Wait for user `proceed` before executing Prompt 1.

Token security rules (kit baseline):
- Resolve secrets from env first (CI), then from the project's secrets file (local).
- Tokens NEVER echo to stderr or log files. `set +x` around any secrets-file parsing.
- Never use `--token=$VAR` flag patterns for any CLI. Use Authorization: Bearer headers via curl, OR `TOKEN=$VAR cli ...` env-var-only invocations.
- Destructive prod-side writes (DROP / TRUNCATE / DELETE / migration apply) require an explicit guard flag (e.g., `--i-mean-it`).

Cowork pre-sprint discipline rule: the chore PR for Sprint <sprint-N> contains ONLY the new sprint folder + any sprint-runner table updates. NO lint config edits, NO ADR adds, NO test spec adds, NO doc edits in the chore PR. If the chore PR contained any other edits, flag it as a discrepancy before proceeding.

Schema-first rule: <schema-first-statement>

Build Plan Execution Style: this sprint uses the `proceed` handshake from STARTER-PROJECT-PLANNING.md "Build Plan Execution Style". After each prompt's commit, end the completion report with: `Status: STOPPED for review. Reply 'proceed' to begin Prompt N+1, or paste feedback to revise this commit.` After every 3 prompts OR if context-use crosses 60%, also append: `Status: SESSION RESET RECOMMENDED. Reply 'fresh start' to spin up a new session that resumes from .claude-code-status/sprint-progress.json.` On `fresh start`, the user opens a fresh chat, types `resume sprint <sprint-N>`, and Claude Code reads the JSON to pick up at the next prompt. The reusable footer text source-of-truth lives at _sprint-templates/_proceed-handshake-snippet.md.
```

---

## Per-prompt continuation prompts

After each prompt completes and you've reviewed the manual QA table, type `proceed` to advance — Claude Code reads the next prompt from the build plan automatically. The continuation snippets below are short-form reminders; if you want to override or add steering, paste verbatim instructions instead of `proceed`.

**After Setup:** `proceed`

**After Prompt 1, 2, 3, …:** `proceed`

**At session-reset trigger (every 3 prompts OR context-use ≥ 60%):**

```
fresh start
```

Then in the new session:

```
resume sprint <sprint-N>
```

Claude Code reads `.claude-code-status/sprint-progress.json`, confirms `current_prompt`, and prompts to execute the next prompt.

---

## Notes

- **Network access:** every prompt may talk to your project's third-party APIs (deployment platform, database provider, observability provider). Confirm the relevant CLIs (`gh`, your platform CLI, `jq`, `curl`, etc.) are available before starting.
- **Token security:** all secrets loaded from env (CI) or the project's secrets file (local). Never paste tokens anywhere they could leak.
- **Build Plan Execution Style:** the `proceed` handshake is canonical from Prompt 1 forward (see `STARTER-PROJECT-PLANNING.md` "Build Plan Execution Style"). Session-reset (`fresh start`) trigger fires after every 3 prompts by default; the user can also trigger it on demand if context-use rises sooner than expected.
