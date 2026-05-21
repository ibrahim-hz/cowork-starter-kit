# `proceed` handshake snippet — completion-report footer

Source-of-truth text for the canonical completion-report footer that every prompt in every sprint emits. Build plans can reference this snippet via a one-line link in their Sprint Completion section; the snippet itself is reproduced verbatim in Claude Code's actual completion reports per the runtime instructions in `STARTER-PROJECT-PLANNING.md` "Build Plan Execution Style: `proceed` handshake, one prompt at a time".

The leading underscore in this filename is intentional — it sorts above the other templates in directory listings and signals "this is a reusable fragment, not a per-sprint deliverable".

## Canonical text

```
---
Status: STOPPED for review.
- Reply `proceed` to begin Prompt N+1.
- Or paste feedback to revise this commit.
- Context-use is approximately X%. <If X >= 60 OR every-3-prompts trigger fires: append: "Status: SESSION RESET RECOMMENDED. Reply 'fresh start' to spin up a new session that resumes from .claude-code-status/sprint-progress.json.">
```

## Substitution markers

| Marker | What to substitute |
|---|---|
| `N+1` | The integer prompt number the next paste will execute. After Prompt 7's commit, this is `8`. After Setup, this is `1`. |
| `X` | Claude Code's self-reported context-use percentage at the moment of writing. Best-effort — the runtime exposes this where it can; otherwise estimate. |

## When the SESSION RESET line fires

Append the second line **only if either**:

- The completed prompt's number is a multiple of 3 (3, 6, 9, …) — the every-3-prompts trigger.
- `X >= 60` — the context-bloat threshold.

Otherwise omit the second line entirely.

## How the user picks up after a reset

The user types `fresh start` in the current chat (Claude Code confirms no work in flight), opens a new chat, then types `resume sprint <N>`. The new session reads `.claude-code-status/sprint-progress.json`, confirms `current_prompt`, and prompts to execute the next one.

## Drift-resistance

Don't reword this footer in build plans or per-prompt instructions. The runtime grep (and Cowork's parsers) key off the literal phrases `proceed`, `fresh start`, and `resume sprint`. Paraphrasing breaks downstream tooling — if a reword feels necessary, update **this file** so every consumer picks it up uniformly.
