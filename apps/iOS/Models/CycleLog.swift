import Foundation
import SwiftData

@Model
final class CycleLog: Identifiable, Codable {
    @Attribute(.unique) var id: UUID
    var laneType: FocusLaneType
    var taskTitle: String
    var startTime: Date
    var endTime: Date
    var durationMinutes: Int
    var completed: Bool

    init(
        id: UUID = UUID(),
        laneType: FocusLaneType,
        taskTitle: String,
        startTime: Date,
        endTime: Date,
        durationMinutes: Int,
        completed: Bool
    ) {
        self.id = id
        self.laneType = laneType
        self.taskTitle = taskTitle
        self.startTime = startTime
        self.endTime = endTime
        self.durationMinutes = max(0, durationMinutes)
        self.completed = completed
    }

    enum CodingKeys: String, CodingKey {
        case id
        case laneType
        case taskTitle
        case startTime
        case endTime
        case durationMinutes
        case completed
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        laneType = try container.decode(FocusLaneType.self, forKey: .laneType)
        taskTitle = try container.decode(String.self, forKey: .taskTitle)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decode(Date.self, forKey: .endTime)
        durationMinutes = try container.decode(Int.self, forKey: .durationMinutes)
        completed = try container.decode(Bool.self, forKey: .completed)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(laneType, forKey: .laneType)
        try container.encode(taskTitle, forKey: .taskTitle)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(durationMinutes, forKey: .durationMinutes)
        try container.encode(completed, forKey: .completed)
    }
}
