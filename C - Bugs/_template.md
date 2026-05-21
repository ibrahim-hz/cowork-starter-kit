# BUG-NNN: <one-line descriptive title>

<!--
HOW TO USE:
1. Copy this file to `open/BUG-NNN-<short-kebab-summary>.md`. Replace NNN with the next available bug number (check existing files in open/, fixed/, wont-fix/ — increment from the highest).
2. Replace `<...>` placeholders.
3. Add a row to ../BACKLOG.md referencing the new file.
4. Commit both files together.
-->

## Metadata

- **Severity:** <Critical | High | Medium | Low>
- **Filed:** <YYYY-MM-DD>
- **Reporter:** <name or session description>
- **Sprint target:** <this | next | unscheduled>
- **Component / surface:** <which part of the app — e.g., "login flow", "admin dashboard role-gate", "data import worker">
- **Affected versions:** <if known — e.g., "v0.5.0 onward", "since Sprint 3 P2 deploy">

## Description

<2–4 sentence summary of what's broken and the user-visible impact.>

## Reproduction steps

1. <Step 1>
2. <Step 2>
3. <Step 3>

## Expected behavior

<What should happen.>

## Actual behavior

<What actually happens. Include screenshots / log excerpts / error messages if available.>

## Suspected root cause

<If you have a hypothesis, document it. If not, "unknown — needs investigation" is fine.>

## Workaround (if any)

<Any temporary mitigation users can apply. If none, say so.>

## Related

<Cross-references to related bugs, ADRs, retro entries, or prior commits. E.g., "may be related to BUG-XXX", "could be addressed by ADR-YYYY's mitigation Z".>

---

## Resolution

<!--
Fill in this section when the bug is fixed and the file moves from open/ to fixed/.
Leave the section header but the content blank if the bug is still open.
-->

- **Fixed in:** <Sprint N, Prompt P, commit SHA>
- **Fix date:** <YYYY-MM-DD>
- **Description:**
  <One paragraph describing what changed to fix the bug.>
- **Verification:**
  <How the fix was verified — test added, manual QA confirmed, etc.>
- **Cross-references:**
  - Sprint <N> RETRO.md entry (if surfaced new conventions)
  - Sprint <N> Build Plan Prompt <P> (if the fix landed mid-prompt)
  - ADR-NNNN (if the fix triggered an architectural decision)

---

## Decision (only for wont-fix files)

<!--
Fill in this section only when the bug moves from open/ to wont-fix/.
Delete this entire section if the bug gets fixed instead.
-->

- **Decided:** <YYYY-MM-DD>
- **Decided by:** <name>
- **Rationale:**
  <Why this bug won't be fixed. Examples: "Out of scope for current product direction", "Would require redesigning X which is too costly", "Affects <0.1% of users and workaround exists".>
- **Workaround for affected users:**
  <If applicable, document what users can do to mitigate. If nothing, say so.>
- **Reconsideration triggers:**
  <If anything would change the decision, document it. E.g., "Reconsider if affected user count crosses 5% or if X major feature ships."
