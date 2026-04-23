# Dashboard PRD

## Goal

Help users understand where time went and where goals are drifting.

## Primary widgets
- Today Ring
- Weekly Cap Usage
- Planned vs Actual Hours
- Over-Invested Projects
- Neglected Priorities
- Completion Rate
- Reflection Streak
- Upcoming Deadlines

## User stories
- As a founder, I want to see if job search is underfunded.
- As a PM, I want to see if Project A exceeded its cap.
- As a user, I want clear weekly tradeoffs.

## Functional requirements
- Dashboard loads and renders:
  - Today Ring (session-driven)
  - Weekly Cap Usage (planned vs actual)
  - Over-invested projects (largest overage)
  - Neglected priorities (capped projects with low actual late in week)
  - Completion rate (starter: session count or tasks done; define precisely)
  - Reflection streak (starter: consecutive days with reflection)
  - Upcoming deadlines (starter: tasks with deadlines; optional)
- Visibility:
  - paused projects excluded by default
  - archived projects excluded by default
- Offline:
  - fully functional from local store

#### Weekly cap usage insights (MVP-lite)

These are derived labels to help users make tradeoffs quickly. They must be explainable and reversible (they do not take actions).

- **Over-Invested Projects**
  - definition: projects with the highest absolute overage (actual - cap) or highest overage ratio
  - display: top 1–3 projects with over-cap badge and variance
- **Neglected Priorities**
  - definition: projects with a cap but near-zero actual time late in the week (e.g., < 10% cap by Thu/Fri)
  - display: top 1–3 projects with “neglected” badge
- **Paused Projects**
  - definition: projects in Paused state
  - display: hidden by default; accessible via a “Show paused” toggle or secondary section
- **Recovered Time**
  - definition: time saved from pausing a project or reducing its cap week-over-week (requires history)
  - display: “You recovered ~Xh this week” with a simple explanation (optional until history exists)

## Nonfunctional requirements
- Renders quickly from local store.
- Computations avoid blocking the main thread.

## Acceptance criteria
- Dashboard loads in <2 sec on a recent iPhone (warm).
- Weekly charts visible.
- Over-cap projects highlighted.
- Paused projects excluded by default.
- Empty states handled cleanly.

## Success metrics
- Weekly dashboard opens/user >= 3
- Planning completion improves
- Users stay within caps more often

## Edge cases
- No data yet
- Many projects
- Paused all projects
- Offline mode
- Partial week

## Dependencies
- Session logs
- Project buckets + weekly caps (`product/prd-weekly-caps.md`)


## Analytics (starter)
Events:
- `dashboard_opened`
- `dashboard_resume_timer_tapped`
- `week_view_opened`
