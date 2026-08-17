# macOS Consolidation — Phase 2

Last updated: August 17, 2026.

`timebite-platform` is the monorepo for all four TimeBite Apple targets. This
document tracks the consolidation of the standalone `timebite-macos` repository
into it, and the rebuild of `apps/iOS` from that implementation.

See [`repository-architecture.md`](./repository-architecture.md) for the
authoritative naming rules and target structure, and
[`cross-platform-slice-handoff.md`](./cross-platform-slice-handoff.md) for the
detailed state of the in-progress vertical slice.

## The end state

| Piece | Where it lands |
| --- | --- |
| Shared domain, ring calculations, day-part logic, semantic tokens | `TimeBiteCore` (currently `Shared/`, becomes `Packages/TimeBiteCore`) |
| macOS app | `apps/macOS/` — migrated from `timebite-macos`, retaining its shell and views |
| iOS app | `apps/iOS/` — **rebuilt** from the macOS implementation on top of `TimeBiteCore` |
| watchOS app | `apps/watchOS/` — glance-first rings and summary |
| visionOS app | `apps/visionOS/` — conventional SwiftUI window |

`timebite-macos` remains its own GitHub repository until migration completes.
Its fate afterward — archive or retain — is an open decision.

## Why iOS gets rebuilt rather than patched

The existing `apps/iOS` app predates the macOS work and has diverged from it in
information architecture, visual direction, and domain modeling. Patching it
incrementally would mean maintaining two different products indefinitely.
Rebuilding it from the macOS implementation on top of `TimeBiteCore` produces one
product with two native presentations.

This does not mean copying macOS layouts onto a phone. Domain logic, semantic
tokens, and information architecture are shared; navigation, layout, and input
affordances stay native to each platform.

## What has landed

- Shared models for ring progress, sessions, tracking, planning, and summaries.
- Shared domain calculators and aggregation services, including
  `ActivityProgressCalculator` — the single place AM/PM/Total progress is computed.
- Shared presentation primitives: adaptive palette with Activity Ring semantic
  colors, typography, and one canonical `ActivityRingView`.
- Deterministic demo fixtures for the rings vertical slice.
- A minimal macOS app shell scaffold under `apps/macOS/`, to be superseded by the
  real macOS app during migration.

**Not yet compiled.** `Shared/` is not a member of any Xcode target, so this code
is correct by inspection but unverified by the compiler.

## Sequence

1. Add the `Shared/` vertical-slice files to the existing iOS target and get it
   compiling. This is the fastest proof the shared layer builds.
2. Refactor `apps/iOS/TimeBite/Features/Action/ActionView.swift` to consume the
   shared layer instead of duplicating ring math and drawing.
3. Add macOS, watchOS, and visionOS targets against the shared layer.
4. Migrate `timebite-macos` into `apps/macOS/`.
5. Formalize `Shared/` as `Packages/TimeBiteCore`.
6. Rebuild `apps/iOS` from the macOS implementation on top of `TimeBiteCore`.
7. Decide the fate of the standalone `timebite-macos` repository.

Steps 1–3 are the current vertical slice. Steps 4–6 are the migration proper.

## Known hazards

- **`Shared/` in the two repos is not the same.** The copies in
  `timebite-platform` were reconciled and extended (adaptive palette, AM/PM/Total
  ring semantics, system rounded fonts). Copying `timebite-macos/Shared/` over the
  top silently reverts that, and the result still compiles — the rings just lose
  their semantics. Merge additively.
- **`timebite-macos` has uncommitted work** — roughly 11 modified files plus an
  untracked `Views/CreatingYourReality/`. It must be committed there before
  migration or it is lost.
- **`project.pbxproj` uses the old explicit format.** Every file needs a
  `PBXFileReference`, `PBXBuildFile`, group entry, and `Sources` build-phase entry,
  or it silently will not compile. Run `plutil -lint` after each edit.
- **`TimeBiteKit` is a superseded name** for `TimeBiteCore`. Older docs and commit
  messages that use it predate the August 17 decision.

## Open decisions

- Preserve git history during migration (`git subtree` / `filter-repo`) or take a
  plain file copy with a single migration commit.
- Whether the `Creating Your Reality` space migrates now or is deferred.
- Whether to adopt the bundled League Spartan font (OFL license in
  `timebite-macos/LICENSES/`) across all platforms, or keep system rounded fonts.
- Whether macOS gets its own `.xcodeproj` or becomes a target in the existing
  `apps/iOS/TimeBite.xcodeproj`.
- Archive or retain the `timebite-macos` repository after migration.
