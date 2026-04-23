# User Stories

This catalog is a planning + QA artifact. Feature-level requirements and metrics live in `specs/master-requirements.md`.

## Personas (initial)
- **Founder/Operator:** high autonomy, time-fragmentation, needs execution truth
- **PM/Lead:** balancing deep work and meetings, wants intentional allocation
- **Builder:** wants a calm “now” surface, not a project management system

## Stories by feature

### Daily Intent
- As a user, I can create today’s plan in under 2 minutes.
- As a user, I can set lane budgets (minutes) so that I have a time-based plan.
- As a user, I can “commit” today’s plan to reduce mid-day drift.

### Focus Lanes
- As a user, I see a small set of lanes (3–4) so that the UI stays calm.
- As a user, I can assign tasks to lanes so that my day is grouped by context.

### Ring Timer
- As a user, I can start a timer on a task with one tap.
- As a user, I can pause/resume without losing elapsed time.
- As a user, ending a session updates my lane and dashboard totals.

### Reflection
- As a user, I can add a short reflection to my day.
- As a user, I can write a note at the end of a session.

### Dashboard
- As a user, I can see target vs actual minutes per lane for today.
- As a user, I can review a simple weekly trend.

### Time Allocation (weekly caps)
- As a user, I can cap a project at X hours/week so tradeoffs are explicit.
- As a user, I can see planned vs actual hours per project each week.

### Project states
- As a user, I can pause a project so it stops consuming planning attention and cap budget.
- As a user, I can archive a project without deleting its history.

### Energy-aware scheduling
- As a user, I can label tasks by energy cost.
- As a user, I get an optional “suggested next” based on my peak hours.

### Voice Capture
- As a user, I can speak a task and confirm it becomes a lane task.

### Vision/OCR Capture
- As a user, I can capture tasks from a screenshot/photo and confirm them.

### AI Assistance
- As a user, I can ask for plan suggestions that remain editable and optional.
- As a user, I can disable AI and still use the app.

### Local-first + Sync later
- As a user, I can use TimeBite offline.
- As a user, if I opt in to sync later, my devices converge without losing data.

## QA mapping (starter)

For each story, define:
- Happy path
- Two edge cases
- One “recovery from failure” case (restart app, lose network, etc.)
