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

    // MARK: - Adaptive Finance presentation tokens

    static func financeModalBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? background : Color(red: 0.96, green: 0.97, blue: 0.98)
    }

    static func financeModalSurface(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? surface : Color.white
    }

    static func financeModalTextPrimary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? textPrimary : Color(red: 0.08, green: 0.10, blue: 0.14)
    }

    static func financeModalTextSecondary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.68, green: 0.70, blue: 0.74) : textSecondary
    }

    static func financeModalBorder(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? border : Color.black.opacity(0.06)
    }

    static func financeModalShadow(for colorScheme: ColorScheme) -> Color {
        Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1)
    }

    static let financeModalButtonText = Color(red: 0.02, green: 0.12, blue: 0.11)
    static let financeModalError = Color(red: 0.90, green: 0.25, blue: 0.28)

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
