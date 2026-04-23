# Master Requirements (iPhone Launch)

This document defines **requirements-first** scope for TimeBite’s core loop. It is written to be implementation-ready while remaining friendly to solo-founder velocity.

## Operating assumptions (product-level)

TimeBite is built around real constraints:
- finite hours (budgets and caps matter)
- changing energy (task energy cost is first-class)
- multiple concurrent projects (work is not a single linear backlog)
- weekly caps (allocation vs reality is measurable)
- measurable outcomes (tasks roll up to outcomes)
- projects can be paused/resumed without deletion

## Global product requirements

### Nonfunctional requirements (global)
- **Local-first:** Full core loop works offline with no account.
- **Performance:** App launch < 2s warm on recent iPhones; timer UI updates smoothly at 60fps.
- **Reliability:** Timer session logs are durable across app restarts and low-battery conditions.
- **Privacy:** No sensitive text (notes/reflections/transcripts) is sent off-device by default.
- **Accessibility:** Supports Dynamic Type, VoiceOver basics, and reduced motion.
- **Observability:** Local debug log + lightweight analytics events (privacy-preserving).
- **Maintainability:** Clear feature boundaries; minimal global state; small number of core models.

### Data/source-of-truth requirements (global)
- **Canonical day model:** one day plan containing lanes, tasks, and session logs (see `schemas/focus_os_schema.json`).
- **Execution truth:** dashboards computed from session logs + task state.
- **Migration-ready:** schema versioning and migration plan for local store.

---

## Feature requirements

Each core feature includes:
- user story
- functional requirements
- nonfunctional requirements
- acceptance criteria
- success metrics
- edge cases
- dependencies

---

## 1) Daily Intent planning

### User story
As a user, I want to commit to a small set of priorities for today so that I can protect time for what matters.

### Functional requirements
- Create or edit a **Day Plan** for a selected date.
- Define **3–4 Focus Lanes** (default: App, Income, Brand, optional Support).
- Set a **target minutes** budget per lane.
- Assign **one primary task** per lane, plus up to N queued tasks.
- Commit the plan (explicit “commit” action) to reduce accidental drift.

### Nonfunctional requirements
- Fast entry (single-screen flow in < 60 seconds).
- Works fully offline; no account required.

### Acceptance criteria
- A user can create today’s plan with 3 lanes + 3 primary tasks in under 2 minutes.
- Primary task per lane is enforced (at most one `is_primary=true` per lane per day).
- Plan persists across app restart and date changes.

### Success metrics
- `% days_with_committed_intent` (weekly)
- `median_time_to_commit_intent_seconds`
- `intent_to_execution_rate` = days with intent + at least one timed session

### Edge cases
- User skips planning: app offers a “quick start” default plan.
- User edits plan mid-day: preserve history or log “plan change” event.
- Time zone change: day boundary behavior is deterministic and documented.

### Dependencies
- Local persistence
- Lane + task models (`schemas/focus_os_schema.json`)

---

## 2) Focus lanes

### User story
As a user, I want my day grouped into lanes so that I can context-switch less and track progress per area.

### Functional requirements
- Lanes have: label, color token, target minutes, actual minutes, completion ratio.
- Lane UI shows: ring progress + primary task + quick actions (start, complete).
- Lane settings: rename label; reorder lanes (optional for MVP).

### Nonfunctional requirements
- Lane UI is glanceable (fits iPhone screen without scrolling for default lanes).

### Acceptance criteria
- Lanes render consistently across Dashboard, Plan, and Timer.
- Lane actual minutes matches sum of session logs for that lane’s tasks for the day.

### Success metrics
- `lane_switches_per_day` (lower is better, within reason)
- `sessions_per_lane_distribution`

### Edge cases
- Task without a lane: must be assigned or kept in an “Unsorted” holding area.
- Lane target set to 0: ring shows “no budget” state, not divide-by-zero.

### Dependencies
- Ring engine
- Session logging

---

## 3) Ring timer execution

### User story
As a user, I want to start a timer for the task I’m doing so that I can build execution truth and feel progress.

### Functional requirements
- Start/pause/resume/stop a session for a selected task.
- Persist the active session state across app backgrounding/restart.
- End session writes a durable session log with start/end times and duration.
- Optional “complete task” action at end of session.
- Ring depletion reflects remaining time relative to lane budget and/or task planned minutes (define in PRD).

