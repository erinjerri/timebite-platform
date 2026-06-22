import Foundation
import SwiftData

@Model
final class AIWorkSummary {
    @Attribute(.unique) var id: UUID
    var totalSessions: Int
    var totalRuntime: TimeInterval
    var totalPrompts: Int
    var totalCost: Double
    var interventionRate: Double
    var completionRate: Double
    var humanHoursSavedEstimate: Double

    init(
        id: UUID = UUID(),
        totalSessions: Int = 0,
        totalRuntime: TimeInterval = 0,
        totalPrompts: Int = 0,
        totalCost: Double = 0,
        interventionRate: Double = 0,
        completionRate: Double = 0,
        humanHoursSavedEstimate: Double = 0
    ) {
        self.id = id
        self.totalSessions = totalSessions
        self.totalRuntime = totalRuntime
        self.totalPrompts = totalPrompts
        self.totalCost = totalCost
        self.interventionRate = interventionRate
        self.completionRate = completionRate
        self.humanHoursSavedEstimate = humanHoursSavedEstimate
    }
}
