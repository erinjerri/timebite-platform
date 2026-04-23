# PRD — Daily Intent

## Summary

Daily Intent is the lightweight planning flow that produces a committed day plan: a small set of lane budgets and primary tasks.

## User story
As a user, I want to commit to a small set of priorities for today so that my day is intentional rather than reactive.

## Problem
Most planning tools either:
- encourage too many tasks, or
- disconnect planning from execution evidence.

Daily Intent exists to create a **time budget + primary commitments** that the timer and dashboard can enforce and reflect.

## Goals
- A committed plan in < 2 minutes.
- A small surface: 3–4 lanes, one primary task each.
- Immediate utility even with no history and no backend.

## Non-goals (MVP)
- Full project management
- Complex recurrence
- Deep integrations

## Functional requirements
- Create/edit day plan for a date.
- Default lanes (App, Income, Brand, optional Support).
- For each lane:
  - set `target_minutes`
  - set 1 `primary_task`
  - optionally add queued tasks (cap to keep UI calm)
- Commit intent:
  - explicit “Commit” action
  - record a timestamp and “committed=true”
- Quick start:
  - if no plan exists, generate defaults (lane minutes + blank primary tasks).

## Nonfunctional requirements
- Offline-first, no account required.
- Low friction:
  - single-screen flow preferred
  - minimal typing (templates + quick add)

## Acceptance criteria
- A new user can:
  1) open Plan,
  2) set 3 lane budgets,
  3) add 3 primary tasks,
  4) commit,
  and see the result reflected on Dashboard immediately.
- At most one primary task per lane is enforced.
- Editing after commit logs a “plan changed” event (for analytics and debugging).

## Success metrics
- `% days_with_committed_intent`
- `median_time_to_commit_intent_seconds`
- `intent_to_execution_rate` (intent + ≥1 session)

## Edge cases
- User refuses structure: allow minimal “one lane” mode (later) but keep default lanes.
- User changes time zone: day identity should remain stable and documented.
- User mid-day re-plans: keep history and do not discard session truth.

## Dependencies
- Local persistence layer
- Canonical data model (day_plan, focus_lane, task_item)
- Ring engine rules (so budgets have meaning)

## Analytics (starter)
Events:
- `daily_intent_opened`
- `daily_intent_committed`
- `daily_intent_edited_after_commit`
Properties:
- `lane_count`, `has_support_lane`, `time_to_commit_seconds`

