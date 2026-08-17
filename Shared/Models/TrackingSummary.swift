import Foundation

struct TrackingSummary: Codable, Hashable, Sendable {
    var plannedMinutes: Int
    var completedMinutes: Int
    var completionRatio: Double
}
