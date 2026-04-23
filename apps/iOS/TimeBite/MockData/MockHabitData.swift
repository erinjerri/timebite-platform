import Foundation

enum MockHabitData {
    static let dailyEntries: [HabitEntry] = [
        .init(title: "Deep work sprint", durationMinutes: 85, completed: true, category: .build, note: "UI shell and navigation"),
        .init(title: "Walk + reset", durationMinutes: 25, completed: true, category: .health, note: "Outside break between builds"),
        .init(title: "Inbox triage", durationMinutes: 18, completed: true, category: .admin, note: "Cleared the noisy stuff fast"),
        .init(title: "Reading block", durationMinutes: 30, completed: false, category: .growth, note: "Still on deck for tonight"),
        .init(title: "Sketch new ideas", durationMinutes: 20, completed: false, category: .creative, note: "Low-pressure creative time")
    ]

    static let weeklyHeatmapIntensity: [[Double]] = [
        [0.10, 0.20, 0.30, 0.55, 0.40, 0.72, 0.62],
        [0.12, 0.15, 0.25, 0.35, 0.52, 0.67, 0.58],
        [0.18, 0.22, 0.48, 0.61, 0.44, 0.70, 0.79],
        [0.24, 0.31, 0.42, 0.53, 0.39, 0.55, 0.66],
        [0.16, 0.28, 0.36, 0.49, 0.60, 0.77, 0.84],
        [0.09, 0.18, 0.27, 0.41, 0.35, 0.50, 0.60]
    ]

    static let weeklyFocusMinutes: [Int] = [46, 58, 71, 65, 82, 94, 78]
}

