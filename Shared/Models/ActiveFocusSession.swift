import Foundation

struct ActiveFocusSession: Codable, Hashable, Sendable {
    var id: UUID
    var title: String
    var startedAt: Date
    var plannedMinutes: Int
    var elapsedSeconds: Int
    var isRunning: Bool
}
