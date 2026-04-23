import Foundation
import SwiftData

@Model
public final class ProjectBucket {
    @Attribute(.unique)
    public var id: UUID

    public var name: String
    public var type: ProjectType
    public var state: ProjectState

    public var weeklyCapMinutes: Int?
    public var outcome: String?
    public var notes: String?

    public var createdAt: Date
    public var updatedAt: Date

    @Relationship(deleteRule: .nullify, inverse: \TaskItem.project)
    public var tasks: [TaskItem]

    @Relationship(deleteRule: .nullify, inverse: \SessionLog.project)
    public var sessions: [SessionLog]

    public init(
        id: UUID = UUID(),
        name: String,
        type: ProjectType,
        state: ProjectState = .active,
        weeklyCapMinutes: Int? = nil,
        outcome: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.state = state
        self.weeklyCapMinutes = weeklyCapMinutes
        self.outcome = outcome
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tasks = []
        self.sessions = []
    }
}
