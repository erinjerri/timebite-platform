# TimeBite Platform

TimeBite is a **cycle-based time system** for modeling how time is actually spent across life categories — not just planned.

Built across:

- **iOS** (primary product surface)
- **visionOS** (spatial computing + torus visualization)
- **macOS** (future productivity + debugging interface)

---

## TL;DR

- **What:** A system that shows how your time is distributed in reality
- **Core:** Cycle Matrix → Cycles Dashboard → Feedback loop
- **Agent:** Constrained assistant (tight RAG, not open chat)
- **Status:** Active development + research monorepo

---

## Core concepts

### Cycle Matrix (backend)

- Source of truth for time allocation
- Structure:
  - rows → time segments
  - columns → categories
  - values → time spent

### TimeBite Cycles (UI)

- User-facing representation of time distribution
- Includes:
  - category allocation (bars)
  - contribution grid (GitHub-style history)
  - cycle score + feedback
  - quarterly goal progress from completed task time

### Quarterly Goal Chart

- Goals belong to a quarter and carry a target time budget
- Completed tasks fill goal progress using captured time
- `percent_complete` is server-computed; clients render the rollup but never submit progress percentages
- Notion mirrors quarterly rollups read-only, consistent with TimeBite's write-primary rule

### Constrained assistant (tight RAG)

- Not a general chatbot
- Only:
  - executes **allowed UI actions**
  - retrieves documentation

---

## Cycles dashboard (UI concept)

TimeBite surfaces time as a **structured system**, not just tasks.

### Daily cycles (example)

```text
[ Today ]

Engineering — 3h 20m ███████░░
Writing     — 1h 45m ████░░░░░
Health      — 0h 50m ██░░░░░░░
Admin       — 2h 10m █████░░░░
Personal    — 0h 30m █░░░░░░░░
```

### Quarterly Goal Chart (example)

```text
[ Q3 2026 ]
Ship TimeBite MVP — 42h of 60h ███████░░░ 70%  (18/24 tasks)
Book pitch draft  —  6h of 20h ███░░░░░░░ 30%  (3/10 tasks)
```

---

## Repository layout (current)

What exists in this repo today (high level):

```text
timebite-platform/
├── apps/                    # Placeholder targets: iOS, visionOS, macOS
├── docs/                    # e.g. system-architecture.md
├── specs/                   # e.g. torus_environment.md
├── schemas/                 # Shared JSON shapes for tasks, goals, and quarterly rollups
├── backend/                 # Services and API routes for cycles and goal rollups
├── research/
│   └── auto_research/       # Research CLI, autoresearch package, outputs
├── README.md
└── .gitignore
```

---
### Target platform layout (planned)

Full monorepo layout (clients, backend, scripts). Expand to view.

<details>
<summary><strong>Full directory tree (planned)</strong></summary>

