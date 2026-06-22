import SwiftData

enum TimeBiteModelContainer {
    static let schema = Schema([
        DailyPlan.self,
        FocusLane.self,
        CycleLog.self,
        Reflection.self
    ])

    static func make() throws -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
