import SwiftData
import SwiftUI

@main
struct TimeBiteApp: App {
    @StateObject private var timerManager = TimerManager()
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try TimeBiteModelContainer.make()
        } catch {
            fatalError("Failed to create TimeBite model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            TimeBiteRootView()
                .environmentObject(timerManager)
        }
        .modelContainer(modelContainer)
    }
}
