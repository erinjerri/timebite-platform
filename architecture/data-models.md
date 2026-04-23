# Data Models

TimeBite’s core model is a **day plan** composed of lanes, tasks, and session logs. The model is designed to be local-first and migration-friendly.

## Canonical schema references
- `schemas/focus_os_schema.json` (richer day/lane/task/session model)
- `schemas/task_schema.json` (older/simple task shape; treat as legacy until reconciled)

## Entities (canonical)

### `project_bucket`
Represents a project (bucket) with weekly time constraints.
- `name`
- `type` (category/grouping)
- `state` (active/paused/deferred/blocked/archived)
- `weekly_cap_minutes` (planned budget per week)
 - `outcome` (optional measurable outcome statement)

### `day_plan`
Represents a single day.
- `date` (local date)
- `lanes[]`
- `active_task_id` (optional)
- `reflection` (optional)

### `focus_lane`
Represents a lane (App/Income/Brand/Support).
- `target_minutes`
- `actual_minutes` (derived from session logs)
- `primary_task_id`
- `ring_style` (visual token)
- `tasks[]`

### `task_item`
Single unit of work.
- `planned_minutes`
- `actual_minutes` (derived)
- `task_state` (planned/ready/active/paused/done/archived)
- `priority_tier` + `effort`
- `project_id` (optional link to `project_bucket`)

### `session_log`
Execution evidence.
- start/end timestamps
- computed duration
- optional note
- `project_id` (optional; may be derived from the task’s `project_id`)

## Derived fields and invariants

Invariants (enforced by model layer):
- One primary task per lane per day.
- Single active task per day (optional for MVP, but timer enforces a single active session).
- `actual_minutes` is computed from session logs, not manually edited.

Derived computations:
- Lane completion ratio = `actual_minutes / target_minutes` (handle zero safely).
- Day totals = sum of lane totals (avoid double counting).
- Weekly project totals = sum of session logs per `project_id` within a week interval.

## Day identity and time zones

Define day attribution rules explicitly:
- Day is keyed by the user’s locale date at session start (starter rule).
- Sessions that cross midnight either:
  - attribute entirely to start date (simplest), or
  - split into two logs (more correct, more complexity).

Pick one rule for MVP and encode it in tests.

## Week identity and caps

Weekly caps require deterministic week boundaries:
- Use locale-based week boundaries by default (Calendar `weekOfYear` interval).
- Attribute sessions by `started_at` (starter rule) unless you choose to split across boundaries.

Paused projects:
- excluded from weekly cap dashboards and over-cap warnings by default.

## Migration strategy (starter)

Minimum viable migration plan:
- Store a `schema_version` with the local database.
- Write forward-only migrations for changes to:
  - enums (lane names, states)
  - optional fields
  - entity splitting/merging

## Privacy classification (starter)

Treat these fields as sensitive:
- reflection text
- session notes
- voice transcripts
- OCR extracted text

These should not leave the device by default.
