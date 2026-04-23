import Foundation

@MainActor
final class TimerService: ObservableObject {
    @Published var elapsedSeconds: Int = 0
    @Published var totalSeconds: Int = 45 * 60
    @Published var isRunning: Bool = false

    private var timer: Timer?

    func configure(totalMinutes: Int, elapsedMinutes: Int) {
        totalSeconds = max(totalMinutes * 60, 1)
        elapsedSeconds = min(elapsedMinutes * 60, totalSeconds)
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                guard self.isRunning else { return }
                self.elapsedSeconds = min(self.elapsedSeconds + 1, self.totalSeconds)
                if self.elapsedSeconds >= self.totalSeconds {
                    self.pause()
                }
            }
        }
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        pause()
        elapsedSeconds = 0
    }

    func skip(minutes: Int) {
        elapsedSeconds = min(max(elapsedSeconds + minutes * 60, 0), totalSeconds)
    }

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return min(Double(elapsedSeconds) / Double(totalSeconds), 1)
    }
}

