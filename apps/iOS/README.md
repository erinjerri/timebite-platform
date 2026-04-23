# TimeBite iOS MVP

This folder contains the SwiftUI iPhone-first MVP for TimeBite.

## What’s included

- 4-tab app shell in this order: `Action`, `Track`, `Goals`, `Dash`
- Local mock data only
- Dark-mode-first visual system
- MVVM-ish feature layout
- Swift Charts-based analytics
- iPhone-oriented onboarding-free experience

## Simulator target

- Recommended: `iPhone 16 Pro`
- Minimum deployment target: `iOS 17.0`

## Open and run

1. Open `apps/iOS/TimeBite.xcodeproj` in Xcode.
2. Select the shared `TimeBite` scheme.
3. Choose an iPhone simulator.
4. Build and run.

## Feature summary

### Action

- Large hero activity ring
- Editable action title
- Timer controls
- Three micro-subtasks
- Streak badge

### Track

- Segmented `Daily | Weekly | Monthly` switcher
- Built-out daily timeline
- Believable weekly and monthly mock visuals
- Local add-habit sheet

### Goals

- GROW-inspired header
- Category filter pills
- Vertical goal cards
- Progress bars and badges
- Expand/collapse goal details

### Dash

- Three KPI cards
- One chart built with Swift Charts
- One donut/category chart
- Compact goal progress rows
- Mock insight cards

## Design tokens

- Background: `#0A0D1A`
- Surface: `#111827`
- Primary accent: `#00E5C4`
- Secondary accent: `#A855F7`
- Gold: `#F4B942`
- Text primary: `#F9FAFB`
- Text secondary: `#6B7280`

## Icon suggestion

Use a simple dark app icon with a centered neon ring and a small TimeBite wordmark or bite-mark notch. A good placeholder is:

- Deep navy background
- One glowing teal ring
- Small purple highlight arc
- No detailed illustration

This keeps the icon aligned with the portfolio-grade, modern, dark-first UI language.

