import Foundation

struct Habit: Codable, Hashable, Identifiable, Sendable {
    var id: UUID
    var title: String
    var category: String
    var targetMinutes: Int
    var colorName: String
}
