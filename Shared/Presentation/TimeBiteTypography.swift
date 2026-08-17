import SwiftUI

enum TimeBiteTypography {
    static func font(_ textStyle: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        .system(textStyle, design: .rounded).weight(weight)
    }
}
