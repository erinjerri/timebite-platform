import Foundation

struct TimelineService {
    func blocks(in dateRange: ClosedRange<Date>, from blocks: [ScheduledBlock]) -> [ScheduledBlock] {
        blocks.filter { dateRange.contains($0.startDate) || dateRange.contains($0.endDate) }
    }
}
