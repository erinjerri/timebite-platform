import Foundation

enum ActivityProgressCalculator {
    static func normalizedProgress(completed: Int, planned: Int) -> Double {
        guard planned > 0 else { return 0 }
        return min(max(Double(completed) / Double(planned), 0), 1)
    }
}
