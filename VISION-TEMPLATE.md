# <APP NAME> — Product Vision

<!--
HOW TO USE THIS TEMPLATE:

1. Rename this file to your project's vision document. Common choices:
   - `PROJECT-VISION.md`
   - `<APP-NAME>-VISION.md`
   - `VISION.md`
2. Fill in each section. Sections with `<...>` placeholders are required;
   feel free to add or remove sections to match your app.
3. Keep this file in the same folder as the rest of the kit's planning docs.
4. Cross-reference this file from your `STARTER-PROJECT-PLANNING.md` (which you'll
   probably rename to just `PROJECT-PLANNING.md` after install).
5. Update §3.0 "Current State" each sprint — that section is a refreshed snapshot
   of what's actually shipped, in contrast to §3.1–§3.4 which are the stable vision.
6. Delete this comment block once you've populated the document.
-->

> **Status:** Product vision document. For current architecture, see `PROJECT-PLANNING.md` and `DEPLOYMENT-WORKFLOW.md`. This file is the long-horizon vision; operational reality is the other docs.

---

## 1. Executive Summary

<2–4 paragraphs describing:
- What this app is
- Who it's for (primary user types)
- What problem it solves or what existing workflow it replaces
- How it's delivered (web, mobile, both?)
- The platform's primary value proposition>

---

## 2. User Types & Access Model

### 2.1 <Primary user type>

<Description. What they do, how they interact with the app, what they can see and modify.>

### 2.2 <Secondary user type>

<Description.>

### 2.3 <Additional user types as needed>

<...>

### 2.x Administrators

<Full platform access. What they can manage, configure, oversee.>

### 2.y AI Bot / System actors (if applicable)

<If your app integrates AI agents, automation, or system-level actors, describe their identity, scope, and audit posture here.>

---

## 3. Platform & Technical Foundation

### 3.0 Current State as of Sprint <N>

<Update this section each sprint. Snapshot of what's actually shipped in production. Includes:
- Infrastructure (hosting, database, auth, CI/CD, observability)
- Tech stack versions
- Application surface area (public routes, authenticated routes, key features)
- Active risks tracked in BEFORE-LAUNCH-CHECKLIST.md

The rest of section 3 below is the stable vision; this subsection is the running tally.>

**Infrastructure (shipped):**
- Hosting: <...>
- Database: <...>
- Auth: <...>
- Observability: <...>
- CI/CD: <...>

**Tech stack versions:**
- <Framework + version>
- <Language + version>
- <ORM + version>
- <UI library + version>
- <...>

**Application surface area (shipped):**
- Public routes: <...>
- Authenticated routes: <...>
- Background jobs / workers: <...>

**Active risks (tracked in BEFORE-LAUNCH-CHECKLIST.md):**
- <...>

### 3.1 Tech Stack

<High-level description of the chosen tech stack and why. This is the "what we're building on" section, distinct from §3.0 which is the version-pinned current state.>

### 3.2 Authentication & Roles

<Auth mechanism (Supabase Auth / NextAuth / Clerk / custom JWT / etc.). Role model — list the roles and what each can see/do.>

### 3.3 Applications

<Web? Mobile? Both? Phased rollout? Real-time features? Push notifications?>

### 3.4 Key Technical Considerations

<Architectural concerns that shape the build:
- Real-time updates
- Push notifications
- Audit logging
- File storage
- Secure credential storage
- Background processing / queues
- AI action queue (if applicable)
- Multi-tenant data isolation
- Anything else load-bearing>

---

## 4. <Major Feature Area 1>

<For each major feature area of your app, describe:
- What it does
- Who uses it
- Key sub-features
- How it integrates with the rest of the platform

Common feature areas include:
- Onboarding & profile
- Core domain workflow (pipeline, board, queue, etc.)
- AI integration / automation
- Content / marketing
- Mobile app
- Reporting / analytics
- Settings & administration
- Integrations with third-party services>

---

## 5. <Major Feature Area 2>

<...>

---

## 6. <Add more sections as needed>

<Add sections for each major capability your app provides. Common patterns from production apps include:
- Operational pipeline / stages
- Kanban / board views
- Workflow automation
- Document processing & generation
- Tasks, deadlines, appointments
- Notifications & activity feed
- Global search
- Customer / counterparty portals
- Dashboards (role-specific)
- Content / marketing pipeline
- Mobile strategy (phased rollout)
- Settings & administration

Your app will have its own shape. Use as many sections as you need.>

---

## X. Build Strategy

<Optional section. If your app reuses code from another project (yours or an upstream open-source project), document what's reused vs newly built.

If everything is greenfield, you can skip this section or replace it with a "Phased build sequence" overview.>

---

## Y. What's Not Included

<Explicit out-of-scope items. Useful for setting boundaries with stakeholders and avoiding scope creep.

Examples:
- Features from prior product briefs that are explicitly deferred
- Integrations that aren't planned
- User types that aren't supported
- Capabilities that other tools cover better>

---

## Z. Next Steps

<Optional roadmap section. Lists the next-most-relevant sprints in rough sequence. Update each sprint to reflect current priorities.

This is intentionally rough — each "next sprint" gets a full build plan in its own `<N> - <Sprint Theme>/` folder before execution per `PROJECT-PLANNING.md`.>

**Sprint <N> — <Theme> (in progress).** <Brief description of scope.>

**Sprint <N+1> — <Theme> (next).** <Brief description.>

**Pre-launch sprints (uncommitted to specific numbering yet):**
- <Major item>
- <Major item>
- <Major item>

---

<!--
LIVING DOCUMENT — UPDATE EACH SPRINT:
- §3.0 Current State: refresh with shipped infrastructure + tech stack + surface area
- §Y What's Not Included: add new out-of-scope items as they surface in planning
- §Z Next Steps: re-prioritize as roadmap evolves

DELETE-AFTER-SETUP CHECKLIST:
- [ ] All `<...>` placeholders filled in
- [ ] HOW TO USE comment block at top of file deleted
- [ ] File renamed to your project's vision doc name (e.g., PROJECT-VISION.md)
- [ ] Cross-reference added in PROJECT-PLANNING.md "How to use this document" section
-->
