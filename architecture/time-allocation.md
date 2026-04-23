# Time Allocation (Projects + Weekly Caps)

This document explains how TimeBite models multiple concurrent projects with finite weekly hours, and how that maps into the SwiftData implementation.

## Core idea

Users have finite weekly hours and multiple concurrent projects. TimeBite makes tradeoffs explicit by:
- letting users set a weekly cap per project
- logging actual time via session logs
- showing planned(cap) vs actual and highlighting overages

## Canonical entities

See `schemas/focus_os_schema.json` (v0.2):
- `project_bucket`
- `task_item.project_id` (optional)
- `session_log.project_id` (optional)

Attribution rule (starter):
- A session contributes to a project if `session_log.project_id` exists.
- Otherwise, if `session_log.task_id` maps to a task with `task_item.project_id`, the session contributes to that project.

## Dashboard rules (starter)

Weekly caps dashboard:
- Planned = project weekly cap
- Actual = sum of session durations in the week interval
- Over cap = `actual > cap`
- Hidden by default:
  - paused projects
  - archived projects
 - Blocked projects remain visible (drift stays visible), with a clear state label

Week boundary:
- Locale-based `weekOfYear` interval.
- Session attribution by `started_at` (simplest).

## SwiftData implementation (starter)

Starter Swift package:
- `shared/TimeBiteDomain/`

SwiftData models:
- `ProjectBucket` (name, type, state, weeklyCapMinutes)
- `TaskItem` (optional project relationship)
- `SessionLog` (optional project relationship; `effectiveProject` falls back to task’s project)

Aggregation:
- `TimeAllocationEngine.weeklyCapsDashboard(...)` builds the planned vs actual view model.

## Migration notes

This feature is additive:
- existing day planning and lanes remain unchanged
- tasks and sessions gain an optional project link

When adopting in the app, treat projects as optional until users create them.
