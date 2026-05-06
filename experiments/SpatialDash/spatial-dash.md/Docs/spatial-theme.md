# spatial-theme.md

`spatial-theme.md` is the user-facing configuration format for TimeBite spatial environments. It is meant to be editable by non-developers while still bounded enough to keep the product usable.

## Safe Editing Rules

- Change colors with hex values.
- Keep opacity between `0.70` and `1.0`.
- Keep motion duration between `0.15` and `0.60`.
- Use the known enum values for intent, mood, style, energy, density, and brightness.
- Do not remove Action, Track, Goals, or Dashboard.
- Keep `preserve_torus_geometry` enabled.

## Light Example

```yaml
spatial_environment:
  id: timebite-light
  name: TimeBite Light
  intent: focus
  mood: calm
  style: minimal
  energy: low
  density: balanced
  brightness: light
```

## Dark Example

```yaml
spatial_environment:
  id: timebite-dark
  name: TimeBite Dark
  intent: flow
  mood: ambient
  style: glass
  energy: medium
  density: balanced
  brightness: dim
```

## Blue Operator Example

```yaml
spatial_environment:
  id: timebite-blue-operator
  name: TimeBite Blue Operator
  intent: operator
  mood: analytical
  style: terminal
  energy: high
  density: dense
  brightness: dark

tokens:
  colors:
    background: "#06111F"
    surface: "#0B1E33"
    primaryText: "#EAF4FF"
    secondaryText: "#8FB3D9"
    accent: "#38BDF8"
    ringPrimary: "#0EA5E9"
    ringSecondary: "#1E3A8A"
```

## How Non-Developers Can Modify It

Start with one preset and make small changes:

- For a quieter workspace, lower density and energy.
- For more command-center contrast, use operator intent and analytical mood.
- For a softer evening dashboard, use flow intent, ambient mood, and dim brightness.
- For readability, adjust secondary text only after checking primary text contrast.

The engine should validate config before rendering. If a value is unknown or unsafe, it should fall back to the nearest supported token rather than applying the value directly.