```text
timebite-platform/
│
├── apps/
│   ├── ios/
│   │   └── timebite-ios/
│   │       ├── App/
│   │       │   ├── TimeBiteApp.swift
│   │       │   ├── RootView.swift
│   │       │   ├── AppState.swift
│   │       │   └── Navigation/
│   │       │       ├── TabRouter.swift
│   │       │       └── RouteDefinitions.swift
│   │       │
│   │       ├── Features/
│   │       │   ├── cycles/
│   │       │   │   ├── Views/
│   │       │   │   │   ├── CyclesDashboardView.swift
│   │       │   │   │   ├── CycleRowView.swift
│   │       │   │   │   ├── CycleBarView.swift
│   │       │   │   │   ├── CycleScoreCard.swift
│   │       │   │   │   ├── RealityCheckView.swift
│   │       │   │   │   └── DailySummaryView.swift
│   │       │   │   ├── ViewModels/
│   │       │   │   │   ├── CyclesViewModel.swift
│   │       │   │   │   └── CycleComputation.swift
│   │       │   │   ├── Models/
│   │       │   │   │   ├── Cycle.swift
│   │       │   │   │   ├── Category.swift
│   │       │   │   │   └── CycleSnapshot.swift
│   │       │   │   └── Components/
│   │       │   │       ├── ProgressBar.swift
│   │       │   │       └── PercentageLabel.swift
│   │       │   │
│   │       │   ├── tasks/
│   │       │   ├── goals/
│   │       │   │   ├── Views/
│   │       │   │   │   └── QuarterlyGoalChartView.swift
│   │       │   │   └── ViewModels/
│   │       │   │       └── QuarterlyGoalViewModel.swift
│   │       │   ├── planner/
│   │       │   ├── insights/
│   │       │   └── assistant/
│   │       │
│   │       ├── Services/
│   │       │   ├── API/
│   │       │   ├── Storage/
│   │       │   ├── Assistant/
│   │       │   └── Integrations/
│   │       │
│   │       └── Shared/
│   │
│   ├── visionos/
│   │   └── timebite-visionos/
│   │       ├── App/
│   │       │   ├── TimeBiteVisionApp.swift
│   │       │   └── SpatialRootView.swift
│   │       │
│   │       ├── Features/
│   │       │   ├── torus/
│   │       │   │   ├── Views/
│   │       │   │   │   ├── TorusView.swift
│   │       │   │   │   ├── Ring3DView.swift
│   │       │   │   │   └── SpatialCyclesView.swift
│   │       │   │   ├── Models/
│   │       │   │   └── ViewModels/
│   │       │   │
│   │       │   └── gestures/
│   │       │       ├── HandTrackingManager.swift
│   │       │       └── GestureRouter.swift
│   │       │
│   │       └── Shared/
│   │
│   ├── macos/
│   │   └── timebite-macos/
│   │       ├── App/
│   │       │   ├── TimeBiteMacApp.swift
│   │       │   └── DesktopRootView.swift
│   │       │
│   │       ├── Features/
│   │       │   ├── cycles/
│   │       │   ├── planner/
│   │       │   ├── insights/
│   │       │   └── debug/
│   │       │       ├── TelemetryView.swift
│   │       │       └── LogsViewer.swift
│   │       │
│   │       └── Services/
│   │
│   └── web/
│       └── timebite-web/
│
├── backend/
│   ├── services/
│   │   ├── cycles/
│   │   │   ├── cycle_matrix.py
│   │   │   ├── cycle_engine.py
│   │   │   └── scoring.py
│   │   │
│   │   ├── goals/
│   │   │   ├── quarterly_rollup.py
│   │   │   └── task_completion_handler.py
│   │   │
│   │   ├── agents/
│   │   │   ├── green_agent/
│   │   │   ├── purple_agent/
│   │   │   └── shared/
│   │   │
│   │   ├── assistant/
│   │   │   ├── orchestrator.py
│   │   │   ├── intent_classifier.py
│   │   │   ├── ui_action_whitelist.py
│   │   │   └── documentation_router.py
│   │   │
│   │   ├── retrieval/
│   │   │   ├── ingest_docs.py
│   │   │   ├── chunking.py
│   │   │   ├── embeddings.py
│   │   │   ├── vector_store.py
│   │   │   └── retriever.py
│   │   │
│   │   └── telemetry/
│   │
│   └── api/
│       └── goals_quarterly.py
│
├── shared/
├── docs/
├── schemas/
│   ├── task_schema.json
│   ├── goal_schema.json
│   └── quarterly_rollup_schema.json
├── research/
└── scripts/
```

</details>

---

## Documentation

- [System architecture](docs/system-architecture.md) — flow diagram and component relationships
- [Torus environment](specs/torus_environment.md) — state and actions sketch

---

## License

No `LICENSE` file is in the repo yet. Add one at the repo root (for example MIT or Apache-2.0) when you are ready to share terms.

---

## Security

Do not commit API keys, tokens, or production endpoints. Use a local `.env` (ignored by git) for secrets.
