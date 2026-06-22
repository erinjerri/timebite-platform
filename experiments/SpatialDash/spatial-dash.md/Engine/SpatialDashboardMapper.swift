import Foundation

struct DailyPlan: Identifiable, Codable, Equatable {
    let id: String
    let tasks: [DailyPlanTask]
}

struct DailyPlanTask: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let lane: TimeBiteLane
    let plannedMinutes: Int
    let isComplete: Bool
}

struct CycleLog: Identifiable, Codable, Equatable {
    let id: String
    let taskID: String?
    let lane: TimeBiteLane
    let minutes: Int
}

struct Reflection: Identifiable, Codable, Equatable {
    let id: String
    let lane: TimeBiteLane?
    let summary: String
}

enum SpatialDashboardMapper {
    static func map(
        dailyPlan: DailyPlan,
        cycleLogs: [CycleLog],
        reflections: [Reflection],
        generatedAt: Date = Date()
    ) -> SpatialDashboardLayout {
        let summaries = TimeBiteLane.allCases.map { lane in
            makeSummary(
                lane: lane,
                dailyPlan: dailyPlan,
                cycleLogs: cycleLogs,
                reflections: reflections
            )
        }

        let totalLoggedMinutes = max(1, summaries.reduce(0) { $0 + $1.loggedMinutes })
        let segments = summaries.map { summary in
            makeRingSegment(summary: summary, totalLoggedMinutes: totalLoggedMinutes)
        }

        return SpatialDashboardLayout(
            id: "layout-\(dailyPlan.id)",
            sourcePlanID: dailyPlan.id,
            generatedAt: generatedAt,
            layoutMode: .threeLaneRing,
            ringSegments: segments,
            laneSummaries: summaries,
            annotations: makeAnnotations(summaries: summaries, reflections: reflections)
        )
    }

    private static func makeSummary(
        lane: TimeBiteLane,
        dailyPlan: DailyPlan,
        cycleLogs: [CycleLog],
        reflections: [Reflection]
    ) -> SpatialLaneSummary {
        let tasks = dailyPlan.tasks.filter { $0.lane == lane }
        let completedTaskCount = tasks.filter(\.isComplete).count
        let loggedMinutes = cycleLogs
            .filter { $0.lane == lane }
            .reduce(0) { $0 + max(0, $1.minutes) }
        let reflectionCount = reflections.filter { $0.lane == lane }.count
        let plannedMinutes = tasks.reduce(0) { $0 + max(0, $1.plannedMinutes) }
        let completionRatio = tasks.isEmpty ? 0 : Double(completedTaskCount) / Double(tasks.count)
        let loggedRatio = plannedMinutes == 0 ? 0 : Double(loggedMinutes) / Double(plannedMinutes)

        return SpatialLaneSummary(
            lane: lane,
            plannedTaskCount: tasks.count,
            completedTaskCount: completedTaskCount,
            loggedMinutes: loggedMinutes,
            reflectionCount: reflectionCount,
            emphasis: emphasis(completionRatio: completionRatio, loggedRatio: loggedRatio)
        )
    }

    private static func makeRingSegment(
        summary: SpatialLaneSummary,
        totalLoggedMinutes: Int
    ) -> SpatialRingSegment {
        let percent = Double(summary.loggedMinutes) / Double(totalLoggedMinutes)
        let activityRatio = summary.plannedTaskCount == 0
            ? 0
            : Double(summary.completedTaskCount) / Double(summary.plannedTaskCount)

        return SpatialRingSegment(
            id: "ring-\(summary.lane.rawValue)",
            lane: summary.lane,
            percent: percent,
            opacity: 0.35 + (0.5 * activityRatio),
            elevation: elevation(for: summary.emphasis),
            glow: glow(for: summary.emphasis),
            annotation: annotation(for: summary)
        )
    }

    private static func makeAnnotations(
        summaries: [SpatialLaneSummary],
        reflections: [Reflection]
    ) -> [SpatialDashboardAnnotation] {
        let laneAnnotations = summaries.compactMap { summary -> SpatialDashboardAnnotation? in
            guard let text = annotation(for: summary) else { return nil }
            return SpatialDashboardAnnotation(
                id: "annotation-\(summary.lane.rawValue)",
                lane: summary.lane,
                text: text,
                priority: priority(for: summary.emphasis)
            )
        }

        let reflectionAnnotation = reflections.first { $0.lane == nil }.map {
            SpatialDashboardAnnotation(
                id: "annotation-reflection-\($0.id)",
                lane: nil,
                text: $0.summary,
                priority: 1
            )
        }

        return laneAnnotations + Array(reflectionAnnotation.map { [$0] } ?? [])
    }

    private static func emphasis(completionRatio: Double, loggedRatio: Double) -> SpatialLaneEmphasis {
        if completionRatio >= 0.67 || loggedRatio >= 0.75 {
            return .highlighted
        }

        if completionRatio > 0 || loggedRatio > 0 {
            return .active
        }

        return .quiet
    }

    private static func elevation(for emphasis: SpatialLaneEmphasis) -> Double {
        switch emphasis {
        case .quiet:
            return 0.18
        case .active:
            return 0.48
        case .highlighted:
            return 0.78
        }
    }

    private static func glow(for emphasis: SpatialLaneEmphasis) -> Double {
        switch emphasis {
        case .quiet:
            return 0.22
        case .active:
            return 0.55
        case .highlighted:
            return 0.9
        }
    }

    private static func priority(for emphasis: SpatialLaneEmphasis) -> Int {
        switch emphasis {
        case .quiet:
            return 0
        case .active:
            return 1
        case .highlighted:
            return 2
        }
    }

    private static func annotation(for summary: SpatialLaneSummary) -> String? {
        if summary.loggedMinutes == 0 && summary.plannedTaskCount == 0 {
            return nil
        }

        if summary.completedTaskCount == summary.plannedTaskCount && summary.plannedTaskCount > 0 {
            return "\(summary.lane.rawValue.capitalized) lane complete"
        }

        if summary.loggedMinutes > 0 {
            return "\(summary.loggedMinutes) min logged in \(summary.lane.rawValue.capitalized)"
        }

        return "\(summary.plannedTaskCount) planned in \(summary.lane.rawValue.capitalized)"
    }
}
