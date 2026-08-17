import Foundation

struct FocusSession: Codable, Hashable, Identifiable, Sendable {
    var id: UUID
    var title: String
    var startedAt: Date
    var endedAt: Date?
    var plannedMinutes: Int
    var completedMinutes: Int
    var note: String?
}
