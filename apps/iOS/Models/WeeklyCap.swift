import Foundation
import SwiftData

/// Optional cap history model (useful once you support week-over-week comparisons and "recovered time").
@Model
public final class WeeklyCap {
    @Attribute(.unique)
    public var id: UUID

    /// Week interval attribution uses locale-based `weekOfYear`. Store the week start for stable grouping.
    public var weekStart: Date
    public var capMinutes: Int

    @Relationship(deleteRule: .nullify, inverse: \Project.capHistory)
    public var project: Project?

    public init(
        id: UUID = UUID(),
        weekStart: Date,
        capMinutes: Int,
        project: Project? = nil
    ) {
        self.id = id
        self.weekStart = weekStart
        self.capMinutes = capMinutes
        self.project = project
    }
}

