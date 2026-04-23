# PRD: Energy-Aware Scheduling

## Summary

TimeBite treats energy as a first-class constraint. Tasks carry energy labels, and the app recommends which tasks to do based on the user’s likely energy window.

## User story
As a user, I want the app to recommend high-focus tasks during my peak hours so that I make progress on what matters when I have the energy to do it.

## Functional requirements
- Tasks include an energy label:
  - High Focus
  - Medium Focus
  - Low Energy
- User can define (MVP-lite):
  - a daily “peak window” (e.g., 9:00–11:30)
  - optional “low energy window” (e.g., 2:00–4:00)
- Recommendations:
  - during peak window, recommend High Focus tasks first
  - during low energy windows, recommend Low Energy tasks first
  - if no tasks match, fall back gracefully (do not block)
- UI surfaces recommendations without requiring a separate “scheduler” app:
  - Dashboard “Suggested next”
  - Timer “Start recommended”

## Nonfunctional requirements
- Local-first; recommendations computed on-device.
- Explainable: show “why” (e.g., “Peak window + High Focus task”).
- Non-intrusive: always optional; user can ignore and start any task.

## Acceptance criteria
- A user can label a task’s energy in under 2 taps.
- During a configured peak window, the default recommendation favors High Focus tasks.
- Recommendations never start timers automatically; user confirms by tapping start.

## Success metrics
- Increase `intent_to_execution_rate` (intent + ≥1 session).
- Increase share of High Focus minutes during peak window (if user opts in).
- `recommendation_start_rate` (how often suggested tasks are started).

## Edge cases
- User has no configured energy windows:
  - fall back to lane primary tasks
- User is traveling/time zone changes:
  - energy windows should follow local time and be editable
- User’s “peak” varies by day:
  - allow per-day override later; start with a simple default
- All tasks are Low Energy:
  - recommendation still works; do not shame the user

## Dependencies
- Task model supports energy labels (map or extend existing `effort` field when implemented)
- Dashboard + Timer surfaces
- Optional “peak window” settings storage

