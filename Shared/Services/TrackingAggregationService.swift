import Foundation

struct TrackingAggregationService {
    func summarize(_ records: [TrackingRecord]) -> TrackingSummary {
        let planned = records.reduce(0) { $0 + $1.plannedMinutes }
        let completed = records.reduce(0) { $0 + $1.completedMinutes }
        let ratio = ActivityProgressCalculator.normalizedProgress(completed: completed, planned: planned)
        return TrackingSummary(plannedMinutes: planned, completedMinutes: completed, completionRatio: ratio)
    }
}
