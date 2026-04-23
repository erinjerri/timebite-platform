import SwiftUI

enum TBColor {
    static let background = Color(red: 0.039, green: 0.051, blue: 0.102)
    static let surface = Color(red: 0.067, green: 0.094, blue: 0.153)
    static let surfaceElevated = Color(red: 0.091, green: 0.122, blue: 0.192)

    static let primaryAccent = Color(red: 0.0, green: 0.898, blue: 0.769)
    static let secondaryAccent = Color(red: 0.659, green: 0.341, blue: 0.969)
    static let gold = Color(red: 0.957, green: 0.725, blue: 0.259)

    static let textPrimary = Color(red: 0.976, green: 0.980, blue: 0.984)
    static let textSecondary = Color(red: 0.420, green: 0.439, blue: 0.494)
    static let textMuted = Color(red: 0.561, green: 0.584, blue: 0.635)

    static let border = Color.white.opacity(0.08)
    static let borderStrong = Color.white.opacity(0.14)

    static let heroGradient = LinearGradient(
        colors: [
            Color(red: 0.054, green: 0.071, blue: 0.129),
            Color(red: 0.145, green: 0.101, blue: 0.286),
            Color(red: 0.039, green: 0.051, blue: 0.102),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [primaryAccent, secondaryAccent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let ringGradient = AngularGradient(
        colors: [
            primaryAccent,
            secondaryAccent,
            gold,
            primaryAccent
        ],
        center: .center
    )
}

