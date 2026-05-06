import SwiftUI

struct DesignTokens {
    let color: ColorTokens
    let typography: TypographyTokens
    let material: MaterialTokens
    let spacing: SpacingTokens
    let motion: MotionTokens
    let lighting: LightingTokens
    let dataViz: DataVizTokens
    let avatar: AvatarTokens
}

struct ColorTokens {
    let background: Color
    let surface: Color
    let primaryText: Color
    let secondaryText: Color
    let accent: Color
    let ringPrimary: Color
    let ringSecondary: Color
    let divider: Color
}

struct TypographyTokens {
    let title: Font
    let section: Font
    let body: Font
    let caption: Font
    let monospaced: Font
}

struct MaterialTokens {
    let surface: SpatialMaterial
    let blur: BlurLevel
    let opacity: Double
}

enum SpatialMaterial: String, Equatable {
    case matte
    case softGlass
    case sharpGlass
}

enum BlurLevel: String, Equatable {
    case low
    case medium
    case high
}

struct SpacingTokens {
    let compact: CGFloat
    let standard: CGFloat
    let spacious: CGFloat
}

struct MotionTokens {
    let duration: Double
    let curve: MotionCurve
    let intensity: MotionIntensity
}

enum MotionCurve: String, Equatable {
    case easeInOut
    case easeOut
    case spring
}

enum MotionIntensity: String, Equatable {
    case low
    case medium
    case safeHigh
}

struct LightingTokens {
    let mode: LightingMode
    let shadow: ShadowStyle
    let contrast: ContrastLevel
}

enum LightingMode: String, Equatable {
    case ambient
    case dimAmbient
    case coolGlow
}

enum ShadowStyle: String, Equatable {
    case soft
    case subtleGlow
    case crispGlow
}

enum ContrastLevel: String, Equatable {
    case low
    case medium
    case high
}

struct DataVizTokens {
    let palette: [Color]
    let lineWidth: CGFloat
    let cornerRadius: CGFloat
}

struct AvatarTokens {
    let enabled: Bool
    let style: String
    let behavior: String
}

extension Color {
    init(hex: String) {
        var normalized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        normalized.removeAll { $0 == "#" }

        var value: UInt64 = 0
        Scanner(string: normalized).scanHexInt64(&value)

        let red = Double((value >> 16) & 0xFF) / 255.0
        let green = Double((value >> 8) & 0xFF) / 255.0
        let blue = Double(value & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}
