import Foundation
import SwiftData

public enum ProjectState: String, Codable, CaseIterable, Sendable {
    case active
    case paused
    case deferred
    case blocked
    case archived
}

public enum ProjectType: String, Codable, CaseIterable, Sendable {
    case app
    case income
    case brand
    case support
    case personal
    case other
}

@Model
public final class Project {
    @Attribute(.unique)
    public var id: UUID

    public var name: String
    public var type: ProjectType
    public var state: ProjectState

    /// The current planned budget for the project, per week.
    public var weeklyCapMinutes: Int?

    /// A measurable outcome statement (optional).
    public var outcome: String?

    public var createdAt: Date
    public var updatedAt: Date

    @Relationship(deleteRule: .nullify, inverse: \SessionLog.project)
    public var sessions: [SessionLog]

    @Relationship(deleteRule: .cascade, inverse: \WeeklyCap.project)
    public var capHistory: [WeeklyCap]

    public init(
        id: UUID = UUID(),
        name: String,
        type: ProjectType,
        state: ProjectState = .active,
        weeklyCapMinutes: Int? = nil,
        outcome: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.state = state
        self.weeklyCapMinutes = weeklyCapMinutes
        self.outcome = outcome
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sessions = []
        self.capHistory = []
    }
}

