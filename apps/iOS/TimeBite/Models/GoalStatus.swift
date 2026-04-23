import SwiftUI

enum GoalStatus: String, CaseIterable, Identifiable, Codable, Hashable {
    case active
    case onTrack
    case atRisk
    case completed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .active: return "Active"
        case .onTrack: return "On Track"
        case .atRisk: return "At Risk"
        case .completed: return "Done"
        }
    }

    var symbol: String {
        switch self {
        case .active: return "bolt.fill"
        case .onTrack: return "checkmark.seal.fill"
        case .atRisk: return "exclamationmark.triangle.fill"
        case .completed: return "checkmark.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .active: return TBColor.primaryAccent
        case .onTrack: return Color(red: 0.39, green: 0.77, blue: 0.98)
        case .atRisk: return TBColor.gold
        case .completed: return Color(red: 0.43, green: 0.91, blue: 0.63)
        }
    }
}

