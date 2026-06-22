import Foundation

struct SpatialEnvironment: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let intent: SpatialIntent
    let mood: SpatialMood
    let style: SpatialStyle
    let energy: SpatialEnergy
    let density: SpatialDensity
    let brightness: SpatialBrightness
    let avatar: AvatarPreference
    let preferredSurfaces: [SurfacePreference]
}

struct AvatarPreference: Codable, Equatable {
    let enabled: Bool
    let style: String
    let behavior: String

    static let none = AvatarPreference(enabled: false, style: "none", behavior: "none")
}

extension SpatialEnvironment {
    static let timebiteLight = SpatialEnvironment(
        id: "timebite-light",
        name: "TimeBite Light",
        intent: .focus,
        mood: .calm,
        style: .minimal,
        energy: .low,
        density: .balanced,
        brightness: .light,
        avatar: .none,
        preferredSurfaces: [
            SurfacePreference(surface: .action, emphasis: .currentTimer, density: .minimal),
            SurfacePreference(surface: .track, emphasis: .cycleHistory, density: .minimal),
            SurfacePreference(surface: .goals, emphasis: .weeklyTargets, density: .balanced),
            SurfacePreference(surface: .dashboard, emphasis: .dataViz, density: .balanced)
        ]
    )

    static let timebiteDark = SpatialEnvironment(
        id: "timebite-dark",
        name: "TimeBite Dark",
        intent: .flow,
        mood: .ambient,
        style: .glass,
        energy: .medium,
        density: .balanced,
        brightness: .dim,
        avatar: .none,
        preferredSurfaces: [
            SurfacePreference(surface: .action, emphasis: .currentTimer, density: .balanced),
            SurfacePreference(surface: .track, emphasis: .cycleHistory, density: .balanced),
            SurfacePreference(surface: .goals, emphasis: .reflection, density: .balanced),
            SurfacePreference(surface: .dashboard, emphasis: .dataViz, density: .balanced)
        ]
    )

    static let timebiteBlueOperator = SpatialEnvironment(
        id: "timebite-blue-operator",
        name: "TimeBite Blue Operator",
        intent: .operator,
        mood: .analytical,
        style: .terminal,
        energy: .high,
        density: .dense,
        brightness: .dark,
        avatar: .none,
        preferredSurfaces: [
            SurfacePreference(surface: .action, emphasis: .currentTimer, density: .balanced),
            SurfacePreference(surface: .track, emphasis: .cycleHistory, density: .dense),
            SurfacePreference(surface: .goals, emphasis: .weeklyTargets, density: .balanced),
            SurfacePreference(surface: .dashboard, emphasis: .dataViz, density: .dense)
        ]
    )

    static let presets: [SpatialEnvironment] = [
        .timebiteLight,
        .timebiteDark,
        .timebiteBlueOperator
    ]

    func preference(for surface: SurfaceType) -> SurfacePreference {
        preferredSurfaces.first { $0.surface == surface }
            ?? SurfacePreference(surface: surface, emphasis: .reflection, density: density)
    }
}

