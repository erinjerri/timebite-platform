import Foundation
import SwiftData

@Model
final class GoalImpact {
    @Attribute(.unique) var id: UUID
    var goalId: UUID
    var goalProgressBefore: Double
    var goalProgressAfter: Double
    var timeSpent: TimeInterval
    var aiAssisted: Bool
    var impactScore: Double

    init(
        id: UUID = UUID(),
        goalId: UUID,
        goalProgressBefore: Double = 0,
        goalProgressAfter: Double = 0,
        timeSpent: TimeInterval = 0,
        aiAssisted: Bool = false,
        impactScore: Double = 0
    ) {
        self.id = id
        self.goalId = goalId
        self.goalProgressBefore = goalProgressBefore
        self.goalProgressAfter = goalProgressAfter
        self.timeSpent = timeSpent
        self.aiAssisted = aiAssisted
        self.impactScore = impactScore
    }
}
