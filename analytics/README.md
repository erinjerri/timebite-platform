# Analytics

Analytics for TimeBite should serve product learning and execution quality, without compromising user privacy.

Principles:
- Default to on-device aggregation where possible.
- No recording of sensitive user text by default (reflection, notes, voice transcripts).
- Events describe *interaction + outcome*, not raw content.
- Metrics tie back to requirements in `specs/master-requirements.md`.

Event naming (suggested):
- `snake_case` event names, e.g. `timer_started`, `daily_intent_committed`
- Use consistent properties: `day_id`, `lane`, `task_id`, `source`, `duration_seconds`

