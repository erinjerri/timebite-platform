import Foundation

/// Pure, deterministic conversion from raw activity counts into normalized ring
/// data. This is the single place progress is computed for Activity Rings —
/// platform views must not derive equivalent numbers independently.
///
/// See `docs/macos-consolidation-phase-2.md` for the full Activity Ring
/// architecture this implements.
struct ActivityProgressCalculator {
    struct Output: Sendable, Hashable {
        /// Progress clamped to 0...1, safe to feed directly to a ring view.
        var normalizedProgress: Double
        /// The unclamped completion ratio, preserved for downstream use
        /// (e.g. "10 of 8 planned" should still render a full ring while the
        /// underlying overcompletion is not lost).
        var rawCompletionRatio: Double
        /// Same as `normalizedProgress`; kept as a distinct, explicitly-named
        /// value so call sites are clear about which number is display-safe.
        var clampedProgress: Double
    }

    init() {}

    func calculate(completed: Int, planned: Int) -> Output {
        let safePlanned = max(planned, 0)
        let safeCompleted = max(completed, 0)

        let rawRatio: Double
        if safePlanned == 0 {
            rawRatio = safeCompleted > 0 ? 1 : 0
        } else {
            rawRatio = Double(safeCompleted) / Double(safePlanned)
        }

        let normalized = rawRatio.isFinite ? rawRatio : 0
        let clamped = min(max(normalized, 0), 1)

        return Output(
            normalizedProgress: clamped,
            rawCompletionRatio: normalized,
            clampedProgress: clamped
        )
    }

    /// Builds the AM, PM, and Total ring progress for a day from raw
    /// completed/planned action counts per half of day. Every platform feeds
    /// this the same raw counts and renders the same three resulting values.
    func ringProgress(
        amCompleted: Int,
        amPlanned: Int,
        pmCompleted: Int,
        pmPlanned: Int
    ) -> (am: ActivityRingProgress, pm: ActivityRingProgress, total: ActivityRingProgress) {
        let amOutput = calculate(completed: amCompleted, planned: amPlanned)
        let pmOutput = calculate(completed: pmCompleted, planned: pmPlanned)
        let totalOutput = calculate(
            completed: amCompleted + pmCompleted,
            planned: amPlanned + pmPlanned
        )

        let am = ActivityRingProgress(
            normalizedProgress: amOutput.clampedProgress,
            rawCompletionCount: amCompleted,
            plannedCount: amPlanned
        )
        let pm = ActivityRingProgress(
            normalizedProgress: pmOutput.clampedProgress,
            rawCompletionCount: pmCompleted,
            plannedCount: pmPlanned
        )
        let total = ActivityRingProgress(
            normalizedProgress: totalOutput.clampedProgress,
            rawCompletionCount: amCompleted + pmCompleted,
            plannedCount: amPlanned + pmPlanned
        )

        return (am, pm, total)
    }
}
