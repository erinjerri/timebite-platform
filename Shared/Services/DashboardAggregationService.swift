import Foundation

struct DashboardAggregationService {
    func makeMetrics(from summaries: [DailyActivitySummary]) -> DashboardMetrics {
        DashboardMetrics(
            activeStreakDays: summaries.filter { $0.totalProgress.normalizedProgress > 0.5 }.count,
            weeklyCompletions: summaries.reduce(0) { $0 + $1.totalProgress.rawCompletionCount },
            monthlyCompletions: summaries.reduce(0) { $0 + $1.totalProgress.rawCompletionCount },
            nextMilestoneTitle: nil
        )
    }
}
