import Foundation
import SwiftData

@Model
final class Reflection: Identifiable, Codable {
    @Attribute(.unique) var id: UUID
    var date: Date
    var appResult: ReflectionStatus
    var incomeResult: ReflectionStatus
    var brandResult: ReflectionStatus?
    var note: String

    init(
        id: UUID = UUID(),
        date: Date = Calendar.current.startOfDay(for: Date()),
        appResult: ReflectionStatus,
        incomeResult: ReflectionStatus,
        brandResult: ReflectionStatus? = nil,
        note: String = ""
    ) {
        self.id = id
        self.date = date
        self.appResult = appResult
        self.incomeResult = incomeResult
        self.brandResult = brandResult
        self.note = note
    }

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case appResult
        case incomeResult
        case brandResult
        case note
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        appResult = try container.decode(ReflectionStatus.self, forKey: .appResult)
        incomeResult = try container.decode(ReflectionStatus.self, forKey: .incomeResult)
        brandResult = try container.decodeIfPresent(ReflectionStatus.self, forKey: .brandResult)
        note = try container.decode(String.self, forKey: .note)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(appResult, forKey: .appResult)
        try container.encode(incomeResult, forKey: .incomeResult)
        try container.encodeIfPresent(brandResult, forKey: .brandResult)
        try container.encode(note, forKey: .note)
    }
}
