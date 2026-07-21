# Schemas Changelog

## Goal Loop Pivot

- Replaced quarterly budget-first goal shape with a habit-centric Goal Loop shape.
- Added first-class fields for intent, frequency, sessions, completion history, reflections, current streak, longest streak, weekly summary, monthly summary, and tags.
- Repositioned analytics and quarterly rollups as derived/future projections rather than MVP source-of-truth data.

## Legacy Quarterly Goal Chart

- Previous quarterly target fields are deprecated for the MVP.
- Existing task-time and quarterly rollup schemas may remain temporarily for migration, but new product work should use the Goal Loop model.
