import Foundation

struct SpatialDashboardLayout: Identifiable, Codable, Equatable {
    let id: String
    let sourcePlanID: String
    let generatedAt: Date
    let layoutMode: SpatialDashboardLayoutMode
    let ringSegments: [SpatialRingSegment]
    let laneSummaries: [SpatialLaneSummary]
    let annotations: [SpatialDashboardAnnotation]

    var totalRingPercent: Double {
        ringSegments.reduce(0) { $0 + $1.percent }.clamped(to: 0...1)
    }
}

enum SpatialDashboardLayoutMode: String, Codable, Equatable {
    case threeLaneRing
}

struct SpatialLaneSummary: Identifiable, Codable, Equatable {
    let lane: TimeBiteLane
    let plannedTaskCount: Int
    let completedTaskCount: Int
    let loggedMinutes: Int
    let reflectionCount: Int
    let emphasis: SpatialLaneEmphasis

    var id: TimeBiteLane { lane }
}

enum SpatialLaneEmphasis: String, Codable, Equatable {
    case quiet
    case active
    case highlighted
}

struct SpatialDashboardAnnotation: Identifiable, Codable, Equatable {
    let id: String
    let lane: TimeBiteLane?
    let text: String
    let priority: Int
}
