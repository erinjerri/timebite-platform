import Foundation

public struct ProjectWeeklyUsage: Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let type: ProjectType
    public let state: ProjectState
    public let weeklyCapMinutes: Int?
    public let actualMinutes: Int

    public init(
        id: UUID,
        name: String,
        type: ProjectType,
        state: ProjectState,
        weeklyCapMinutes: Int?,
        actualMinutes: Int
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.state = state
        self.weeklyCapMinutes = weeklyCapMinutes
        self.actualMinutes = actualMinutes
    }

    public var plannedMinutes: Int? { weeklyCapMinutes }
    public var varianceMinutes: Int? {
        guard let weeklyCapMinutes else { return nil }
        return actualMinutes - weeklyCapMinutes
    }

    public var isOverCap: Bool {
        guard let weeklyCapMinutes else { return false }
        return actualMinutes > weeklyCapMinutes
    }
}

public struct WeeklyCapsDashboard: Sendable {
    public let week: DateInterval
    public let usages: [ProjectWeeklyUsage]

    public init(week: DateInterval, usages: [ProjectWeeklyUsage]) {
        self.week = week
        self.usages = usages
    }
}

public enum TimeAllocationEngine {
    /// Builds a weekly "planned(cap) vs actual" dashboard for projects.
    ///
    /// Default filtering:
    /// - hides paused and archived projects
    /// - includes active and deferred projects
    /// - session attribution uses `startedAt` within the week interval
    public static func weeklyCapsDashboard(
        asOf date: Date,
        projects: [ProjectBucket],
        sessions: [SessionLog],
        calendar: Calendar = .current
    ) -> WeeklyCapsDashboard? {
        guard let week = WeekBoundary.weekInterval(containing: date, calendar: calendar) else {
            return nil
        }

        let visibleProjects = projects.filter { project in
            switch project.state {
            case .paused, .archived:
                return false
            case .active, .deferred, .blocked:
                return true
            }
        }

        var actualMinutesByProjectId: [UUID: Int] = [:]
        actualMinutesByProjectId.reserveCapacity(visibleProjects.count)

        for session in sessions {
            guard week.contains(session.startedAt) else { continue }
            guard let projectId = session.effectiveProject?.id else { continue }
            actualMinutesByProjectId[projectId, default: 0] += session.durationMinutes
        }

        let usages = visibleProjects
            .map { project in
                ProjectWeeklyUsage(
                    id: project.id,
                    name: project.name,
                    type: project.type,
                    state: project.state,
                    weeklyCapMinutes: project.weeklyCapMinutes,
                    actualMinutes: actualMinutesByProjectId[project.id, default: 0]
                )
            }
            .sorted { lhs, rhs in
                if lhs.isOverCap != rhs.isOverCap { return lhs.isOverCap && !rhs.isOverCap }
                if lhs.type != rhs.type { return lhs.type.rawValue < rhs.type.rawValue }
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }

        return WeeklyCapsDashboard(week: week, usages: usages)
    }
}
