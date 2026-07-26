import SwiftData
import SwiftUI

struct GoalConsiderationsModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let goal: Goal
    var onDone: (() -> Void)?

    @State private var skippedFields: Set<Field> = []
    @State private var saveError: String?

    private enum Field: Hashable {
        case considerations
        case dependencies
        case successCriteria
        case nextAction
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    GoalFormStyle.intro(
                        headline: "Anything worth flagging before you start?",
                        subtext: "Answer what you know. Skip the rest — you can always come back."
                    )

                    considerationRow(
                        label: "Considerations",
                        placeholder: "What might make this harder than it looks?",
                        text: binding(\.considerations),
                        field: .considerations
                    )
                    considerationRow(
                        label: "Dependencies / Blockers / Resources",
                        placeholder: "What do you need, or what's in the way?",
                        text: binding(\.dependenciesResources),
                        field: .dependencies
                    )
                    considerationRow(
                        label: "Success Criteria",
                        placeholder: "How will you know this is done?",
                        text: binding(\.successCriteria),
                        field: .successCriteria
                    )
                    considerationRow(
                        label: "Next Action",
                        placeholder: "What's the very next step?",
                        text: binding(\.nextAction),
                        field: .nextAction
                    )

                    if let saveError {
                        Text(saveError)
                            .font(TBTypography.caption(.semibold))
                            .foregroundStyle(TBColor.financeModalError)
                    }

                    Button(action: finish) {
                        Text("Done")
                            .font(TBTypography.body(.semibold))
                            .foregroundStyle(TBColor.financeModalButtonText)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(TBColor.primaryAccent)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .background(GoalFormStyle.background)
            .navigationTitle("Goal Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: finish) {
                        Image(systemName: "xmark")
                            .foregroundStyle(TBColor.textSecondary)
                    }
                    .accessibilityLabel("Save and close")
                }
            }
        }
    }

    private func considerationRow(
        label: String,
        placeholder: String,
        text: Binding<String>,
        field: Field
    ) -> some View {
        let isSkipped = skippedFields.contains(field)
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(TBTypography.caption(.semibold))
                    .foregroundStyle(TBColor.textSecondary)
                Spacer()
                Button(isSkipped ? "Undo" : "Skip") {
                    if isSkipped {
                        skippedFields.remove(field)
                    } else {
                        text.wrappedValue = ""
                        skippedFields.insert(field)
                    }
                }
                .font(TBTypography.caption(.semibold))
                .foregroundStyle(isSkipped ? TBColor.primaryAccent : TBColor.textSecondary)
            }

            TextField(isSkipped ? "Skipped" : placeholder, text: text)
                .font(TBTypography.body(.semibold))
                .foregroundStyle(TBColor.textPrimary)
                .textInputAutocapitalization(.sentences)
                .padding(14)
                .background(GoalFormStyle.inputBackground)
                .disabled(isSkipped)
                .opacity(isSkipped ? 0.48 : 1)
        }
    }

    private func binding(_ keyPath: ReferenceWritableKeyPath<Goal, String>) -> Binding<String> {
        Binding(
            get: { goal[keyPath: keyPath] },
            set: {
                goal[keyPath: keyPath] = $0
                goal.updatedAt = .now
            }
        )
    }

    private func finish() {
        do {
            try modelContext.save()
            if let onDone {
                onDone()
            } else {
                dismiss()
            }
        } catch {
            saveError = "Unable to save these details. Please try again."
        }
    }
}
