import Foundation

struct DailyReflectionSummary: Codable, Hashable, Sendable {
    var date: Date
    var prompt: String
    var answer: String?
    var isComplete: Bool
}
