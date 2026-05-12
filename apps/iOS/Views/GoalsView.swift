import SwiftData
import SwiftUI

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyPlan.createdAt, order: .reverse) private var plans: [DailyPlan]
    @Query private var lanes: [FocusLane]

    @State private var appFocus = ""
    @State private var incomeFocus = ""
    @State private var brandFocus = ""
    @State private var appMinutes = 45
    @State private var incomeMinutes = 45
    @State private var brandMinutes = 30

    var body: some View {
        TBScreen(title: "Goals", eyebrow: "Strategic Direction") {
            TBSectionHeader(title: "Priorities", subtitle: "Set the day before the system starts tracking it")

            TBCard(isProminent: true) {
                goalField("App focus", text: $appFocus, minutes: $appMinutes, range: 5...240)
                Divider().overlay(TBTheme.stroke)
                goalField("Income focus", text: $incomeFocus, minutes: $incomeMinutes, range: 5...240)
                Divider().overlay(TBTheme.stroke)
                goalField("Brand focus optional", text: $brandFocus, minutes: $brandMinutes, range: 5...180)

                Button("Save Goals") {
                    savePlan()
                }
                .buttonStyle(TBPrimaryButtonStyle())
                .disabled(appFocus.nilIfBlank == nil || incomeFocus.nilIfBlank == nil)
                .accessibilityLabel("Save daily goals")
            }

            if let currentPlan = plans.first {
                TBSectionHeader(title: "Saved Goals", subtitle: "The current behavioral plan")
                TBCard {
                    savedGoalRow("App", value: currentPlan.appFocus)
                    savedGoalRow("Income", value: currentPlan.incomeFocus)
                    if let brandFocus = currentPlan.brandFocus {
                        savedGoalRow("Brand", value: brandFocus)
                    }
                }
            }
        }
        .onAppear(perform: hydrateFromSavedPlan)
    }

    private func goalField(
        _ title: String,
        text: Binding<String>,
        minutes: Binding<Int>,
        range: ClosedRange<Int>
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField(title, text: text)
                .font(.headline.weight(.semibold))
                .foregroundStyle(TBTheme.primaryText)
                .textFieldStyle(.plain)
                .padding(14)
                .background(TBTheme.graphite.opacity(0.56), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            HStack {
                Text("\(minutes.wrappedValue) min target")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(TBTheme.secondaryText)
                Spacer()
                Stepper(title, value: minutes, in: range, step: 5)
                    .labelsHidden()
            }
        }
    }

    private func savedGoalRow(_ label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label.uppercased())
                .font(.caption.weight(.bold))
                .tracking(1.1)
                .foregroundStyle(TBTheme.secondaryText)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(TBTheme.primaryText)
                .multilineTextAlignment(.trailing)
        }
    }

    private func hydrateFromSavedPlan() {
        guard let plan = plans.first, appFocus.isEmpty, incomeFocus.isEmpty else { return }
        appFocus = plan.appFocus
        incomeFocus = plan.incomeFocus
        brandFocus = plan.brandFocus ?? ""

        for lane in lanes {
            switch lane.type {
            case .app:
                appMinutes = lane.targetMinutes
            case .income:
                incomeMinutes = lane.targetMinutes
            case .brand:
                brandMinutes = lane.targetMinutes
            }
        }
    }

    private func savePlan() {
        let today = Calendar.current.startOfDay(for: Date())
        let plan = DailyPlan(
            date: today,
            appFocus: appFocus.trimmingCharacters(in: .whitespacesAndNewlines),
            incomeFocus: incomeFocus.trimmingCharacters(in: .whitespacesAndNewlines),
            brandFocus: brandFocus
        )

        clearExistingLanes()
        modelContext.insert(plan)
        modelContext.insert(FocusLane(type: .app, title: plan.appFocus, targetMinutes: appMinutes))
        modelContext.insert(FocusLane(type: .income, title: plan.incomeFocus, targetMinutes: incomeMinutes))

        if let brandFocus = plan.brandFocus {
            modelContext.insert(FocusLane(type: .brand, title: brandFocus, targetMinutes: brandMinutes))
        }

        try? modelContext.save()
    }

    private func clearExistingLanes() {
        for lane in lanes {
            modelContext.delete(lane)
        }
    }
}
