# spatial-dash.md

`spatial-dash.md` describes dashboard-specific layout and behavior for TimeBite surfaces. It can sit beside a broader environment config and tell the renderer how each panel should express the active environment.

## Dashboard Schema

```yaml
dashboard:
  layout: three_panel
  density: dense
  preserve_torus_geometry: true
  panels:
    left:
      type: data_viz
      emphasis: productivity_rhythm
    center:
      type: torus_timer
      emphasis: active_cycle
    right:
      type: ambient
      emphasis: music_placeholder
```

## Panel Layout Rules

- The active timer remains the visual anchor.
- Data visualization can become denser in operator environments.
- Ambient and music panels should soften in flow environments.
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
      type: data_viz
      title: Rhythm
      metrics:
        - focus_minutes
        - cycle_count
        - goal_progress
    center:
      type: torus_timer
      title: Active Timer
      preserve_geometry: true
    right:
      type: ambient
      title: Ambient
      controls:
        - play_pause
        - focus_mix
```

## Surface Expression

The same `SpatialEnvironment` can express itself differently per tab:

- Actions: prioritize current timer and daily action items.
- Goals: prioritize focus areas and weekly targets.
- Track: prioritize cycle history, logs, telemetry, and progress visualization.
- Dashboard: prioritize summary metrics and spatial balance.

For TimeBite, the dashboard should feel like a command view in Operator, a calm overview in Light, and a reflective studio in Dark.

## Generative Spatial Dashboard Layer

The spatial dashboard is not a freeform AI-generated interface. It is a structured visualization system.

The data model remains canonical:
- DailyPlan
- FocusLane
- CycleLog
- Reflection

GenAI may transform:
- layout emphasis
- annotations
- summaries
- view presets
- prioritization

GenAI may NOT transform:
- raw task data
- logged time
- completion status
- reflection records

The AI layer outputs a constrained `SpatialDashboardLayout` object that maps existing data into visual grammar.

This preserves trust, auditability, and repeatable visualization while allowing the dashboard to feel adaptive.
