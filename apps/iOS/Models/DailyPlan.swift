import Foundation
import SwiftData

@Model
final class DailyPlan: Identifiable, Codable {
    @Attribute(.unique) var id: UUID
    var date: Date
    var appFocus: String
    var incomeFocus: String
    var brandFocus: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        date: Date = Calendar.current.startOfDay(for: Date()),
        appFocus: String,
        incomeFocus: String,
        brandFocus: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.appFocus = appFocus
        self.incomeFocus = incomeFocus
        self.brandFocus = brandFocus?.nilIfBlank
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case appFocus
        case incomeFocus
        case brandFocus
        case createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        appFocus = try container.decode(String.self, forKey: .appFocus)
        incomeFocus = try container.decode(String.self, forKey: .incomeFocus)
        brandFocus = try container.decodeIfPresent(String.self, forKey: .brandFocus)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(appFocus, forKey: .appFocus)
        try container.encode(incomeFocus, forKey: .incomeFocus)
        try container.encodeIfPresent(brandFocus, forKey: .brandFocus)
        try container.encode(createdAt, forKey: .createdAt)
    }
}