### Nonfunctional requirements
- Timer does not drift noticeably over typical sessions (accurate to seconds).
- Minimal battery impact during active timing.

### Acceptance criteria
- Starting a timer creates an active session within 200ms UI feedback.
- Backgrounding for 30 minutes and returning reflects correct elapsed time.
- Ending a session updates: task actual minutes, lane actual minutes, dashboard ring.

### Success metrics
- `weekly_timed_sessions_per_active_user`
- `median_session_minutes`
- `timer_crash_free_sessions` (or crash-free rate)

### Edge cases
- Phone reboot mid-session: recovery behavior is defined (auto-end at last known timestamp, or resume).
- Over-budget: ring continues past 100% with distinct “over” state.
- Multiple timers: enforce single active timer at a time.

### Dependencies
- Local persistence
- Notification/background execution policies (iOS)

---

## 4) Reflection journaling

### User story
As a user, I want a lightweight reflection so that tomorrow’s plan improves based on reality.

### Functional requirements
- Daily prompt(s): what went well, what didn’t, what to change tomorrow (configurable later).
- Link reflection to the day plan.
- Optional “session notes” (short) at end of timer.

### Nonfunctional requirements
- Reflection is private by default and remains on-device unless user opts in.

### Acceptance criteria
- User can write and edit today’s reflection in under 2 minutes.
- Reflection persists and is viewable in dashboard/history.

### Success metrics
- `% days_with_reflection`
- `reflection_followthrough_rate` (next-day plan references yesterday’s learnings)

### Edge cases
- User writes sensitive data: do not transmit off-device by default.
- Missed days: allow retroactive reflection for previous dates.

### Dependencies
- Local persistence
- Daily plan/history view

---

## 5) Dashboard analytics

### User story
As a user, I want to see how I spent time vs intent so that I can adjust behavior.

### Functional requirements
- Today view: lanes with target vs actual minutes; progress rings; active task shortcut.
- Week view (MVP-lite): simple aggregation per lane and trend line.
- “Execution truth” is computed from session logs.

### Nonfunctional requirements
- Dashboard renders quickly from local store; no heavy computations on main thread.

### Acceptance criteria
- Dashboard numbers reconcile with session logs (no double-counting).
- Week view correctly spans the user’s locale week start (configurable later).

### Success metrics
- `% users_view_dashboard_weekly`
- `intent_accuracy_delta` (abs(target-actual)/target) trend

### Edge cases
- Sessions overlapping midnight: define attribution rule (by start date, by split, etc.).
- Missing targets: show actual-only mode.

### Dependencies
- Session logs
- Lane budgets

---

## 6) Project Buckets + Weekly Time Caps

### User story
As a user, I want to manage multiple concurrent projects with weekly hour caps so that my time is allocated intentionally and low-value work can’t expand infinitely.

### Functional requirements
- Create project buckets with:
  - `name`
  - `type` (category for grouping)
  - `state` (Active / Paused / Deferred / Blocked / Archived)
  - `outcome` (optional measurable outcome statement)
- Weekly time caps:
  - user sets `weekly_cap` per project (hours/week)
  - cap applies to the current week’s allocation (“planned”)
- Time tracking:
  - timer sessions log against a project (directly or via the task’s project)
- Weekly caps dashboard:
  - planned(cap) vs actual hours per project
  - over-cap warning state
  - paused projects hidden by default

### Nonfunctional requirements
- Local-first; works offline with no account.
- Fast edits: set or change a weekly cap in a single interaction.
- Deterministic week boundaries (locale-based, documented).

### Acceptance criteria
- A user can create a project + set a weekly cap in < 30 seconds.
- Weekly dashboard reconciles with session logs (no double counting).
- Over-cap projects are visually distinguished.
- Paused projects do not appear in the weekly dashboard by default and do not trigger over-cap warnings.
 - Blocked projects remain visible in dashboards (tradeoffs stay visible), but are clearly labeled.

### Success metrics
- `% weeks_with_caps_set` (weekly)
- `over_cap_rate` (trend down over time)
- `high_value_project_share` (proxy metric, defined per user’s projects)

