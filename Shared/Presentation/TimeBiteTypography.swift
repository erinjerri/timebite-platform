import SwiftUI

/// Semantic type scale shared by every TimeBite platform target.
///
/// Uses the system rounded font family rather than a bundled custom face
/// (`timebite-macos` currently uses League Spartan). Registering and bundling a
/// custom OFL font correctly across four targets — including watchOS, which has
/// its own registration story — is real added scope that this vertical slice does
/// not need to prove the shared-token architecture. This is a deliberate, easily
/// revisited scoping decision, not an oversight.
enum TimeBiteTypography {
    static func font(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .rounded).weight(weight)
    }

    static func font(
        size: CGFloat,
        weight: Font.Weight = .regular,
        relativeTo style: Font.TextStyle = .body
    ) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}
