import Foundation

struct PlanningHierarchy: Codable, Hashable, Sendable {
    var goalTitle: String
    var objectiveTitle: String?
    var currentPriority: String?
}
