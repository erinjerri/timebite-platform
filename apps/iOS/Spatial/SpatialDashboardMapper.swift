import Foundation

enum SpatialDashboardMapper {
    static func map(
        dailyPlan: DailyPlan?,
        lanes: [FocusLane],
        cycleLogs: [CycleLog],
        reflection: Reflection?
    ) -> SpatialDashboardLayout {
        let activeLanes = laneInputs(dailyPlan: dailyPlan, lanes: lanes)
        let summaries = activeLanes.map { lane in
            let logs = cycleLogs.filter { $0.laneType == lane.type }
            let loggedMinutes = logs.reduce(0) { $0 + max(0, $1.durationMinutes) }
            return SpatialLaneSummary(
                laneType: lane.type,
                title: lane.title,
                targetMinutes: lane.targetMinutes,
                loggedMinutes: loggedMinutes,
                completedCycles: logs.filter(\.completed).count,
                reflectionStatus: reflectionStatus(for: lane.type, reflection: reflection)
            )
        }

        let segments = summaries.map(makeSegment(summary:))
        let totalTarget = max(0, summaries.reduce(0) { $0 + $1.targetMinutes })
        let totalLogged = max(0, summaries.reduce(0) { $0 + $1.loggedMinutes })
        let percent = totalTarget == 0 ? 0 : min(1, Double(totalLogged) / Double(totalTarget))

        return SpatialDashboardLayout(
            id: dailyPlan?.id ?? UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            date: dailyPlan?.date ?? Calendar.current.startOfDay(for: Date()),
            laneSummaries: summaries,
            ringSegments: segments,
            visualState: SpatialVisualState(
                totalTargetMinutes: totalTarget,
                totalLoggedMinutes: totalLogged,
                overallPercentComplete: percent,
                hasReflection: reflection != nil
            )
        )
    }

    private static func laneInputs(dailyPlan: DailyPlan?, lanes: [FocusLane]) -> [FocusLane] {
        if !lanes.isEmpty {
            return lanes.sorted { $0.type.rawValue < $1.type.rawValue }
        }

        guard let dailyPlan else {
            return [
                FocusLane(type: .app, title: "App", targetMinutes: 45),
                FocusLane(type: .income, title: "Income", targetMinutes: 45)
            ]
        }

        var derived = [
            FocusLane(type: .app, title: dailyPlan.appFocus, targetMinutes: 45),
            FocusLane(type: .income, title: dailyPlan.incomeFocus, targetMinutes: 45)
        ]

        if let brandFocus = dailyPlan.brandFocus {
            derived.append(FocusLane(type: .brand, title: brandFocus, targetMinutes: 30))
        }

        return derived
    }

    private static func makeSegment(summary: SpatialLaneSummary) -> SpatialRingSegment {
        let percent = summary.targetMinutes == 0
            ? 0
            : min(1, Double(summary.loggedMinutes) / Double(summary.targetMinutes))
        let remaining = max(0, summary.targetMinutes - summary.loggedMinutes)
        let activeWeight = percent > 0 ? 1.0 : 0.0

        return SpatialRingSegment(
            laneType: summary.laneType,
            percentComplete: percent,
            opacity: 0.28 + (0.54 * percent),
            glow: 0.18 + (0.68 * percent),
            elevation: 0.16 + (0.52 * activeWeight),
            remainingMinutes: remaining
        )
    }

    private static func reflectionStatus(
        for laneType: FocusLaneType,
        reflection: Reflection?
    ) -> ReflectionStatus? {
        guard let reflection else { return nil }

        switch laneType {
        case .app:
            return reflection.appResult
        case .income:
            return reflection.incomeResult
        case .brand:
            return reflection.brandResult
        }
    }
}
