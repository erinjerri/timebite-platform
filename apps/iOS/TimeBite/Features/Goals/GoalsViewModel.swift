import Foundation

@MainActor
final class GoalsViewModel: ObservableObject {
    @Published var selectedFilter: CategoryType = .all
    @Published var goals: [GoalItem]
    @Published var expandedGoalIDs: Set<UUID> = []
    @Published var showNewGoalSheet: Bool = false
    @Published var newGoalTitle: String = ""
    @Published var newGoalSummary: String = ""
    @Published var newGoalCategory: CategoryType = .build

    init(goals: [GoalItem]) {
        self.goals = goals
    }

    static func mock() -> GoalsViewModel {
        GoalsViewModel(goals: MockGoalData.goals)
    }

    var filteredGoals: [GoalItem] {
        guard selectedFilter != .all else { return goals }
        return goals.filter { $0.category == selectedFilter }
    }

    func toggleExpansion(for goal: GoalItem) {
        if expandedGoalIDs.contains(goal.id) {
            expandedGoalIDs.remove(goal.id)
        } else {
            expandedGoalIDs.insert(goal.id)
        }
    }

    func isExpanded(_ goal: GoalItem) -> Bool {
        expandedGoalIDs.contains(goal.id)
    }

    func addGoal() {
        guard !newGoalTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let goal = GoalItem(
            title: newGoalTitle,
            phase: "Short-Term",
            summary: newGoalSummary.isEmpty ? "New local goal created in the MVP." : newGoalSummary,
            category: newGoalCategory,
            status: .active,
            progress: 0.12,
            targetDate: "TBD",
            badges: ["New"],
            checkpoints: ["Define next step"],
            details: ["Goal added from the local mock sheet."]
        )

        goals.insert(goal, at: 0)
        newGoalTitle = ""
        newGoalSummary = ""
        newGoalCategory = .build
        showNewGoalSheet = false
    }
}

