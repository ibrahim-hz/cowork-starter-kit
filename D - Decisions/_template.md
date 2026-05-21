# ADR-NNNN: <one-line descriptive title>

<!--
HOW TO USE:
1. Copy this file to `0NNN-<short-kebab-summary>.md`. Replace NNNN with the next available 4-digit number (check INDEX.md for the highest existing).
2. Replace `<...>` placeholders.
3. Add a row to ../INDEX.md referencing the new ADR file.
4. Commit the ADR with the code change that implements it, when possible.
-->

## Metadata

- **Status:** <Proposed | Accepted | Superseded by ADR-NNNN | Deprecated>
- **Date:** <YYYY-MM-DD>
- **Author:** <name or session description>
- **Sprint:** <which sprint this decision was made in>
- **Topic:** <high-level category — e.g., "Data layer", "Security", "Deployment", "AI / autonomy">

## Context

<2–4 paragraphs describing the situation that prompted this decision. Cover:
- What problem are we trying to solve?
- What constraints exist? (technical, organizational, regulatory, cost, time)
- What forces are pulling the decision in different directions?
- Why is this decision being made now (vs deferred)?
>

## Considered options

### Option 1: <Name>

<Description.>

**Pros:**
- <...>
- <...>

**Cons:**
- <...>
- <...>

### Option 2: <Name>

<Description.>

**Pros:**
- <...>
- <...>

**Cons:**
- <...>
- <...>

### Option 3: <Name> (if applicable)

<...>

---

## Decision

<One-sentence statement of the decision. E.g., "We will use Drizzle ORM rather than Prisma." or "AI bot tools will be classified into three tiers: Autonomous, Pause-and-confirm, Forbidden.">

<1–2 paragraphs explaining WHY this option was chosen over the alternatives. Reference the trade-offs from the "Considered options" section.>

## Consequences

<What changes downstream as a result of this decision. Include both positive and negative consequences. Examples:

**Positive:**
- <Faster compile times>
- <Smaller bundle size>
- <Lower hosting cost>
- <Aligns with team's existing experience>

**Negative / trade-offs:**
- <Loses feature X that the alternative had>
- <Requires writing custom code for Y>
- <Migration cost from previous decision Z>

**Forces follow-ups:**
- <Specific work that this decision requires us to do — these go in the "Follow-ups" section below>>

## Follow-ups

<Concrete action items that this decision requires. Each should land in a specific sprint or be queued in the planning tracker.>

- [ ] <Action item 1 — assigned to Sprint N>
- [ ] <Action item 2 — assigned to Sprint N+1>
- [ ] <Action item 3 — queued in tracker (Outstanding)>

## Related

<Cross-references to related ADRs, bugs, retros, sprint folders, external documentation.>

- ADR-XXXX (related decision on adjacent topic)
- BUG-NNN (incident that motivated this decision)
- Sprint N RETRO.md entry
- External: <link to vendor doc, blog post, paper that informed the decision>

---

<!--
SUPERSESSION:
If a later ADR replaces this one, update the Status field at the top to:
  Superseded by ADR-NNNN
And add a "Superseded by" section here pointing at the replacement.

DO NOT edit the rest of this file. The historical record matters — a future reader
should be able to see what we thought at the time, even if we later changed our minds.
-->
