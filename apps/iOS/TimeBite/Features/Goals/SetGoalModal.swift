import SwiftData
import SwiftUI

struct SetGoalModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var syncCoordinator: SyncCoordinator

    let goal: Goal?

    @State private var title = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var dueDate = Date()
    @State private var deadlineIncludesTime = false
    @State private var goalType = GoalType.shortTerm
    @State private var goalKind = GoalKind.work
    @State private var customGoalKind = ""
    @State private var lifeArea = "Work"
    @State private var customLifeArea = ""
    @AppStorage("timebite.customLifeAreas") private var customLifeAreasRaw = ""
    @State private var quarter = Date.currentQuarterIdentifier
    @State private var targetHours = 0
    @State private var considerations = ""
    @State private var blockers = ""
    @State private var resources = ""
    @State private var dependenciesResources = ""
    @State private var successCriteria = ""
    @State private var nextAction = ""
    @State private var milestones = ""
    @State private var showValidation = false
    @State private var saveError: String?

    private var isEditing: Bool {
        goal != nil
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    intro

                    goalField("Life Area") {
                        lifeAreaSelector
                    }

                    goalField("Goal Focus") {
                        goalKindSelector
                    }

                    goalField("Title", isRequired: true) {
                        styledTextField("Build an emergency fund", text: $title)
                    }

                    goalField("Description") {
                        styledEditor(text: $description, minHeight: 76)
                    }

                    goalField("Start Date") {
                        styledDatePicker(selection: $startDate, includesTime: false)
                    }

                    goalField("Deadline", isRequired: true) {
                        VStack(alignment: .leading, spacing: 10) {
                            Toggle("Include a time-of-day", isOn: $deadlineIncludesTime)
                                .font(TBTypography.body(.semibold))
                                .foregroundStyle(TBColor.textPrimary)
                                .tint(TBColor.primaryAccent)

                            styledDatePicker(selection: $dueDate, includesTime: deadlineIncludesTime)
                        }
                        .padding(12)
                        .background(inputBackground)
                    }

                    goalField("Time Horizon") {
                        Picker("Goal Type", selection: $goalType) {
                            ForEach(GoalType.allCases) { type in
                                Text(type.title).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    goalField("Next Action") {
                        styledEditor(text: $nextAction, minHeight: 74)
                    }

                    goalField("Monthly Tasks") {
                        VStack(alignment: .leading, spacing: 8) {
                            styledEditor(text: $milestones, minHeight: 104)

                            Text("Add one task per line. These will feed month and quarter views in Track.")
                                .font(TBTypography.caption())
                                .foregroundStyle(TBColor.textSecondary)
                        }
                    }

                    if showValidation && !isValid {
                        validationMessage("Title is required.")
                    }

                    if let saveError {
                        validationMessage(saveError)
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .background(background)
            .navigationTitle(isEditing ? "Edit Goal" : "Set Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(TBColor.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(TBColor.primaryAccent)
                }
            }
            .onAppear(perform: load)
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isEditing ? "Refine the commitment." : "Turn intent into a clear commitment.")
                .font(TBTypography.title(.title3, weight: .semibold))
                .foregroundStyle(TBColor.textPrimary)

            Text("Capture the shape of the goal now; cards and timelines can build from the same source later.")
                .font(TBTypography.caption())
                .foregroundStyle(TBColor.textSecondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(TBColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(TBColor.primaryAccent.opacity(0.18), lineWidth: 1)
                )
        )
    }

    private var background: some View {
        LinearGradient(
            colors: [
                TBColor.background,
                Color(red: 0.03, green: 0.11, blue: 0.14),
                TBColor.background
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private func goalField<Content: View>(
        _ label: String,
        isRequired: Bool = false,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(label)
                    .font(TBTypography.caption(.semibold))
                    .foregroundStyle(TBColor.textSecondary)

                if isRequired {
                    Text("*")
                        .font(TBTypography.caption(.semibold))
                        .foregroundStyle(TBColor.primaryAccent)
                }
            }

            content()
        }
    }

    private func styledTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(TBTypography.body(.semibold))
            .foregroundStyle(TBColor.textPrimary)
            .textInputAutocapitalization(.sentences)
            .padding(14)
            .background(inputBackground)
    }

    private func styledEditor(text: Binding<String>, minHeight: CGFloat) -> some View {
        TextEditor(text: text)
            .font(TBTypography.body())
            .foregroundStyle(TBColor.textPrimary)
            .scrollContentBackground(.hidden)
            .frame(minHeight: minHeight)
            .padding(10)
            .background(inputBackground)
    }

    private func styledDatePicker(selection: Binding<Date>, includesTime: Bool) -> some View {
        DatePicker("", selection: selection, displayedComponents: includesTime ? [.date, .hourAndMinute] : [.date])
            .labelsHidden()
            .datePickerStyle(.compact)
            .tint(TBColor.primaryAccent)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(inputBackground)
    }

    private var lifeAreaSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 112), spacing: 8)], spacing: 8) {
                ForEach(lifeAreaOptions, id: \.self) { option in
                    Button {
                        lifeArea = option
                    } label: {
                        Text(option)
                            .font(TBTypography.caption(.semibold))
                            .foregroundStyle(lifeArea == option ? Color.black.opacity(0.86) : TBColor.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .background(lifeArea == option ? TBColor.primaryAccent : TBColor.surfaceElevated)
                            .overlay(Rectangle().stroke(lifeArea == option ? TBColor.primaryAccent : TBColor.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                TextField("Add another Life Area", text: $customLifeArea)
                    .font(TBTypography.caption(.semibold))
                    .textInputAutocapitalization(.words)
                Button("Add") { addCustomLifeArea() }
                    .font(TBTypography.caption(.semibold))
                    .disabled(customLifeArea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(10)
            .overlay(Rectangle().stroke(TBColor.border, lineWidth: 1))
        }
    }

    private var goalKindSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 126), spacing: 8)], spacing: 8) {
                ForEach(GoalKind.allCases) { kind in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                            goalKind = kind
                            if kind.isFinanceRelated {
                                lifeArea = "Finance"
                            }
                        }
                    } label: {
                        Label(kind.title, systemImage: kind.symbolName)
                            .font(TBTypography.caption(.semibold))
                            .foregroundStyle(goalKind == kind ? TBColor.financeModalButtonText : TBColor.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .frame(minHeight: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(goalKind == kind ? TBColor.primaryAccent : TBColor.surfaceElevated)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(goalKind == kind ? TBColor.primaryAccent : TBColor.border, lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(goalKind == kind ? .isSelected : [])
                }
            }

            if goalKind == .other {
                styledTextField("Describe this goal type", text: $customGoalKind)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            if goalKind.isFinanceRelated {
                Label("This helps TimeBite personalize Finance when you’re ready.", systemImage: "sparkles")
                    .font(TBTypography.caption())
                    .foregroundStyle(TBColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity)
            }
        }
    }

    private var lifeAreaOptions: [String] {
        let custom = customLifeAreasRaw
            .components(separatedBy: "|")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return Array(NSOrderedSet(array: LifeAreaCatalog.defaults + custom)) as? [String] ?? LifeAreaCatalog.defaults
    }

    private func addCustomLifeArea() {
        let clean = customLifeArea.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        let custom = lifeAreaOptions.filter { !LifeAreaCatalog.defaults.contains($0) } + [clean]
        customLifeAreasRaw = Array(NSOrderedSet(array: custom)).compactMap { $0 as? String }.joined(separator: "|")
        lifeArea = clean
        customLifeArea = ""
    }

    private var inputBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(TBColor.surfaceElevated.opacity(0.82))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(TBColor.border, lineWidth: 1)
            )
    }

    private func validationMessage(_ message: String) -> some View {
        Text(message)
            .font(TBTypography.caption(.semibold))
            .foregroundStyle(TBColor.gold)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(TBColor.gold.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(TBColor.gold.opacity(0.24), lineWidth: 1)
                    )
            )
    }

    private func load() {
        guard let goal else { return }

        title = goal.title
        description = goal.goalDescription
        startDate = goal.startDate
        dueDate = goal.dueDate
        deadlineIncludesTime = goal.deadlineIncludesTime
        goalType = GoalType(rawValue: goal.goalType) ?? .shortTerm
        goalKind = GoalKind(storedValue: goal.category)
        customGoalKind = goalKind == .other ? goal.category : ""
        lifeArea = goal.lifeArea
        quarter = goal.quarter
        targetHours = goal.targetMinutes / 60
        considerations = goal.considerations
        blockers = goal.blockers
        resources = goal.resources
        let legacyDependencies = [goal.blockers, goal.resources].filter { !$0.isEmpty }.joined(separator: "\n\n")
        dependenciesResources = goal.dependenciesResources.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? legacyDependencies
            : goal.dependenciesResources
        successCriteria = goal.successCriteria
        nextAction = goal.nextAction
        milestones = fetchMilestoneTitles(goalId: goal.id).joined(separator: "\n")
    }

    private func save() {
        showValidation = true
        saveError = nil

        guard isValid else { return }

        do {
            let baseUpdatedAt = goal?.updatedAt
            let savedGoal = try saveGoal()
            try replaceMilestones(for: savedGoal)
            try modelContext.save()
            try syncCoordinator.enqueueGoal(savedGoal, baseUpdatedAt: baseUpdatedAt)
            dismiss()
        } catch {
            saveError = "Unable to save this goal. Please try again."
        }
    }

    private func saveGoal() throws -> Goal {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        if let goal {
            goal.title = cleanTitle
            goal.goalDescription = description
            goal.startDate = startDate
            goal.dueDate = dueDate
            goal.deadlineIncludesTime = deadlineIncludesTime
            goal.goalType = goalType.title
            goal.category = storedGoalKind
            goal.lifeArea = lifeArea
            goal.quarter = normalizedQuarter
            goal.targetMinutes = targetHours * 60
            goal.considerations = considerations
            goal.blockers = blockers
            goal.resources = resources
            goal.dependenciesResources = dependenciesResources
            goal.successCriteria = successCriteria
            goal.nextAction = nextAction
            goal.updatedAt = .now
            return goal
        }

        let goal = Goal(
            title: cleanTitle,
            description: description,
            category: storedGoalKind,
            lifeArea: lifeArea,
            goalType: goalType.title,
            startDate: startDate,
            dueDate: dueDate,
            deadlineIncludesTime: deadlineIncludesTime,
            progress: 0,
            status: "Pending",
            considerations: considerations,
            blockers: blockers,
            resources: resources,
            dependenciesResources: dependenciesResources,
            successCriteria: successCriteria,
            nextAction: nextAction,
            quarter: normalizedQuarter,
            targetMinutes: targetHours * 60
        )
        modelContext.insert(goal)
        return goal
    }

    private var normalizedQuarter: String {
        let cleanQuarter = quarter.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        return cleanQuarter.isEmpty ? Date.currentQuarterIdentifier : cleanQuarter
    }

    private var storedGoalKind: String {
        guard goalKind == .other else { return goalKind.rawValue }
        let cleanCustomKind = customGoalKind.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleanCustomKind.isEmpty ? GoalKind.other.rawValue : cleanCustomKind
    }

    private func fetchMilestoneTitles(goalId: UUID) -> [String] {
        let descriptor = FetchDescriptor<Milestone>(
            predicate: #Predicate { milestone in
                milestone.goalId == goalId
            },
            sortBy: [SortDescriptor(\.dueDate, order: .forward)]
        )

        return (try? modelContext.fetch(descriptor).map(\.title)) ?? []
    }

    private func replaceMilestones(for goal: Goal) throws {
        let goalId = goal.id
        let descriptor = FetchDescriptor<Milestone>(
            predicate: #Predicate { milestone in
                milestone.goalId == goalId
            }
        )
        let existingMilestones = try modelContext.fetch(descriptor)
        existingMilestones.forEach(modelContext.delete)

        let titles = milestones
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        for (index, title) in titles.enumerated() {
            let dueDate = Calendar.current.date(byAdding: .day, value: index * 7, to: startDate) ?? startDate
            modelContext.insert(
                Milestone(
                    goalId: goalId,
                    title: title,
                    dueDate: min(dueDate, goal.dueDate),
                    status: "Pending"
                )
            )
        }
    }
}

