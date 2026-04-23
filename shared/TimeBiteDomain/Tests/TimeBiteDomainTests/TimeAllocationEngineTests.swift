import XCTest
@testable import TimeBiteDomain

final class TimeAllocationEngineTests: XCTestCase {
    func testWeeklyCapsDashboardHidesPausedAndArchivedProjects() {
        let now = Date()

        let active = ProjectBucket(name: "Active", type: .app, state: .active, weeklyCapMinutes: 60)
        let paused = ProjectBucket(name: "Paused", type: .app, state: .paused, weeklyCapMinutes: 60)
        let archived = ProjectBucket(name: "Archived", type: .app, state: .archived, weeklyCapMinutes: 60)

        let s1 = SessionLog(startedAt: now, durationSeconds: 30 * 60, project: active)
        let s2 = SessionLog(startedAt: now, durationSeconds: 30 * 60, project: paused)

        let dashboard = TimeAllocationEngine.weeklyCapsDashboard(
            asOf: now,
            projects: [active, paused, archived],
            sessions: [s1, s2]
        )

        XCTAssertNotNil(dashboard)
        XCTAssertEqual(dashboard?.usages.map(\.name), ["Active"])
        XCTAssertEqual(dashboard?.usages.first?.actualMinutes, 30)
    }

    func testWeeklyCapsDashboardFlagsOverCap() {
        let now = Date()

        let project = ProjectBucket(name: "P", type: .brand, state: .active, weeklyCapMinutes: 60)
        let s1 = SessionLog(startedAt: now, durationSeconds: 70 * 60, project: project)

        let dashboard = TimeAllocationEngine.weeklyCapsDashboard(
            asOf: now,
            projects: [project],
            sessions: [s1]
        )

        XCTAssertEqual(dashboard?.usages.count, 1)
        XCTAssertEqual(dashboard?.usages.first?.isOverCap, true)
        XCTAssertEqual(dashboard?.usages.first?.varianceMinutes, 10)
    }
}