### Edge cases
- Sessions without a project:
  - allowed, but show under “Unassigned” or excluded (define behavior)
- Cap changes mid-week:
  - planned changes, actual remains unchanged
- Week boundary attribution:
  - define whether attribution is by session start or split across weeks
 - Blocked projects:
  - they may accumulate time unintentionally; keep visibility but avoid punitive messaging

### Dependencies
- Ring timer + durable session logs
- Project states (visibility and exclusion rules)

---

## 7) Voice capture (optional for iPhone MVP, but planned)

### User story
As a user, I want to speak a task so that capture is frictionless.

### Functional requirements
- One-tap record, transcribe, and propose task(s) and lane assignment.
- Confirm before creating tasks.

### Nonfunctional requirements
- On-device transcription preferred where possible; otherwise explicit opt-in to cloud.

### Acceptance criteria
- User can capture a spoken task and see a proposed task card within 10 seconds (network permitting).

### Success metrics
- `voice_capture_to_task_create_rate`

### Edge cases
- Noisy environment: allow retry; do not create garbage tasks by default.
- Privacy: avoid storing raw audio unless user chooses.

### Dependencies
- iOS speech APIs or chosen transcription provider
- Task creation flow

---

## 8) Vision/OCR capture (optional for iPhone MVP, but planned)

### User story
As a user, I want to capture tasks from a screenshot/photo so that I can import work without retyping.

### Functional requirements
- Capture image, run OCR, extract candidate tasks, confirm creation.
- Store extracted text locally.

### Nonfunctional requirements
- Strong privacy guardrails; user-controlled retention.

### Acceptance criteria
- OCR proposals are editable before saving.

### Success metrics
- `vision_capture_to_task_create_rate`

### Edge cases
- OCR errors: user can correct; do not silently create many tasks.

### Dependencies
- iOS Vision framework (OCR)
- Task creation flow

---

## 9) AI workflow assistance

### User story
As a user, I want AI assistance to summarize, prioritize, and propose plans so that I can decide faster—not outsource judgment.

### Functional requirements
- Suggest lane targets based on history.
- Propose primary task choices when user has many tasks.
- Provide “next action” suggestions during execution (optional).

### Nonfunctional requirements
- AI suggestions are explainable (“based on last week you overspent Admin by 2h/day”).
- AI is constrained: cannot take irreversible actions without confirmation.

### Acceptance criteria
- AI never starts timers or deletes tasks without explicit user action.
- User can disable AI entirely and still use the full core loop.

### Success metrics
- `ai_suggestion_accept_rate`
- `time_to_commit_intent_reduction`

### Edge cases
- Hallucinations: show AI output as suggestions with clear provenance and easy undo.

### Dependencies
- Local data summary
- (Optional) backend for model calls, or on-device model in future

---

## 10) Local-first persistence

### User story
As a user, I want the app to be reliable offline so that my planning and execution never depend on a server.

### Functional requirements
- Store day plans, lanes, tasks, sessions, and reflections locally.
- Provide export (later) for user ownership and debugging.

### Nonfunctional requirements
- Safe migrations across versions; no data loss.

### Acceptance criteria
- App works in airplane mode with full core loop.
- Data remains after reinstall only if user uses iCloud/backup or export (define later).

### Success metrics
- Crash-free sessions
- Data-loss incidents (should be zero)

### Edge cases
- Corruption handling: detect and recover gracefully (backup/repair).

### Dependencies
- Chosen persistence layer (SwiftData/Core Data/SQLite)

---

## 11) Optional backend sync (later)

### User story
As a user, I want my data on multiple devices so that my plan and execution follow me.

### Functional requirements
- Opt-in account creation.
- Sync day plans, tasks, and sessions across devices with conflict resolution.
- Prefer additive merge; never silently delete.

### Nonfunctional requirements
- Privacy-first; end-to-end encryption considered for sensitive fields.

### Acceptance criteria
- Two devices converge on the same day plan within minutes.
- Conflicts are visible and recoverable.

### Success metrics
- `sync_enabled_rate`
- `sync_error_rate`

### Edge cases
- Offline edits on multiple devices: conflict resolution rules are deterministic.

### Dependencies
- Auth
- Sync API + storage
- Versioned data model
