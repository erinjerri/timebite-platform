import SwiftUI
import SwiftData

@main
struct TimeBiteApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [
            Goal.self,
            Milestone.self,
            GoalProgressEntry.self,
            AgentSession.self,
            AIWorkSummary.self,
            GoalImpact.self,
            DailyAIReflection.self
        ])
    }
}
