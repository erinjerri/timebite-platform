import SwiftData
import SwiftUI

struct ExecutionView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var timerManager: TimerManager
    @Query private var lanes: [FocusLane]
    @Query(sort: \CycleLog.startTime, order: .reverse) private var cycleLogs: [CycleLog]

    var body: some View {
        NavigationStack {
            List {
                Section("Active Session") {
                    if timerManager.isRunning {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(timerManager.activeTaskTitle ?? "Active focus")
                                .font(.headline)
                            Text("\(timerManager.elapsedMinutes) min elapsed")
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(.secondary)
                            Button("Stop Timer") {
                                timerManager.stopSession(modelContext: modelContext)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 4)
                    } else {
                        Text("No active session")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Tasks") {
                    ForEach(sortedLanes) { lane in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    LaneBadge(laneType: lane.type)
                                    Text(lane.title)
                                }
                                Text("\(lane.targetMinutes) min target")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Start") {
                                timerManager.startSession(laneType: lane.type, taskTitle: lane.title)
                            }
                            .disabled(timerManager.isRunning)
                        }
                    }
                }

                Section("Recent Cycles") {
                    ForEach(cycleLogs.prefix(6)) { log in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(log.taskTitle)
                                Text(log.startTime, style: .time)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(log.durationMinutes)m")
                                .font(.subheadline.monospacedDigit())
                        }
                    }
                }
            }
            .navigationTitle("Execution")
        }
    }

    private var sortedLanes: [FocusLane] {
        lanes.sorted { $0.type.rawValue < $1.type.rawValue }
    }
}
