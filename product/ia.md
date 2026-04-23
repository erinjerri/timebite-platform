# TimeBite Information Architecture

This document defines the iPhone-first information architecture so implementation stays calm, cohesive, and scalable.

## Main Tabs (iPhone)

1. **Today**
2. **Projects**
3. **Dashboard**
4. **Reflection**
5. **Profile**

Rationale:
- **Today** is the execution command center.
- **Projects** makes competing priorities explicit (finite weekly hours).
- **Dashboard** makes tradeoffs visible (planned vs actual).
- **Reflection** closes the loop (learn → reallocate).
- **Profile** is settings, privacy, and account (later).

## Screen map (starter)

### Today
- Lane + project-aware “what now” surface
- Primary actions:
  - plan day (lightweight)
  - start timer
  - switch task/project
  - quick capture (later)

### Projects
- Create/edit project buckets (name, type, state, outcome)
- Set weekly cap (hours/week)
- Assign tasks to projects
- Pause/defer/block/archive projects without deleting tasks

### Dashboard
- Tradeoffs and drift:
  - Weekly Cap Usage (planned vs actual)
  - Over-Invested Projects
  - Neglected Priorities
  - Completion rate + streaks (later)
  - deadlines (later)

### Reflection
- Daily reflection entries
- Weekly review prompts (later)

## Objects and their “home”

Core objects:
- **Project** (`project_bucket`) — owned by **Projects**, summarized on **Dashboard**
- **Task** (`task_item`) — owned by **Today/Projects**, executed from **Today**
- **Session** (`session_log`) — created by timer, summarized on **Dashboard**
- **Weekly Cap** (`project_bucket.weekly_cap_minutes`) — edited in **Projects**, used by **Dashboard**
- **Outcome** (project-level measurable outcome statement; stored on Project)
- **Project State** (Active/Paused/Deferred/Archived/Blocked) — edited in **Projects**, affects visibility and recommendations

Project states:
- Active
- Paused
- Deferred
- Archived
- Blocked

## Primary flows

- Plan day
- Start timer
- Switch project
- Review dashboard
- Reflect
- Reallocate weekly hours

## Later (post-MVP)
- Search
- Calendar view
- Integrations management
- AI assistant “chat” surface (prefer embedded suggestions)
