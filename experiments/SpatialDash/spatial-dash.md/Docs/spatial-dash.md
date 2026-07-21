# spatial-dash.md

`spatial-dash.md` describes spatial layout and behavior for TimeBite ritual surfaces. It can sit beside a broader environment config and tell the renderer how each panel should express the active environment.

## Dashboard Schema

```yaml
dashboard:
  layout: three_panel
  density: dense
  preserve_torus_geometry: true
  panels:
    left:
      type: calendar
      emphasis: monthly_completion
    center:
      type: torus_timer
      emphasis: active_session
    right:
      type: reflection
      emphasis: lightweight_journal
```

## Panel Layout Rules

- The active timer remains the visual anchor.
- Calendar and summary panels can become slightly denser in operator environments.
- Reflection panels should soften in flow environments.
- Panel count should remain stable across environments.
- Motion should support state changes, not distract from work.
- Card radius, spacing, and shadow come from design tokens.

## TimeBite Dashboard Example

```yaml
dashboard:
  layout: three_panel
  density: balanced
  panels:
    left:
      type: calendar
      title: Month
      metrics:
        - completed_days
        - current_streak
        - reflection_count
    center:
      type: torus_timer
      title: Active Session
      preserve_geometry: true
    right:
      type: reflection
      title: Reflection
      controls:
        - add_note
        - save_reflection
```

## Surface Expression

The same `SpatialEnvironment` can express itself differently per tab:

- Today: prioritize daily intent, active session, and completion checkmarks.
- Goals: prioritize intent, frequency, streaks, tags, and recent sessions.
- Calendar: prioritize monthly completion and day detail.
- Dashboard: prioritize streaks, summaries, reflections, and light insights.

For TimeBite, the spatial surface should feel like a focused ritual in Operator, a calm overview in Light, and a reflective studio in Dark.

## Generative Spatial Dashboard Layer

The spatial dashboard is not a freeform AI-generated interface. It is a structured visualization system.

The data model remains canonical:
- Goal
- DailyIntent
- Session
- CompletionHistory
- Reflection

GenAI may transform:
- layout emphasis
- annotations
- summaries
- view presets
- prioritization

GenAI may NOT transform:
- raw goal data
- logged time
- completion status
- reflection records

The AI layer outputs a constrained `SpatialDashboardLayout` object that maps existing data into visual grammar.

This preserves trust, auditability, and repeatable visualization while allowing the dashboard to feel adaptive.
