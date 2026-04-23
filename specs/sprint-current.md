# Current Sprint (Apr 20, 2026 → May 1, 2026)

Sprint length: 2 weeks  
Sprint goal: ship the **local-first execution truth loop** as the foundation for the iPhone MVP.

## Objectives

1. Canonical day model persists locally (day plan, lanes, tasks, sessions, reflection).
2. Timer sessions are durable across backgrounding/restart.
3. Dashboard Today view reconciles against session logs.

## Sprint backlog (starter)

### P0 — must ship this sprint
- Define canonical Swift models aligned to `schemas/focus_os_schema.json`.
- Choose persistence strategy (SwiftData/Core Data/SQLite) and implement:
  - save/load day plan
  - save session logs
  - migration/versioning stub
- Implement timer state machine:
  - idle → running → paused → ended
  - single active session enforcement
  - recovery after app restart
- Implement dashboard computations off the main thread.

### P1 — if time
- Reflection entry + save
- Basic task editing (title, planned minutes, lane assignment)
- Developer debug screen (local logs, session list)

## Definition of done
- Timer sessions are never lost in normal app usage (lock, background, reopen).
- A user can time at least 3 sessions in a day and see totals update correctly.
- Clear empty states when no plan or no sessions exist.

## Risks to watch
- iOS background timing behavior and accuracy
- data migration strategy (avoid lock-in / data loss)
- UI scope creep (keep surfaces minimal)

