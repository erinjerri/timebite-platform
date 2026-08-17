import Foundation

struct DashboardMetrics: Codable, Hashable, Sendable {
    var activeStreakDays: Int
    var weeklyCompletions: Int
    var monthlyCompletions: Int
    var nextMilestoneTitle: String?
}
