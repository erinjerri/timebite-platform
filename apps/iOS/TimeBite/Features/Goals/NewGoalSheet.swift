import SwiftUI

struct NewGoalSheet: View {
    @Binding var title: String
    @Binding var summary: String
    @Binding var category: CategoryType
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Goal") {
                    TextField("Launch portfolio MVP", text: $title)
                    TextField("Short summary", text: $summary, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach([CategoryType.build, .growth, .health, .creative, .admin], id: \.self) { item in
                            Text(item.title).tag(item)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(TBColor.background)
            .navigationTitle("New Goal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: onSave)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

