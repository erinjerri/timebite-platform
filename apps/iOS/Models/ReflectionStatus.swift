import Foundation

enum ReflectionStatus: String, CaseIterable, Codable, Identifiable {
    case done
    case partial
    case missed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .done:
            return "Done"
        case .partial:
            return "Partial"
        case .missed:
            return "Missed"
        }
    }
}
