import Foundation
import SwiftData

@MainActor
enum GoalPreviewData {
    static let sampleGoalId = UUID(uuidString: "3ED04DDD-77EB-4F49-A07A-A04E80F7821A")!

    static var modelContainer: ModelContainer {
        let schema = Schema([
            Goal.self,
            Milestone.self,
            GoalProgressEntry.self,
            AgentSession.self,
            AIWorkSummary.self,
            GoalImpact.self,
            DailyAIReflection.self
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: configuration)
        seed(into: container.mainContext)
        return container
    }

    static func seed(into modelContext: ModelContext) {
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -14, to: now) ?? now
        let dueDate = calendar.date(byAdding: .day, value: 42, to: now) ?? now

        let goal = Goal(
            id: sampleGoalId,
            title: "Launch TimeBite iPhone MVP",
            description: "Deliver the polished four-tab loop with local persistence ready for future planning surfaces.",
            category: "Build",
            goalType: "Short-Term",
            startDate: startDate,
            dueDate: dueDate,
            progress: 0.76,
            status: "Active",
            considerations: "Keep the app calm, tactile, and biased toward the next useful action.",
            blockers: "Avoid overbuilding planning UI before the core loop feels natural.",
            resources: "SwiftData, local mock data, product architecture notes.",
            successCriteria: "A goal can be created, reviewed, and completed from the Goals dashboard.",
            nextAction: "Connect goal cards to SwiftData-backed creation.",
            createdAt: startDate,
            updatedAt: now
        )

        modelContext.insert(goal)
        modelContext.insert(
            Milestone(
                goalId: goal.id,
                title: "Model persistence layer",
                dueDate: calendar.date(byAdding: .day, value: 3, to: now) ?? now,
                status: "Done",
                notes: "Goal, milestone, and progress entities are available for cards and timeline views."
            )
        )
        modelContext.insert(
            Milestone(
                goalId: goal.id,
                title: "Goal card prototype",
                dueDate: calendar.date(byAdding: .day, value: 14, to: now) ?? now,
                status: "Planned",
                notes: "Use stored progress and blockers without changing the tab structure."
            )
        )
        modelContext.insert(
            GoalProgressEntry(
                goalId: goal.id,
                date: calendar.date(byAdding: .day, value: -7, to: now) ?? now,
                progressValue: 0.58,
                note: "Core app shell feels stable."
            )
        )
        modelContext.insert(
            GoalProgressEntry(
                goalId: goal.id,
                date: now,
                progressValue: 0.76,
                note: "Persistence layer ready for future Gantt work."
            )
        )
        modelContext.insert(
            AgentSession(
                startTime: calendar.date(byAdding: .hour, value: -4, to: now) ?? now,
                endTime: calendar.date(byAdding: .minute, value: -165, to: now) ?? now,
                toolName: "Codex",
                repository: "timebite-platform",
                taskName: "Build Goals timeline",
                promptCount: 9,
                completionStatus: "Completed",
                estimatedTokens: 42000,
                estimatedCost: 1.68,
                interventionCount: 3,
                notes: "Human review focused the timeline around meaningful goal progress."
            )
        )
        modelContext.insert(
            GoalImpact(
                goalId: goal.id,
                goalProgressBefore: 0.58,
                goalProgressAfter: 0.76,
                timeSpent: 2.4 * 3600,
                aiAssisted: true,
                impactScore: 0.82
            )
        )
        modelContext.insert(
            DailyAIReflection(
                date: now,
                meaningfulProgressResponse: "AI helped turn rough product intent into a working goal timeline.",
                mostBenefitedTaskResponse: "SwiftUI iteration and compile feedback.",
                humanJudgmentResponse: "Deciding what belonged in Goals versus Admin.",
                automationCandidateResponse: "Collect agent sessions from local developer tooling."
            )
        )

        try? modelContext.save()
    }
}
