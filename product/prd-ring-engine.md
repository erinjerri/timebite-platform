# PRD — Ring Engine (Timer + Progress Semantics)

## Summary

The Ring Engine is the heart of TimeBite: it converts time budgets and session logs into a visceral progress signal.

## User story
As a user, I want progress to feel tangible while I work so that I’m more likely to stay focused and finish what I intended.

## Functional requirements
- Timer state machine:
  - idle → running → paused → ended
  - single active session across the app
- Session logging:
  - start/end timestamps
  - computed duration
  - optional end note
- Ring computation (MVP):
  - lane ring shows `actual_minutes / target_minutes`
  - supports > 100% (over-budget)
- Task progress (optional MVP):
  - show `actual_minutes / planned_minutes` for the active task

## Nonfunctional requirements
- Accurate timekeeping; no meaningful drift across backgrounding.
- Smooth UI updates without heavy CPU usage.
- Durable session state across app restart.

## Acceptance criteria
- Starting a timer updates UI immediately and creates an active session record.
- Backgrounding the app and returning shows correct elapsed time.
- Ending a session updates:
  - `session_log`
  - `task_item.actual_minutes`
  - `focus_lane.actual_minutes`
  - dashboard rings

## Success metrics
- `weekly_timed_sessions_per_active_user`
- `median_session_minutes`
- `session_end_note_rate` (optional)

## Edge cases
- App killed mid-session: recover deterministically (documented rule).
- Midnight crossing: define attribution rule (by start date or split).
- Target minutes unset/zero: ring displays “no budget” state.
- User edits target minutes mid-day: ring recalculates but session truth stays unchanged.

## Dependencies
- Persistence (session logs)
- Dashboard aggregation rules
- iOS background behavior constraints

## Implementation notes (starter, not binding)
- Prefer a pure function for ring math:
  - inputs: target minutes, session logs, “now”
  - outputs: progress ratio, over-budget flag, display strings
- Keep timer logic separate from SwiftUI views.

