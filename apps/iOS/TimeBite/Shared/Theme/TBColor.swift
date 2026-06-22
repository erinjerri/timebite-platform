import SwiftUI

enum TBColor {
    static let background = Color(red: 0.04, green: 0.05, blue: 0.10)
    static let surface = Color(red: 0.07, green: 0.10, blue: 0.16)
    static let surfaceElevated = Color(red: 0.10, green: 0.14, blue: 0.21)

    static let primaryAccent = Color(red: 0.00, green: 0.90, blue: 0.77)
    static let secondaryAccent = Color(red: 0.66, green: 0.34, blue: 0.97)
    static let gold = Color(red: 0.96, green: 0.73, blue: 0.26)

    static let textPrimary = Color(red: 0.98, green: 0.98, blue: 0.99)
    static let textSecondary = Color(red: 0.42, green: 0.44, blue: 0.49)

    static let border = Color.white.opacity(0.08)

    static let heroGradient = LinearGradient(
        colors: [
            Color(red: 0.05, green: 0.06, blue: 0.12),
            Color(red: 0.16, green: 0.09, blue: 0.30),
            Color(red: 0.04, green: 0.05, blue: 0.10)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [primaryAccent, secondaryAccent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

