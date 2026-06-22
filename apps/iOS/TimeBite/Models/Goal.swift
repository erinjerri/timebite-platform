import Foundation
import SwiftData

@Model
final class Goal {
    @Attribute(.unique) var id: UUID
    var title: String
    var goalDescription: String
    var category: String
    var goalType: String
    var startDate: Date
    var dueDate: Date
    var progress: Double
    var status: String
    var considerations: String
    var blockers: String
    var resources: String
    var successCriteria: String
    var nextAction: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        category: String = "",
        goalType: String = "",
        startDate: Date = .now,
        dueDate: Date = .now,
        progress: Double = 0,
        status: String = "Not Started",
        considerations: String = "",
        blockers: String = "",
        resources: String = "",
        successCriteria: String = "",
        nextAction: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.goalDescription = description
        self.category = category
        self.goalType = goalType
        self.startDate = startDate
        self.dueDate = dueDate
        self.progress = progress
        self.status = status
        self.considerations = considerations
        self.blockers = blockers
        self.resources = resources
        self.successCriteria = successCriteria
        self.nextAction = nextAction
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
