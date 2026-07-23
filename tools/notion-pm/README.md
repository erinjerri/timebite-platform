# TimeBite Notion PM sync

This tool upserts the July 2026 iOS + visionOS release work into the existing
**TimeBite Apple Submission Command Center** data source.

## Run

```bash
cd tools/notion-pm
npm install
NOTION_TOKEN=secret_... npm run sync
```

`NOTION_DATA_SOURCE_ID` is optional and defaults to the current TimeBite PM data
source.

## Idempotency and rate limiting

- Every task has a stable `external_id` in `release-tasks.json`.
- The resolved `notion_page_id` is stored in the gitignored
  `.notion-sync-state.json`.
- If local state is missing, the sync looks up the exact `Task` + `Milestone`
  pair before creating anything.
- All Notion reads and writes pass through a 334 ms limiter, keeping request
  starts at or below three per second.
- Failures append an `AgentActionEvent` with `outcome="failed"` to
  `backend/services/telemetry/runs.jsonl`.

The database's canonical status option is `Not started`; the iOS dogfood UI
renders the user-facing label as `Not Started`.
