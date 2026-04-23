import Foundation
import SwiftData

@Model
public final class SessionLog {
    @Attribute(.unique)
    public var id: UUID

    public var startedAt: Date
    public var endedAt: Date?
    public var durationSeconds: Int
    public var notes: String?

    @Relationship(deleteRule: .nullify, inverse: \TaskItem.sessions)
    public var task: TaskItem?

    @Relationship(deleteRule: .nullify, inverse: \ProjectBucket.sessions)
    public var project: ProjectBucket?

    public init(
        id: UUID = UUID(),
        startedAt: Date,
        endedAt: Date? = nil,
        durationSeconds: Int,
        notes: String? = nil,
        task: TaskItem? = nil,
        project: ProjectBucket? = nil
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.durationSeconds = durationSeconds
        self.notes = notes
        self.task = task
        self.project = project ?? task?.project
    }

    public var durationMinutes: Int {
        max(0, Int(round(Double(durationSeconds) / 60.0)))
    }

    public var effectiveProject: ProjectBucket? {
        project ?? task?.project
    }
}

