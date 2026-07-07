import SwiftUI

struct SettingsView: View {
    private let comingSoonFeatures = [
        ComingSoonFeature(title: "Vision Board", detail: "Visual planning for future goals."),
        ComingSoonFeature(title: "Studio", detail: "Creative capture and guided work sessions."),
        ComingSoonFeature(title: "Library", detail: "Saved frameworks, plans, and reusable templates."),
        ComingSoonFeature(title: "Quotes", detail: "Motivation tied to active goals and habits.")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                header
                comingSoonSection
                privacySection
                permissionsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 78)
            .padding(.bottom, 118)
        }
        .background(TBColor.background.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Settings")
                .font(TBTypography.title(.largeTitle, weight: .bold))
                .foregroundStyle(TBColor.textPrimary)

            Text("Submission build keeps future modules visible as roadmap items, not active navigation.")
                .font(TBTypography.body())
                .foregroundStyle(TBColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var comingSoonSection: some View {
        settingsCard(title: "Coming Soon", subtitle: "These features are intentionally gated for the MVP.") {
            VStack(spacing: 10) {
                ForEach(comingSoonFeatures) { feature in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(TBColor.primaryAccent)
                            .frame(width: 22, height: 22)
                            .background(Circle().fill(TBColor.primaryAccent.opacity(0.12)))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(feature.title)
                                .font(TBTypography.body(.semibold))
                                .foregroundStyle(TBColor.textPrimary)

                            Text(feature.detail)
                                .font(TBTypography.caption())
                                .foregroundStyle(TBColor.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 8)

                        Text("Soon")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(TBColor.primaryAccent)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 8)
                            .background(Capsule(style: .continuous).fill(TBColor.primaryAccent.opacity(0.12)))
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }

    private var privacySection: some View {
        settingsCard(title: "AI & Data", subtitle: "No external AI model calls are active in this MVP navigation.") {
            VStack(alignment: .leading, spacing: 10) {
                labeledRow(icon: "lock.shield", title: "Local first", detail: "Goals, tasks, habits, and finance entries are stored on device unless a future sync feature is enabled.")
                labeledRow(icon: "network.slash", title: "Offline ready", detail: "When the quarterly goals service is unavailable, the chart shows an empty state instead of sample data.")
                labeledRow(icon: "text.bubble", title: "Future disclosure", detail: "Any future AI capture will explain what text is sent and ask for permission before use.")
            }
        }
    }

    private var permissionsSection: some View {
        settingsCard(title: "Permissions", subtitle: "TimeBite continues to work when optional permissions are denied.") {
            VStack(alignment: .leading, spacing: 10) {
                labeledRow(icon: "heart.text.square", title: "Health access", detail: "Used only to connect activity minutes with the Track view when granted.")
                labeledRow(icon: "mic", title: "Voice capture", detail: "Used only when dictating a task or reflection.")
                labeledRow(icon: "bell", title: "Notifications", detail: "Used for reminders you choose, such as finance and task follow-ups.")
            }
        }
    }

    private func settingsCard<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(TBTypography.title(.headline, weight: .semibold))
                    .foregroundStyle(TBColor.textPrimary)

                Text(subtitle)
                    .font(TBTypography.caption())
                    .foregroundStyle(TBColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(TBColor.surfaceElevated.opacity(0.78))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(TBColor.primaryAccent.opacity(0.16), lineWidth: 1)
                )
        )
    }

    private func labeledRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(TBColor.primaryAccent)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(TBTypography.body(.semibold))
                    .foregroundStyle(TBColor.textPrimary)

                Text(detail)
                    .font(TBTypography.caption())
                    .foregroundStyle(TBColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct ComingSoonFeature: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
}

private struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 16 Pro")
    }
}
