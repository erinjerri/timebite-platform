# Notion Export Docs

Notion export is a mirror of TimeBite's Goal Loop, not a source of truth.

---

## Exported Objects

| TimeBite object | Notion representation |
| --- | --- |
| Goal | Goal page or database row |
| Daily Intent | Daily log relation or property |
| Session | Session row under a goal |
| Completion History | Calendar/status property |
| Reflection | Private note block or related row, opt-in only |
| Weekly Summary | Weekly review block |
| Monthly Summary | Monthly review block |

---

## Export Rules

- TimeBite remains write-primary.
- Notion edits are not imported into the MVP unless an explicit sync design is added later.
- Reflections require user opt-in before export.
- Streaks are exported as derived display values.
- Completion events remain the source for streak and calendar state.
- PM task sync is implemented by `tools/notion-pm/sync-release-tasks.mjs`.
- PM rows are upserted by stable `external_id`, with the resolved `notion_page_id`
  persisted in `.notion-sync-state.json` and an exact title + milestone fallback.
- Notion requests are limited to three per second.
- Failed writes append an `AgentActionEvent` with `outcome="failed"` to the
  telemetry JSONL log.

---

## Deprecated Export Shape

Quarterly goal rollups are deprecated for the MVP. They may remain as a future analytics export, but Notion should prioritize Goal Loop records, weekly summaries, and monthly summaries.
