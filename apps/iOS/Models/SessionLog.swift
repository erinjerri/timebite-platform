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

    @Relationship(deleteRule: .nullify, inverse: \Project.sessions)
    public var project: Project?

    public init(
        id: UUID = UUID(),
        startedAt: Date,
        endedAt: Date? = nil,
        durationSeconds: Int,
        notes: String? = nil,
        project: Project? = nil
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.durationSeconds = durationSeconds
        self.notes = notes
        self.project = project
    }

    public var durationMinutes: Int {
        max(0, Int(round(Double(durationSeconds) / 60.0)))
    }

    public var effectiveProject: Project? {
        project
    }
}

