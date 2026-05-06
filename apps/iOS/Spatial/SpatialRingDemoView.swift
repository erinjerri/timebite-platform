import SwiftData
import SwiftUI

struct SpatialRingDemoView: View {
    @EnvironmentObject private var timerManager: TimerManager
    @Query(sort: \CycleLog.startTime, order: .reverse) private var cycleLogs: [CycleLog]
    @State private var fallbackProgress = 0.35

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                TorusRingSceneView(progress: progress)
                    .frame(minHeight: 400)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Ring progress")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }

                    Slider(value: $fallbackProgress, in: 0...1)
                        .disabled(timerManager.isRunning)

                    if timerManager.isRunning {
                        Text("Bound to active timer")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Slider fallback")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
            .background(Color.black.ignoresSafeArea())
            .foregroundStyle(.white)
            .navigationTitle("Spatial Ring")
        }
    }

    private var progress: Double {
        if timerManager.isRunning {
            return timerManager.progress(for: 45)
        }

        let logged = cycleLogs.reduce(0) { $0 + $1.durationMinutes }
        if logged > 0 {
            return min(1, Double(logged) / 120)
        }

        return fallbackProgress
    }
}
