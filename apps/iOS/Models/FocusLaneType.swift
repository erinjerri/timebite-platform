import Foundation

enum FocusLaneType: String, CaseIterable, Codable, Identifiable {
    case app
    case income
    case brand

    var id: String { rawValue }

    var title: String {
        switch self {
        case .app:
            return "App"
        case .income:
            return "Income"
        case .brand:
            return "Brand"
        }
    }
}
