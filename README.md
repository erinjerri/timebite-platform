# TimeBite Platform

TimeBite is a calm, habit-centric goal loop for turning intent into completed focus sessions, lightweight reflection, streak reinforcement, and useful insights.

The MVP is intentionally not analytics-first. Analytics serve the loop after the user has built a rhythm.

Built across:

- **iOS** as the primary MVP surface
- **visionOS** for future spatial ritual and completion review
- **macOS** for future productivity and debugging workflows

---

## TL;DR

- **What:** A daily ritual for choosing an intent, completing a focused session, reflecting briefly, and seeing continuity over time.
- **Core:** Goal Loop -> Execution -> Reflection -> Streak -> Insights.
- **MVP priority:** Goal Loop, Daily Intent, Timer, Reflection, Monthly Completion Calendar, Dashboard, Analytics, AI features.
- **Assistant:** Future constrained assistant only; not part of the primary MVP loop.
- **Status:** Active development and product pivot toward a calmer goal practice.

---

## Product Direction

TimeBite should feel like a quiet daily ritual, not a command center. The app helps the user answer five low-friction questions:

1. What matters today?
2. What session will I do now?
3. Did I complete it?
4. What did I notice?
5. How is my streak and month shaping up?

The interaction patterns are completion checkmarks, gentle streak reinforcement, quick journaling, a monthly completion calendar, and minimal cognitive load. We are inspired by calm ritual products, but TimeBite must retain its own identity and avoid cloning any existing UI.

---

## Core Concepts

### Goal Loop

The Goal is the durable habit object. It carries the user's intent, category, frequency, sessions, completion history, reflections, current streak, longest streak, weekly summary, monthly summary, and tags.

### Daily Intent

The first meaningful action each day is choosing one or a few goals that matter today. The intent can be tiny and plain-language.

### Execution

Execution is a focused timer session tied to a goal. The user should be able to start, pause, complete, or skip without handling analytics decisions.

### Reflection

After completion, TimeBite asks for a lightweight reflection. Reflection is optional, short, and ritual-like: one line is enough.

### Streak

Streaks reinforce continuity without shaming. The product should celebrate return, recovery, and consistency over perfect behavior.

### Insights

Insights summarize patterns after enough completion and reflection data exists. Analytics are a later layer, not the primary MVP.

---

## MVP Navigation

The MVP should bias toward fewer surfaces:

- **Today:** Daily intent, active timer, completion checkmarks, quick reflection.
- **Goals:** Goal setup, frequency, tags, streak status, recent sessions.
- **Calendar:** Monthly completion calendar and reflection markers.
- **Dashboard:** Calm rollup of streaks, weekly summary, monthly summary, and light insights.
- **Settings:** Privacy, reminders, export, and gated future features.

---

## Repository Layout

```text
timebite-platform/
├── apps/                    # iOS, visionOS, macOS, website surfaces
├── backend/                 # Services for goals, cycles, assistant, telemetry
├── docs/                    # Product, architecture, roadmap, sprint docs
├── schemas/                 # Shared JSON shapes for goals, tasks, rollups
├── shared/                  # Shared domain code
├── specs/                   # Focused product and platform specifications
├── research/                # Research experiments and outputs
└── README.md
```

---

## Documentation

- [Goal Loop specification](docs/goal-loop-specification.md)
- [System architecture](docs/system-architecture.md)
- [UI architecture](docs/ui-architecture.md)
- [Dashboard specification](docs/dashboard-specification.md)
- [Roadmap](docs/roadmap.md)
- [Sprint plan and backlog](docs/sprint-plan.md)
- [Feature checklist](docs/feature-checklist.md)
- [Migration checklist](docs/migration-checklist.md)
- [Implementation roadmap](docs/implementation-roadmap.md)
- [Notion export docs](docs/notion-export.md)
- [Torus environment](specs/torus_environment.md)

`docs/to-do-list.md` now points to the sprint plan so backlog work has one source of truth.

---

## Privacy

The MVP should remain local-first where possible. Reflections, goals, sessions, and streak history are user content. External AI and analytics features must remain gated until explicit privacy and user-consent flows exist.

---

## Security

Do not commit API keys, tokens, or production endpoints. Use a local `.env` ignored by git for secrets.
