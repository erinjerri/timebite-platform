import Foundation
import SwiftData

@Model
final class GoalProgressEntry {
    @Attribute(.unique) var id: UUID
    var goalId: UUID
    var date: Date
    var progressValue: Double
    var note: String

    init(
        id: UUID = UUID(),
        goalId: UUID,
        date: Date = .now,
        progressValue: Double,
        note: String = ""
    ) {
        self.id = id
        self.goalId = goalId
        self.date = date
        self.progressValue = progressValue
        self.note = note
    }
}

