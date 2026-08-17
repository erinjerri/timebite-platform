# Cross-Platform Vertical Slice — Handoff

Branch: `claude/cross-platform-vertical-slice` (branched from `codex/merge-actions-activity-rings` @ `628c88f`)

Goal: one Actions → Activity Rings → Daily Summary vertical slice across iOS, macOS, watchOS, visionOS.

## Done

**`12d2be8`** — Imported the previously-uncommitted `Shared/` + `apps/macOS/` scaffold and
`docs/macos-consolidation-phase-2.md` verbatim from the primary checkout, as a protective
baseline commit before any edits. (That work existed only on disk, untracked, and was at risk.)

**`56ec9b3`** — Reconciled the shared Activity Ring foundation against the canonical
`timebite-macos` implementation, per `timebite-macos/docs/ACTIVITY_RING_ARCHITECTURE.md`:

| File | What changed |
| --- | --- |
| `Shared/Presentation/TimeBitePalette.swift` | Restored adaptive light/dark token functions (the scaffold copy was dark-only, non-adaptive). Added `amRingColor` / `pmRingColor` / `totalRingColor` so the same ring means the same thing on every platform. |
| `Shared/Presentation/TimeBiteTypography.swift` | Kept the macOS semantic API shape; uses system rounded fonts rather than bundled League Spartan (deliberate scoping decision, documented in-file). |
| `Shared/Domain/ActivityProgressCalculator.swift` | Restored the raw-ratio-preserving `Output` struct; added `ringProgress(amCompleted:amPlanned:pmCompleted:pmPlanned:)` as the single place AM/PM/Total progress is computed. |
| `Shared/Models/DailyActivitySummary.swift` | Adopted macOS field set, extended with `amProgress` / `pmProgress` / `totalProgress`. |
| `Shared/Models/DailyReflectionSummary.swift`, `ActiveFocusSession.swift` | Adopted macOS canonical shapes. |
| `Shared/Presentation/ActivityRingView.swift` | Adopted the fuller macOS version (trim animation, label padding) as the one canonical ring renderer. |
| `Shared/DemoData/ActivityRingsDemoFixtures.swift` | New. Deterministic demo state: AM 2/3, PM 1/3, Total 3/6 — partial on all three rings. Kept out of production domain logic. |
| `Shared/Services/TrackingAggregationService.swift`, `apps/macOS/App/RootView.swift` | Fixed the two call sites the reconciliation broke. |

## Not done — remaining work

1. **Refactor `apps/iOS/TimeBite/Features/Action/ActionView.swift`** to consume `Shared/`.
2. **Add three `PBXNativeTarget`s** (macOS / watchOS / visionOS) to `apps/iOS/TimeBite.xcodeproj/project.pbxproj`.
3. **Build-verify all four targets**, update docs, produce the close-out report.

## Critical caveats for whoever continues

- **Nothing in `Shared/` has been compiled yet.** It is not a member of any Xcode target. The
  reconciliation is correct by inspection but **unproven by the compiler**. Adding the shared
  files to the existing iOS target is the fastest way to get real compile verification, and
  should be done before or alongside the iOS refactor.
- **`project.pbxproj` is the old explicit format** — no `PBXFileSystemSynchronizedRootGroup`.
  Every new file needs a `PBXFileReference` + `PBXBuildFile` + `PBXGroup` entry + a `Sources`
  build-phase line, or it silently will not compile. Run `plutil -lint` on the pbxproj after
  every edit.
- **Do not flatten iOS's half-day rings into a plain progress ring.** `HalfDayRingView` /
  `DailyActionSlice` draw *time-positioned arc segments* (`startFraction`,
  `plannedEndFraction`, `completedEndFraction`) showing *when* in the 12-hour window each
  action sits. That is genuinely richer than the macOS ring, not duplicated drawing. Share the
  **math and semantic colors**; keep the segmented rendering. The true duplicate worth removing
  is `ActionProgressRing` (a plain progress ring, same concept as the shared `ActivityRingView`).
- **iOS rings are minute-based** (`Double` planned/consumed minutes); the shared calculator is
  count-based (`Int`). Recommend adding a `Double` overload to `ActivityProgressCalculator`
  rather than rounding at the call site, so no precision is lost.
- **Consider `Packages/TimeBiteCore`** (a local SwiftPM package) for `Shared/` instead of adding
  the same file references to four separate targets. `docs/repository-architecture.md` names
  `TimeBiteCore` as the shared module for all four targets, so this follows the approved
  architecture rather than inventing one, and shrinks the pbxproj surface considerably.
  (`TimeBiteKit` is the superseded name for this module; ignore it where it still appears.)
- **iOS will eventually be rebuilt from the macOS implementation** rather than patched
  indefinitely — see `docs/repository-architecture.md`. That happens after the macOS migration,
  so the iOS refactor described here is still worth doing: it proves the shared layer compiles
  and keeps the current app working in the meantime.
- **`timebite-macos` was only ever read from, never written to.** It has its own uncommitted
  local changes; leave it alone.
- **This sandbox cannot launch a simulator app** (`simctl launch` hangs; the native simulator
  tool requires a full `/Applications/Xcode.app`, and only `Xcode-beta.app` is installed).
  `xcodebuild build` compile verification works fine and is unaffected. Screenshots and demo
  videos must be captured locally.

## Build commands

```bash
export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer
cd apps/iOS
xcodebuild -project TimeBite.xcodeproj -scheme TimeBite \
  -destination "id=F2F18F6C-04A1-49BB-8996-26B2DC5B8FA3" build   # iPhone 16 Pro, iOS 18.5 — verified working
```

macOS / watchOS / visionOS targets do not exist yet. Once added, verify with `-target <name>`
(not `-scheme`) to avoid also hand-authoring `.xcscheme` XML.
