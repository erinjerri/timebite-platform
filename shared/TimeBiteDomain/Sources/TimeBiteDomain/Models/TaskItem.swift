import Foundation
import SwiftData

@Model
public final class TaskItem {
    @Attribute(.unique)
    public var id: UUID

    public var title: String
    public var summary: String?

    public var lane: Lane
    public var plannedMinutes: Int

    public var createdAt: Date
    public var updatedAt: Date

    @Relationship(deleteRule: .nullify, inverse: \ProjectBucket.tasks)
    public var project: ProjectBucket?

    @Relationship(deleteRule: .cascade, inverse: \SessionLog.task)
    public var sessions: [SessionLog]

    public init(
        id: UUID = UUID(),
        title: String,
        lane: Lane,
        plannedMinutes: Int,
        summary: String? = nil,
        project: ProjectBucket? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.lane = lane
        self.plannedMinutes = plannedMinutes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.project = project
        self.sessions = []
    }
}

