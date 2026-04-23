import Foundation

struct HabitEntry: Identifiable, Hashable {
    let id: UUID
    var title: String
    var durationMinutes: Int
    var completed: Bool
    var category: CategoryType
    var note: String

    init(
        id: UUID = UUID(),
        title: String,
        durationMinutes: Int,
        completed: Bool,
        category: CategoryType,
        note: String
    ) {
        self.id = id
        self.title = title
        self.durationMinutes = durationMinutes
        self.completed = completed
        self.category = category
        self.note = note
    }
}

