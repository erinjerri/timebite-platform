# UI Screen Architecture

This document translates the reference screenshots into a concrete TimeBite screen system for iPhone first, then watchOS, visionOS, and macOS.

The product should feel like:

- `Inflow` for task breakdown and clean checklist interaction
- `Kin / calendar tools` for soft planning and temporal context
- `TimeBite` for execution truth through a reverse-pomodoro torus ring

## Product shape

TimeBite should have three primary views on iPhone:

1. `Dashboard`
2. `Plan`
3. `Focus Timer`

That is enough for the hackathon and keeps the architecture coherent.

## Bottom navigation

Recommended tab bar:

- `Dashboard`
- `Plan`
- `Timer`

This matches your instinct that the timer should live as a persistent bottom-menu destination, not be buried.

## View 1: Dashboard

This is the main menu and data-viz entry point.

### Job to be done

Answer these three questions immediately:

- What matters today?
- What lane is moving?
- What should I start next?

### Layout

Top section:

- greeting or day label
- date
- compact cycle score or summary

Middle section:

- three lane cards: `App`, `Income`, `Brand`
- each card shows:
  - mini ring
  - primary task title
  - progress text like `45 / 180 min`
  - state chip like `Ready`, `Active`, `Done`

Bottom section:

- one-tap resume button for active timer
- optional mini timeline or today's sessions

### Visual direction

Compared with the Inflow references, this view should be more atmospheric and less form-like:

- warm off-white or soft cream background
- torus/ring colors by lane
- rounded cards with quiet shadows
- avoid a dense productivity-dashboard look

### Interaction

- tap a lane card opens `Plan` filtered to that lane
- tap active task opens `Focus Timer`
- long-press could mark a task done later, but not needed for MVP

## View 2: Plan

This is the task creation and task-list view inspired by Inflow.

### Job to be done

Let the user:

- create the day's main task
- break it into subtasks
- assign a date/time if needed
- keep the queue small and intentional

### Layout

Header:

- large task or lane title
- subtask count
- optional trash/edit actions

Primary content:

- clean checklist of subtasks
- checkbox on the left
- delete or remove affordance on the right
- `+ Add subtask` pill

Scheduling section:

- date row
- time row
- repeat row if needed

Primary CTA:

- `Add task`
- or `Save plan`

### Important adaptation for TimeBite

Unlike Inflow, this should work at two levels:

1. `Lane-level daily planning`
2. `Task-level breakdown`

That means this screen should support two modes:

- `Daily lane mode`
  - one primary task for App, Income, or Brand
  - up to three queued tasks under it
- `Task breakdown mode`
  - one task expanded into subtasks

### Why this matters

Your product is not just task capture. It is task capture in service of timer-based execution.

So this screen should always keep `planned minutes` visible or editable.

## View 3: Calendar

This is the planning view inspired by the calendar references and `IMG_1417`.

### Job to be done

Provide temporal context without becoming a full calendar app.

### Layout

Top:

- month or week toggle
- date selector

Center:

- soft calendar grid
- selected day highlight
- lane-colored dots or blocks for planned work

Lower panel:

- selected day summary
- tasks grouped by `App`, `Income`, `Brand`

### Product stance

This is not meant to compete with Fantastical or Google Calendar.

It should answer:

- what day is this planned for?
- what lane owns today?
- where are the gaps?

### Recommended MVP scope

- month view only, or week strip plus agenda
- selecting a day updates the day's lane list below

## View 4: Focus Timer

This is the execution screen and the emotional center of the product.

### Job to be done

Make doing the work feel singular, calm, and embodied.

### Core concept

Use a reverse pomodoro ring:

- ring starts full
- ring depletes as time is spent
- session writes back into `actual_minutes`
- completing the session updates the lane and dashboard

### Layout

Top:

- current lane label
- current task title
- optional subtask title

Center:

- large torus ring
- remaining minutes in the center
- subtle lane color glow

Bottom:

- `Start`
- `Pause`
- `Complete`
- optional quick note or "what happened?" field

### State model

The timer should reflect:

- `idle`
- `running`
- `paused`
- `session complete`

### Required write-back

When a session ends, the app should update:

- `session_log`
- `task_item.actual_minutes`
- `focus_lane.actual_minutes`
- `day_plan.active_task_id`

## Recommended iPhone information architecture

```text
TabView
├── Dashboard
├── Plan
│   ├── Daily lane planner
│   └── Task breakdown editor
└── Timer
    └── Focus Timer
```

## watchOS adaptation

watchOS should not mirror the full iPhone app.

It should be the execution companion.

### watchOS screens

1. `Now`
2. `Choose Task`
3. `Complete`

### watchOS Now

- active task title
- compact ring
- start or pause

### watchOS Choose Task

- one row each for App, Income, Brand primary tasks
- tap to start

### watchOS Complete

- mark done
- add a tiny reflection later on phone

For watchOS, the bottom navigation idea should reduce to one timer-first root plus a lightweight chooser sheet.

## visionOS adaptation

visionOS should emphasize spatial context rather than form entry.

### Best role for visionOS

- dashboard plus timer
- immersive torus
- lightweight lane selection

### Less suitable for visionOS

- deep task editing
- dense subtasks and forms

So on visionOS:

- `Dashboard` and `Focus Timer` should be primary
- `Plan` can be simplified or delegated to iPhone and macOS

## macOS adaptation

macOS is best for planning depth.

### Best roles

- backlog grooming
- queue ordering
- calendar overview
- session history

### Suggested structure

- sidebar with lanes and dates
- center list for tasks
- right panel for timer details and notes

## Recommended build order

1. `Dashboard`
2. `Focus Timer`
3. `Plan`
4. `Calendar`

This order matches the hackathon goal:

- first show the concept
- then prove the timer loop
- then add planning and scheduling

## SwiftUI file map

If you scaffold this in Xcode, the first-pass file structure should look like:

```text
Features/
  dashboard/
    DashboardView.swift
    LaneCardView.swift
    DailySummaryHeader.swift
  planner/
    PlanView.swift
    TaskEditorView.swift
    SubtaskRowView.swift
    ScheduleFieldsView.swift
  calendar/
    CalendarPlanView.swift
    DayAgendaView.swift
  timer/
    FocusTimerView.swift
    TorusRingView.swift
    TimerControlsView.swift
```

## Design rules

- Keep the number of visible items small
- Prefer one primary task per lane
- Let planning feel soft, not enterprise
- Let timer mode feel sacred and immersive
- Use the torus as the brand object, not as decoration only
