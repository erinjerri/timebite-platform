import SwiftUI

enum TBTypography {
    static func title(_ size: Font.TextStyle = .title2, weight: Font.Weight = .semibold) -> Font {
        .system(size, design: .rounded).weight(weight)
    }

    static func body(_ weight: Font.Weight = .regular) -> Font {
        .system(.body, design: .rounded).weight(weight)
    }

    static func subheadline(_ weight: Font.Weight = .medium) -> Font {
        .system(.subheadline, design: .rounded).weight(weight)
    }

    static func caption(_ weight: Font.Weight = .medium) -> Font {
        .system(.caption, design: .rounded).weight(weight)
    }
}

