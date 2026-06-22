import Foundation

struct DailyLog: Identifiable, Hashable {
    let id: UUID
    var dateLabel: String
    var totalMinutes: Int
    var focusMinutes: Int
    var note: String

    init(
        id: UUID = UUID(),
        dateLabel: String,
        totalMinutes: Int,
        focusMinutes: Int,
        note: String
    ) {
        self.id = id
        self.dateLabel = dateLabel
        self.totalMinutes = totalMinutes
        self.focusMinutes = focusMinutes
        self.note = note
    }
}

extension DailyLog {
    static let mock: [DailyLog] = [
        .init(dateLabel: "Mon", totalMinutes: 210, focusMinutes: 95, note: "Strong build session."),
        .init(dateLabel: "Tue", totalMinutes: 180, focusMinutes: 80, note: "Focused but lighter."),
        .init(dateLabel: "Wed", totalMinutes: 240, focusMinutes: 120, note: "Best day of the week."),
        .init(dateLabel: "Thu", totalMinutes: 195, focusMinutes: 88, note: "Steady execution."),
        .init(dateLabel: "Fri", totalMinutes: 225, focusMinutes: 104, note: "Solid finish."),
        .init(dateLabel: "Sat", totalMinutes: 140, focusMinutes: 55, note: "Recovery-friendly."),
        .init(dateLabel: "Sun", totalMinutes: 110, focusMinutes: 42, note: "Light planning reset.")
    ]
}

