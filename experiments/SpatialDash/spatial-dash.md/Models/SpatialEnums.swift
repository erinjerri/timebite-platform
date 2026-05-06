import Foundation

enum SpatialIntent: String, Codable, CaseIterable, Identifiable {
    case focus
    case `operator`
    case flow

    var id: String { rawValue }
}

enum SpatialMood: String, Codable, CaseIterable, Identifiable {
    case calm
    case energetic
    case ambient
    case analytical

    var id: String { rawValue }
}

enum SpatialStyle: String, Codable, CaseIterable, Identifiable {
    case minimal
    case glass
    case terminal
    case softNeo
    case animeNeon

    var id: String { rawValue }
}

enum SpatialEnergy: String, Codable, CaseIterable, Identifiable {
    case low
    case medium
    case high

    var id: String { rawValue }
}

enum SpatialDensity: String, Codable, CaseIterable, Identifiable {
    case minimal
    case balanced
    case dense

    var id: String { rawValue }
}

enum SpatialBrightness: String, Codable, CaseIterable, Identifiable {
    case light
    case dark
    case dim

    var id: String { rawValue }
}

enum SurfaceType: String, Codable, CaseIterable, Identifiable {
    case action
    case track
    case goals
    case dashboard

    var id: String { rawValue }
}

enum SurfaceEmphasis: String, Codable {
    case currentTimer
    case cycleHistory
    case weeklyTargets
    case dataViz
    case reflection
}

struct SurfacePreference: Codable, Identifiable, Equatable {
    let surface: SurfaceType
    let emphasis: SurfaceEmphasis
    let density: SpatialDensity

    var id: SurfaceType { surface }
}

