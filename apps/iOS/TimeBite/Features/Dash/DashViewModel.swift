import Foundation

@MainActor
final class DashViewModel: ObservableObject {
    @Published var selectedRange: TimeRange = .week

    let kpis: [KPIStat]
    let weekPoints: [FocusHourPoint]
    let monthPoints: [FocusHourPoint]
    let categoryShares: [CategoryShare]
    let goalProgress: [GoalProgressSnapshot]
    let insights: [InsightCardModel]

    init(
        kpis: [KPIStat],
        weekPoints: [FocusHourPoint],
        monthPoints: [FocusHourPoint],
        categoryShares: [CategoryShare],
        goalProgress: [GoalProgressSnapshot],
        insights: [InsightCardModel]
    ) {
        self.kpis = kpis
        self.weekPoints = weekPoints
        self.monthPoints = monthPoints
        self.categoryShares = categoryShares
        self.goalProgress = goalProgress
        self.insights = insights
    }

    static func mock() -> DashViewModel {
        DashViewModel(
            kpis: MockAnalyticsData.kpis,
            weekPoints: MockAnalyticsData.weekPoints,
            monthPoints: MockAnalyticsData.monthPoints,
            categoryShares: MockAnalyticsData.categoryShares,
            goalProgress: MockAnalyticsData.goalSnapshots,
            insights: MockAnalyticsData.insights
        )
    }

    var currentSeries: [FocusHourPoint] {
        switch selectedRange {
        case .week: return weekPoints
        case .month: return monthPoints
        case .quarter: return [
            .init(label: "Jan", minutes: 164),
            .init(label: "Feb", minutes: 182),
            .init(label: "Mar", minutes: 206)
        ]
        }
    }
}

