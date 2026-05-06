import Foundation
import SwiftData

@Model
final class FocusLane: Identifiable, Codable {
    @Attribute(.unique) var id: UUID
    var type: FocusLaneType
    var title: String
    var targetMinutes: Int
    var allocatedMinutes: Int

    init(
        id: UUID = UUID(),
        type: FocusLaneType,
        title: String,
        targetMinutes: Int,
        allocatedMinutes: Int = 0
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.targetMinutes = max(0, targetMinutes)
        self.allocatedMinutes = max(0, allocatedMinutes)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case title
        case targetMinutes
        case allocatedMinutes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(FocusLaneType.self, forKey: .type)
        title = try container.decode(String.self, forKey: .title)
        targetMinutes = try container.decode(Int.self, forKey: .targetMinutes)
        allocatedMinutes = try container.decode(Int.self, forKey: .allocatedMinutes)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(title, forKey: .title)
        try container.encode(targetMinutes, forKey: .targetMinutes)
        try container.encode(allocatedMinutes, forKey: .allocatedMinutes)
    }
}
