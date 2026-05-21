# Stack-Template Agents

> Starter reviewers for stacks other than Next.js App Router. Copy the matching template into `.claude/agents/`, then tune the system prompt to your project's actual patterns over the first 1–2 sprints.
>
> Plain version: these are "first draft" reviewers — they catch common bugs in their stack, but they're not battle-tested against your specific codebase yet. The first sprint's RETRO is where you sharpen them.

---

## When to use this folder

The 3 default agents in `.claude/agents/` (`code-reviewer`, `test-runner`, `docs-researcher`) are stack-agnostic and ship by default. If your project is Next.js App Router, the `_optional-agents/` folder has tuned reviewers ready to copy in.

For everything else — Vue, Nuxt, Django, Rails, plain React + Vite, Express / Node, generic Python — this folder has a starting point. Each template:

- Lists the most common bug classes in that stack
- Is structured the same way as the defaults (front-matter, "what to check", "what to output", "what NOT to do", "how to start")
- Has a `<EXAMPLE: …>` placeholder section for project-specific patterns
- Should be tuned within 1–2 sprints based on retro evidence

---

## Which template fits your stack

| Template | When to use |
|---|---|
| `vue-nuxt-reviewer.md` | Vue 3 + Pinia, with or without Nuxt 3 |
| `django-reviewer.md` | Django (with or without DRF) |
| `rails-reviewer.md` | Ruby on Rails |
| `react-vite-reviewer.md` | React + Vite as an SPA (no Next.js, no Remix) |
| `express-node-reviewer.md` | Express, Fastify, Koa, or any Node.js HTTP framework |
| `generic-python-reviewer.md` | Python that doesn't fit Django — FastAPI, Flask, pure scripts, data pipelines |

For stacks not listed here (Phoenix / Elixir, Spring Boot / Java, .NET, Go web frameworks, etc.), copy the closest match and rewrite the "What to check" section. The structural shell of the file is the reusable part.

---

## How to install one

```bash
# Copy the matching template into the project's active agent roster
cp _stack-templates/<template-name>.md .claude/agents/

# Optional: rename to match your project's convention
# (e.g., from "django-reviewer.md" to "<project>-code-reviewer.md" if you only
# have one reviewer and want the name to match the project)
mv .claude/agents/<template-name>.md .claude/agents/<chosen-name>.md

# Edit the file:
#   - Update the front-matter `name:` to match the filename
#   - Update the header comment with today's date
#   - Replace the <EXAMPLE: …> placeholders with project-specific anti-patterns
#     as you learn them from retros

# Commit in a chore PR
git add .claude/agents/<chosen-name>.md
git commit -m "chore: add <chosen-name> sub-agent — stack-specific reviewer"
```

After install, the reviewer runs on every prompt's VERIFY block. Update `STARTER-SUB-AGENT-METHODOLOGY.md`'s "Roster history" table to record the addition.

---

## Tuning after the first sprint

Stack templates are starting points. Your first sprint will surface failure classes the template either over-flags or misses entirely. After each RETRO:

1. **If the template over-flags** (catches too many false positives) — narrow the rules. Add specifics about what NOT to flag in the "What NOT to do" section.
2. **If the template misses real bugs** — add a new check to "What to check on every diff" with a concrete pattern and a grep / AST query that catches it.
3. **If your stack uses libraries the template doesn't know about** — extend the "Common framework / library gotchas" section.

By sprint 3, the template should feel like it was written for your codebase specifically. If it still feels generic, the template is being ignored — consider whether you actually need a stack reviewer at all, or whether the default `code-reviewer` is doing enough.

---

## Coexisting with the default `code-reviewer`

The default `code-reviewer` and a stack template overlap on general code quality (N+1, debug code, missing error handling). That's fine — running both is belt-and-suspenders. But once a stack template is tuned to your project, you have three options:

1. **Keep both running every prompt.** Simple. Some duplicate findings.
2. **Trim general-quality checks from the stack template**, leaving only stack-specific patterns. The default `code-reviewer` handles the general stuff; the stack template handles the framework-specific stuff.
3. **Replace the default `code-reviewer` with the tuned stack template entirely.** Only do this once the stack template has earned its keep — the default reviewer's S1–S15 security checklist is hard to recreate from scratch.

The 5-sprint review (`STARTER-SUB-AGENT-METHODOLOGY.md`) is the natural moment to decide.

---

## Cross-references

- `STARTER-SUB-AGENT-METHODOLOGY.md` → "Stack-template agents (6)" — full catalog with rationale per template
- `.claude/agents/` — where installed templates live
- `_optional-agents/` — upstream-derived specialist reviewers (Next.js stack + cross-stack security / resilience / step-ordering)
