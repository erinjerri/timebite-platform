import Foundation

/// The shared domain object behind the Actions → Activity Rings → Daily Summary
/// loop. Every platform (iOS, macOS, watchOS, visionOS) renders from this same
/// summary rather than deriving equivalent progress independently.
struct DailyActivitySummary: Codable, Hashable, Sendable {
    var date: Date
    var plannedWork: Int
    var completedWork: Int
    var completedActions: Int
    var focusTime: TimeInterval
    /// Progress toward a linked Goal, if this day's activity is tied to one.
    /// Distinct from ring progress below.
    var goalLinkedProgress: Double
    var amProgress: ActivityRingProgress
    var pmProgress: ActivityRingProgress
    var totalProgress: ActivityRingProgress
    var reflectionSummary: DailyReflectionSummary
    var activeFocusSession: ActiveFocusSession?

    init(
        date: Date,
        plannedWork: Int,
        completedWork: Int,
        completedActions: Int,
        focusTime: TimeInterval,
        goalLinkedProgress: Double,
        amProgress: ActivityRingProgress,
        pmProgress: ActivityRingProgress,
        totalProgress: ActivityRingProgress,
        reflectionSummary: DailyReflectionSummary = .init(),
        activeFocusSession: ActiveFocusSession? = nil
    ) {
        self.date = date
        self.plannedWork = plannedWork
        self.completedWork = completedWork
        self.completedActions = completedActions
        self.focusTime = focusTime
        self.goalLinkedProgress = goalLinkedProgress
        self.amProgress = amProgress
        self.pmProgress = pmProgress
        self.totalProgress = totalProgress
        self.reflectionSummary = reflectionSummary
        self.activeFocusSession = activeFocusSession
    }
}