private enum GoalType: String, CaseIterable, Identifiable {
    case shortTerm = "Short Term"
    case intermediate = "Intermediate"
    case longTerm = "Long Term"

    var id: String { rawValue }
    var title: String { rawValue }
}

enum LifeAreaCatalog {
    static let defaults = ["Faith", "Fitness/Health", "Finance", "Fun", "Family", "Friends", "Work"]

    static func color(for area: String) -> Color {
        switch normalized(area) {
        case "faith":
            return Color(red: 0.70, green: 0.53, blue: 0.98)
        case "fitness/health", "fitness", "health":
            return TBColor.gold
        case "finance":
            return Color(red: 0.34, green: 0.82, blue: 0.62)
        case "fun":
            return Color(red: 0.98, green: 0.52, blue: 0.38)
        case "family":
            return Color(red: 0.92, green: 0.47, blue: 0.82)
        case "friends":
            return Color(red: 0.39, green: 0.77, blue: 0.98)
        case "work", "build":
            return TBColor.primaryAccent
        case "reading":
            return Color(red: 0.50, green: 0.74, blue: 0.98)
        case "creative", "sketching":
            return Color(red: 0.98, green: 0.62, blue: 0.78)
        default:
            let index = area.unicodeScalars.reduce(0) { $0 + Int($1.value) } % WorkLabel.palette.count
            return WorkLabel.palette[index]
        }
    }

    static func icon(for area: String) -> String {
        switch normalized(area) {
        case "faith":
            return "sparkles"
        case "fitness/health", "fitness", "health":
            return "figure.strengthtraining.traditional"
        case "finance":
            return "dollarsign.circle.fill"
        case "fun":
            return "party.popper.fill"
        case "family":
            return "house.fill"
        case "friends":
            return "person.2.fill"
        case "work", "build":
            return "hammer.fill"
        case "reading":
            return "book.fill"
        case "creative", "sketching":
            return "pencil.and.outline"
        default:
            return "circle.grid.2x2.fill"
        }
    }

    static func normalized(_ area: String) -> String {
        area.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

#if DEBUG
struct SetGoalModal_Previews: PreviewProvider {
    static var previews: some View {
        SetGoalModal(goal: nil)
            .modelContainer(GoalPreviewData.modelContainer)
            .preferredColorScheme(.dark)
    }
}
#endif
