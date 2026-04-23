import SwiftUI

public struct TopTasksCard: View {
    @Binding var tasks: [CommandTask]

    public init(tasks: Binding<[CommandTask]>) {
        _tasks = tasks
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today Top 3")
                    .font(.headline)
                Spacer()
                Text("\(completedCount)/\(tasks.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 10) {
                ForEach(Array(tasks.indices.prefix(3)), id: \.self) { idx in
                    let task = $tasks[idx]
                    Button {
                        task.wrappedValue.isDone.toggle()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: task.wrappedValue.isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(task.wrappedValue.isDone ? Color.white : .secondary)

                            Text(task.wrappedValue.title)
                                .foregroundStyle(.primary)
                                .lineLimit(2)

                            Spacer(minLength: 0)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .commandCenterCard()
        .accessibilityElement(children: .contain)
    }

    private var completedCount: Int {
        tasks.filter(\.isDone).count
    }
}

struct TopTasksCard_Previews: PreviewProvider {
    static var previews: some View {
        Wrapper()
    }

    private struct Wrapper: View {
        @State var tasks: [CommandTask] = [
            .init(title: "Ship CommandCenterView", isDone: false),
            .init(title: "Implement lane drill‑in", isDone: true),
            .init(title: "Cut scope ruthlessly", isDone: false),
        ]

        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                TopTasksCard(tasks: $tasks)
                    .padding()
            }
            .preferredColorScheme(.dark)
        }
    }
}
