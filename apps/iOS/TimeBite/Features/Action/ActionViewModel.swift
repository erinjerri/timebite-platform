import Foundation

@MainActor
final class ActionViewModel: ObservableObject {
    @Published var actionTitle: String
    @Published var actionCategory: CategoryType
    @Published var streakDays: Int
    @Published var remainingMinutes: Int
    @Published var targetMinutes: Int
    @Published var subActions: [SubAction]

    init(
        actionTitle: String,
        actionCategory: CategoryType,
        streakDays: Int,
        remainingMinutes: Int,
        targetMinutes: Int,
        subActions: [SubAction]
    ) {
        self.actionTitle = actionTitle
        self.actionCategory = actionCategory
        self.streakDays = streakDays
        self.remainingMinutes = remainingMinutes
        self.targetMinutes = targetMinutes
        self.subActions = subActions
    }

    static func mock() -> ActionViewModel {
        ActionViewModel(
            actionTitle: MockActionData.action.title,
            actionCategory: MockActionData.action.category,
            streakDays: MockActionData.streakDays,
            remainingMinutes: max(MockActionData.action.targetMinutes - MockActionData.action.elapsedMinutes, 0),
            targetMinutes: MockActionData.action.targetMinutes,
            subActions: MockActionData.subActions
        )
    }

    var completedSubActions: Int {
        subActions.filter(\.isDone).count
    }

    var progress: Double {
        let elapsed = targetMinutes - remainingMinutes
        guard targetMinutes > 0 else { return 0 }
        return min(Double(elapsed) / Double(targetMinutes), 1)
    }

    var progressText: String {
        "\(max(targetMinutes - remainingMinutes, 0)) / \(targetMinutes) min"
    }

    var countdownText: String {
        let minutes = max(remainingMinutes, 0)
        return "\(minutes)m left"
    }

    func toggleSubAction(_ subAction: SubAction) {
        guard let index = subActions.firstIndex(where: { $0.id == subAction.id }) else { return }
        subActions[index].isDone.toggle()
    }

    func skipFiveMinutes() {
        remainingMinutes = max(remainingMinutes - 5, 0)
    }

    func addFiveMinutes() {
        remainingMinutes += 5
    }

    func resetTimer() {
        remainingMinutes = targetMinutes
    }
}

