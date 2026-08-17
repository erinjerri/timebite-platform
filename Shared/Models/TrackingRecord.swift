import Foundation

struct TrackingRecord: Codable, Hashable, Identifiable, Sendable {
    var id: UUID
    var date: Date
    var plannedMinutes: Int
    var completedMinutes: Int
}
