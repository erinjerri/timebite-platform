import Combine
import Foundation
import SwiftData

@MainActor
final class TimerManager: ObservableObject {
    @Published private(set) var activeLaneType: FocusLaneType?
    @Published private(set) var activeTaskTitle: String?
    @Published private(set) var sessionStartTime: Date?
    @Published private(set) var elapsedSeconds: TimeInterval = 0

    private var ticker: Timer?
    private let defaults: UserDefaults

    var isRunning: Bool {
        sessionStartTime != nil
    }

    var elapsedMinutes: Int {
        max(0, Int(ceil(elapsedSeconds / 60)))
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        restoreActiveSession()
        startTickerIfNeeded()
    }

    func startSession(laneType: FocusLaneType, taskTitle: String) {
        activeLaneType = laneType
        activeTaskTitle = taskTitle
        sessionStartTime = Date()
        elapsedSeconds = 0
        persistActiveSession()
        startTickerIfNeeded()
    }

    @discardableResult
    func stopSession(modelContext: ModelContext, completed: Bool = true) -> CycleLog? {
        guard
            let laneType = activeLaneType,
            let taskTitle = activeTaskTitle,
            let startTime = sessionStartTime
        else {
            clearActiveSession()
            return nil
        }

        let endTime = Date()
        let durationMinutes = max(1, Int(ceil(endTime.timeIntervalSince(startTime) / 60)))
        let log = CycleLog(
            laneType: laneType,
            taskTitle: taskTitle,
            startTime: startTime,
            endTime: endTime,
            durationMinutes: durationMinutes,
            completed: completed
        )
        modelContext.insert(log)

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save cycle log: \(error)")
        }

        clearActiveSession()
        return log
    }

    func progress(for targetMinutes: Int) -> Double {
        guard targetMinutes > 0 else { return 0 }
        return min(1, elapsedSeconds / Double(targetMinutes * 60))
    }

    private func restoreActiveSession() {
        guard
            let laneRawValue = defaults.string(forKey: Keys.laneType),
            let laneType = FocusLaneType(rawValue: laneRawValue),
            let taskTitle = defaults.string(forKey: Keys.taskTitle)
        else {
            return
        }

        let startTime = defaults.object(forKey: Keys.startTime) as? Date
        activeLaneType = laneType
        activeTaskTitle = taskTitle
        sessionStartTime = startTime
        updateElapsed()
    }

    private func startTickerIfNeeded() {
        guard isRunning, ticker == nil else { return }

        ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateElapsed()
            }
        }
    }

    private func updateElapsed() {
        guard let sessionStartTime else {
            elapsedSeconds = 0
            ticker?.invalidate()
            ticker = nil
            return
        }

        elapsedSeconds = max(0, Date().timeIntervalSince(sessionStartTime))
    }

    private func persistActiveSession() {
        defaults.set(activeLaneType?.rawValue, forKey: Keys.laneType)
        defaults.set(activeTaskTitle, forKey: Keys.taskTitle)
        defaults.set(sessionStartTime, forKey: Keys.startTime)
    }

    private func clearActiveSession() {
        activeLaneType = nil
        activeTaskTitle = nil
        sessionStartTime = nil
        elapsedSeconds = 0
        ticker?.invalidate()
        ticker = nil
        defaults.removeObject(forKey: Keys.laneType)
        defaults.removeObject(forKey: Keys.taskTitle)
        defaults.removeObject(forKey: Keys.startTime)
    }
}

private enum Keys {
    static let laneType = "timebite.activeSession.laneType"
    static let taskTitle = "timebite.activeSession.taskTitle"
    static let startTime = "timebite.activeSession.startTime"
}
