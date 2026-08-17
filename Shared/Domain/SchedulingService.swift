import Foundation

struct SchedulingService {
    func nextBlock(after date: Date, blocks: [ScheduledBlock]) -> ScheduledBlock? {
        blocks.sorted { $0.startDate < $1.startDate }.first { $0.startDate >= date }
    }
}
