import Foundation
import SwiftData

@Model
final class Milestone {
    @Attribute(.unique) var id: UUID
    var goalId: UUID
    var title: String
    var dueDate: Date
    var status: String
    var notes: String

    init(
        id: UUID = UUID(),
        goalId: UUID,
        title: String,
        dueDate: Date = .now,
        status: String = "Not Started",
        notes: String = ""
    ) {
        self.id = id
        self.goalId = goalId
        self.title = title
        self.dueDate = dueDate
        self.status = status
        self.notes = notes
    }
}

