# PRD — Weekly Caps

## Summary

Weekly Caps make TimeBite’s core principle real: **finite weekly hours** and **visible tradeoffs** across multiple concurrent projects.

Weekly caps are the user’s “planned” allocation for a project. Session logs provide “actual” usage. The dashboard compares planned vs actual and highlights drift.

## User story
As a user, I want to set weekly hour caps per project so I can make tradeoffs explicit and prevent low-value work from consuming the week.

## Functional requirements
- Set a weekly cap on a project:
  - input in hours/week (store as minutes)
  - fast edit (single interaction)
- Weekly cap usage view (current week):
  - planned(cap) vs actual hours
  - remaining hours
  - over-cap warning state
- Visibility rules:
  - Paused projects hidden by default
  - Archived projects hidden by default
  - Blocked projects visible (so drift is visible), but clearly labeled
- Attribution:
  - sessions count toward a project if:
    1) the session is linked to a project, or
    2) the session’s task links to a project (fallback)
- Week boundary:
  - locale-based week interval
  - attribution by session start time (starter rule)

## Nonfunctional requirements
- Local-first: works offline with no account.
- Explainable: every number can be traced back to session logs.
- Fast load: weekly caps widget should render quickly from local store.

## Acceptance criteria
- A user can set a project cap in < 15 seconds.
- Weekly Cap Usage renders:
  - planned(cap) vs actual
  - over-cap projects highlighted
  - paused projects excluded by default
- Empty states:
  - no projects → prompt to create first project
  - projects exist but no sessions → show 0 actual with encouragement to start timer
- Offline mode behaves identically (local store).

## Success metrics
- `% users_with_caps_set` (weekly)
- `weekly_dashboard_opens_per_user` (goal: ≥ 3/week)
- `over_cap_rate` trend decreases over time (or users learn to set realistic caps)

## Edge cases
- Cap is unset: show actual-only and no over-cap warnings.
- Many projects: list virtualization or “top drift” ranking.
- User paused all projects: weekly caps widget shows empty-with-toggle state.
- Partial week: calculations still valid; avoid “neglected” judgment too early in week.

## Dependencies
- Project buckets + states (`product/prd-project-states.md`)
- Time allocation engine (`product/prd-time-allocation-engine.md`)
- Session logging (Ring Timer)

