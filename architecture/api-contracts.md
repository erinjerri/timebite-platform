# API Contracts

This doc defines **interfaces** between TimeBite components and a future backend. For the iPhone MVP, most “APIs” are internal protocols and data access boundaries.

## Internal app APIs (recommended)

### Persistence boundary
- `DayPlanRepository`
  - `loadDayPlan(date)`
  - `saveDayPlan(dayPlan)`
  - `appendSessionLog(session)`

### Timer boundary
- `TimerController`
  - `start(taskId)`
  - `pause()`
  - `resume()`
  - `end(note?)`
  - `activeSession()`

### Aggregation boundary
- `DashboardAggregator`
  - `todaySummary(date)`
  - `weekSummary(weekOf)`

### Assistant boundary (optional)
- `SuggestionEngine`
  - `suggestLaneBudgets(history)`
  - `suggestPrimaryTasks(dayPlan, history)`

## Future backend APIs (opt-in)

### Versioning
- All sync APIs are versioned: `/v1/...`
- Payloads include `schema_version`

### Auth (later)
- Device + account identity.
- Support anonymous local use forever (no forced signup).

### Sync (later)
Suggested resources:
- `GET /v1/day-plans?from=YYYY-MM-DD&to=YYYY-MM-DD`
- `PUT /v1/day-plans/{date}`
- `POST /v1/session-logs`

Conflict approach (starter):
- Prefer additive merges.
- Never silently delete; tombstones are explicit.

### Telemetry (opt-in)
- `POST /v1/telemetry/events` with strict allowlist and no sensitive text fields.

## Acceptance criteria (contract-level)
- iPhone MVP ships with all boundaries local and testable.
- Adding a backend later does not require rewriting UI screens; only adapters behind repositories/controllers.

