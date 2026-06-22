import Foundation

enum TimeBiteLane: String, Codable, CaseIterable, Identifiable {
    case app
    case income
    case brand

    var id: String { rawValue }
}

struct SpatialRingSegment: Identifiable, Codable, Equatable {
    let id: String
    let lane: TimeBiteLane
    let percent: Double
    let opacity: Double
    let elevation: Double
    let glow: Double
    let annotation: String?

    init(
        id: String,
        lane: TimeBiteLane,
        percent: Double,
        opacity: Double,
        elevation: Double,
        glow: Double,
        annotation: String? = nil
    ) {
        self.id = id
        self.lane = lane
        self.percent = percent.clamped(to: 0...1)
        self.opacity = opacity.clamped(to: 0...1)
        self.elevation = elevation.clamped(to: 0...1)
        self.glow = glow.clamped(to: 0...1)
        self.annotation = annotation
    }
}

extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
