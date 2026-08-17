import Foundation

/// Deterministic sample data for the Actions → Activity Rings → Daily Summary
/// vertical slice. Kept separate from production domain logic (`Shared/Models`,
/// `Shared/Domain`). Consumed by the macOS, watchOS, and visionOS entry points
/// — which have no persistence layer wired up yet — and by iOS SwiftUI previews.
/// iOS's real screen continues to source from its own local action store.
enum ActivityRingsDemoFixtures {
    struct DemoAction: Identifiable, Hashable {
        let id: UUID
        var title: String
        var minutes: Int
        var halfDay: HalfDay
        var isComplete: Bool
    }

    enum HalfDay: String, CaseIterable {
        case morning
        case evening

        var shortTitle: String { self == .morning ? "AM" : "PM" }
    }

    static let sampleDate: Date = {
        Calendar.current.date(from: DateComponents(year: 2026, month: 8, day: 16, hour: 9)) ?? Date()
    }()

    /// AM: 2 of 3 actions complete. PM: 1 of 3 complete.
    static let sampleActions: [DemoAction] = [
        .init(id: UUID(), title: "Draft investor update outline", minutes: 30, halfDay: .morning, isComplete: true),
        .init(id: UUID(), title: "Review pull requests", minutes: 20, halfDay: .morning, isComplete: true),
        .init(id: UUID(), title: "Team stand-up notes", minutes: 15, halfDay: .morning, isComplete: false),
        .init(id: UUID(), title: "Prep demo video script", minutes: 25, halfDay: .evening, isComplete: true),
        .init(id: UUID(), title: "Reply to design feedback", minutes: 20, halfDay: .evening, isComplete: false),
        .init(id: UUID(), title: "Plan tomorrow's priorities", minutes: 10, halfDay: .evening, isComplete: false)
    ]

    /// AM 2/3 (0.67), PM 1/3 (0.33), Total 3/6 (0.5) — deliberately partial on
    /// all three rings so every platform has something meaningful to show.
    static let summary: DailyActivitySummary = {
        let calculator = ActivityProgressCalculator()
        let ring = calculator.ringProgress(amCompleted: 2, amPlanned: 3, pmCompleted: 1, pmPlanned: 3)
        return DailyActivitySummary(
            date: sampleDate,
            plannedWork: 6,
            completedWork: 3,
            completedActions: 3,
            focusTime: 65 * 60,
            goalLinkedProgress: 0.42,
            amProgress: ring.am,
            pmProgress: ring.pm,
            totalProgress: ring.total,
            reflectionSummary: DailyReflectionSummary(
                amReflection: "Good focus before the 10am sync.",
                pmReflection: nil
            ),
            activeFocusSession: nil
        )
    }()
}
