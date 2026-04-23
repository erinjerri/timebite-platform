import Foundation

struct DailyLog: Identifiable, Hashable {
    let id: UUID
    var date: Date
    var totalMinutes: Int
    var focusMinutes: Int
    var categories: [CategoryType: Int]
    var note: String

    init(
        id: UUID = UUID(),
        date: Date,
        totalMinutes: Int,
        focusMinutes: Int,
        categories: [CategoryType: Int],
        note: String
    ) {
        self.id = id
        self.date = date
        self.totalMinutes = totalMinutes
        self.focusMinutes = focusMinutes
        self.categories = categories
        self.note = note
    }
}

