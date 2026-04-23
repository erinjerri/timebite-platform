# Focus OS

This document turns the prioritization chat into a canonical TimeBite planning model.

The goal is not a generic to-do list. The goal is a small, opinionated operating system:

- `App` keeps the product moving.
- `Income` keeps cash and career momentum alive.
- `Brand` keeps narrative and distribution alive.

Everything else is either support work or noise.

## 1. Prioritization model

### Tier 1: survival

These tasks protect cash flow, reduce stress, and keep optionality open.

- job applications
- interview prep
- consulting replies and follow-up

### Tier 2: strategic leverage

These tasks build the product story and the demo.

- hackathon deliverable
- TimeBite core app loop

### Tier 3: optimization

These tasks may matter later, but should not displace the first two tiers.

- social media automation
- scraping pipelines
- dashboard meta-work

## 2. Operating rules

Each day gets exactly a few visible items:

- `1 App task`
- `1 Income task`
- `1 Brand task`

Optional:

- `1 Support task` for admin, health, or personal upkeep

This keeps the UI small enough to feel like a focused command center on iPhone, Apple Watch, visionOS, and Mac.

## 3. Canonical entities

TimeBite should model the day in four layers.

### DayPlan

The container for a single day.

- date
- energy
- reflection
- selected lanes
- active item id

### FocusLane

The top-level ring or checklist row the user sees.

- `app`
- `income`
- `brand`
- optional `support`

Each lane has one primary item for the day plus a few queued items.

### TaskItem

The actual actionable task. This is the checklist atom.

- title
- lane
- priority tier
- effort
- planned minutes
- state
- platform surfaces
- outcome value

### SessionLog

Execution evidence. Sessions feed timer state, ring depletion, and post-hoc truth.

- start
- end
- duration
- task id
- notes

## 4. Recommended task mapping

Map the chat into these lanes:

### App lane

- Ship hackathon demo loop
- Build ring depletion UI
- Connect timer to session logging

### Income lane

- Apply to 3 to 5 jobs
- Prep next interview
- Reply to consulting leads

### Brand lane

- Publish one build-in-public update
- Tighten CTA or Substack positioning

### Explicitly deprioritized for now

- Claude exploration for its own sake
- Apify social scraping
- custom social dashboard work

Those belong in backlog until either the MVP ships or income pressure drops.

## 5. UI translation

### Shared interaction model

Every platform should show the same core state:

- lane label
- one primary task
- completion checkbox
- torus or ring progress
- planned versus actual minutes
- quick start timer action

### iPhone

Best as a compact command center with three to four stacked lane cards.

- one ring per lane
- primary task title under each ring
- tap to expand queued tasks
- swipe or tap to complete

### Apple Watch

Best as a "next thing now" interface.

- show active lane
- show one current task
- one-tap start or complete
- simplified ring only, no long lists

### visionOS

Best as a spatial status board.

- torus ring as the 3 dimensional hero object with subrings that are 2D
- lanes arranged around it
- glanceable progress and session state
- pinch to start or complete

### macOS

Best as the planning and debugging surface.

- multi-column lane board
- queue management
- session history
- notes and reflection

## 6. Checklist view contract

To feel closer to Notion or Inflow, each lane should render as:

1. `lane header`
2. `primary task`
3. `progress ring`
4. `0-3 queued tasks`

That means the canonical model should support:

- a single `is_primary` item per lane per day
- a sortable `position`
- a `queue_state` of `primary`, `queued`, or `hidden`

## 7. Sample day

```json
{
  "date": "2026-04-03",
  "lanes": [
    {
      "lane": "app",
      "label": "Hackathon",
      "target_minutes": 180,
      "actual_minutes": 45,
      "primary_task_id": "task_app_demo_loop"
    },
    {
      "lane": "income",
      "label": "Income",
      "target_minutes": 120,
      "actual_minutes": 0,
      "primary_task_id": "task_income_consulting_replies"
    },
    {
      "lane": "brand",
      "label": "Brand",
      "target_minutes": 45,
      "actual_minutes": 0,
      "primary_task_id": "task_brand_build_post"
    }
  ]
}
```

## 8. Product stance

TimeBite should not behave like a giant life dashboard.

It should behave like a small execution surface that answers:

- What matters today?
- What is active right now?
- What has actually happened?

That is the right abstraction to port into the hackathon repo.
