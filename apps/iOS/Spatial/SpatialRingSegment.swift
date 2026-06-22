import Foundation

struct SpatialRingSegment: Identifiable, Codable, Equatable {
    var id: FocusLaneType { laneType }
    let laneType: FocusLaneType
    let percentComplete: Double
    let opacity: Double
    let glow: Double
    let elevation: Double
    let remainingMinutes: Int
}
