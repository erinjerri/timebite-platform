import SwiftUI
import SwiftData

public struct ProjectsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.name, order: .forward) private var projects: [Project]

    @State private var isPresentingCreate = false

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                if projects.isEmpty {
                    ContentUnavailableView(
                        "No projects yet",
                        systemImage: "folder",
                        description: Text("Create a project to set a weekly cap and track tradeoffs.")
                    )
                } else {
                    ForEach(projects) { project in
                        NavigationLink {
                            ProjectDetailView(project: project)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(project.name)
                                    Text(project.state.rawValue.capitalized)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if let cap = project.weeklyCapMinutes {
                                    Text("\(cap) min/wk")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                Button {
                    isPresentingCreate = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $isPresentingCreate) {
                CreateProjectSheet()
            }
        }
    }
}

private struct CreateProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name: String = ""
    @State private var type: ProjectType = .app
    @State private var state: ProjectState = .active
    @State private var capMinutesText: String = ""
    @State private var outcome: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Project") {
                    TextField("Name", text: $name)
                    Picker("Type", selection: $type) {
                        ForEach(ProjectType.allCases, id: \.self) { t in
                            Text(t.rawValue.capitalized).tag(t)
                        }
                    }
                    Picker("State", selection: $state) {
                        ForEach(ProjectState.allCases, id: \.self) { s in
                            Text(s.rawValue.capitalized).tag(s)
                        }
                    }
                }

                Section("Weekly Cap") {
                    TextField("Cap (minutes/week)", text: $capMinutesText)
                        .keyboardType(.numberPad)
                }

                Section("Outcome") {
                    TextField("Measurable outcome (optional)", text: $outcome)
                }
            }
            .navigationTitle("New Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let cap = Int(capMinutesText)
                        let project = Project(
                            name: name.isEmpty ? "Untitled" : name,
                            type: type,
                            state: state,
                            weeklyCapMinutes: cap,
                            outcome: outcome.isEmpty ? nil : outcome
                        )
                        modelContext.insert(project)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private struct ProjectDetailView: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var project: Project

    init(project: Project) {
        self.project = project
    }

    var body: some View {
        Form {
            Section("Basics") {
                TextField("Name", text: $project.name)
                Picker("Type", selection: $project.type) {
                    ForEach(ProjectType.allCases, id: \.self) { t in
                        Text(t.rawValue.capitalized).tag(t)
                    }
                }
                Picker("State", selection: $project.state) {
                    ForEach(ProjectState.allCases, id: \.self) { s in
                        Text(s.rawValue.capitalized).tag(s)
                    }
                }
            }

            Section("Weekly Cap") {
                Stepper(value: capBinding, in: 0...10_000, step: 15) {
                    Text(project.weeklyCapMinutes == nil ? "No cap" : "\(project.weeklyCapMinutes!) min/week")
                }
                Button("Clear cap") { project.weeklyCapMinutes = nil }
            }

            Section("Outcome") {
                TextField("Outcome (optional)", text: outcomeBinding)
            }
        }
        .navigationTitle(project.name)
    }

    private var capBinding: Binding<Int> {
        Binding(
            get: { project.weeklyCapMinutes ?? 0 },
            set: { newValue in project.weeklyCapMinutes = newValue }
        )
    }

    private var outcomeBinding: Binding<String> {
        Binding(
            get: { project.outcome ?? "" },
            set: { newValue in project.outcome = newValue.isEmpty ? nil : newValue }
        )
    }
}

