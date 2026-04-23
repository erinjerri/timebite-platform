# PRD — Reflection

## Summary

Reflection is the “learn” step in the loop. It should be lightweight and tightly tied to execution truth.

## User story
As a user, I want a short daily reflection so that I can improve tomorrow’s plan based on what actually happened.

## Functional requirements
- Daily reflection attached to a `day_plan`.
- Suggested prompts (MVP):
  - “What went well?”
  - “What didn’t?”
  - “What will I do differently tomorrow?”
- Session end note (optional) attached to `session_log`.
- Reflection history accessible from dashboard (MVP-lite: last 7 days).

## Nonfunctional requirements
- Private by default; on-device storage.
- Fast entry; no elaborate editor.

## Acceptance criteria
- User can write/edit today’s reflection and see it on the day summary.
- Reflection does not block timer workflows (always dismissible).

## Success metrics
- `% days_with_reflection`
- `reflection_time_seconds` (keep low)
- `reflection_followthrough_rate` (proxy: next-day edits soon after reading yesterday)

## Edge cases
- User reflects days later: allow editing past days.
- Sensitive content: never transmitted off-device by default.

## Dependencies
- Day plan history
- Local persistence

## Analytics (starter)
Events:
- `reflection_opened`
- `reflection_saved`
- `session_note_saved`

