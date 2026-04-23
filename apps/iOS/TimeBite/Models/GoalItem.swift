import Foundation

struct GoalItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var phase: String
    var summary: String
    var category: CategoryType
    var status: GoalStatus
    var progress: Double
    var targetDate: String
    var badges: [String]
    var checkpoints: [String]
    var details: [String]

    init(
        id: UUID = UUID(),
        title: String,
        phase: String,
        summary: String,
        category: CategoryType,
        status: GoalStatus,
        progress: Double,
        targetDate: String,
        badges: [String],
        checkpoints: [String],
        details: [String]
    ) {
        self.id = id
        self.title = title
        self.phase = phase
        self.summary = summary
        self.category = category
        self.status = status
        self.progress = progress
        self.targetDate = targetDate
        self.badges = badges
        self.checkpoints = checkpoints
        self.details = details
    }
}

