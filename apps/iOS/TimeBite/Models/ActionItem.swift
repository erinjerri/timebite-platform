import Foundation

struct ActionItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var targetMinutes: Int
    var elapsedMinutes: Int
    var category: CategoryType
    var dateLabel: String

    init(
        id: UUID = UUID(),
        title: String,
        targetMinutes: Int,
        elapsedMinutes: Int,
        category: CategoryType,
        dateLabel: String
    ) {
        self.id = id
        self.title = title
        self.targetMinutes = targetMinutes
        self.elapsedMinutes = elapsedMinutes
        self.category = category
        self.dateLabel = dateLabel
    }

    var progress: Double {
        guard targetMinutes > 0 else { return 0 }
        return min(Double(elapsedMinutes) / Double(targetMinutes), 1)
    }
}

