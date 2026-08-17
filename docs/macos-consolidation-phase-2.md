# Phase 2 Migration Notes

This repository is being prepared to absorb the macOS implementation as the canonical Apple-platform workspace while keeping the current iOS code intact.

## What landed first

- shared models for ring/progress, sessions, tracking, planning, and summaries
- shared domain calculators and simple aggregation services
- shared presentation primitives for palette, typography, and activity rings
- a minimal macOS app shell scaffold under `apps/macOS`

## Why it is intentionally small

- the existing iOS target is still working and should not be broken by a large rewrite
- the macOS reference repo has richer navigation and shared architecture than the current repo
- the next step is to wire these shared primitives into real targets, not to force the entire UI over at once

## Next migration step

1. add a multi-target Xcode workspace or project structure
2. point the macOS target at `apps/macOS`
3. move the real macOS workspace views into `apps/macOS`
4. centralize shared logic under `Shared`
5. simplify the iOS shell around the shared models
