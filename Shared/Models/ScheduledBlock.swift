import Foundation

struct ScheduledBlock: Codable, Hashable, Identifiable, Sendable {
    var id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var category: String
}
