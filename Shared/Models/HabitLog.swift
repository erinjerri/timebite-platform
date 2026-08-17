import Foundation

struct HabitLog: Codable, Hashable, Identifiable, Sendable {
    var id: UUID
    var habitID: UUID
    var date: Date
    var completedMinutes: Int
    var notes: String?
}
