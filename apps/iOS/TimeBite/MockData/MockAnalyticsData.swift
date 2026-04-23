import Foundation

enum TimeRange: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case quarter = "Quarter"

    var id: String { rawValue }
}

struct KPIStat: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var value: String
    var subtitle: String
    var symbol: String
    var tint: CategoryType
}

struct FocusHourPoint: Identifiable, Hashable {
    let id = UUID()
    var label: String
    var minutes: Double
}

struct CategoryShare: Identifiable, Hashable {
    let id = UUID()
    var category: CategoryType
    var value: Double
}

struct GoalProgressSnapshot: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var progress: Double
    var status: GoalStatus
}

struct InsightCardModel: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var body: String
    var symbol: String
    var accent: CategoryType
}

enum MockAnalyticsData {
    static let weekPoints: [FocusHourPoint] = [
        .init(label: "Mon", minutes: 62),
        .init(label: "Tue", minutes: 74),
        .init(label: "Wed", minutes: 69),
        .init(label: "Thu", minutes: 91),
        .init(label: "Fri", minutes: 83),
        .init(label: "Sat", minutes: 48),
        .init(label: "Sun", minutes: 36)
    ]

    static let monthPoints: [FocusHourPoint] = [
        .init(label: "W1", minutes: 41),
        .init(label: "W2", minutes: 55),
        .init(label: "W3", minutes: 73),
        .init(label: "W4", minutes: 89)
    ]

    static let categoryShares: [CategoryShare] = [
        .init(category: .build, value: 42),
        .init(category: .growth, value: 21),
        .init(category: .health, value: 16),
        .init(category: .admin, value: 11),
        .init(category: .creative, value: 10)
    ]

    static let kpis: [KPIStat] = [
        .init(title: "Focus Time", value: "7h 42m", subtitle: "+18% vs last week", symbol: "clock.fill", tint: .build),
        .init(title: "Completion", value: "84%", subtitle: "Goals on track", symbol: "checkmark.circle.fill", tint: .growth),
        .init(title: "Streak", value: "12 days", subtitle: "Best in 30 days", symbol: "flame.fill", tint: .health)
    ]

    static let goalSnapshots: [GoalProgressSnapshot] = [
        .init(title: "TimeBite MVP", progress: 0.76, status: .active),
        .init(title: "Consistency", progress: 0.58, status: .onTrack),
        .init(title: "Recovery", progress: 0.34, status: .atRisk)
    ]

    static let insights: [InsightCardModel] = [
        .init(
            title: "Best focus block is mid-morning",
            body: "You consistently hit your strongest sessions between 9:30 and 11:30. Front-load heavy design work there.",
            symbol: "sun.max.fill",
            accent: .build
        ),
        .init(
            title: "Creative work needs a protected slot",
            body: "Creative entries are present but short. Reserve one longer block before the day starts fragmenting.",
            symbol: "wand.and.stars",
            accent: .creative
        )
    ]
}

