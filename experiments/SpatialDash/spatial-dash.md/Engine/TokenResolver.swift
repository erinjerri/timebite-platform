import SwiftUI

enum TokenResolver {
    static func resolve(_ environment: SpatialEnvironment) -> DesignTokens {
        switch environment.id {
        case SpatialEnvironment.timebiteDark.id:
            return timebiteDark(environment)
        case SpatialEnvironment.timebiteBlueOperator.id:
            return timebiteBlueOperator(environment)
        default:
            return timebiteLight(environment)
        }
    }

    private static func timebiteLight(_ environment: SpatialEnvironment) -> DesignTokens {
        DesignTokens(
            color: ColorTokens(
                background: Color(hex: "#F7F7F2"),
                surface: Color(hex: "#FFFFFF"),
                primaryText: Color(hex: "#111827"),
                secondaryText: Color(hex: "#6B7280"),
                accent: Color(hex: "#7C8F6A"),
                ringPrimary: Color(hex: "#9CAF88"),
                ringSecondary: Color(hex: "#D8E2C8"),
                divider: Color(hex: "#E5E7EB")
            ),
            typography: typography(for: environment),
            material: MaterialTokens(surface: .matte, blur: .low, opacity: 0.96),
            spacing: SpacingTokens(compact: 8, standard: 16, spacious: 24),
            motion: MotionTokens(duration: 0.32, curve: .easeInOut, intensity: .low),
            lighting: LightingTokens(mode: .ambient, shadow: .soft, contrast: .low),
            dataViz: DataVizTokens(
                palette: [Color(hex: "#9CAF88"), Color(hex: "#7C8F6A"), Color(hex: "#D8E2C8")],
                lineWidth: 8,
                cornerRadius: 18
            ),
            avatar: avatar(from: environment)
        )
    }

    private static func timebiteDark(_ environment: SpatialEnvironment) -> DesignTokens {
        DesignTokens(
            color: ColorTokens(
                background: Color(hex: "#0E1116"),
                surface: Color(hex: "#171B22"),
                primaryText: Color(hex: "#F9FAFB"),
                secondaryText: Color(hex: "#9CA3AF"),
                accent: Color(hex: "#A78BFA"),
                ringPrimary: Color(hex: "#8B5CF6"),
                ringSecondary: Color(hex: "#312E81"),
                divider: Color(hex: "#2A3040")
            ),
            typography: typography(for: environment),
            material: MaterialTokens(surface: .softGlass, blur: .medium, opacity: 0.82),
            spacing: SpacingTokens(compact: 10, standard: 18, spacious: 28),
            motion: MotionTokens(duration: 0.45, curve: .spring, intensity: .medium),
            lighting: LightingTokens(mode: .dimAmbient, shadow: .subtleGlow, contrast: .low),
            dataViz: DataVizTokens(
                palette: [Color(hex: "#8B5CF6"), Color(hex: "#A78BFA"), Color(hex: "#312E81")],
                lineWidth: 10,
                cornerRadius: 22
            ),
            avatar: avatar(from: environment)
        )
    }

    private static func timebiteBlueOperator(_ environment: SpatialEnvironment) -> DesignTokens {
        DesignTokens(
            color: ColorTokens(
                background: Color(hex: "#06111F"),
                surface: Color(hex: "#0B1E33"),
                primaryText: Color(hex: "#EAF4FF"),
                secondaryText: Color(hex: "#8FB3D9"),
                accent: Color(hex: "#38BDF8"),
                ringPrimary: Color(hex: "#0EA5E9"),
                ringSecondary: Color(hex: "#1E3A8A"),
                divider: Color(hex: "#16476D")
            ),
            typography: typography(for: environment),
            material: MaterialTokens(surface: .sharpGlass, blur: .medium, opacity: 0.88),
            spacing: SpacingTokens(compact: 6, standard: 12, spacious: 20),
            motion: MotionTokens(duration: 0.22, curve: .easeOut, intensity: .safeHigh),
            lighting: LightingTokens(mode: .coolGlow, shadow: .crispGlow, contrast: .high),
            dataViz: DataVizTokens(
                palette: [Color(hex: "#0EA5E9"), Color(hex: "#38BDF8"), Color(hex: "#1E3A8A")],
                lineWidth: 6,
                cornerRadius: 12
            ),
            avatar: avatar(from: environment)
        )
    }

    private static func typography(for environment: SpatialEnvironment) -> TypographyTokens {
        let titleWeight: Font.Weight = environment.intent == .operator ? .semibold : .medium
        let bodyDesign: Font.Design = environment.style == .terminal ? .monospaced : .default

        return TypographyTokens(
            title: .system(size: 34, weight: titleWeight, design: bodyDesign),
            section: .system(size: 19, weight: .semibold, design: bodyDesign),
            body: .system(size: 16, weight: .regular, design: bodyDesign),
            caption: .system(size: 12, weight: .medium, design: bodyDesign),
            monospaced: .system(size: 13, weight: .medium, design: .monospaced)
        )
    }

    private static func avatar(from environment: SpatialEnvironment) -> AvatarTokens {
        AvatarTokens(
            enabled: environment.avatar.enabled,
            style: environment.avatar.style,
            behavior: environment.avatar.behavior
        )
    }
}

