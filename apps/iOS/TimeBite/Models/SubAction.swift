import Foundation

struct SubAction: Identifiable, Hashable {
    let id: UUID
    var title: String
    var isDone: Bool
    var estimatedMinutes: Int

    init(id: UUID = UUID(), title: String, isDone: Bool, estimatedMinutes: Int) {
        self.id = id
        self.title = title
        self.isDone = isDone
        self.estimatedMinutes = estimatedMinutes
    }
}

