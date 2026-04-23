# PRD: Time Allocation Engine

## Problem

Users manage multiple active projects but consistently overestimate available hours.

Most tools schedule tasks without realistic caps, so low-value work expands and crowds out strategic progress.

## Solution

Introduce **Projects** (buckets) with **weekly hour caps**, and make the system continuously compare:
- **Planned Hours** vs **Actual Hours**

This enables forced tradeoffs and keeps the week honest.

## User story
As a user, I want to cap time per project each week so that low-value work does not consume strategic time.

## User stories (examples)
- As a founder, I want to cap social media at **1 hr/week** so low-value work does not consume strategic time.
- As a PM, I want to allocate **12 hrs/week** to Project A so progress is intentional.
- As a job seeker, I want **10 hrs/week** for applications so career goals are protected.

## Functional requirements
- Create a **project bucket** (name, optional color/token, optional outcome statement).
- Assign a **weekly hour cap** to each project (in hours/minutes).
- Assign tasks to a project (a task may also belong to a lane).
- Log actual time from session logs into the project’s weekly totals.
- Show variance:
  - planned vs actual
  - remaining hours in week
  - over-cap highlighting
- Alerts/flags when over cap (soft nudge; no blocking).
- Paused projects are excluded from cap totals and dashboards.
- Blocked projects remain visible (tradeoffs stay visible), but clearly labeled.

## Nonfunctional requirements
- Local-first: works offline with no account.
- Fast edits: set or change a cap in a single interaction.
- Privacy: project/outcome names are not transmitted off-device by default.

## Acceptance criteria
- A user can set a weekly cap in **< 15 seconds** from the UI.
- Dashboard shows:
  - cap usage per project (e.g. `3.5h / 12h`)
  - remaining hours
  - overages highlighted with a distinct state
- Paused projects are excluded from weekly totals and “over cap” alerts.
- Actual hours reconcile with session logs (no double counting).

## Success metrics
- Weekly planning completion > 60% (users setting/confirming caps weekly).
- Users stay within caps > 50% (or reduce over-cap variance over time).
- Task completion rises week over week (proxy: more sessions on high-value projects).

## Edge cases
- Week boundary:
  - define week start (locale default) and persist it
  - sessions crossing week boundary have deterministic attribution (starter: by session start)
- Cap changes mid-week:
  - variance recalculates; actual time remains unchanged
- Tasks without a project:
  - allowed, but shown under “Unassigned” with no cap
- Multiple devices (future sync):
  - conflicts must be additive and visible

## Dependencies
- Canonical session logging (Ring Timer)
- Project state model (`product/prd-project-states.md`)
- Dashboard aggregation engine
- Data model extension to link `task_item → project_id` (when implemented)
