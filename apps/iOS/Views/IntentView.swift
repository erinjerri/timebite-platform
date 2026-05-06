import SwiftData
import SwiftUI

struct IntentView: View {
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
        NavigationStack {
            Form {
                Section("Today") {
                    TextField("App focus", text: $appFocus)
                    Stepper("App target: \(appMinutes) min", value: $appMinutes, in: 5...240, step: 5)

                    TextField("Income focus", text: $incomeFocus)
                    Stepper("Income target: \(incomeMinutes) min", value: $incomeMinutes, in: 5...240, step: 5)

                    TextField("Brand focus optional", text: $brandFocus)
                    Stepper("Brand target: \(brandMinutes) min", value: $brandMinutes, in: 5...180, step: 5)
                }

                Section {
                    Button("Save Daily Plan") {
                        savePlan()
                    }
                    .disabled(appFocus.nilIfBlank == nil || incomeFocus.nilIfBlank == nil)
                }

                if let currentPlan = plans.first {
                    Section("Saved Intent") {
                        Text(currentPlan.appFocus)
                        Text(currentPlan.incomeFocus)
                        if let brandFocus = currentPlan.brandFocus {
                            Text(brandFocus)
                        }
                    }
                }
            }
            .navigationTitle("Intent")
            .onAppear(perform: hydrateFromSavedPlan)
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
