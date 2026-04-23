import Foundation
import SwiftData

public enum TimeBiteModelContainerFactory {
    public static func makeInMemory() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: ProjectBucket.self, TaskItem.self, SessionLog.self, configurations: config)
    }

    public static func makeOnDisk(url: URL? = nil) throws -> ModelContainer {
        let config = ModelConfiguration(url: url)
        return try ModelContainer(for: ProjectBucket.self, TaskItem.self, SessionLog.self, configurations: config)
    }
}

