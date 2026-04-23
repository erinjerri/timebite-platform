import SwiftUI

public struct CommandCenterView: View {
    @StateObject private var viewModel: CommandCenterViewModel

    public init(viewModel: CommandCenterViewModel = .mock()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    focusLanes

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Weekly Allocation")
                                .font(.headline)
                            Spacer()
                            Text(viewModel.weekRangeText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        WeeklyAllocationRing(segments: viewModel.weeklyAllocationSegments)

                        WeeklyAllocationLegend(segments: viewModel.weeklyAllocationSegments)
                    }
                    .commandCenterCard()

                    TopTasksCard(tasks: $viewModel.topTasks)

                    KillListCard(items: viewModel.killListItems)

                    ReflectionFooter(text: $viewModel.reflectionText)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
            .scrollIndicators(.hidden)
            .background(background)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Good Morning")
                .font(.largeTitle)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 6) {
                Text("Weekly Mission:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(viewModel.weeklyMission)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(2)
            }
            .padding(14)
            .commandCenterCard()
        }
    }

    private var focusLanes: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Focus Lanes")
                .font(.headline)

            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach($viewModel.focusLanes) { $lane in
                        NavigationLink {
                            FocusLaneTasksView(lane: $lane)
                        } label: {
                            FocusLaneCard(
                                title: lane.title,
                                iconSystemName: lane.iconSystemName,
                                targetToday: lane.targetToday,
                                progress: lane.progress,
                                accent: lane.accent
                            )
                            .frame(width: 240)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color.black,
                Color.black.opacity(0.86),
                Color(.systemBackground),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - MVVM (mock data first)

public final class CommandCenterViewModel: ObservableObject {
    @Published public var weeklyMission: String
    @Published public var focusLanes: [FocusLane]
    @Published public var weeklyAllocationSegments: [WeeklyAllocationRing.Segment]
    @Published public var topTasks: [CommandTask]
    @Published public var killListItems: [String]
    @Published public var reflectionText: String

    public init(
        weeklyMission: String,
        focusLanes: [FocusLane],
        weeklyAllocationSegments: [WeeklyAllocationRing.Segment],
        topTasks: [CommandTask],
        killListItems: [String],
        reflectionText: String
    ) {
        self.weeklyMission = weeklyMission
        self.focusLanes = focusLanes
        self.weeklyAllocationSegments = weeklyAllocationSegments
        self.topTasks = topTasks
        self.killListItems = killListItems
        self.reflectionText = reflectionText
    }

    public static func mock(calendar: Calendar = .current) -> CommandCenterViewModel {
        let segments: [WeeklyAllocationRing.Segment] = [
            .init(title: "Build", fraction: 0.60, color: .cyan),
            .init(title: "Income", fraction: 0.25, color: .green),
            .init(title: "Brand", fraction: 0.15, color: .purple),
        ]

        return CommandCenterViewModel(
            weeklyMission: "Ship Apple MVP by Apr 29",
            focusLanes: [
                FocusLane(
                    title: "Build",
                    iconSystemName: "hammer.fill",
                    targetToday: "Finish Today tab UI + navigation",
                    progress: 0.42,
                    accent: .cyan,
                    tasks: [
                        .init(title: "CommandCenterView layout", isDone: true),
                        .init(title: "Cards + ring components", isDone: false),
                        .init(title: "Tab integration stub", isDone: false),
                    ]
                ),
                FocusLane(
                    title: "Income",
                    iconSystemName: "dollarsign.circle.fill",
                    targetToday: "Send 3 outreach messages",
                    progress: 0.20,
                    accent: .green,
                    tasks: [
                        .init(title: "Follow up with 2 warm leads", isDone: false),
                        .init(title: "Draft pricing note", isDone: false),
                        .init(title: "Book one call", isDone: false),
                    ]
                ),
                FocusLane(
                    title: "Brand",
                    iconSystemName: "megaphone.fill",
                    targetToday: "Post build log + screenshot",
                    progress: 0.10,
                    accent: .purple,
                    tasks: [
                        .init(title: "Screenshot Today tab", isDone: false),
                        .init(title: "Write 5‑sentence update", isDone: false),
                        .init(title: "Schedule post", isDone: false),
                    ]
                ),
            ],
            weeklyAllocationSegments: segments,
            topTasks: [
                .init(title: "Ship CommandCenterView", isDone: false),
                .init(title: "Implement Focus Lane task drill‑in", isDone: false),
                .init(title: "Cut scope: remove anything not Today", isDone: false),
            ],
            killListItems: [
                "Redesign site",
                "Random new features",
                "Tool hopping",
            ],
            reflectionText: ""
        )
    }

    public var weekRangeText: String {
        // Lightweight label; avoids date formatting complexity while still feeling “real”.
        "This week"
    }
}

public struct FocusLane: Identifiable {
    public let id: UUID
    public var title: String
    public var iconSystemName: String
    public var targetToday: String
    public var progress: Double
    public var accent: Color
    public var tasks: [CommandTask]

    public init(
        id: UUID = UUID(),
        title: String,
        iconSystemName: String,
        targetToday: String,
        progress: Double,
        accent: Color,
        tasks: [CommandTask]
    ) {
        self.id = id
        self.title = title
        self.iconSystemName = iconSystemName
        self.targetToday = targetToday
        self.progress = progress
        self.accent = accent
        self.tasks = tasks
    }
}

public struct CommandTask: Identifiable, Equatable {
    public let id: UUID
    public var title: String
    public var isDone: Bool

    public init(id: UUID = UUID(), title: String, isDone: Bool) {
        self.id = id
        self.title = title
        self.isDone = isDone
    }
}

// MARK: - Drill-in

private struct FocusLaneTasksView: View {
    @Binding var lane: FocusLane

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text(lane.title)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Target today")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(lane.targetToday)
                        .font(.subheadline)
                }
                .padding(.vertical, 4)
            }

            Section("Tasks") {
                ForEach($lane.tasks) { $task in
                    Button {
                        task.isDone.toggle()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(task.isDone ? lane.accent : .secondary)
                            Text(task.title)
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("Tasks")
    }
}

private struct WeeklyAllocationLegend: View {
    let segments: [WeeklyAllocationRing.Segment]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(segments) { seg in
                HStack(spacing: 10) {
                    Circle()
                        .fill(seg.color)
                        .frame(width: 8, height: 8)

                    Text(seg.title)
                        .font(.subheadline)

                    Spacer()

                    Text(seg.fraction, format: .percent.precision(.fractionLength(0)))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct CommandCenterView_Previews: PreviewProvider {
    static var previews: some View {
        CommandCenterView(viewModel: .mock())
            .preferredColorScheme(.dark)
    }
}
