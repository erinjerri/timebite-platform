import SwiftData
import SwiftUI

struct ReflectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Reflection.date, order: .reverse) private var reflections: [Reflection]
    @Query private var lanes: [FocusLane]

    @State private var appResult: ReflectionStatus = .partial
    @State private var incomeResult: ReflectionStatus = .partial
    @State private var brandResult: ReflectionStatus = .partial
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Results") {
                    Picker("App", selection: $appResult) {
                        ForEach(ReflectionStatus.allCases) { status in
                            Text(status.title).tag(status)
                        }
                    }

                    Picker("Income", selection: $incomeResult) {
                        ForEach(ReflectionStatus.allCases) { status in
                            Text(status.title).tag(status)
                        }
                    }

                    if hasBrandLane {
                        Picker("Brand", selection: $brandResult) {
                            ForEach(ReflectionStatus.allCases) { status in
                                Text(status.title).tag(status)
                            }
                        }
                    }
                }

                Section("Note") {
                    TextEditor(text: $note)
                        .frame(minHeight: 120)
                }

                Section {
                    Button("Save Reflection") {
                        saveReflection()
                    }
                }

                if let latest = reflections.first {
                    Section("Latest Reflection") {
                        Text(latest.note.isEmpty ? "No note" : latest.note)
                            .foregroundStyle(latest.note.isEmpty ? .secondary : .primary)
                    }
                }
            }
            .navigationTitle("Reflection")
            .onAppear(perform: hydrateLatest)
        }
    }

    private var hasBrandLane: Bool {
        lanes.contains { $0.type == .brand }
    }

    private func hydrateLatest() {
        guard let latest = reflections.first, note.isEmpty else { return }
        appResult = latest.appResult
        incomeResult = latest.incomeResult
        brandResult = latest.brandResult ?? .partial
        note = latest.note
    }

    private func saveReflection() {
        let reflection = Reflection(
            appResult: appResult,
            incomeResult: incomeResult,
            brandResult: hasBrandLane ? brandResult : nil,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        modelContext.insert(reflection)
        try? modelContext.save()
    }
}
