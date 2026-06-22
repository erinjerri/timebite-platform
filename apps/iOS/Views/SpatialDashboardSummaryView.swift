import SwiftData
import SwiftUI

struct SpatialDashboardSummaryView: View {
    @Query(sort: \DailyPlan.createdAt, order: .reverse) private var plans: [DailyPlan]
    @Query private var lanes: [FocusLane]
    @Query(sort: \CycleLog.startTime, order: .reverse) private var cycleLogs: [CycleLog]
    @Query(sort: \Reflection.date, order: .reverse) private var reflections: [Reflection]

    var body: some View {
        let layout = SpatialDashboardMapper.map(
            dailyPlan: plans.first,
            lanes: lanes,
            cycleLogs: cycleLogs,
            reflection: reflections.first
        )

        List {
            Section("Derived Layout") {
                Text("\(Int(layout.visualState.overallPercentComplete * 100))% complete")
                Text("\(layout.visualState.totalLoggedMinutes) / \(layout.visualState.totalTargetMinutes) minutes")
            }

            Section("Segments") {
                ForEach(layout.ringSegments) { segment in
                    HStack {
                        LaneBadge(laneType: segment.laneType)
                        Spacer()
                        Text("\(Int(segment.percentComplete * 100))%")
                            .font(.subheadline.monospacedDigit())
                    }
                }
            }
        }
    }
}
