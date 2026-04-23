# Integrations (later, optional)

TimeBite integrations should be adapters that enrich the canonical model, not replace it.

## Principles
- Canonical TimeBite day plan remains source of truth.
- Integrations are opt-in and permission-scoped.
- Read-only first; write-back only if it is safe and reversible.

## Planned integrations

### Calendar (read-only first)
Use case:
- import events as context/time blocks
- optionally suggest lane budgets based on meeting load

Risks:
- users interpret imported events as “tasks”; keep boundaries clear

### Notion (optional)
Use case:
- import tasks from a database
- write back completion status (later)

Risks:
- mapping complexity; avoid syncing every field early

### Sunsama / Asana (optional)
Use case:
- import tasks and deadlines

Risks:
- becoming an integration platform too early

## Data mapping contract

All imported items become `task_item` records with:
- `source` + `source_id`
- minimal fields (title, deadline, notes)
- lane assignment is suggested, not automatic, unless confirmed

## Dependencies
- Sync/auth infrastructure (if multi-device or remote integrations)
- Background refresh constraints (iOS)

