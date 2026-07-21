# Sprint Plan And Backlog

This is the active sprint backlog for the habit-centric MVP.

---

## Sprint 1: Goal Loop Model

| Status | Task | Notes |
| --- | --- | --- |
| TODO | Replace quarterly-first goal model with Goal Loop fields | Intent, frequency, sessions, completion history, reflections, streaks, summaries, tags. |
| TODO | Add local persistence for Goal records | Prefer local-first MVP behavior. |
| TODO | Add goal create/edit/archive flow | Keep creation under one minute. |
| TODO | Add migration adapter for old goal records | Preserve titles/categories where available. |

## Sprint 2: Daily Intent And Today

| Status | Task | Notes |
| --- | --- | --- |
| TODO | Build Today surface | Primary MVP entry point. |
| TODO | Add daily intent selection | One or a few goals per day. |
| TODO | Add completion checkmark states | Completed, partial, skipped, rest. |
| TODO | Add calm empty states | Direct user to start tiny. |

## Sprint 3: Timer Execution

| Status | Task | Notes |
| --- | --- | --- |
| TODO | Tie timer to Goal sessions | Session belongs to one goal. |
| TODO | Persist running session state | Recover if app closes. |
| TODO | Implement complete/partial/skip/rest actions | Completion event feeds history. |
| TODO | Update history from session completion | History is source for calendar and streaks. |

## Sprint 4: Reflection

| Status | Task | Notes |
| --- | --- | --- |
| TODO | Add post-completion reflection sheet | Optional and one-line friendly. |
| TODO | Store reflection by goal/session/date | Support later review. |
| TODO | Add reflection prompt variants | Keep tone gentle. |
| TODO | Add reflection from calendar day detail | Capture late notes. |

## Sprint 5: Streak And Calendar

| Status | Task | Notes |
| --- | --- | --- |
| TODO | Implement streak engine | Derived from completion history and frequency. |
| TODO | Show current and longest streak | Reinforcement without shame. |
| TODO | Build monthly completion calendar | Goal-specific and aggregate states. |
| TODO | Add day detail view | Sessions and reflections. |

## Sprint 6: Dashboard

| Status | Task | Notes |
| --- | --- | --- |
| TODO | Add calm dashboard summary | Streaks, weekly summary, monthly summary. |
| TODO | Add recent reflections | Lightweight review. |
| TODO | Add first light insights | Derived and explainable. |
| TODO | Hide dense analytics until later | Avoid MVP cognitive load. |

## Later

| Priority | Area | Notes |
| --- | --- | --- |
| 7 | Analytics | Derived projections from Goal Loop data. |
| 8 | AI features | Explicit opt-in after privacy review. |
