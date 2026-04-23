import SwiftUI

enum CategoryType: String, CaseIterable, Identifiable, Codable, Hashable {
    case all
    case build
    case focus
    case health
    case growth
    case admin
    case creative

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .build: return "Build"
        case .focus: return "Focus"
        case .health: return "Health"
        case .growth: return "Growth"
        case .admin: return "Admin"
        case .creative: return "Creative"
        }
    }

    var symbol: String {
        switch self {
        case .all: return "sparkles"
        case .build: return "hammer.fill"
        case .focus: return "scope"
        case .health: return "heart.fill"
        case .growth: return "arrow.triangle.up.circle.fill"
        case .admin: return "tray.full.fill"
        case .creative: return "paintpalette.fill"
        }
    }

    var tint: Color {
        switch self {
        case .all: return TBColor.textMuted
        case .build: return TBColor.primaryAccent
        case .focus: return TBColor.secondaryAccent
        case .health: return TBColor.gold
        case .growth: return Color(red: 0.38, green: 0.82, blue: 0.57)
        case .admin: return Color(red: 0.54, green: 0.63, blue: 0.92)
        case .creative: return Color(red: 0.92, green: 0.47, blue: 0.82)
        }
    }
}

