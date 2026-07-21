import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authentication: AuthenticationStore
    @State private var accounts: [RemoteFinancialAccount] = []
    @State private var errorMessage: String?
    @State private var showingDeleteConfirmation = false
    @State private var isDeleting = false
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
                membershipSection
                integrationsSection
                comingSoonSection
                privacySection
                permissionsSection
                accountSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 78)
            .padding(.bottom, 118)
        }
        .background(TBColor.background.ignoresSafeArea())
        .task { await loadAccounts() }
        .confirmationDialog(
            "Delete your TimeBite account?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Account", role: .destructive) { Task { await deleteAccount() } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This disconnects linked banks and permanently removes synchronized TimeBite data.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Profile")
                .font(TBTypography.title(.largeTitle, weight: .bold))
                .foregroundStyle(TBColor.textPrimary)

            Text("Erin Jerri · erin@example.com")
                .font(TBTypography.body())
                .foregroundStyle(TBColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var membershipSection: some View {
        settingsCard(title: "Account Type", subtitle: "Synced with SSO through Apple, Google, or email.") {
            VStack(alignment: .leading, spacing: 10) {
                labeledRow(icon: "person.crop.circle.badge.checkmark", title: "Beta - Free", detail: "Two-week paid trial path, then $9.99 monthly or $89.99 annual.")
                labeledRow(icon: "envelope.fill", title: "SSO email", detail: "erin@example.com")
                labeledRow(icon: "checkmark.seal.fill", title: "Sync status", detail: "Account sync ready for TimeBite cloud.")
            }
        }
    }

    private var integrationsSection: some View {
        settingsCard(title: "Integrations", subtitle: "Connect the services that feed goals and finance.") {
            VStack(alignment: .leading, spacing: 10) {
                labeledRow(icon: "building.columns.fill", title: "Plaid", detail: accounts.isEmpty ? "Not connected" : "\(accounts.count) linked accounts")
                labeledRow(icon: "calendar.badge.clock", title: "Planner sync", detail: "Future paper planner and calendar import lives under Chatbot capture.")
                labeledRow(icon: "square.and.arrow.down", title: "Exports", detail: "Goal and reflection export controls will live here.")
            }
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
        settingsCard(title: "AI & Data", subtitle: "No external AI model calls are active in this beta.") {
            VStack(alignment: .leading, spacing: 10) {
                labeledRow(icon: "lock.shield", title: "Private sync", detail: "MongoDB is the synchronized source of truth. SwiftData keeps an offline cache on this device.")
                labeledRow(icon: "network.slash", title: "Offline ready", detail: "Edits made offline are retried safely when your connection returns.")
                labeledRow(icon: "building.columns", title: "Financial data", detail: "Plaid handles bank credentials. TimeBite stores encrypted connection tokens only on its server and never displays them.")
                labeledRow(icon: "text.bubble", title: "Future disclosure", detail: "Any future AI capture will explain what text is sent and ask for permission before use.")
            }
        }
    }

    private var accountSection: some View {
        settingsCard(title: "Account", subtitle: "Control synchronized data and linked institutions.") {
            VStack(spacing: 10) {
                ForEach(Array(Set(accounts.map(\.plaidItemID))), id: \.self) { itemID in
                    Button(role: .destructive) {
                        Task { await disconnect(itemID: itemID) }
                    } label: {
                        Label("Disconnect linked bank", systemImage: "building.columns.fill")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Button { Task { await authentication.signOut() } } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(role: .destructive) { showingDeleteConfirmation = true } label: {
                    Label(isDeleting ? "Deleting…" : "Delete Account", systemImage: "trash")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .disabled(isDeleting)

                if let errorMessage {
                    Text(errorMessage).font(TBTypography.caption()).foregroundStyle(.red)
                }
            }
            .buttonStyle(.bordered)
        }
    }

    @MainActor
    private func loadAccounts() async {
        accounts = (try? await RemoteFinanceRepository(client: authentication.client).accounts()) ?? []
    }

    @MainActor
    private func disconnect(itemID: UUID) async {
        do {
            try await RemoteFinanceRepository(client: authentication.client).disconnect(itemID: itemID)
            await loadAccounts()
        } catch { errorMessage = error.localizedDescription }
    }

    @MainActor
    private func deleteAccount() async {
        isDeleting = true
        defer { isDeleting = false }
        do { try await authentication.deleteAccount() }
        catch { errorMessage = error.localizedDescription }
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

#if DEBUG
private struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthenticationStore())
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 16 Pro")
    }
}
#endif
