import Foundation

enum MockActionData {
    static let action = ActionItem(
        title: "Ship the TimeBite MVP",
        targetMinutes: 45,
        elapsedMinutes: 18,
        category: .build,
        dateLabel: "Today • 5 Jan 2026"
    )

    static let subActions: [SubAction] = [
        .init(title: "Tighten the hero ring layout", isDone: true, estimatedMinutes: 8),
        .init(title: "Polish timer controls and states", isDone: false, estimatedMinutes: 12),
        .init(title: "Add the last round of mock data", isDone: false, estimatedMinutes: 10)
    ]

    static let streakDays = 12
}

