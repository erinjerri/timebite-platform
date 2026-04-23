# PRD: Project States

## Summary

Projects (buckets) let users manage multiple concurrent initiatives with explicit weekly caps and outcomes. Project state enables realistic planning: projects can pause/resume without deleting tasks.

## User story
As a user, I want to pause or resume a project so that I can stop allocating time to it without losing context or history.

## Projects can be
- Active
- Paused
- Deferred
- Blocked
- Archived

## Functional requirements
- Create a project with:
  - name
  - optional outcome statement (measurable goal)
  - weekly cap (see Time Allocation Engine)
  - state
- Change project state at any time without deleting tasks.
- State effects:
  - **Active:** included in planning and dashboards
  - **Paused:** excluded from caps and default views; tasks remain available if explicitly searched/selected
  - **Deferred:** excluded from “this week” planning, but visible as planned-later
  - **Blocked:** visible with a blocker note (optional), excluded from “recommended now”
  - **Archived:** read-only; excluded from planning, included in history
- Tasks inherit project state behavior in default views:
  - tasks in paused/deferred/archived projects do not show up as “recommended” by default

## Nonfunctional requirements
- State changes are instant and local-first.
- State transitions are reversible (except archived is “hard to accidentally do”; require confirmation later).

## Acceptance criteria
- Changing a project to **Paused** removes it from:
  - weekly cap usage summaries
  - “over cap” alerts
  - default dashboard lists
- No tasks are deleted when state changes.
- Archived projects remain visible in history views but not editable.

## Success metrics
- Reduced “over cap” variance after pausing low-value projects.
- Increased weekly planning completion rate.

## Edge cases
- A task is actively running when its project is paused:
  - allow session to finish; future recommendations exclude the project
- Project state changed mid-week:
  - historical actual time remains; inclusion rules apply from the moment of change (or define as “state is evaluated at render time” for MVP)
- Project deleted (future):
  - prefer archive over delete to preserve truth

## Dependencies
- Project entity in the data model (when implemented)
- Time Allocation Engine dashboards/alerts (`product/prd-time-allocation-engine.md`)
- UI affordances in Plan/Dashboard

