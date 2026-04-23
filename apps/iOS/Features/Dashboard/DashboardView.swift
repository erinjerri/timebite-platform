import SwiftUI
import SwiftData

public struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Project.name, order: .forward) private var projects: [Project]
    @Query(sort: \SessionLog.startedAt, order: .reverse) private var sessions: [SessionLog]

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Section("Weekly Cap Usage") {
                    let summary = WeeklyCapUsage.summaryForCurrentWeek(projects: projects, sessions: sessions)

                    if summary.usages.isEmpty {
                        ContentUnavailableView(
                            "No weekly caps yet",
                            systemImage: "hourglass",
                            description: Text("Create a project and set a weekly cap to see planned vs actual hours.")
                        )
                    } else {
                        ForEach(summary.usages) { usage in
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(usage.projectName)
                                        .font(.headline)
                                    Text(usage.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text(usage.trailingText)
                                    .font(.subheadline)
                                    .foregroundStyle(usage.isOverCap ? .red : .primary)
                            }
                        }
                    }
                }

                Section("Insights") {
                    Text("Over‑Invested Projects")
                        .foregroundStyle(.secondary)
                    Text("Neglected Priorities")
                        .foregroundStyle(.secondary)
                    Text("Recovered Time")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Dashboard")
        }
    }
}

// MARK: - Minimal local aggregation helpers (placeholder)

struct WeeklyCapUsage {
    struct UsageRow: Identifiable {
        let id: UUID
        let projectName: String
        let subtitle: String
        let trailingText: String
        let isOverCap: Bool
    }

    struct Summary {
        let usages: [UsageRow]
    }

    static func summaryForCurrentWeek(projects: [Project], sessions: [SessionLog], calendar: Calendar = .current) -> Summary {
        guard let week = calendar.dateInterval(of: .weekOfYear, for: Date()) else {
            return Summary(usages: [])
        }

        let visibleProjects = projects.filter { project in
            switch project.state {
            case .paused, .archived:
                return false
            case .active, .deferred, .blocked:
                return true
            }
        }

        var minutesByProjectId: [UUID: Int] = [:]
        for session in sessions {
            guard week.contains(session.startedAt) else { continue }
            guard let project = session.effectiveProject else { continue }
            minutesByProjectId[project.id, default: 0] += session.durationMinutes
        }

        let rows: [UsageRow] = visibleProjects.map { project in
            let actual = minutesByProjectId[project.id, default: 0]
            let cap = project.weeklyCapMinutes
            let over = (cap != nil) ? (actual > cap!) : false

            let subtitle: String
            if let cap {
                subtitle = "\(actual) / \(cap) min"
            } else {
                subtitle = "\(actual) min"
            }

            let trailing: String
            if let cap {
                let remaining = cap - actual
                trailing = remaining >= 0 ? "\(remaining) min left" : "\(abs(remaining)) min over"
            } else {
                trailing = "No cap"
            }

            return UsageRow(
                id: project.id,
                projectName: project.name,
                subtitle: subtitle,
                trailingText: trailing,
                isOverCap: over
            )
        }

        return Summary(usages: rows)
    }
}

