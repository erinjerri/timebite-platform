import Foundation

struct SpatialDashboardLayout: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let laneSummaries: [SpatialLaneSummary]
    let ringSegments: [SpatialRingSegment]
    let visualState: SpatialVisualState
}

struct SpatialLaneSummary: Identifiable, Codable, Equatable {
    var id: FocusLaneType { laneType }
    let laneType: FocusLaneType
    let title: String
    let targetMinutes: Int
    let loggedMinutes: Int
    let completedCycles: Int
    let reflectionStatus: ReflectionStatus?
}

struct SpatialVisualState: Codable, Equatable {
    let totalTargetMinutes: Int
    let totalLoggedMinutes: Int
    let overallPercentComplete: Double
    let hasReflection: Bool
}
