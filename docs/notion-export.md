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

---

## Deprecated Export Shape

Quarterly goal rollups are deprecated for the MVP. They may remain as a future analytics export, but Notion should prioritize Goal Loop records, weekly summaries, and monthly summaries.
