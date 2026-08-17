import Foundation

struct DailyActivitySummary: Codable, Hashable, Sendable {
    var date: Date
    var nowProgress: ActivityRingProgress
    var amProgress: ActivityRingProgress
    var pmProgress: ActivityRingProgress
    var totalProgress: ActivityRingProgress
    var nextActionTitle: String?
    var reflectionPrompt: String?
}
