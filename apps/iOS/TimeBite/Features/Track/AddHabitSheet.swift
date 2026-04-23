import SwiftUI

struct AddHabitSheet: View {
    @Binding var habitName: String
    @Binding var selectedCategory: CategoryType
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Habit") {
                    TextField("Morning walk", text: $habitName)
                        .textInputAutocapitalization(.sentences)
                }

                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(CategoryType.allCases.filter { $0 != .all }, id: \.self) { category in
                            Label(category.title, systemImage: category.symbol)
                                .tag(category)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(TBColor.background)
            .navigationTitle("Add Habit")
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

